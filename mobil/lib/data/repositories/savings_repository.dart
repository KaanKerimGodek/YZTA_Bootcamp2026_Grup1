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

  /// Kullanıcı hedef ayarlarını günceller.
  Future<AppUser> updateGoalSettings({
    String? goalTitle,
    double? savingsGoal,
    double? monthlyGoal,
    String? currency,
  });

  /// Hedefi tamamlayıp tamamlananlar listesine ekler ve yeni hedef için sıfırlar.
  /// Mevcut hedefi [completedGoals] listesine ekler, goalTitle/savingsGoal'ı null yapar.
  Future<AppUser> completeGoalAndReset();

  /// Hedefi tamamlar - lokal state'den gelen hedef verisiyle (optimistic update sonrası).
  /// [completedGoal] parametresi ile hedef bilgisi doğrudan verilir, backend'e tekrar fetch yapmaz.
  Future<AppUser> completeGoalWithData(CompletedGoal completedGoal);
}
