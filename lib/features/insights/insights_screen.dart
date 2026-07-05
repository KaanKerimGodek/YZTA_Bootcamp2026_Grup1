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
import '../../shared/widgets/insight_card.dart';
import '../../shared/widgets/section_header.dart';

/// İçgörüler ekranı — AI İçgörüleri + Davranışsal Gelişim + Tasarruf Kalıpları + Aylık Trend.
///
/// Tüm analizler `recentItemsProvider` ve `insightsProvider` verisinden
/// istemci tarafında hesaplanır; ayrı bir endpoint gerekmez.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(recentItemsProvider);
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // Sayfa başlığı
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: Text(
                  'İçgörüler',
                  style: AppTypography.headlineSection.copyWith(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // AI İçgörüler Carousel
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: const SectionHeader(title: 'AI İçgörüler'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            SliverToBoxAdapter(
              child: _InsightCarousel(insightsAsync: insightsAsync),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Davranışsal Gelişim + Tasarruf Kalıpları yan yana
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SectionHeaderSmall(title: 'Davranışsal Gelişim'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SectionHeaderSmall(title: 'Tasarruf Kalıpları'),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            itemsAsync.when(
              data: (items) => SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _BehaviorCard(items: items),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _PatternCard(items: items),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: _CardSkeleton(),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Aylık Trend
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: const _SectionHeaderSmall(title: 'Aylık Trend'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            itemsAsync.when(
              data: (items) => SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: _MonthlyTrendCard(items: items),
                ),
              ),
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: _CardSkeleton(),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Yardımcı: Küçük bölüm başlığı (yan yana kartlar için)
// ---------------------------------------------------------------------------
class _SectionHeaderSmall extends StatelessWidget {
  const _SectionHeaderSmall({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Yardımcı: Yatay İçgörü Carousel'i
// ---------------------------------------------------------------------------
class _InsightCarousel extends StatelessWidget {
  const _InsightCarousel({required this.insightsAsync});
  final AsyncValue insightsAsync;

  @override
  Widget build(BuildContext context) {
    return insightsAsync.when(
      data: (insights) {
        if (insights.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: Responsive.screenHorizontal(context),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, i) => InsightCard(insight: insights[i]),
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.sm),
            itemCount: insights.length,
          ),
        );
      },
      loading: () => const SizedBox(
        height: 168,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ---------------------------------------------------------------------------
// Davranışsal Gelişim Kartı
// ---------------------------------------------------------------------------
class _BehaviorCard extends StatelessWidget {
  const _BehaviorCard({required this.items});
  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Bu hafta: Pazartesi'den bugüne
    final weekday = now.weekday; // 1=Pazartesi, 7=Pazar
    final thisMonday = today.subtract(Duration(days: weekday - 1));
    final lastMonday = thisMonday.subtract(const Duration(days: 7));

    int thisWeekCount = 0;
    double thisWeekTotal = 0;
    int lastWeekCount = 0;

    for (final item in items) {
      final d = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      if (!d.isBefore(thisMonday)) {
        thisWeekCount++;
        thisWeekTotal += item.price;
      } else if (!d.isBefore(lastMonday) && d.isBefore(thisMonday)) {
        lastWeekCount++;
      }
    }

    // Yüzdelik değişim
    final countDiff = lastWeekCount > 0
        ? (thisWeekCount - lastWeekCount) / lastWeekCount
        : (thisWeekCount > 0 ? 1.0 : 0.0);
    final isUp = countDiff >= 0;

    return _InsightPanel(
      icon: isUp
          ? Icons.trending_up_rounded
          : Icons.trending_down_rounded,
      iconColor: isUp
          ? AppColors.successEmerald
          : AppColors.tertiary,
      summary: isUp
          ? '${Formatting.percent(countDiff)} daha başarılı'
          : (countDiff == 0
              ? 'Geçen haftayla aynı'
              : '${Formatting.percent(countDiff)} daha az'),
      detail: thisWeekCount == 0
          ? 'Bu hafta henüz vazgeçiş yok'
          : 'Bu hafta $thisWeekCount vazgeçiş • ${Formatting.currency(thisWeekTotal, decimal: false)} tasarruf',
    );
  }
}

// ---------------------------------------------------------------------------
// Tasarruf Kalıpları Kartı
// ---------------------------------------------------------------------------
class _PatternCard extends StatelessWidget {
  const _PatternCard({required this.items});
  final List<SkippedItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _InsightPanel(
        icon: Icons.auto_awesome_rounded,
        iconColor: AppColors.primary,
        summary: 'Yeterli veri yok',
        detail: 'Vazgeçiş ekledikçe burada kalıplarını göreceksin.',
      );
    }

    // Saat bazlı gruplama → en çok hangi saat diliminde vazgeçilmiş
    final hourGroups = <String, int>{};
    for (final item in items) {
      final h = item.createdAt.hour;
      final slot = _hourSlot(h);
      hourGroups[slot] = (hourGroups[slot] ?? 0) + 1;
    }
    final topHour = hourGroups.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSlot = topHour.first.key;

    // En sık vazgeçilen kategori
    final catCounts = <String, int>{};
    for (final item in items) {
      catCounts[item.aiCategory] = (catCounts[item.aiCategory] ?? 0) + 1;
    }
    final topCat = catCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = topCat.first.key;

    return _InsightPanel(
      icon: Icons.schedule_rounded,
      iconColor: AppColors.primary,
      summary: topSlot,
      detail: 'En çok $topCategory kategorisinde vazgeçtin',
    );
  }

  static String _hourSlot(int hour) {
    if (hour >= 6 && hour < 12) return 'Sabah 06–12';
    if (hour >= 12 && hour < 18) return 'Öğleden sonra 12–18';
    if (hour >= 18 && hour < 22) return 'Akşam 18–22';
    return 'Gece 22–06';
  }
}

// ---------------------------------------------------------------------------
// Aylık Trend Kartı
// ---------------------------------------------------------------------------
class _MonthlyTrendCard extends StatelessWidget {
  const _MonthlyTrendCard({required this.items});
  final List<SkippedItem> items;

  /// Bu ay için sabit hedef — ileride AppUser.monthlyGoal ile değiştirilebilir.
  static const double _monthlyGoal = 5000;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    double monthTotal = 0;
    int monthCount = 0;
    for (final item in items) {
      if (!item.createdAt.isBefore(thisMonth)) {
        monthTotal += item.price;
        monthCount++;
      }
    }

    final progress = (monthTotal / _monthlyGoal).clamp(0.0, 1.0);
    final progressPct = (progress * 100).round();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst: ikon + yüzde
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.successEmerald.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppShapes.md),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: AppColors.successEmerald,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aylık Hedefine Yakınlık',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bu ay düzenli vazgeçme eylemlerin sayesinde hedefine %$progressPct daha yaklaşıyorsun.',
                      style: AppTypography.labelSubtext.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppShapes.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(AppColors.successEmerald),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Alt: tutar / hedef
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Formatting.currency(monthTotal, decimal: false)} tasarruf',
                style: AppTypography.labelSubtext.copyWith(
                  color: AppColors.successEmerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${Formatting.currency(_monthlyGoal, decimal: false)} hedef',
                style: AppTypography.labelSubtext.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Ek bilgi: bu ay kaç vazgeçiş
          Text(
            'Bu ay toplam $monthCount vazgeçiş kaydettin',
            style: AppTypography.labelSubtext.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ortak洞察 panel kartı (davranışsal gelişim + tasarruf kalıpları için)
// ---------------------------------------------------------------------------
class _InsightPanel extends StatelessWidget {
  const _InsightPanel({
    required this.icon,
    required this.iconColor,
    required this.summary,
    required this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final String summary;
  final String detail;

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary,
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: AppTypography.labelSubtext.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton placeholder
// ---------------------------------------------------------------------------
class _CardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.xl),
      ),
    );
  }
}
