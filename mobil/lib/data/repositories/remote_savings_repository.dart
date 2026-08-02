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
    required String? Function() userIdProvider,
  }) : _userIdProvider = userIdProvider;

  final N8nWebhookService webhookService;
  final ApiClient client;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String? Function() _userIdProvider;

  String? get _userId => _userIdProvider();

  Map<String, dynamic> get _restHeaders => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Prefer': 'return=representation',
      };

  /// Supabase REST yanıtını normalize eder.
  /// PostgREST bazen doğrudan array `[{...}]` döner, bazen `{"data": [...]}`.
  List<Map<String, dynamic>> _parseList(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json.cast<Map<String, dynamic>>();
    }
    if (json is Map && json['data'] is List) {
      return (json['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<AppUser> fetchUser() async {
    final userId = _userId;
    if (userId == null) {
      print('[RemoteSavingsRepository] fetchUser: userId is null');
      return AppUser(id: '', createdAt: DateTime.now(), totalSaved: 0);
    }
    print('[RemoteSavingsRepository] fetchUser: $userId');
    try {
      final json = await client.get(
        '$supabaseUrl/rest/v1/users?user_id=eq.$userId&select=*',
        headers: _restHeaders,
      );
      final list = _parseList(json);
      print('[RemoteSavingsRepository] fetchUser result: ${list.length} items');
      if (list.isEmpty) {
        return AppUser(id: userId, createdAt: DateTime.now(), totalSaved: 0);
      }
      return AppUser.fromJson(list.first);
    } on ApiException catch (e) {
      // CORS veya ağ hatası olursa (web'de yaygın), boş user dön
      if (e.message.contains('CORS') || e.message.contains('ağ hatası') || e.statusCode == 0) {
        print('[RemoteSavingsRepository] CORS/ağ hatası, fallback user: $e');
        return AppUser(id: userId, createdAt: DateTime.now(), totalSaved: 0);
      }
      print('[RemoteSavingsRepository] fetchUser error: $e');
      rethrow;
    }
  }

  @override
  Future<List<SkippedItem>> fetchRecentItems({int limit = 20}) async {
    final userId = _userId;
    if (userId == null) {
      print('[RemoteSavingsRepository] fetchRecentItems: userId is null');
      return [];
    }
    print('[RemoteSavingsRepository] fetchRecentItems: $userId, limit: $limit');
    try {
      final json = await client.get(
        '$supabaseUrl/rest/v1/skipped_items'
        '?user_id=eq.$userId&order=created_at.desc&limit=$limit&select=*',
        headers: _restHeaders,
      );
      final list = _parseList(json);
      print('[RemoteSavingsRepository] fetchRecentItems result: ${list.length} items');
      return list.map(SkippedItem.fromJson).toList();
    } on ApiException catch (e) {
      if (e.message.contains('CORS') || e.message.contains('ağ hatası') || e.statusCode == 0) {
        print('[RemoteSavingsRepository] CORS/ağ hatası, fallback empty items: $e');
        return [];
      }
      print('[RemoteSavingsRepository] fetchRecentItems error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AiInsight>> fetchInsights() async {
    final userId = _userId;
    if (userId == null) {
      print('[RemoteSavingsRepository] fetchInsights: userId is null');
      return [];
    }
    print('[RemoteSavingsRepository] fetchInsights: $userId');
    try {
      final json = await client.get(
        '$supabaseUrl/rest/v1/ai_insights'
        '?user_id=eq.$userId&order=generated_at.desc&limit=10&select=*',
        headers: _restHeaders,
      );
      final list = _parseList(json);
      print('[RemoteSavingsRepository] fetchInsights result: ${list.length} items');
      return list.map(AiInsight.fromJson).toList();
    } on ApiException catch (e) {
      if (e.message.contains('CORS') || e.message.contains('ağ hatası') || e.statusCode == 0) {
        print('[RemoteSavingsRepository] CORS/ağ hatası, fallback empty insights: $e');
        return [];
      }
      print('[RemoteSavingsRepository] fetchInsights error: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser> updateGoalSettings({
    String? goalTitle,
    double? savingsGoal,
    double? monthlyGoal,
    String? currency,
  }) async {
    final userId = _userId;
    if (userId == null) {
      print('[RemoteSavingsRepository] updateGoalSettings: userId is null');
      throw ApiException(
        'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.',
        statusCode: 401,
      );
    }

    final body = <String, dynamic>{};
    if (goalTitle != null) body['goal_title'] = goalTitle;
    if (savingsGoal != null) body['savings_goal'] = savingsGoal;
    if (monthlyGoal != null) body['monthly_goal'] = monthlyGoal;
    if (currency != null) body['currency'] = currency;

    print('[RemoteSavingsRepository] updateGoalSettings: $userId, body: $body');

    if (body.isEmpty) {
      print('[RemoteSavingsRepository] updateGoalSettings: empty body, returning fetchUser');
      return fetchUser();
    }

    try {
      final json = await client.patch(
        '$supabaseUrl/rest/v1/users?user_id=eq.$userId',
        body: body,
        headers: _restHeaders,
      );
      final list = _parseList(json);
      print('[RemoteSavingsRepository] updateGoalSettings result: ${list.length} items');
      if (list.isEmpty) {
        // Güncelleme başarılı ama veri dönmedi (kolon yok olabilir)
        // Local state'i güncellemek için fetchUser çağır
        print('[RemoteSavingsRepository] updateGoalSettings: empty result, calling fetchUser');
        return fetchUser();
      }
      return AppUser.fromJson(list.first);
    } on ApiException catch (e) {
      // Kolon yok hatası (PostgreSQL 42703) veya diğer hatalar
      // Fallback: Local state güncelle, hata fırlatma
      if (e.statusCode == 400 || e.statusCode == 42703) {
        // Kolon henüz eklenmemiş olabilir, local güncelle
        print('[RemoteSavingsRepository] updateGoalSettings column error (fallback): $e');
        return fetchUser(); // Mevcut user'ı döndür (local state güncellenecek)
      }
      print('[RemoteSavingsRepository] updateGoalSettings error: $e');
      rethrow;
    }
  }

  @override
  Future<({SkippedItem item, double totalSaved})> submit({
    required String itemName,
    required double price,
    String? rawCategory,
  }) async {
    final userId = _userId;
    if (userId == null) {
      print('[RemoteSavingsRepository] submit: userId is null');
      throw ApiException(
        'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.',
        statusCode: 401,
      );
    }
    print('[RemoteSavingsRepository] submit: $itemName, $price, category: $rawCategory');
    final result = await webhookService.submit(
      itemName: itemName,
      price: price,
      rawCategory: rawCategory,
    );
    print('[RemoteSavingsRepository] submit result: itemId=${result.itemId}, aiCategory=${result.aiCategory}, totalSaved=${result.totalSaved}, isFallback=${result.isFallback}');

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

    // NOT: Fallback durumunda (n8n timeout/CORS/5xx) webhookService'in döndüğü
    // totalSaved SADECE bu ürünün fiyatıdır, kümülatif toplam DEĞİLDİR.
    // n8n arka planda hâlâ çalışıyor olabilir ve gerçek toplamı Supabase'e
    // yazacaktır, ama biz o anı bekleyemeyiz. Bu yüzden burada Supabase'deki
    // (n8n'in henüz güncellemediği, bir önceki) toplamı çekip üstüne bu
    // ürünün fiyatını ekleyerek daha doğru bir tahmini toplam gösteriyoruz.
    // Kesin doğru toplam, kullanıcı bir sonraki fetchUser() çağrısında
    // (örn. uygulamayı yeniden açtığında) Supabase'den gelecektir.
    if (result.isFallback) {
      try {
        final currentUser = await fetchUser();
        final estimatedTotal = currentUser.totalSaved + price;
        print('[RemoteSavingsRepository] submit: fallback düzeltmesi, gerçek önceki toplam=${currentUser.totalSaved}, tahmini yeni toplam=$estimatedTotal');
        return (item: item, totalSaved: estimatedTotal);
      } catch (e) {
        // fetchUser bile başarısız olursa, en azından yanlış olmayan bir
        // şey döndürmek yerine elimizdeki tek veriyle devam ediyoruz.
        print('[RemoteSavingsRepository] submit: fallback düzeltmesi başarısız, ham totalSaved kullanılıyor: $e');
      }
    }

    return (item: item, totalSaved: result.totalSaved);
  }

  @override
  Future<AppUser> completeGoalAndReset() async {
    final userId = _userId;
    if (userId == null) {
      print('[RemoteSavingsRepository] completeGoalAndReset: userId is null');
      throw ApiException(
        'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.',
        statusCode: 401,
      );
    }

    print('[RemoteSavingsRepository] completeGoalAndReset: $userId');

    // Önce mevcut kullanıcıyı al
    final currentUser = await fetchUser();
    if (!currentUser.hasGoal) {
      print('[RemoteSavingsRepository] completeGoalAndReset: no active goal');
      throw ApiException('Tamamlanacak aktif hedef yok.', statusCode: 400);
    }

    print('[RemoteSavingsRepository] completeGoalAndReset: current goal="${currentUser.goalTitle}", target=${currentUser.savingsGoal}, saved=${currentUser.totalSaved}');

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

    print('[RemoteSavingsRepository] completeGoalAndReset: completed goal added, total completed: ${updatedGoals.length}');

    // Backend'e gönderilecek body
    final body = <String, dynamic>{
      'goal_title': null,
      'savings_goal': null,
      'completed_goals': updatedGoals.map((e) => e.toJson()).toList(),
    };

    try {
      final json = await client.patch(
        '$supabaseUrl/rest/v1/users?user_id=eq.$userId',
        body: body,
        headers: _restHeaders,
      );
      final list = _parseList(json);
      print('[RemoteSavingsRepository] completeGoalAndReset result: ${list.length} items');
      if (list.isEmpty) {
        // Backend güncelleme başarılı ama veri dönmedi
        // Local state'i güncellemek için yeni user nesnesi oluştur
        print('[RemoteSavingsRepository] completeGoalAndReset: empty result, using local copy');
        return currentUser.copyWith(
          goalTitle: null,
          savingsGoal: null,
          completedGoals: updatedGoals,
        );
      }
      return AppUser.fromJson(list.first);
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 42703) {
        // Kolon yok, local fallback
        print('[RemoteSavingsRepository] completeGoalAndReset column error (fallback): $e');
        return currentUser.copyWith(
          goalTitle: null,
          savingsGoal: null,
          completedGoals: updatedGoals,
        );
      }
      print('[RemoteSavingsRepository] completeGoalAndReset error: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser> completeGoalWithData(CompletedGoal completedGoal) async {
    final userId = _userId;
    if (userId == null) {
      print('[RemoteSavingsRepository] completeGoalWithData: userId is null');
      throw ApiException(
        'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.',
        statusCode: 401,
      );
    }

    print('[RemoteSavingsRepository] completeGoalWithData: $userId, goal: ${completedGoal.goalTitle}');

    // Mevcut kullanıcıyı al (completedGoals için)
    final currentUser = await fetchUser();
    final existingGoals = currentUser.completedGoals ?? [];
    final updatedGoals = [...existingGoals, completedGoal];

    print('[RemoteSavingsRepository] completeGoalWithData: completed goal added, total completed: ${updatedGoals.length}');

    // Backend'e gönderilecek body
    final body = <String, dynamic>{
      'goal_title': null,
      'savings_goal': null,
      'completed_goals': updatedGoals.map((e) => e.toJson()).toList(),
    };

    try {
      final json = await client.patch(
        '$supabaseUrl/rest/v1/users?user_id=eq.$userId',
        body: body,
        headers: _restHeaders,
      );
      final list = _parseList(json);
      print('[RemoteSavingsRepository] completeGoalWithData result: ${list.length} items');
      if (list.isEmpty) {
        // Backend güncelleme başarılı ama veri dönmedi
        print('[RemoteSavingsRepository] completeGoalWithData: empty result, using local copy');
        return currentUser.copyWith(
          goalTitle: null,
          savingsGoal: null,
          completedGoals: updatedGoals,
        );
      }
      return AppUser.fromJson(list.first);
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 42703) {
        // Kolon yok, local fallback
        print('[RemoteSavingsRepository] completeGoalWithData column error (fallback): $e');
        return currentUser.copyWith(
          goalTitle: null,
          savingsGoal: null,
          completedGoals: updatedGoals,
        );
      }
      print('[RemoteSavingsRepository] completeGoalWithData error: $e');
      rethrow;
    }
  }
}