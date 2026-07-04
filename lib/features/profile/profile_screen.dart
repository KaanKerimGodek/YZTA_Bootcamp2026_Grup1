import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/responsive.dart';
import '../../data/providers/savings_providers.dart';
import '../../data/services/api_client.dart';

/// Profil ekranı — kullanıcı bilgileri + ayarlar bölümleri.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final itemsAsync = ref.watch(recentItemsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            // Üst bar
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profil',
                      style: AppTypography.headlineSection.copyWith(fontSize: 24),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: AppColors.textSecondary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Profil kartı
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: userAsync.when(
                  data: (user) => _ProfileCard(
                    name: user.displayName ?? 'Vazgeçtim Üyesi',
                    email: user.email,
                    memberSince: user.createdAt,
                  ),
                  loading: () => const _ProfileCardPlaceholder(),
                  error: (_, __) => const _ProfileCardPlaceholder(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Hızlı istatistikler
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: _QuickStats(
                  userAsync: userAsync,
                  itemsAsync: itemsAsync,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Ayarlar bölümleri
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: const _SectionTitle('Hesap'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: const _SettingsGroup(
                  items: [
                    _SettingsItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Kişisel Bilgiler',
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_none_rounded,
                      label: 'Bildirimler',
                      trailing: _ModeBadge(mode: 'Mock'),
                    ),
                    _SettingsItem(
                      icon: Icons.shield_outlined,
                      label: 'Gizlilik & Güvenlik',
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: const _SectionTitle('Destek'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.screenHorizontal(context),
                child: const _SettingsGroup(
                  items: [
                    _SettingsItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Yardım Merkezi',
                    ),
                    _SettingsItem(
                      icon: Icons.description_outlined,
                      label: 'Kullanım Şartları',
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Hakkında',
                      trailing: _VersionBadge(version: 'v0.1.0'),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    this.email,
    required this.memberSince,
  });
  final String name;
  final String? email;
  final DateTime memberSince;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').map((e) => e.isEmpty ? '' : e[0]).take(2).join();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: primaryGradient(),
        borderRadius: BorderRadius.circular(AppShapes.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.heroGlow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.headlineSection.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    email!,
                    style: AppTypography.labelSubtext.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Üyelik: ${Formatting.date(memberSince)}',
                  style: AppTypography.labelSubtext.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCardPlaceholder extends StatelessWidget {
  const _ProfileCardPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.xl),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.userAsync, required this.itemsAsync});
  final AsyncValue userAsync;
  final AsyncValue itemsAsync;

  @override
  Widget build(BuildContext context) {
    final total = userAsync.valueOrNull?.totalSaved ?? 0;
    final count = itemsAsync.valueOrNull?.length ?? 0;
    final avg = count > 0 ? total / count : 0.0;
    final biggest = itemsAsync.valueOrNull?.fold<double>(
          0,
          (a, e) => e.price > a ? e.price : a,
        ) ??
        0.0;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Toplam',
            value: Formatting.currency(total, decimal: false),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(label: 'Vazgeçiş', value: '$count adet'),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'En Büyük',
            value: Formatting.currency(biggest, decimal: false),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md - 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShapes.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.bodyBold.copyWith(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSubtext.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<Widget> items;

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
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              const Divider(height: 1, indent: 64),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.lg),
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.md),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: AppTypography.bodyMain.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.mode});
  final String mode;
  @override
  Widget build(BuildContext context) {
    final isMock = AppConfig.isMock;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isMock ? AppColors.tertiary : AppColors.successEmerald)
            .withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppShapes.full),
      ),
      child: Text(
        mode,
        style: AppTypography.labelSubtext.copyWith(
          color: isMock ? AppColors.tertiary : AppColors.successEmerald,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge({required this.version});
  final String version;
  @override
  Widget build(BuildContext context) {
    return Text(
      version,
      style: AppTypography.labelSubtext.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}
