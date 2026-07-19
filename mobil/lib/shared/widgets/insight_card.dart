import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../data/models/ai_insight.dart';

/// AI Insight Carousel'inin tek bir kartı.
///
/// DESIGN.md → AI Insight Carousel:
/// - Beyaz yüzey, standart gölge
/// - Sol tarafta Emerald-500 sparkle ikonu
/// - Doğal, sohbet dili metni (örn: "Yürüyerek tasarruf ettin!")
class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight, this.width = 300});

  final AiInsight insight;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShapes.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // rgba(0,0,0,0.08)
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emerald sparkle ikonu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successEmerald.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppShapes.md),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.successEmerald,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI İçgörü',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.successEmerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (insight.amount != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successEmerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppShapes.full),
                          ),
                          child: Text(
                            Formatting.saved(insight.amount!),
                            style: AppTypography.labelSubtext.copyWith(
                              color: AppColors.successEmerald,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    insight.text,
                    style: AppTypography.bodyMain.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    Formatting.relativeDay(insight.generatedAt),
                    style: AppTypography.labelSubtext.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
