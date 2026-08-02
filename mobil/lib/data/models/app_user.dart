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
    this.goalTitle,
    this.savingsGoal,
    this.monthlyGoal,
    this.currency,
    this.completedGoals,
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
      goalTitle: json['goal_title'] as String? ?? json['goal_name'] as String?,
      savingsGoal: (json['savings_goal'] as num? ?? json['goal_target'] as num?)?.toDouble(),
      monthlyGoal: (json['monthly_goal'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      completedGoals: _parseCompletedGoals(json['completed_goals']),
    );
  }

  static List<CompletedGoal>? _parseCompletedGoals(dynamic json) {
    if (json == null) return null;
    if (json is List) {
      return json
          .map((e) => CompletedGoal.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  final String id;
  final DateTime createdAt;
  final double totalSaved;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final String? goalTitle;
  final double? savingsGoal;
  final double? monthlyGoal;
  final String? currency;
  final List<CompletedGoal>? completedGoals;

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'created_at': createdAt.toIso8601String(),
        'total_saved': totalSaved,
        if (displayName != null) 'display_name': displayName,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (goalTitle != null) 'goal_title': goalTitle,
        if (savingsGoal != null) 'savings_goal': savingsGoal,
        if (monthlyGoal != null) 'monthly_goal': monthlyGoal,
        if (currency != null) 'currency': currency,
        if (completedGoals != null)
          'completed_goals': completedGoals!.map((e) => e.toJson()).toList(),
      };

  AppUser copyWith({
    String? id,
    DateTime? createdAt,
    double? totalSaved,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? goalTitle,
    double? savingsGoal,
    double? monthlyGoal,
    String? currency,
    List<CompletedGoal>? completedGoals,
  }) {
    return AppUser(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      totalSaved: totalSaved ?? this.totalSaved,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      goalTitle: goalTitle ?? this.goalTitle,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      monthlyGoal: monthlyGoal ?? this.monthlyGoal,
      currency: currency ?? this.currency,
      completedGoals: completedGoals ?? this.completedGoals,
    );
  }

  /// Hedef ilerleme yüzdesi (0.0 - 1.0)
  /// Hedef yoksa 0.0 döner (100% göstermemek için)
  double get goalProgress {
    if (savingsGoal == null || savingsGoal! <= 0) return 0.0;
    return (totalSaved / savingsGoal!).clamp(0.0, 1.0);
  }

  /// Hedef tamamlandı mı?
  bool get isGoalCompleted => savingsGoal != null && savingsGoal! > 0 && goalProgress >= 1.0;

  /// Aylık hedef ilerleme yüzdesi
  double get monthlyProgress {
    if (monthlyGoal == null || monthlyGoal! <= 0) return 0.0;
    return (totalSaved / monthlyGoal!).clamp(0.0, 1.0);
  }

  /// Hedef var mı kontrolü
  bool get hasGoal => goalTitle != null && goalTitle!.isNotEmpty && savingsGoal != null && savingsGoal! > 0;
}

/// Tamamlanmış hedef modeli
@immutable
class CompletedGoal {
  const CompletedGoal({
    required this.goalTitle,
    required this.targetAmount,
    required this.completedAt,
    required this.totalSavedAtCompletion,
    this.durationDays,
  });

  factory CompletedGoal.fromJson(Map<String, dynamic> json) {
    return CompletedGoal(
      goalTitle: json['goal_title'] as String? ?? json['goal_name'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      completedAt: DateTime.parse(json['completed_at'] as String),
      totalSavedAtCompletion: (json['total_saved_at_completion'] as num).toDouble(),
      durationDays: (json['duration_days'] as num?)?.toInt(),
    );
  }

  final String goalTitle;
  final double targetAmount;
  final DateTime completedAt;
  final double totalSavedAtCompletion;
  final int? durationDays;

  Map<String, dynamic> toJson() => {
        'goal_title': goalTitle,
        'target_amount': targetAmount,
        'completed_at': completedAt.toIso8601String(),
        'total_saved_at_completion': totalSavedAtCompletion,
        if (durationDays != null) 'duration_days': durationDays,
      };

  CompletedGoal copyWith({
    String? goalTitle,
    double? targetAmount,
    DateTime? completedAt,
    double? totalSavedAtCompletion,
    int? durationDays,
  }) {
    return CompletedGoal(
      goalTitle: goalTitle ?? this.goalTitle,
      targetAmount: targetAmount ?? this.targetAmount,
      completedAt: completedAt ?? this.completedAt,
      totalSavedAtCompletion: totalSavedAtCompletion ?? this.totalSavedAtCompletion,
      durationDays: durationDays ?? this.durationDays,
    );
  }
}
