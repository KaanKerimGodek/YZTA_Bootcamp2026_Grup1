import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_session.dart';
import '../services/mock_auth_service.dart';

/// Tek bir [MockAuthService] örneği sağlar.
///
/// İleride [AppConfig.isMock]'a göre mock/remote ayrımı yapacak şekilde
/// genişletilebilir; mevcut plan yalnızca mock kullanır.
final authServiceProvider = Provider<AuthService>((ref) {
  return MockAuthService();
});

/// Mevcut oturum durumu.
///
/// `null` → çıkış yapılmış; dolu → giriş yapılmış.
final sessionProvider =
    StateNotifierProvider<SessionNotifier, AuthSession?>(
  SessionNotifier.new,
);

/// Oturum açma/kapatma işlemlerini yönetir.
///
/// [GoRouter] bu provider'ı bir `ref.listen` üzerinden izler ve auth durumu
/// değiştiğinde redirect'i yeniden değerlendirir (router'da kurulur).
class SessionNotifier extends StateNotifier<AuthSession?> {
  SessionNotifier(this._ref) : super(null);

  final Ref _ref;

  /// `true` iken bir giriş/kayıt isteği devam ediyor demektir.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      state = await _ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      state = await _ref.read(authServiceProvider).signUp(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
          );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> signOut() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      await _ref.read(authServiceProvider).signOut();
    } catch (_) {
      // Çıkış hatası olsa bile yerel oturumu temizle.
    } finally {
      _isLoading = false;
      state = null;
    }
  }
}
