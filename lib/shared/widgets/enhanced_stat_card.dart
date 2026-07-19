import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../data/models/skipped_item.dart';

/// İstatistik ekranında kullanılan geliştirilmiş özet kartları.
///
/// - Toplam kart: En yüksek tutarlı ilk 3 vazgeçişi listeler
/// - Vazgeçiş adet kartı: En çok vazgeçilen ilk 3 kategoriyi ve adetleri gösterir
/// - Ortalama kart: Son 7 günün tasarruf dağılımını dikey mini Bar Chart ile gösterir
class EnhancedStatCard extends StatelessWidget {
  const EnhancedStatCard({
    super.key,
    required this.label,
    required this.mainValue,
    required this.icon,
    required this.accent,
    required this.detailWidget,
  });

  final String label;
  final String mainValue;
  final IconData icon;
  final Color accent;
  final Widget detailWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShapes.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkon + etiket
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppShapes.md),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Ana değer
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              mainValue,
              style: AppTypography.bodyBold.copyWith(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Detay widget (liste, kategori, grafik vb.)
          detailWidget,
        ],
      ),
    );
  }
}

/// Toplam Tasarruf kartı detayı: En yüksek 3 vazgeçiş.
class TopSkipsDetail extends StatelessWidget {
  const TopSkipsDetail({super.key, required this.items});

  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'Henüz vazgeçiş yok',
        style: AppTypography.labelSubtext.copyWith(color: AppColors.textSecondary),
      );
    }

    // En yüksek 3'i al
    final sorted = List<SkippedItem>.from(items)
      ..sort((a, b) => b.price.compareTo(a.price));
    final top3 = sorted.take(3).toList();

    return Column(
      children: top3.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              // Sıra numarası
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _rankColor(index).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppShapes.full),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTypography.labelSubtext.copyWith(
                    color: _rankColor(index),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Kategori ikonu
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppShapes.sm),
                ),
                child: Icon(item.icon, color: item.color, size: 12),
              ),
              const SizedBox(width: AppSpacing.xs),
              // İsim
              Expanded(
                child: Text(
                  item.name,
                  style: AppTypography.labelSubtext.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Tutar
              Text(
                Formatting.currency(item.price, decimal: false),
                style: AppTypography.bodyBold.copyWith(
                  color: AppColors.successEmerald,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _rankColor(int index) {
    switch (index) {
      case 0:
        return AppColors.tertiary; // Altın - 1. sıra
      case 1:
        return AppColors.outlineVariant; // Gümüş - 2. sıra
      case 2:
        return Color(0xFFCD7F32); // Bronz - 3. sıra
      default:
        return AppColors.primary;
    }
  }
}

/// Vazgeçiş Adet kartı detayı: En çok vazgeçilen 3 kategori + adet.
class TopCategoriesDetail extends StatelessWidget {
  const TopCategoriesDetail({super.key, required this.items});

  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'Henüz vazgeçiş yok',
        style: AppTypography.labelSubtext.copyWith(color: AppColors.textSecondary),
      );
    }

    // Kategori bazlı sayım
    final catCounts = <String, int>{};
    for (final item in items) {
      catCounts[item.aiCategory] = (catCounts[item.aiCategory] ?? 0) + 1;
    }

    final sorted = catCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();

    return Column(
      children: top3.asMap().entries.map((entry) {
        final index = entry.key;
        final catEntry = entry.value;
        final category = catEntry.key;
        final count = catEntry.value;
        final icon = CategoryMeta.iconFor(category);
        final color = CategoryMeta.colorFor(category);

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              // Sıra numarası
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _rankColor(index).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppShapes.full),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTypography.labelSubtext.copyWith(
                    color: _rankColor(index),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Kategori ikonu
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppShapes.sm),
                ),
                child: Icon(icon, color: color, size: 12),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Kategori adı
              Expanded(
                child: Text(
                  category,
                  style: AppTypography.labelSubtext.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Adet
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppShapes.full),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.labelSubtext.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _rankColor(int index) {
    switch (index) {
      case 0:
        return AppColors.tertiary;
      case 1:
        return AppColors.outlineVariant;
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }
}

/// Ortalama kartı detayı: Son 7 günün dikey mini Bar Chart.
class WeeklySavingsChartDetail extends StatelessWidget {
  const WeeklySavingsChartDetail({super.key, required this.items});

  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    // Son 7 gün için gün indexine göre gruplama
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final dayTotals = List<double>.filled(7, 0);

    for (final item in items) {
      final d = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      final idx = days.indexWhere((x) => x == d);
      if (idx >= 0) dayTotals[idx] += item.price;
    }

    final maxVal = dayTotals.fold<double>(0, (a, e) => a > e ? a : e);

    if (maxVal == 0) {
      return Text(
        'Bu hafta veri yok',
        style: AppTypography.labelSubtext.copyWith(color: AppColors.textSecondary),
      );
    }

    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final val = dayTotals[i];
          final h = (val / maxVal).clamp(0.05, 1.0);
          final isToday = days[i] == today;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Çubuk
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: h,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isToday
                                ? [
                                    AppColors.primary,
                                    AppColors.successEmerald,
                                  ]
                                : [
                                    AppColors.primary.withOpacity(0.6),
                                    AppColors.primary.withOpacity(0.3),
                                  ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(AppShapes.sm),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Gün adı
                  Text(
                    ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'][days[i].weekday - 1],
                    style: AppTypography.labelSubtext.copyWith(
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}