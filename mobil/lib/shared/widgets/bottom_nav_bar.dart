import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';

/// Alt navigasyon — Ana Sayfa · İstatistik · [FAB] · İçgörüler · Profil.
///
/// DESIGN.md → Floating Action Button (FAB):
/// - Bottom nav'ın ortasında, negatif margin ile yukarı taşmış
/// - Dairesel, Primary Gradient, beyaz "+" ikonu
/// - Derin brand gölgeli
class VazgectimBottomNav extends StatelessWidget {
  const VazgectimBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFab,
  });

  /// 0 = Ana Sayfa, 1 = İstatistik, 2 = İçgörüler, 3 = Profil.
  /// (FAB'a tıklamak [onFab] çağırır, index dışı.)
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFab;

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Ana Sayfa'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'İstatistik'),
    _NavItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome_rounded, label: 'İçgörüler'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Nav arka planı
          Container(
            margin: EdgeInsets.only(bottom: bottomInset),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppShapes.xl),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs + 2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTab(0, _items[0]),
                    ),
                    Expanded(
                      child: _buildTab(1, _items[1]),
                    ),
                    // FAB için boşluk
                    const SizedBox(width: 64),
                    Expanded(
                      child: _buildTab(2, _items[2]),
                    ),
                    Expanded(
                      child: _buildTab(3, _items[3]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // FAB — ortada, yukarı taşmış
          Positioned(
            top: 0,
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: _Fab(onPressed: onFab),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, _NavItem item) {
    final active = index == currentIndex;
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(AppShapes.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? item.activeIcon : item.icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _Fab extends StatelessWidget {
  const _Fab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: primaryGradient(),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: AppColors.heroGlow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
