import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../data/models/skipped_item.dart';
import '../../shared/widgets/category_icon.dart';

/// İstatistik ekranındaki geliştirilmiş özet kartları - Dikey (Column) düzeninde.
///
/// Her kart tam genişlikte, içeriği yatay (Row) olarak düzenlenmiştir:
/// - Toplam kart: Sol = Başlık + Tutarı (sabit genişlik), Sağ = En yüksek 3 vazgeçiş (yatay satırlar)
/// - Vazgeçiş kart: Sol = Başlık + Adet (sabit genişlik), Sağ = En çok 3 kategori (yatay satırlar)
/// - Ortalama kart: Sol = Başlık + Ortalama (sabit genişlik), Sağ = 7 günlük Bar Chart
class EnhancedSummaryCard extends StatelessWidget {
  const EnhancedSummaryCard({
    super.key,
    required this.config,
    this.onTap,
  });

  final EnhancedSummaryConfig config;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppShapes.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
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
            border: Border(
              top: BorderSide(
                color: config.accent.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SOL KISIM: Sabit genişlikte - Başlık + Ana Değer
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İkon + Etiket
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                config.accent.withValues(alpha: 0.15),
                                config.accent.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppShapes.md),
                          ),
                          child: Icon(config.icon, color: config.accent, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            config.label,
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Ana Değer
                    Flexible(
                      child: Text(
                        config.mainValue,
                        style: AppTypography.displayWallet.copyWith(
                          fontSize: 28,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // SAĞ KISIM: Detay İçeriği - Tüm kalan alanı kapla
              Expanded(
                child: config.detailBuilder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toplam Tasarruf kartı - En yüksek 3 vazgeçişi temiz yatay satırlarda listeler.
class TotalSummaryConfig {
  const TotalSummaryConfig(this.items);

  final List<SkippedItem> items;

  EnhancedSummaryConfig build() {
    final total = items.fold<double>(0, (a, e) => a + e.price);

    final top3 = items.toList()
      ..sort((a, b) => b.price.compareTo(a.price));
    final topItems = top3.take(3).toList();

    return EnhancedSummaryConfig(
      label: 'Toplam',
      mainValue: Formatting.currency(total, decimal: false),
      icon: Icons.savings_outlined,
      accent: AppColors.primary,
      detailBuilder: _buildTopItemsList(topItems),
    );
  }

  Widget _buildTopItemsList(List<SkippedItem> topItems) {
    if (topItems.isEmpty) {
      return Center(
        child: Text(
          'Henüz veri yok',
          style: AppTypography.bodyMain.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: topItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == topItems.length - 1 ? 0 : AppSpacing.xs,
          ),
          child: _buildItemRow(
            rank: index + 1,
            icon: item.icon,
            color: item.color,
            name: item.name,
            category: item.aiCategory,
            amount: Formatting.currency(item.price, decimal: false),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItemRow({
    required int rank,
    required IconData icon,
    required Color color,
    required String name,
    required String category,
    required String amount,
  }) {
    final medalColor = _medalColor(rank);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sıralama madalyası
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: medalColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$rank',
            style: AppTypography.labelSubtext.copyWith(
              color: rank == 2 ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Kategori ikonu
        CategoryIcon(
          icon: icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 8),
        // İsim ve kategori - Esnek genişlikte
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ürün adı - belirgin
              Text(
                name,
                style: AppTypography.bodyBold.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              // Kategori - küçük ve soluk
              Text(
                category,
                style: AppTypography.labelSubtext.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Tutar (sağ köşe)
        Text(
          amount,
          style: AppTypography.bodyBold.copyWith(
            color: AppColors.successEmerald,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _medalColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.tertiary; // Altın
      case 2:
        return AppColors.outlineVariant; // Gümüş
      case 3:
        return AppColors.primary; // Bronz
      default:
        return AppColors.primary;
    }
  }
}

/// Vazgeçiş Sayısı kartı - En çok vazgeçilen 3 kategoriyi temiz yatay satırlarda listeler.
class CountSummaryConfig {
  const CountSummaryConfig(this.items);

  final List<SkippedItem> items;

  EnhancedSummaryConfig build() {
    final count = items.length;

    final categoryCounts = <String, int>{};
    for (final item in items) {
      categoryCounts[item.aiCategory] = (categoryCounts[item.aiCategory] ?? 0) + 1;
    }
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(3).toList();

    return EnhancedSummaryConfig(
      label: 'Vazgeçiş',
      mainValue: '$count adet',
      icon: Icons.check_circle_outline_rounded,
      accent: AppColors.successEmerald,
      detailBuilder: _buildCategoryList(topCategories),
    );
  }

  Widget _buildCategoryList(List<MapEntry<String, int>> topCategories) {
    if (topCategories.isEmpty) {
      return Center(
        child: Text(
          'Henüz veri yok',
          style: AppTypography.bodyMain.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: topCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final categoryEntry = entry.value;
        final category = categoryEntry.key;
        final count = categoryEntry.value;
        final color = CategoryMeta.colorFor(category);
        final icon = CategoryMeta.iconFor(category);

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == topCategories.length - 1 ? 0 : AppSpacing.xs,
          ),
          child: _buildCategoryRow(
            rank: index + 1,
            icon: icon,
            color: color,
            name: category,
            count: count,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryRow({
    required int rank,
    required IconData icon,
    required Color color,
    required String name,
    required int count,
  }) {
    final medalColor = _medalColor(rank);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sıralama madalyası
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: medalColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$rank',
            style: AppTypography.labelSubtext.copyWith(
              color: rank == 2 ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Kategori ikonu
        CategoryIcon(
          icon: icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 8),
        // Kategori adı - Esnek genişlikte
        Expanded(
          child: Text(
            name,
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Adet badge (sağ köşe)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppShapes.full),
          ),
          child: Text(
            '$count',
            style: AppTypography.labelSubtext.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Color _medalColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.tertiary;
      case 2:
        return AppColors.outlineVariant;
      case 3:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}

/// Ortalama kartı - 7 günlük dikey mini bar chart.
class AverageSummaryConfig {
  const AverageSummaryConfig(this.items);

  final List<SkippedItem> items;

  EnhancedSummaryConfig build() {
    final count = items.length;
    final total = items.fold<double>(0, (a, e) => a + e.price);
    final avg = count > 0 ? total / count : 0.0;

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

    return EnhancedSummaryConfig(
      label: 'Ortalama',
      mainValue: Formatting.currency(avg, decimal: false),
      icon: Icons.trending_up_rounded,
      accent: AppColors.tertiary,
      detailBuilder: _buildMiniBarChart(days, dayTotals, maxVal, today),
    );
  }

  Widget _buildMiniBarChart(
    List<DateTime> days,
    List<double> dayTotals,
    double maxVal,
    DateTime today,
  ) {
    const dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    // Fixed height container provides the constraint FractionallySizedBox needs
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final val = dayTotals[i];
          final h = maxVal > 0
              ? (val / maxVal).clamp(0.08, 1.0)
              : 0.0;
          final isToday = days[i] == today;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Çubuk
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: h,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isToday
                              ? LinearGradient(
                                  colors: [
                                    AppColors.tertiary.withValues(alpha: 0.9),
                                    AppColors.primary.withValues(alpha: 0.9),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.8),
                                    AppColors.successEmerald.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppShapes.sm),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Gün adı - tek satırda, çubuk tam altına hizalı
                  Text(
                    dayLabels[i],
                    style: AppTypography.labelSubtext.copyWith(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isToday
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
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

/// Geliştirilmiş özet kartı yapılandırması.
class EnhancedSummaryConfig {
  const EnhancedSummaryConfig({
    required this.label,
    required this.mainValue,
    required this.icon,
    required this.accent,
    required this.detailBuilder,
  });

  final String label;
  final String mainValue;
  final IconData icon;
  final Color accent;
  final Widget detailBuilder;
}