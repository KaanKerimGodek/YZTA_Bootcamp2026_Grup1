import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/skipped_item.dart';

/// Ana Sayfadaki Hero Wallet Card (Toplam Tasarruf) altına eklenen
/// haftalık başarı rozeti / mini rozet.
///
/// DESIGN.md → Haftalık Başarı Rozeti:
/// - Yumuşak yuvarlatılmış köşeli pill şeklinde
/// - İkon + anlamlı metin
/// - Haftalık verilere dayalı dinamik mesaj
class WeeklyAchievementBadge extends StatelessWidget {
  const WeeklyAchievementBadge({
    super.key,
    required this.items,
  });

  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const WeeklyAchievementBadgeSkeleton();
    }

    final achievement = _computeAchievement(items);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: achievement.backgroundColor,
            borderRadius: BorderRadius.circular(AppShapes.full),
            border: Border.all(
              color: achievement.borderColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                achievement.icon,
                color: achievement.iconColor,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                achievement.text,
                style: AppTypography.labelSubtext.copyWith(
                  color: achievement.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _AchievementData _computeAchievement(List<SkippedItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = now.weekday; // 1=Pazartesi, 7=Pazar
    final thisMonday = today.subtract(Duration(days: weekday - 1));

    // Bu haftaki öğeleri filtrele (Pazartesi'den bugüne)
    final thisWeekItems = items.where((item) {
      final d = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      return !d.isBefore(thisMonday) && !d.isAfter(today);
    }).toList();

    if (thisWeekItems.isEmpty) {
      return _AchievementData(
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.successEmerald,
        backgroundColor: AppColors.successEmerald.withOpacity(0.12),
        borderColor: AppColors.successEmerald,
        textColor: AppColors.successEmerald,
        text: 'Bu hafta henüz vazgeçiş yok',
      );
    }

    // 1. Ardışık gün sayısı (streak) - bugünden geriye doğru
    int streak = 0;
    DateTime checkDay = today;
    final daysWithItems = <DateTime>{};
    for (final item in thisWeekItems) {
      final d = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      daysWithItems.add(d);
    }

    while (daysWithItems.contains(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    // 2. Bu hafta kaç farklı kategoride vazgeçilmiş
    final categories = thisWeekItems.map((e) => e.aiCategory).toSet();
    final categoryCount = categories.length;

    // 3. Bu haftaki toplam tasarruf
    final weekTotal = thisWeekItems.fold<double>(0, (a, e) => a + e.price);

    // 4. Bu hafta kaç vazgeçiş
    final weekCount = thisWeekItems.length;

    // En anlamlı başarıyı seç (öncelik: streak > kategori > sayı > tutar)
    if (streak >= 3) {
      return _AchievementData(
        icon: Icons.local_fire_department_rounded,
        iconColor: AppColors.tertiary,
        backgroundColor: AppColors.tertiary.withOpacity(0.12),
        borderColor: AppColors.tertiary,
        textColor: AppColors.tertiary,
        text: streak == 7
            ? '🔥 Mükemmel! 7 gün üst üste vazgeçiş!'
            : '🔥 $streak gün üst üste vazgeçiş serisi!',
      );
    }

    if (categoryCount >= 3) {
      return _AchievementData(
        icon: Icons.emoji_events_rounded,
        iconColor: AppColors.primary,
        backgroundColor: AppColors.primary.withOpacity(0.12),
        borderColor: AppColors.primary,
        textColor: AppColors.primary,
        text: '🏆 Bu hafta $categoryCount farklı kategoride vazgeçtin!',
      );
    }

    if (weekCount >= 5) {
      return _AchievementData(
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.successEmerald,
        backgroundColor: AppColors.successEmerald.withOpacity(0.12),
        borderColor: AppColors.successEmerald,
        textColor: AppColors.successEmerald,
        text: '📈 Bu hafta $weekCount vazgeçiş — harika bir disiplin!',
      );
    }

    if (weekTotal >= 500) {
      return _AchievementData(
        icon: Icons.savings_rounded,
        iconColor: AppColors.primary,
        backgroundColor: AppColors.primary.withOpacity(0.12),
        borderColor: AppColors.primary,
        textColor: AppColors.primary,
        text: '💰 Bu hafta ${_formatAmount(weekTotal)} tasarruf ettin!',
      );
    }

    // Varsayılan: en az 1 vazgeçiş var
    return _AchievementData(
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.successEmerald,
      backgroundColor: AppColors.successEmerald.withOpacity(0.12),
      borderColor: AppColors.successEmerald,
      textColor: AppColors.successEmerald,
      text: '✨ Bu hafta $weekCount vazgeçiş, ${_formatAmount(weekTotal)} birikim!',
    );
  }

  static String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _AchievementData {
  const _AchievementData({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String text;
}

/// Skeleton/placeholder versiyonu (loading state).
class WeeklyAchievementBadgeSkeleton extends StatelessWidget {
  const WeeklyAchievementBadgeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppShapes.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 180,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppShapes.full),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}