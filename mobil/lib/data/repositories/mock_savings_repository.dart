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
  Future<AppUser> fetchUser() => _mock.fetchUser();

  @override
  Future<List<SkippedItem>> fetchRecentItems({int limit = 20}) =>
      _mock.fetchRecentItems(limit: limit);

  @override
  Future<List<AiInsight>> fetchInsights() => _mock.fetchInsights();

  @override
  Future<({SkippedItem item, double totalSaved})> submit({
    required String itemName,
    required double price,
    String? rawCategory,
  }) {
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
}
