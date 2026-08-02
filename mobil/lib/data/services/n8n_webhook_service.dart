import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/skipped_item.dart';
import 'api_client.dart';

/// n8n Workflow 1 (Kayıt & Kategorizasyon) ile konuşan servis.
///
/// Akış (Backend Steering → Workflow 1):
/// 1. Frontend, JSON payload'u webhook'a POST eder.
/// 2. n8n validation yapar (fiyat > 0, isim boş değil).
/// 3. LLM kategorizasyonu → `ai_category`.
/// 4. Supabase insert → güncel `total_saved`.
/// 5. n8n `{ success, item_id, ai_category, total_saved }` döner.
///
/// Bu sınıf yalnızca HTTP往返 tarafını yönetir; doğrulama n8n'de yapılır.
/// n8n erişilemezse (timeout, CORS, vb.) lokal fallback ile çalışır.
class N8nWebhookService {
  N8nWebhookService({required this.client, required this.webhookUrl, Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final ApiClient client;
  final String webhookUrl;
  final Uuid _uuid;

  /// Mevcut giriş yapmış kullanıcının ID'sini Supabase Auth'tan alır.
  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  /// Basit keyword-based kategori tahmini (fallback için)
  String _mockCategorize(String name, String? raw) {
    if (raw != null && raw.trim().isNotEmpty) return raw.trim();
    final lower = name.toLowerCase();
    if (RegExp(r'kahve|latte|coffee|çay|tea|içecek|süt|ayran|cola').hasMatch(lower)) {
      return 'İçecek';
    }
    if (RegExp(r'burger|pizza|yemek|restaurant|lokanta|kebap|pide|çorba|getir|yemeksepeti').hasMatch(lower)) {
      return 'Yemek';
    }
    if (RegExp(r'ayakkabı|tişört|pantolon|mont|ceket|tshirt|elbise|giyim|trendyol').hasMatch(lower)) {
      return 'Giyim';
    }
    if (RegExp(r'sinema|tiyatro|konser|film|netflix|spotify|oyun|eğlence').hasMatch(lower)) {
      return 'Eğlence';
    }
    if (RegExp(r'uber|taksi|metro|otobüs|benzin|ulaşım|park').hasMatch(lower)) {
      return 'Ulaşım';
    }
    if (RegExp(r'iphone|laptop|kulaklık|telefon|teknoloji|apple|samsung|aksesuar').hasMatch(lower)) {
      return 'Teknoloji';
    }
    if (RegExp(r'berber|kuaför|spor|salon|cilt|krem|parfüm|bakım').hasMatch(lower)) {
      return 'Kişisel Bakım';
    }
    return 'Diğer';
  }

  /// Yeni bir vazgeçiş gönderir.
  ///
  /// user_id otomatik olarak Supabase Auth'tan alınır.
  /// n8n erişilemezse lokal fallback ile işler.
  Future<SubmitResult> submit({
    required String itemName,
    required double price,
    String? rawCategory,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('[N8nWebhookService] ERROR: User not authenticated');
      throw const ApiException(
        'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.',
        statusCode: 401,
      );
    }

    final payload = withLocalTimestamp({
      'user_id': userId,
      'item_name': itemName,
      'price': price,
      if (rawCategory != null && rawCategory.isNotEmpty) 'raw_category': rawCategory,
    });

    print('[N8nWebhookService] Submitting to n8n: $webhookUrl');
    print('[N8nWebhookService] Payload: $payload');

    try {
      final json = await client.post(webhookUrl, body: payload);

      print('[N8nWebhookService] Response: $json');

      // n8n yanıtı doğrulama hatasıysa (400) ApiException fırlatılmış olur.
      final success = json['success'] as bool? ?? json['basari'] as bool? ?? true;
      if (!success) {
        final errorMsg = (json['message'] as String?) ?? 'Vazgeçiş kaydedilemedi';
        print('[N8nWebhookService] n8n returned error: $errorMsg');
        throw ApiException(
          errorMsg,
          statusCode: 400,
          payload: json,
        );
      }

      return SubmitResult.fromJson(json);
    } on ApiException catch (e) {
      // n8n hatası (validation vb.) - fırlat
      if (e.statusCode == 400) {
        print('[N8nWebhookService] n8n validation error: ${e.message}');
        rethrow;
      }
      // Diğer hatalar (timeout, CORS, 5xx) -> lokal fallback
      print('[N8nWebhookService] n8n error (fallback to local): ${e.message}');
      return _submitLocalFallback(userId, itemName, price, rawCategory);
    } catch (e) {
      // Network/timeout/CORS -> lokal fallback
      print('[N8nWebhookService] Network error (fallback to local): $e');
      return _submitLocalFallback(userId, itemName, price, rawCategory);
    }
  }

  /// n8n erişilemezse lokal işler
  SubmitResult _submitLocalFallback(
    String userId,
    String itemName,
    double price,
    String? rawCategory,
  ) {
    print('[N8nWebhookService] Using LOCAL FALLBACK for: $itemName ($price)');
    final aiCategory = _mockCategorize(itemName, rawCategory);
    final item = SkippedItem(
      id: _uuid.v4(),
      userId: userId,
      name: itemName,
      price: price,
      rawCategory: rawCategory,
      aiCategory: aiCategory,
      createdAt: DateTime.now(),
    );
    // totalSaved burada SADECE bu item'ın fiyatı; kümülatif toplam DEĞİL.
    // isFallback: true işaretiyle RemoteSavingsRepository gerçek toplamı
    // Supabase'den çekip bu fiyatı üstüne ekleyerek düzeltir.
    return SubmitResult(
      itemId: item.id,
      aiCategory: aiCategory,
      totalSaved: price,
      item: item,
      isFallback: true,
    );
  }
}

/// n8n Workflow 1'in döndürdüğü başarılı yanıt.
class SubmitResult {
  const SubmitResult({
    required this.itemId,
    required this.aiCategory,
    required this.totalSaved,
    this.item,
    this.isFallback = false,
  });

  factory SubmitResult.fromJson(Map<String, dynamic> json) {
    final itemJson = (json['item'] as Map<String, dynamic>?) ?? {};
    return SubmitResult(
      itemId: json['item_id'] as String? ?? itemJson['item_id'] as String? ?? '',
      aiCategory: json['ai_category'] as String? ??
          itemJson['ai_category'] as String? ??
          AppConstants.fallbackCategory,
      totalSaved: (json['total_saved'] as num? ?? json['toplam_tasarruf'] as num? ?? 0).toDouble(),
      item: itemJson.isNotEmpty
          ? SkippedItem.fromJson(itemJson)
          : null,
      isFallback: false,
    );
  }

  final String itemId;
  final String aiCategory;
  final double totalSaved;
  final SkippedItem? item;

  /// n8n'e ulaşılamayıp (timeout/CORS/5xx) lokal fallback kullanıldıysa true.
  ///
  /// NOT: Fallback durumunda [totalSaved] SADECE bu ürünün fiyatıdır,
  /// kümülatif toplam DEĞİLDİR (çünkü lokal fallback gerçek toplamı bilmez).
  /// Çağıran taraf (`RemoteSavingsRepository`) bu flag true olduğunda
  /// [totalSaved]'i doğrudan güvenilir toplam olarak kullanmamalı.
  final bool isFallback;

  SubmitResult copyWith({double? totalSaved, SkippedItem? item}) => SubmitResult(
        itemId: itemId,
        aiCategory: aiCategory,
        totalSaved: totalSaved ?? this.totalSaved,
        item: item ?? this.item,
        isFallback: isFallback,
      );
}