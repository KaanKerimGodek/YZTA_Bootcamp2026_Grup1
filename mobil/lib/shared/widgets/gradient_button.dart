import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';

/// Birincil aksiyon butonu — Primary Gradient (135° blue → emerald).
///
/// DESIGN.md → "Buttons: 12px veya 16px radius, gradient background,
/// hafif dikey gölge offseti ile basılabilirlik hissi."
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.isLoading = false,
    this.radius = AppShapes.lg,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool isLoading;
  final double radius;
  final double height;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final inner = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: widget.height,
      decoration: BoxDecoration(
        gradient: enabled ? primaryGradient() : null,
        color: enabled ? null : AppColors.outlineVariant,
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.heroGlow,
                  blurRadius: _pressed ? 6 : 14,
                  offset: Offset(0, _pressed ? 1 : 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.radius),
          onTap: enabled ? widget.onPressed : null,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: AppSpacing.xs + 2),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      width: widget.expanded ? double.infinity : null,
      child: inner,
    );
  }
}
