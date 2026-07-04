import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';

/// Aktivite listesindeki ikon kutusu.
///
/// DESIGN.md → "Icon Enclosures: 48x48px circular veya 12px rounded square."
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.size = 48,
    this.iconColor,
    this.shape = CategoryIconShape.circle,
  });

  /// Bir [SkippedItem] için kolay factory.
  factory CategoryIcon.forIcon(
    IconData icon, {
    Color color = AppColors.primary,
    Color? iconColor,
  }) {
    return CategoryIcon(icon: icon, color: color, iconColor: iconColor);
  }

  final IconData icon;
  final Color color;
  final double size;
  final Color? iconColor;
  final CategoryIconShape shape;

  @override
  Widget build(BuildContext context) {
    // Renk %12 opaklıkta tonal arka plan, ikon doygun renk.
    final bg = color.withOpacity(0.12);
    final fg = iconColor ?? color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: shape == CategoryIconShape.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape == CategoryIconShape.roundedSquare
            ? BorderRadius.circular(AppShapes.md)
            : null,
      ),
      child: Icon(icon, color: fg, size: size * 0.5),
    );
  }
}

enum CategoryIconShape { circle, roundedSquare }
