import '../models/ai_insight.dart';
import '../models/app_user.dart';
import '../models/skipped_item.dart';
import '../services/api_client.dart';
import '../services/n8n_webhook_service.dart';
import 'savings_repository.dart';

/// n8n + Supabase üzerinden konuşan repository.
///
/// [AppConfig.isMock] false iken kullanılır.
///
/// NOT: Bu sürümde `fetchUser`, `fetchRecentItems`, `fetchInsights`
/// doğrudan Supabase REST'e gider (Basit tutmak amacıyla; Supabase client
/// [ApiClient] üzerinden /rest/v1/ çağrısı yapar). Üretimde `supabase_flutter`
/// paketiyle değiştirilebilir.
class RemoteSavingsRepository implements SavingsRepository {
  RemoteSavingsRepository({
    required this.webhookService,
    required this.client,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.userId,
  });

  final N8nWebhookService webhookService;
  final ApiClient client;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String userId;

  Map<String, dynamic> get _restHeaders => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      };

  @override
  Future<AppUser> fetchUser() async {
    final json = await client.get(
      '$supabaseUrl/rest/v1/users?user_id=eq.$userId&select=*',
      query: _restHeaders,
    );
    final list = json['data'] as List? ?? [];
    if (list.isEmpty) {
      return AppUser(id: userId, createdAt: DateTime.now(), totalSaved: 0);
    }
    return AppUser.fromJson(list.first as Map<String, dynamic>);
  }

  @override
  Future<List<SkippedItem>> fetchRecentItems({int limit = 20}) async {
    final json = await client.get(
      '$supabaseUrl/rest/v1/skipped_items'
      '?user_id=eq.$userId&order=created_at.desc&limit=$limit&select=*',
      query: _restHeaders,
    );
    final list = json['data'] as List? ?? [];
    return list
        .cast<Map<String, dynamic>>()
        .map(SkippedItem.fromJson)
        .toList();
  }

  @override
  Future<List<AiInsight>> fetchInsights() async {
    final json = await client.get(
      '$supabaseUrl/rest/v1/ai_insights'
      '?user_id=eq.$userId&order=generated_at.desc&limit=10&select=*',
      query: _restHeaders,
    );
    final list = json['data'] as List? ?? [];
    return list.cast<Map<String, dynamic>>().map(AiInsight.fromJson).toList();
  }

  @override
  Future<({SkippedItem item, double totalSaved})> submit({
    required String itemName,
    required double price,
    String? rawCategory,
  }) async {
    final result = await webhookService.submit(
      userId: userId,
      itemName: itemName,
      price: price,
      rawCategory: rawCategory,
    );
    // n8n doğrulama/LLM'den dönen zenginleştirilmiş kaydı kullan.
    final item = result.item ??
        SkippedItem(
          id: result.itemId,
          userId: userId,
          name: itemName,
          price: price,
          rawCategory: rawCategory,
          aiCategory: result.aiCategory,
          createdAt: DateTime.now(),
        );
    return (item: item, totalSaved: result.totalSaved);
  }
}
