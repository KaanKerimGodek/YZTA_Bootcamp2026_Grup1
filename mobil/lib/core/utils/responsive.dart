import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';

/// Responsive breakpoint'ler ve ekran yardımcıları.
///
/// DESIGN.md → "mobile-first 4 sütun / desktop 12 sütun" kuralı.
class Responsive {
  Responsive._();

  /// Tablet breakpoint'i.
  static const double tablet = 600;

  /// Masaüstü breakpoint'i.
  static const double desktop = 1024;

  /// Ekran genişliğine göre true/false.
  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= tablet && w < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  /// Ana ekranlarda yatay marjin (DESIGN.md → screen-edge 24px).
  static EdgeInsets screenHorizontal(BuildContext context) {
    // Geniş ekranlarda içeriği ortalı ferah tut.
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 64);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 40);
    }
    return const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge);
  }

  /// Alt gezinme / FAB için cihaz güvenli alanı.
  static EdgeInsets safeAreaBottom(BuildContext context) {
    return EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom);
  }
}
