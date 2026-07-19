import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/auth_session.dart';
import 'api_client.dart';

/// Oturum açma/kapatma işlemleri için soyut arayüz.
///
/// [MockAuthService] ve ilerideki [SupabaseAuthService] bu sözleşmeye uyar.
abstract class AuthService {
  Future<AuthSession> signIn({
    required String email,
    required String password,
  });

  Future<AuthSession> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

/// Demo amaçlı mock auth servisi.
///
/// Gerçek backend gerektirmez; e-posta/şifre doğrulaması bellekte yapılır.
/// Tüm çağrılar kısa bir gecikme ile döner → gerçek API hissini taklit eder.
///
/// Kurallar:
/// - E-posta geçerli formatta olmalı.
/// - Şifre en az 6 karakter olmalı.
/// - Kayıtta e-posta daha önce alınmışsa hata fırlatır.
/// - Girişte e-posta kayıtlı ve şifre eşleşmeli.
/// - Geliştirme modunda "yacolak" / "yacolak" ile hızlı giriş yapılabilir.
class MockAuthService implements AuthService {
  MockAuthService({Uuid? uuid}) : _uuid = uuid ?? const Uuid() {
    _seedTestUser();
  }

  final Uuid _uuid;

  /// email → {password, session} eşlemi (in-memory kullanıcı deposu).
  final Map<String, _MockUser> _users = {};

  static const _emailRegex = r'^[\w.+-]+@[\w-]+\.[\w.-]+$';

  /// Geliştirici/test kullanıcısını belleğe ekler.
  void _seedTestUser() {
    const testEmail = 'yacolak@test.com';
    const testPassword = 'yacolak123';
    if (!_users.containsKey(testEmail)) {
      final session = AuthSession(
        userId: _uuid.v4(),
        email: testEmail,
        displayName: 'Yacolak Test',
        createdAt: DateTime.now(),
      );
      _users[testEmail] = _MockUser(password: testPassword, session: session);
    }
  }

  Future<void> _delayed() =>
      Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    await _delayed();
    _validateCredentials(email, password);

    final normalized = email.trim().toLowerCase();
    final user = _users[normalized];
    if (user == null) {
      throw const ApiException(
        'Bu e-posta ile kayıtlı hesap bulunamadı.',
        statusCode: 404,
      );
    }
    if (user.password != password) {
      throw const ApiException(
        'E-posta veya şifre hatalı.',
        statusCode: 401,
      );
    }
    return user.session;
  }

  @override
  Future<AuthSession> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    await _delayed();

    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      throw const ApiException('Ad ve soyad boş bırakılamaz.', statusCode: 400);
    }
    _validateCredentials(email, password);

    final normalized = email.trim().toLowerCase();
    if (_users.containsKey(normalized)) {
      throw const ApiException(
        'Bu e-posta zaten kayıtlı.',
        statusCode: 409,
      );
    }

    final session = AuthSession(
      userId: _uuid.v4(),
      email: normalized,
      displayName: '${firstName.trim()} ${lastName.trim()}',
      createdAt: DateTime.now(),
    );
    _users[normalized] = _MockUser(password: password, session: session);
    return session;
  }

  @override
  Future<void> signOut() async {
    await _delayed();
    // Mock modde gerçek bir oturum yok; işlem başarılı kabul edilir.
  }

  void _validateCredentials(String email, String password) {
    if (!RegExp(_emailRegex).hasMatch(email.trim())) {
      throw const ApiException(
        'Geçerli bir e-posta adresi gir.',
        statusCode: 400,
      );
    }
    if (password.length < 6) {
      throw const ApiException(
        'Şifre en az 6 karakter olmalı.',
        statusCode: 400,
      );
    }
  }
}

class _MockUser {
  const _MockUser({required this.password, required this.session});
  final String password;
  final AuthSession session;
}
