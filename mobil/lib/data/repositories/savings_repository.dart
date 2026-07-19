import '../models/ai_insight.dart';
import '../models/app_user.dart';
import '../models/skipped_item.dart';

/// Vazgeçiş/tasarruf verisine erişim soyutlaması.
///
/// İki somut uygulaması var:
/// - [MockSavingsRepository] — backend olmadan demo verisi.
/// - [RemoteSavingsRepository] — n8n webhook + Supabase üzerinden.
abstract class SavingsRepository {
  Future<AppUser> fetchUser();
  Future<List<SkippedItem>> fetchRecentItems({int limit = 20});
  Future<List<AiInsight>> fetchInsights();

  /// Yeni vazgeçiş ekler; güncellenmiş toplam tasarrufu döndürür.
  Future<({SkippedItem item, double totalSaved})> submit({
    required String itemName,
    required double price,
    String? rawCategory,
  });
}
