import '../models/ai_insight.dart';
import '../models/app_user.dart';
import '../models/skipped_item.dart';
import '../services/api_client.dart';
import '../services/mock_data_service.dart';
import 'savings_repository.dart';

/// [MockDataService] üzerine kurulu repository.
///
/// [AppConfig.isMock] true iken kullanılır.
class MockSavingsRepository implements SavingsRepository {
  MockSavingsRepository(this._mock, this._userId);

  final MockDataService _mock;
  final String _userId;

  @override
  Future<AppUser> fetchUser() {
    print('[MockSavingsRepository] fetchUser: $_userId');
    return _mock.fetchUser();
  }

  @override
  Future<List<SkippedItem>> fetchRecentItems({int limit = 20}) {
    print('[MockSavingsRepository] fetchRecentItems: $_userId, limit: $limit');
    return _mock.fetchRecentItems(limit: limit);
  }

  @override
  Future<List<AiInsight>> fetchInsights() {
    print('[MockSavingsRepository] fetchInsights: $_userId');
    return _mock.fetchInsights();
  }

  @override
  Future<({SkippedItem item, double totalSaved})> submit({
    required String itemName,
    required double price,
    String? rawCategory,
  }) {
    print('[MockSavingsRepository] submit: $itemName, $price, category: $rawCategory');
    if (price <= 0) {
      throw const ApiException('Tutar 0\'dan büyük olmalı', statusCode: 400);
    }
    if (itemName.trim().isEmpty) {
      throw const ApiException('Ürün adı boş olamaz', statusCode: 400);
    }
    return _mock.submit(
      userId: _userId,
      itemName: itemName.trim(),
      price: price,
      rawCategory: rawCategory,
    );
  }

  @override
  Future<AppUser> updateGoalSettings({
    String? goalTitle,
    double? savingsGoal,
    double? monthlyGoal,
    String? currency,
  }) async {
    print('[MockSavingsRepository] updateGoalSettings: $_userId, goalTitle: $goalTitle, savingsGoal: $savingsGoal, monthlyGoal: $monthlyGoal');
    // Mock modda local state güncelle
    final currentUser = await _mock.fetchUser();
    return currentUser.copyWith(
      goalTitle: goalTitle ?? currentUser.goalTitle,
      savingsGoal: savingsGoal ?? currentUser.savingsGoal,
      monthlyGoal: monthlyGoal ?? currentUser.monthlyGoal,
      currency: currency ?? currentUser.currency,
    );
  }

  @override
  Future<AppUser> completeGoalAndReset() async {
    print('[MockSavingsRepository] completeGoalAndReset: $_userId');
    final currentUser = await _mock.fetchUser();
    if (!currentUser.hasGoal) {
      throw ApiException('Tamamlanacak aktif hedef yok.', statusCode: 400);
    }

    print('[MockSavingsRepository] completeGoalAndReset: current goal="${currentUser.goalTitle}", target=${currentUser.savingsGoal}, saved=${currentUser.totalSaved}');

    // Tamamlanan hedefi oluştur
    final completedGoal = CompletedGoal(
      goalTitle: currentUser.goalTitle!,
      targetAmount: currentUser.savingsGoal!,
      completedAt: DateTime.now(),
      totalSavedAtCompletion: currentUser.totalSaved,
      durationDays: currentUser.createdAt.difference(DateTime.now()).inDays.abs(),
    );

    // Mevcut completedGoals listesini al
    final existingGoals = currentUser.completedGoals ?? [];
    final updatedGoals = [...existingGoals, completedGoal];

    print('[MockSavingsRepository] completeGoalAndReset: completed goal added, total completed: ${updatedGoals.length}');

    // Mock state'i güncelle (local copy)
    return currentUser.copyWith(
      goalTitle: null,
      savingsGoal: null,
      completedGoals: updatedGoals,
    );
  }

  @override
  Future<AppUser> completeGoalWithData(CompletedGoal completedGoal) async {
    print('[MockSavingsRepository] completeGoalWithData: $_userId, goal: ${completedGoal.goalTitle}');
    final currentUser = await _mock.fetchUser();
    
    // Mevcut completedGoals listesini al
    final existingGoals = currentUser.completedGoals ?? [];
    final updatedGoals = [...existingGoals, completedGoal];

    print('[MockSavingsRepository] completeGoalWithData: completed goal added, total completed: ${updatedGoals.length}');

    // Mock state'i güncelle (local copy)
    return currentUser.copyWith(
      goalTitle: null,
      savingsGoal: null,
      completedGoals: updatedGoals,
    );
  }
}