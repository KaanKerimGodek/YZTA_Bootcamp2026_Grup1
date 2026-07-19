import 'package:flutter/material.dart';

/// Oturum açmış kullanıcıyı temsil eder.
///
/// Mock ve (ileride) Supabase auth akışlarında ortak model.
@immutable
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['user_id'] as String? ?? json['id'] as String,
      email: json['email'] as String,
      displayName:
          json['display_name'] as String? ?? json['displayName'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  final String userId;
  final String email;
  final String displayName;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'display_name': displayName,
        'created_at': createdAt.toIso8601String(),
      };

  AuthSession copyWith({
    String? userId,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
