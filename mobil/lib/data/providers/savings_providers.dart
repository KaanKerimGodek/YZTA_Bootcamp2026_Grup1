import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_insight.dart';
import '../models/app_user.dart';
import '../models/skipped_item.dart';
import '../services/api_client.dart';
import '../repositories/savings_repository.dart';
import 'di.dart';

// ---------------------------------------------------------------------------
// Async view-model providers
// ---------------------------------------------------------------------------

/// Kullanıcı + Hero Card toplam tasarrufu.
final userProvider = StateNotifierProvider<UserNotifier, AppUser?>((ref) {
  return UserNotifier(ref.read(savingsRepositoryProvider));
});

class UserNotifier extends StateNotifier<AppUser?> {
  UserNotifier(this._repo) : super(null) {
    _loadUser();
  }

  final SavingsRepository _repo;

  Future<void> _loadUser() async {
    state = await _repo.fetchUser();
  }

  /// Yeni vazgeçiş sonrası toplamı cache üzerinden günceller.
  void applySaved(double addedAmount) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(totalSaved: current.totalSaved + addedAmount);
  }

  Future<void> refresh() async {
    state = await _repo.fetchUser();
  }

/// Hedef ayarlarını günceller.
  Future<void> updateGoalSettings({
    String? goalTitle,
    double? savingsGoal,
    double? monthlyGoal,
    String? currency,
  }) async {
    final updated = await _repo.updateGoalSettings(
      goalTitle: goalTitle,
      savingsGoal: savingsGoal,
      monthlyGoal: monthlyGoal,
      currency: currency,
    );
    state = updated;
  }

  /// Hedefi tamamlar, tamamlananlar listesine ekler ve yeni hedef için sıfırlar.
  /// Lokal state'deki hedef verisini kullanır (optimistic update sonrası doğru totalSaved için).
  Future<void> completeGoalAndReset() async {
    final current = state;
    if (current == null || !current.hasGoal) {
      throw ApiException('Tamamlanacak aktif hedef yok.', statusCode: 400);
    }

    // Lokal state'den tamamlanan hedefi oluştur (güncel totalSaved ile)
    final completedGoal = CompletedGoal(
      goalTitle: current.goalTitle!,
      targetAmount: current.savingsGoal!,
      completedAt: DateTime.now(),
      totalSavedAtCompletion: current.totalSaved,
      durationDays: current.createdAt.difference(DateTime.now()).inDays.abs(),
    );

    // Repository'ye hedef verisiyle birlikte çağır
    final updated = await _repo.completeGoalWithData(completedGoal);
    state = updated;
  }

  /// Hedef tamamlandı mı kontrol et.
  bool get isGoalCompleted => state?.isGoalCompleted ?? false;
}

/// Son vazgeçişler (Ana Sayfa aktivite listesi).
final recentItemsProvider =
    AsyncNotifierProvider<RecentItemsNotifier, List<SkippedItem>>(
        RecentItemsNotifier.new);

class RecentItemsNotifier extends AsyncNotifier<List<SkippedItem>> {
  @override
  Future<List<SkippedItem>> build() {
    return ref.read(savingsRepositoryProvider).fetchRecentItems();
  }

  void prepend(SkippedItem item) {
    final current = state.valueOrNull ?? const [];
    state = AsyncData([item, ...current]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsRepositoryProvider).fetchRecentItems(),
    );
  }
}

/// AI içgörüleri (Ana Sayfa carousel).
final insightsProvider =
    AsyncNotifierProvider<InsightsNotifier, List<AiInsight>>(
        InsightsNotifier.new);

class InsightsNotifier extends AsyncNotifier<List<AiInsight>> {
  @override
  Future<List<AiInsight>> build() {
    return ref.read(savingsRepositoryProvider).fetchInsights();
  }
}

// ---------------------------------------------------------------------------
// Submit action — use case tarzı, tek seferlik çağrı
// ---------------------------------------------------------------------------

/// Vazgeçiş gönderimi tek noktadan yönetilir; başarılı olursa ilgili
/// state'leri (user + recent items) günceller.
class SubmitResult {
  const SubmitResult({required this.item, required this.totalSaved});
  final SkippedItem item;
  final double totalSaved;
}

Future<SubmitResult> submitVazgecis(
  WidgetRef ref, {
  required String itemName,
  required double price,
  String? rawCategory,
}) async {
  final repo = ref.read(savingsRepositoryProvider);
  final userNotifier = ref.read(userProvider.notifier);
  final currentUser = userNotifier.state;

  final res = await repo.submit(
    itemName: itemName,
    price: price,
    rawCategory: rawCategory,
  );

  // User state'ini güncelle (optimistic)
  userNotifier.applySaved(res.item.price);

  // State'leri güncelle
  ref.read(recentItemsProvider.notifier).prepend(res.item);

  return SubmitResult(item: res.item, totalSaved: res.totalSaved);
}
