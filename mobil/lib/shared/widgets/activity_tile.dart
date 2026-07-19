import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../data/models/skipped_item.dart';
import 'category_icon.dart';

/// Recent Activity List'inin tek satırı.
///
/// DESIGN.md → Recent Activity List:
/// - Sol: 48px dairesel ikon (Slate-100 bg)
/// - Orta: başlık + tarih
/// - Sağ: vazgeçilen tutar, Emerald-500, "+" önekli
class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.item, this.onTap});

  final SkippedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppShapes.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm - 2,
        ),
        child: Row(
          children: [
            CategoryIcon(icon: item.icon, color: item.color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.aiCategory,
                          style: AppTypography.labelSubtext.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Flexible(
                        child: Text(
                          Formatting.relativeDay(item.createdAt),
                          style: AppTypography.labelSubtext.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              Formatting.saved(item.price),
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.successEmerald,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
