import 'package:flutter/material.dart';

/// Backend Steering → Tablo 1: Users.
@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.createdAt,
    required this.totalSaved,
    this.displayName,
    this.email,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['user_id'] as String? ?? json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      totalSaved: (json['total_saved'] as num? ?? json['totalSaved'] as num? ?? 0).toDouble(),
      displayName: json['display_name'] as String? ?? json['displayName'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final String id;
  final DateTime createdAt;
  final double totalSaved;
  final String? displayName;
  final String? email;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'created_at': createdAt.toIso8601String(),
        'total_saved': totalSaved,
        if (displayName != null) 'display_name': displayName,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  AppUser copyWith({
    String? id,
    DateTime? createdAt,
    double? totalSaved,
    String? displayName,
    String? email,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      totalSaved: totalSaved ?? this.totalSaved,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
