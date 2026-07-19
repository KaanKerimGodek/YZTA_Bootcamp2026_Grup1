import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/app_constants.dart';

/// Uygulama çalışma modu.
///
/// [mock] → backend gerektirmez, demo verisiyle çalışır.
/// [live]  → n8n webhook + Supabase ile konuşur.
enum AppMode { mock, live }

/// Tüm runtime yapılandırması tek yerden okunur.
class AppConfig {
  AppConfig._();

  /// `.env` → `APP_MODE` değerine göre modu döndürür.
  /// Tanımsız veya hatalıysa güvenli tarafta [AppMode.mock] döner.
  static AppMode get mode {
    final raw = dotenv.maybeGet('APP_MODE') ?? 'mock';
    return raw.toLowerCase() == 'live' ? AppMode.live : AppMode.mock;
  }

  static bool get isMock => mode == AppMode.mock;

  /// n8n webhook URL'i (Workflow 1).
  static String get n8nWebhookUrl =>
      dotenv.maybeGet('N8N_WEBHOOK_URL') ?? 'https://example.com/webhook/vazgec-ekle';

  /// Demo amaçlı sabit kullanıcı ID'si.
  static String get userId =>
      dotenv.maybeGet('USER_ID') ??
      '00000000-0000-0000-0000-000000000000';

  static String get supabaseUrl =>
      dotenv.maybeGet('SUPABASE_URL') ?? '';

  static String get supabaseAnonKey =>
      dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';
}

/// Yumuşak şekilde doğrulama fırlatan özel HTTP hatası.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.payload});
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? payload;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Dio tabanlı HTTP client.
///
/// Tüm istekler 15sn timeout ile ve JSON content-type ile gider.
/// Backend Steering "Zaman Damgaları" kuralı: her payload'a
/// frontend'in yerel `timestamp` alanı [N8nWebhookService] içinde eklenir.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                responseType: ResponseType.json,
              ),
            );

  final Dio _dio;

  /// GET isteği — JSON body'yi Map olarak döndürür.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      return res.data ?? {};
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  /// POST isteği — [body] JSON olarak gönderilir.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );
      return res.data ?? {};
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    Map<String, dynamic>? payload;
    String message = e.message ?? 'Bilinmeyen ağ hatası';
    if (data is Map<String, dynamic>) {
      payload = data;
      message = data['message'] as String? ?? data['error'] as String? ?? message;
    }
    return ApiException(message, statusCode: status, payload: payload);
  }
}

/// Backend Steering → Zaman Damgaları kuralı için yardımcı.
/// Frontend yerel timestamp'ini payload'a dahil eder.
Map<String, dynamic> withLocalTimestamp(Map<String, dynamic> payload) {
  return {
    ...payload,
    'client_timestamp': DateTime.now().toIso8601String(),
    'timezone': DateTime.now().timeZoneName,
  };
}

/// Backend Steering kategorilerini LLM prompt'una referans olarak eklemek için.
final String knownCategoriesPayload = AppConstants.knownCategories.join(', ');
