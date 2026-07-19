import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';

/// Ana Sayfada kullanıcının belirlediği hedefi takip eden "Hedef Durumu" kartı.
///
/// DESIGN.md → Hedef Durumu bileşeni:
/// - Beyaz yüzey, standart gölge, yuvarlatılmış köşeler (xl)
/// - Başlık + hedef adı
/// - İlerleme çubuğu (LinearProgressIndicator, Emerald-500)
/// - Alt metin: "%32 • ₺3.108 / ₺10.000"
class GoalStatusCard extends StatelessWidget {
  const GoalStatusCard({
    super.key,
    required this.goalName,
    required this.currentAmount,
    required this.targetAmount,
    this.icon = Icons.flag_rounded,
    this.iconColor = AppColors.successEmerald,
    this.onTap,
  });

  final String goalName;
  final double currentAmount;
  final double targetAmount;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  int get progressPercent => (progress * 100).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShapes.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppShapes.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppShapes.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık + ikon
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppShapes.md),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hedef Durumu',
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goalName,
                            style: AppTypography.bodyBold.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // İlerleme çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppShapes.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(iconColor),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Alt metin: %32 • ₺3.108 / ₺10.000
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '%$progressPercent',
                      style: AppTypography.bodyBold.copyWith(
                        color: iconColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${Formatting.currency(currentAmount, decimal: false)} / ${Formatting.currency(targetAmount, decimal: false)}',
                      style: AppTypography.labelSubtext.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hedef kartı için skeleton/placeholder (loading state).
class GoalStatusCardSkeleton extends StatelessWidget {
  const GoalStatusCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppShapes.md),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppShapes.full),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 140,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppShapes.full),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppShapes.full),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppShapes.full),
                  ),
                ),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppShapes.full),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}