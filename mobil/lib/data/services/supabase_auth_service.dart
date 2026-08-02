// lib/data/services/supabase_auth_service.dart
// Bu dosyayı mock_auth_service.dart'ın yanına koy.
// Sonra auth_providers.dart'ta MockAuthService yerine SupabaseAuthService kullan.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_session.dart';
import 'mock_auth_service.dart'; // AuthService abstract class buradan geliyor
import 'api_client.dart';
import 'dart:developer';

class SupabaseAuthService implements AuthService {
  SupabaseAuthService() {
    _ensureTestUser();
  }

  final _client = Supabase.instance.client;

  /// Test kullanıcısını garanti altına al (sadece geliştirme için)
  Future<void> _ensureTestUser() async {
    // Takım arkadaşı Dashboard'dan oluşturdu
    const testEmail = 'test_user@gmail.com';
    const testPassword = '123asd456';

    try {
      // Önce giriş dene - varsa zaten tamam
      final response = await _client.auth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      );

      if (response.user != null) {
        // Test kullanıcısı zaten var, çıkış yap
        await _client.auth.signOut();
        return;
      }
    } catch (_) {
      // Kullanıcı yok, oluştur
    }

    try {
      // Test kullanıcısı oluştur
      await _client.auth.signUp(
        email: testEmail,
        password: testPassword,
        data: {
          'display_name': 'Test Kullanıcı',
          'first_name': 'Test',
          'last_name': 'Kullanıcı',
        },
      );

      // Email confirmation gerekiyorsa admin API ile confirm et (local dev için)
      // Not: Production'da email confirmation açık olmalı
      // final adminClient = Supabase.instance.client;
      log('Test user created: $testEmail');
    } catch (e) {
      // Ignore - user might already exist
      log('Test user creation: $e');
    }
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const ApiException(
          'Giriş başarısız. Lütfen tekrar dene.',
          statusCode: 401,
        );
      }

      return AuthSession(
        userId: user.id,
        email: user.email ?? email,
        displayName: user.userMetadata?['display_name'] as String? ?? email.split('@').first,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      throw ApiException(
        e.message,
        statusCode: 401,
      );
    }
  }

  @override
  Future<AuthSession> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'display_name': '$firstName $lastName',
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const ApiException(
          'Kayıt başarısız. Lütfen tekrar dene.',
          statusCode: 400,
        );
      }

      return AuthSession(
        userId: user.id,
        email: user.email ?? email,
        displayName: '$firstName $lastName',
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      throw ApiException(
        e.message,
        statusCode: 400,
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Mevcut oturumu kontrol et (uygulama açılışında kullan)
  AuthSession? getCurrentSession() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthSession(
      userId: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String? ?? '',
      createdAt: DateTime.now(),
    );
  }
}
