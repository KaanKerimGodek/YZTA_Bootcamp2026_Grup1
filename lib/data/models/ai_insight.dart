import 'package:flutter/material.dart';

/// Backend Steering → Tablo 3: AI_Insights.
///
/// n8n Workflow 2 (cron job) tarafından üretilen doğal dil motivasyon metni.
/// AI Insight Carousel'de gösterilir.
@immutable
class AiInsight {
  const AiInsight({
    required this.id,
    required this.userId,
    required this.text,
    required this.generatedAt,
    this.amount,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      id: json['insight_id'] as String? ?? json['id'] as String,
      userId: json['user_id'] as String,
      text: json['insight_text'] as String? ?? json['text'] as String,
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'] as String)
          : DateTime.now(),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    );
  }

  final String id;
  final String userId;
  final String text;
  final DateTime generatedAt;

  /// İçgörüye eşlik eden tasarruf miktarı (varsa).
  final double? amount;

  Map<String, dynamic> toJson() => {
        'insight_id': id,
        'user_id': userId,
        'insight_text': text,
        'generated_at': generatedAt.toIso8601String(),
        if (amount != null) 'amount': amount,
      };
}
