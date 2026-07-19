import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';

/// "Google ile ..." butonu.
///
/// Tasarım sistemi nötrdür: beyaz zemin, ince gri kenarlık, koyu metin.
/// Google logosu marka kuralları gereği **renklendirilemez**; bu yüzden
/// 4 renkli orijinal tonlarıyla [CustomPainter] olarak çizilir (asset gerekmez).
///
/// Şu an fonksiyonel değil; tıklanınca "yakında" snackbar'ı gösterir.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;

  /// Boş bırakılırsa varsayılan "yakında" mesajı gösterilir.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShapes.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppShapes.lg),
          onTap: onPressed ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Google ile giriş yakında 🚧'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppShapes.md),
                    ),
                  ),
                );
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google logosu — orijinal renkleriyle, asset gerektirmez
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(painter: _GoogleLogoPainter()),
                ),
                const SizedBox(width: AppSpacing.xs + 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 4 renkli orijinal Google "G" logosunu çizen painter.
///
/// Sırasıyla: mavi, yeşil, sarı, kırmızı — marka renk kuralları sabittir.
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final stroke = radius * 0.34;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dört renkli yay segmentleri (saat yönünde: mavi → kırmızı → sarı → yeşil)
    // Sıralama orijinal logodaki yerleşimi taklit eder.
    const colors = [
      Color(0xFF4285F4), // mavi (üst)
      Color(0xFFEA4335), // kırmızı (sağ-üst → sağ-alt)
      Color(0xFFFBBC05), // sarı (sol-üst)
      Color(0xFF34A853), // yeşil (alt)
    ];

    // Üst yarı (mavi) — -125°'den +5°'ye
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      _degToRad(-125),
      _degToRad(130),
      false,
      paint..color = colors[0],
    );
    // Sağ taraf (kırmızı) — +5°'den 130°'ye
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      _degToRad(5),
      _degToRad(125),
      false,
      paint..color = colors[1],
    );
    // Sol-üst (sarı) — 235°'den -125°'ye
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      _degToRad(235),
      _degToRad(100),
      false,
      paint..color = colors[2],
    );
    // Alt (yeşil) — 130°'den 235°'ye
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      _degToRad(130),
      _degToRad(105),
      false,
      paint..color = colors[3],
    );
  }

  double _degToRad(double deg) => deg * 3.141592653589793 / 180.0;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
