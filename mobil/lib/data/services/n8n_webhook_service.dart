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
class N8nWebhookService {
  N8nWebhookService({required this.client, required this.webhookUrl});

  final ApiClient client;
  final String webhookUrl;

  /// Yeni bir vazgeçiş gönderir.
  ///
  /// [userId] Steering "Zaman Damgaları" kuralı gereği gönderilir.
  /// Dönen yanıt, n8n tarafından zenginleştirilmiş halidir.
  Future<SubmitResult> submit({
    required String userId,
    required String itemName,
    required double price,
    String? rawCategory,
  }) async {
    final payload = withLocalTimestamp({
      'user_id': userId,
      'item_name': itemName,
      'price': price,
      if (rawCategory != null && rawCategory.isNotEmpty) 'raw_category': rawCategory,
    });

    final json = await client.post(webhookUrl, body: payload);

    // n8n yanıtı doğrulama hatasıysa (400) ApiException fırlatılmış olur.
    final success = json['success'] as bool? ?? true;
    if (!success) {
      throw ApiException(
        (json['message'] as String?) ?? 'Vazgeçiş kaydedilemedi',
        statusCode: 400,
        payload: json,
      );
    }

    return SubmitResult.fromJson(json);
  }
}

/// n8n Workflow 1'in döndürdüğü başarılı yanıt.
class SubmitResult {
  const SubmitResult({
    required this.itemId,
    required this.aiCategory,
    required this.totalSaved,
    this.item,
  });

  factory SubmitResult.fromJson(Map<String, dynamic> json) {
    final itemJson = (json['item'] as Map<String, dynamic>?) ?? {};
    return SubmitResult(
      itemId: json['item_id'] as String? ?? itemJson['item_id'] as String? ?? '',
      aiCategory: json['ai_category'] as String? ??
          itemJson['ai_category'] as String? ??
          AppConstants.fallbackCategory,
      totalSaved: (json['total_saved'] as num? ?? 0).toDouble(),
      item: itemJson.isNotEmpty
          ? SkippedItem.fromJson(itemJson)
          : null,
    );
  }

  final String itemId;
  final String aiCategory;
  final double totalSaved;
  final SkippedItem? item;

  SubmitResult copyWith({double? totalSaved, SkippedItem? item}) => SubmitResult(
        itemId: itemId,
        aiCategory: aiCategory,
        totalSaved: totalSaved ?? this.totalSaved,
        item: item ?? this.item,
      );
}
