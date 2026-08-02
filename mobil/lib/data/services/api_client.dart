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
/// Tüm istekler 30sn timeout ile ve JSON content-type ile gider.
/// Backend Steering "Zaman Damgaları" kuralı: her payload'a
/// frontend'in yerel `timestamp` alanı [N8nWebhookService] içinde eklenir.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                responseType: ResponseType.json,
              ),
            );

  final Dio _dio;

  /// GET isteği — JSON body'yi olduğu gibi döndürür (Map veya List olabilir).
  ///
  /// NOT: PostgREST (Supabase REST) çoğu zaman doğrudan bir array döner
  /// (`[{...}, {...}]`), Map değil. Bu yüzden dönüş tipi kasıtlı olarak
  /// `dynamic` — çağıran taraf (`_parseList` gibi bir helper ile) hem List
  /// hem Map formatını handle etmeli. Burada `<Map<String, dynamic>>` generic'i
  /// kullanmak, Dio'nun array yanıtları decode ederken TypeError fırlatmasına
  /// ve bunun yanlışlıkla "CORS/ağ hatası" olarak yorumlanmasına yol açıyordu.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    try {
      print('[ApiClient] GET $path');
      if (query != null) print('[ApiClient] Query: $query');
      if (headers != null) print('[ApiClient] Headers: $headers');
      
      final res = await _dio.get<dynamic>(
        path,
        queryParameters: query,
        options: Options(headers: headers),
      );
      print('[ApiClient] GET $path → Status: ${res.statusCode}, Data: ${res.data}');
      return res.data;
    } on DioException catch (e) {
      print('[ApiClient] GET $path → ERROR: ${e.type}, Status: ${e.response?.statusCode}, Message: ${e.message}, Data: ${e.response?.data}');
      throw _toApiException(e);
    }
  }

  /// POST isteği — [body] JSON olarak gönderilir, yanıt olduğu gibi döner.
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      print('[ApiClient] POST $path');
      if (body != null) print('[ApiClient] Body: $body');
      
      final res = await _dio.post<dynamic>(
        path,
        data: body,
      );
      print('[ApiClient] POST $path → Status: ${res.statusCode}, Data: ${res.data}');
      return res.data;
    } on DioException catch (e) {
      print('[ApiClient] POST $path → ERROR: ${e.type}, Status: ${e.response?.statusCode}, Message: ${e.message}, Data: ${e.response?.data}');
      throw _toApiException(e);
    }
  }

  /// PATCH isteği — [body] JSON olarak gönderilir, yanıt olduğu gibi döner.
  ///
  /// NOT: `Prefer: return=representation` header'ı ile Supabase PATCH
  /// yanıtı olarak güncellenen satırların array'ini döner (Map değil).
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    try {
      print('[ApiClient] PATCH $path');
      if (body != null) print('[ApiClient] Body: $body');
      if (headers != null) print('[ApiClient] Headers: $headers');
      
      final res = await _dio.patch<dynamic>(
        path,
        data: body,
        options: Options(headers: headers),
      );
      print('[ApiClient] PATCH $path → Status: ${res.statusCode}, Data: ${res.data}');
      return res.data;
    } on DioException catch (e) {
      print('[ApiClient] PATCH $path → ERROR: ${e.type}, Status: ${e.response?.statusCode}, Message: ${e.message}, Data: ${e.response?.data}');
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    Map<String, dynamic>? payload;
    String message = e.message ?? 'Bilinmeyen ağ hatası';
    
    // CORS / network error handling for web
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
      message = 'Ağ hatası (CORS veya bağlantı sorunu): ${e.message ?? e.error.toString()}';
    }
    
    if (data is Map<String, dynamic>) {
      payload = data;
      message = data['message'] as String? ?? data['error'] as String? ?? message;
    } else if (data is List) {
      // Some APIs return error as array
      payload = {'errors': data};
      if (data.isNotEmpty && data.first is Map) {
        message = (data.first as Map)['message'] as String? ?? 
                  (data.first as Map)['error'] as String? ?? message;
      }
    }
    print('[ApiClient] ApiException: $message (statusCode: $status, payload: $payload)');
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