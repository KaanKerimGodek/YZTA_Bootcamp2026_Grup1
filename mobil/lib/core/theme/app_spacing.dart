/// 8pt grid sistemine dayalı spacing sabitleri (DESIGN.md → spacing bölümü).
///
/// Tüm düzen aralıkları bu sabitlerin katları olmalıdır.
abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4; // 0.5 base
  static const double base = 8; // grid temeli
  static const double sm = 16; // liste öğeleri arası
  static const double md = 24; // orta bölüm aralığı
  static const double lg = 32; // büyük bölüm aralığı (Hero → Activity)
  static const double xl = 48; // sayfa kenarlarından ferahlatma
  static const double screenEdge = 24; // tüm ana ekranlarda yatay marjin
  static const double gutter = 16; // sütunlar arası oluk
}
