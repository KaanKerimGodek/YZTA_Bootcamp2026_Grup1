import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_session.dart';
import '../services/mock_auth_service.dart';
import '../services/supabase_auth_service.dart';

/// Tek bir [SupabaseAuthService] örneği sağlar.
final authServiceProvider = Provider<AuthService>((ref) {
  return SupabaseAuthService();
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
  SessionNotifier(this._ref) : super(null) {
    _initializeSession();
  }

  final Ref _ref;

  /// `true` iken bir giriş/kayıt isteği devam ediyor demektir.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Uygulama başlangıcında mevcut Supabase session'ı yükler
  /// ve auth state değişikliklerini dinlemeye başlar.
  Future<void> _initializeSession() async {
    // 1. Mevcut session'ı hemen yükle (varsa)
    final authService = _ref.read(authServiceProvider);
    if (authService is SupabaseAuthService) {
      final currentSession = authService.getCurrentSession();
      if (currentSession != null) {
        state = currentSession;
      }
    }

    // 2. Auth state değişikliklerini dinle (giriş/çıkış/token yenileme)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AuthSession(
          userId: session.user.id,
          email: session.user.email ?? '',
          displayName: session.user.userMetadata?['display_name'] as String? ?? '',
          createdAt: DateTime.now(),
        );
      } else {
        state = null;
      }
    });
  }

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
