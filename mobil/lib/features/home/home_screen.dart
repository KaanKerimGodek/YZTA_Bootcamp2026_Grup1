import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/app_user.dart';
import '../../data/models/auth_session.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/savings_providers.dart';
import '../../shared/widgets/activity_tile.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/goal_status_card.dart';
import '../../shared/widgets/hero_wallet_card.dart';
import '../../shared/widgets/insight_card.dart';
import '../../shared/widgets/motivation_quote_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/weekly_achievement_badge.dart';

/// Ana Sayfa — Hero Wallet + Hedef Durumu + AI Insight Carousel + Günün Motivasyonu + Recent Activity.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final itemsAsync = ref.watch(recentItemsProvider);
    final insightsAsync = ref.watch(insightsProvider);
    final session = ref.watch(sessionProvider);

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
              SliverToBoxAdapter(child: _Header(user: user, session: session)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              // Hero Wallet Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: _HeroWallet(user: user),
                ),
              ),
              // Weekly Achievement Badge (Hero Card altı)
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: itemsAsync.when(
                    data: (items) => WeeklyAchievementBadge(items: items),
                    loading: () => const WeeklyAchievementBadgeSkeleton(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              // Hedef Durumu Kartı - Dinamik
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: _GoalCard(user: user),
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
              // Günün Motivasyonu
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: const MotivationQuoteCard(
                    quote: '', // Boş bırakılırsa günün sözü otomatik seçilir
                    author: '',
                  ),
                ),
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
                              const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
  const _Header({required this.user, this.session});
  final AppUser? user;
  final AuthSession? session;

  @override
  Widget build(BuildContext context) {
    // Öncelik: auth session'daki isim → userProvider'daki isim → varsayılan
    final name = session?.displayName ??
        user?.displayName ??
        'Vazgeçtim';
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
                  name,
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

class _HeroWallet extends StatelessWidget {
  const _HeroWallet({required this.user});
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) return _HeroSkeleton();
    final u = user!;
    return HeroWalletCard(totalSaved: u.totalSaved);
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

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.user});
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const GoalStatusCardSkeleton();
    final u = user!;

    final hasGoal = u.goalTitle != null && u.goalTitle!.isNotEmpty;
    final goalName = hasGoal ? u.goalTitle! : 'Hedef belirlemek için tıklayın';
    final targetAmount = u.savingsGoal ?? 10000;
    final currentAmount = u.totalSaved;
    final isCompleted = u.isGoalCompleted;

    return Column(
      children: [
        GoalStatusCard(
          goalName: goalName,
          currentAmount: currentAmount,
          targetAmount: targetAmount,
          icon: Icons.flag_rounded,
          iconColor: AppColors.successEmerald,
          onTap: () => context.push('/goal-settings'),
        ),
        if (isCompleted) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.successEmerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppShapes.lg),
              border: Border.all(
                color: AppColors.successEmerald.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.celebration_rounded,
                  color: AppColors.successEmerald,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '🎉 Tebrikler! Hedefinize ulaştınız!',
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.successEmerald,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _InsightCarousel extends StatelessWidget {
  const _InsightCarousel({required this.insightsAsync});
  final AsyncValue<List<dynamic>> insightsAsync;

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