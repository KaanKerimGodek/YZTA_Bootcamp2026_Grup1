import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../data/providers/savings_providers.dart';
import '../../shared/widgets/activity_tile.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/hero_wallet_card.dart';
import '../../shared/widgets/insight_card.dart';
import '../../shared/widgets/section_header.dart';

/// Ana Sayfa — Hero Wallet + AI Insight Carousel + Recent Activity.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final itemsAsync = ref.watch(recentItemsProvider);
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.wait([
              ref.read(userProvider.notifier).refresh(),
              ref.read(recentItemsProvider.notifier).refresh(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
              // Header
              SliverToBoxAdapter(child: _Header(userAsync: userAsync)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              // Hero Wallet Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: userAsync.when(
                    data: (user) => HeroWalletCard(totalSaved: user.totalSaved),
                    loading: () => _HeroSkeleton(),
                    error: (e, _) => _HeroSkeleton(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              // AI Insights carousel
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
              // Recent Activity
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: const SectionHeader(
                    title: 'Son Vazgeçişler',
                    actionLabel: 'Tümü',
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
              // Aktivite listesi
              itemsAsync.when(
                data: (items) => items.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.savings_outlined,
                          title: 'Henüz vazgeçiş yok',
                          subtitle:
                              'İlk vazgeçişi ekle, tasarruf cüzdanın büyümeye başlasın.',
                        ),
                      )
                    : SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (context, i) => Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: ActivityTile(item: items[i]),
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text('Liste yüklenemedi: $e',
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
              // Bottom nav alanı için boşluk
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userAsync});
  final AsyncValue userAsync;

  @override
  Widget build(BuildContext context) {
    final name = userAsync.valueOrNull?.displayName;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Günaydın'
        : hour < 18
            ? 'İyi günler'
            : 'İyi akşamlar';
    return Padding(
      padding: Responsive.screenHorizontal(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting 👋',
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name != null ? name : 'Vazgeçtim',
                  style: AppTypography.headlineSection.copyWith(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.xl),
      ),
    );
  }
}

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
            // DESIGN.md → snap-x hizalama
            itemBuilder: (context, i) => InsightCard(insight: insights[i]),
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
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
