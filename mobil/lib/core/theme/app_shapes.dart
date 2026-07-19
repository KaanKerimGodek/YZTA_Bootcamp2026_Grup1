import 'package:flutter/widgets.dart';

/// DESIGN.md → rounded bölümündeki köşe yarıçapları.
abstract class AppShapes {
  AppShapes._();

  static const double sm = 4; // 0.25rem
  static const double def = 8; // DEFAULT 0.5rem
  static const double md = 12; // 0.75rem — butonlar
  static const double lg = 16; // 1rem — butonlar / ikon kutuları
  static const double xl = 24; // 1.5rem — kartlar & modallar
  static const double sheetTop = 32; // bottom sheet üst köşesi
  static const double full = 9999; // pill/chip — büyük değer verir

  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusDef = Radius.circular(def);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);

  static const BorderRadius borderSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderDef = BorderRadius.all(radiusDef);
  static const BorderRadius borderMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);

  /// Bottom sheet üst köşeleri için (32px).
  static const BorderRadius borderSheetTop = BorderRadius.vertical(
    top: Radius.circular(sheetTop),
  );

  /// Pill / chip — tam yuvarlak.
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(9999));
}
