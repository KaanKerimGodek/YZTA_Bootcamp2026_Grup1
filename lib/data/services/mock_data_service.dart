import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/ai_insight.dart';
import '../models/app_user.dart';
import '../models/skipped_item.dart';

/// Backend olmadan uygulamanın demo verisiyle çalışmasını sağlayan servis.
///
/// [AppConfig.isMock] true iken repository'ler bunu kullanır.
/// Tüm "yanıtlar" kısa bir gecikme ile döner → gerçek API hissini taklit eder.
class MockDataService {
  MockDataService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  // --- Seed demo verisi -----------------------------------------------
  AppUser _user = AppUser(
    id: '00000000-0000-0000-0000-000000000000',
    createdAt: DateTime(2026, 6, 1),
    totalSaved: 12450.75,
    displayName: 'Yagiz',
    email: 'yagiz@example.com',
  );

  final List<SkippedItem> _items = [
    SkippedItem(
      id: 'seed-1',
      userId: '00000000-0000-0000-0000-000000000000',
      name: 'Starbucks Latte',
      price: 120,
      aiCategory: 'İçecek',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SkippedItem(
      id: 'seed-2',
      userId: '00000000-0000-0000-0000-000000000000',
      name: 'Trendyol Spor Ayakkabı',
      price: 899.90,
      aiCategory: 'Giyim',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    SkippedItem(
      id: 'seed-3',
      userId: '00000000-0000-0000-0000-000000000000',
      name: 'Uber Eve Dönüş',
      price: 185,
      aiCategory: 'Ulaşım',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    SkippedItem(
      id: 'seed-4',
      userId: '00000000-0000-0000-0000-000000000000',
      name: 'Sinema Bileti',
      price: 250,
      aiCategory: 'Eğlence',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    ),
    SkippedItem(
      id: 'seed-5',
      userId: '00000000-0000-0000-0000-000000000000',
      name: 'Yemek Siparişi (Getir)',
      price: 320,
      aiCategory: 'Yemek',
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 8)),
    ),
    SkippedItem(
      id: 'seed-6',
      userId: '00000000-0000-0000-0000-000000000000',
      name: 'iPhone Aksesuar Seti',
      price: 1499,
      aiCategory: 'Teknoloji',
      createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
    ),
    SkippedItem(
      id: 'seed-7',
      userId: '00000000-0000-0000-0000-000000000000',
      name: 'Berber Kuaför',
      price: 400,
      aiCategory: 'Kişisel Bakım',
      createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 1)),
    ),
  ];

  final List<AiInsight> _insights = [
    AiInsight(
      id: 'ins-1',
      userId: '00000000-0000-0000-0000-000000000000',
      text:
          'Yürüyerek eve dönmek yerine tercih ettiğin her adım, gece vardiyası taksi ücretlerini cüzdanına geri koyuyor!',
      generatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      amount: 450,
    ),
    AiInsight(
      id: 'ins-2',
      userId: '00000000-0000-0000-0000-000000000000',
      text:
          'Bu hafta giyim harcamalarından tam 900₺ vazgeçtin. Yıllık bile olsa, bu karne seni gerçekten gururlandıracak!',
      generatedAt: DateTime.now().subtract(const Duration(days: 1)),
      amount: 900,
    ),
    AiInsight(
      id: 'ins-3',
      userId: '00000000-0000-0000-0000-000000000000',
      text:
          'Akşam yemeği siparişi yerine evde pişirmek ayda ortalama 1.500₺ tasarruf demek. Gelecekteki kendine teşekkür edecek.',
      generatedAt: DateTime.now().subtract(const Duration(days: 2)),
      amount: 1500,
    ),
  ];

  // --- API simülasyonu -------------------------------------------------
  Future<AppUser> fetchUser() async => _delayed(() => _user);

  Future<List<SkippedItem>> fetchRecentItems({int limit = 20}) async {
    return _delayed(() {
      final sorted = [..._items]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted.take(limit).toList();
    });
  }

  Future<List<AiInsight>> fetchInsights() async =>
      _delayed(() => List.unmodifiable(_insights));

  /// Yeni vazgeçiş ekler ve güncel toplamı döndürür.
  /// Basit bir keyword bazlı "AI kategorizasyonu" taklit eder.
  Future<({SkippedItem item, double totalSaved})> submit({
    required String userId,
    required String itemName,
    required double price,
    String? rawCategory,
  }) async {
    return _delayed(() {
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
      _items.insert(0, item);
      _user = _user.copyWith(totalSaved: _user.totalSaved + price);
      return (item: item, totalSaved: _user.totalSaved);
    });
  }

  // --- "AI" kategorizasyon (mock) -------------------------------------
  String _mockCategorize(String name, String? raw) {
    if (raw != null && raw.trim().isNotEmpty) return raw.trim();
    final lower = name.toLowerCase();
    if (RegExp(r'kahve|latte|coffee|çay|tea|içecek|süt|ayran|cola')
        .hasMatch(lower)) {
      return 'İçecek';
    }
    if (RegExp(r'burger|pizza|yemek|restaurant|lokanta|kebap|pide|çorba|getir|yemeksepeti')
        .hasMatch(lower)) {
      return 'Yemek';
    }
    if (RegExp(r'ayakkabı|tişört|pantolon|mont|ceket|tshirt|elbise|giyim|trendyol')
        .hasMatch(lower)) {
      return 'Giyim';
    }
    if (RegExp(r'sinema|tiyatro|konser|film|netflix|spotify|oyun|eğlence')
        .hasMatch(lower)) {
      return 'Eğlence';
    }
    if (RegExp(r'uber|taksi|metro|otobüs|benzin|ulaşım|park').hasMatch(lower)) {
      return 'Ulaşım';
    }
    if (RegExp(r'iphone|laptop|kulaklık|telefon|teknoloji|apple|samsung|aksesuar')
        .hasMatch(lower)) {
      return 'Teknoloji';
    }
    if (RegExp(r'berber|kuaför|spor|salon|cilt|krem|parfüm|bakım')
        .hasMatch(lower)) {
      return 'Kişisel Bakım';
    }
    return 'Diğer';
  }

  Future<T> _delayed<T>(T Function() fn) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return fn();
  }
}
