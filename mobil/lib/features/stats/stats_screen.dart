import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/skipped_item.dart';
import '../../data/providers/savings_providers.dart';
import '../../data/services/api_client.dart';
import '../../shared/widgets/activity_tile.dart';
import '../../shared/widgets/category_icon.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/enhanced_summary_cards.dart';
import '../../shared/widgets/section_header.dart';

/// İstatistik ekranı — geliştirilmiş özet kartlar + kategori breakdown + dönem özeti.
///
/// Gelişmiş özet kartları:
/// - Toplam kart: En yüksek 3 vazgeçiş
/// - Vazgeçiş kartı: En çok vazgeçilen 3 kategori + adet
/// - Ortalama kart: Son 7 gün dikey mini Bar Chart
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(recentItemsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: itemsAsync.when(
          data: (items) => items.isEmpty
              ? const EmptyState(
                  icon: Icons.insights_outlined,
                  title: 'Henüz veri yok',
                  subtitle:
                      'Birkaç vazgeçiş ekledikten sonra burada analizini göreceksin.',
                )
              : CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.sm),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Responsive.screenHorizontal(context),
                        child: Text(
                          'İstatistikler',
                          style: AppTypography.headlineSection.copyWith(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.md),
                    ),
                    // Geliştirilmiş özet kartları
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Responsive.screenHorizontal(context),
                        child: _EnhancedSummaryRow(items: items),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.lg),
                    ),
                    // Kategori breakdown
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Responsive.screenHorizontal(context),
                        child: const SectionHeader(title: 'Kategoriye Göre'),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.sm),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Responsive.screenHorizontal(context),
                        child: _CategoryBreakdown(items: items),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.lg),
                    ),
                    // Haftalık aktivite (güncel grafik)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Responsive.screenHorizontal(context),
                        child: const SectionHeader(title: 'Son 7 Gün'),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.sm),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Responsive.screenHorizontal(context),
                        child: _WeeklyBars(items: items),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.lg),
                    ),
                    // Geçmiş Harcamalar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Responsive.screenHorizontal(context),
                        child: const SectionHeader(title: 'Geçmiş Harcamalar'),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.sm),
                    ),
                    SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: ActivityTile(item: items[i]),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 120),
                    ),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Veri yüklenemedi',
            subtitle: AppConfig.isMock ? null : 'Backend bağlantısını kontrol et.',
          ),
        ),
      ),
    );
  }
}

/// Geliştirilmiş özet kartları: 3 kart alt alta (dikey düzen).
class _EnhancedSummaryRow extends StatelessWidget {
  const _EnhancedSummaryRow({required this.items});
  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EnhancedSummaryCard(config: TotalSummaryConfig(items).build()),
        const SizedBox(height: AppSpacing.md),
        EnhancedSummaryCard(config: CountSummaryConfig(items).build()),
        const SizedBox(height: AppSpacing.md),
        EnhancedSummaryCard(config: AverageSummaryConfig(items).build()),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.items});
  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    // Kategori → toplam
    final totals = <String, double>{};
    for (final i in items) {
      totals[i.aiCategory] = (totals[i.aiCategory] ?? 0) + i.price;
    }
    final grandTotal = totals.values.fold<double>(0, (a, e) => a + e);
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
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
      ),
      child: Column(
        children: sorted.map((e) {
          final pct = grandTotal > 0 ? e.value / grandTotal : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _CategoryBar(
              category: e.key,
              amount: e.value,
              percent: pct,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.percent,
  });
  final String category;
  final double amount;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final color = CategoryMeta.colorFor(category);
    return Row(
      children: [
        CategoryIcon(
          icon: CategoryMeta.iconFor(category),
          color: color,
          size: 36,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category,
                    style: AppTypography.bodyBold.copyWith(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    Formatting.currency(amount, decimal: false),
                    style: AppTypography.bodyBold.copyWith(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppShapes.full),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.items});
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

    return Container(
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
      ),
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final val = dayTotals[i];
            final h = maxVal > 0 ? (val / maxVal).clamp(0.05, 1.0) : 0.0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: h,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.7),
                                AppColors.successEmerald.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppShapes.sm),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'][days[i].weekday - 1],
                      style: AppTypography.labelSubtext.copyWith(
                        color: days[i] == today
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: days[i] == today
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}