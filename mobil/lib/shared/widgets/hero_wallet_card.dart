import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';

/// Ana Sayfadaki Hero Wallet Card.
///
/// DESIGN.md → Hero Wallet Card bölümü:
/// - 135deg Primary Gradient arka plan
/// - "Total Saved" etiketi beyaz %80 opaklıkta, üstte
/// - `display-wallet` para birimi metni saf beyaz
/// - Sağ-alt köşede düşük opaklıkta logo filigranı
/// - Tinted glow shadow `rgba(37,99,235,0.15)`
class HeroWalletCard extends StatelessWidget {
  const HeroWalletCard({
    super.key,
    required this.totalSaved,
    this.label = 'Toplam Tasarruf',
    this.subtitle,
    this.onTap,
  });

  final double totalSaved;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        gradient: primaryGradient(),
        borderRadius: BorderRadius.circular(AppShapes.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.heroGlow,
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // İçerik
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo + etiket
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(AppShapes.md),
                    ),
                    child: const Icon(
                      Icons.savings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: AppTypography.labelCaps.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // display-wallet tutar
              Text(
                Formatting.currency(totalSaved),
                style: AppTypography.displayWallet.copyWith(
                  color: Colors.white,
                  fontSize: 42,
                  height: 1.1,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTypography.labelSubtext.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white.withOpacity(0.85),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Geleceğine yatırım',
                      style: AppTypography.labelSubtext.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          // Sağ-alt logo filigranı
          Positioned(
            right: -8,
            bottom: -12,
            child: Icon(
              Icons.arrow_outward_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
        ],
      ),
    );
  }
}
