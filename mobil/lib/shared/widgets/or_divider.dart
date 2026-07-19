import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// İki buton arasında "VEYA" ayıracı.
///
/// İki yatay çizgi ortada bir etiketle birleşir. Auth ekranlarında birincil
/// aksiyon ile sosyal giriş arasında görsel ayrım için kullanılır.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'VEYA'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.borderSlate200, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label,
            style: AppTypography.labelSubtext.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.borderSlate200, thickness: 1),
        ),
      ],
    );
  }
}
