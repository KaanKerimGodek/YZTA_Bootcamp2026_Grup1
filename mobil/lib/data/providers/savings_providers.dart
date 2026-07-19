import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_insight.dart';
import '../models/app_user.dart';
import '../models/skipped_item.dart';
import '../repositories/savings_repository.dart';
import 'di.dart';

// ---------------------------------------------------------------------------
// Async view-model providers
// ---------------------------------------------------------------------------

/// Kullanıcı + Hero Card toplam tasarrufu.
final userProvider = AsyncNotifierProvider<UserNotifier, AppUser>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<AppUser> {
  @override
  Future<AppUser> build() {
    return ref.read(savingsRepositoryProvider).fetchUser();
  }

  /// Yeni vazgeçiş sonrası toplamı cache üzerinden günceller.
  void applySaved(double addedAmount) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(totalSaved: current.totalSaved + addedAmount),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsRepositoryProvider).fetchUser(),
    );
  }
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
  final res = await repo.submit(
    itemName: itemName,
    price: price,
    rawCategory: rawCategory,
  );
  // State'leri güncelle
  ref.read(userProvider.notifier).applySaved(res.item.price);
  ref.read(recentItemsProvider.notifier).prepend(res.item);
  return SubmitResult(item: res.item, totalSaved: res.totalSaved);
}
