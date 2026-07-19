import 'package:flutter/material.dart';

/// DESIGN.md → typography bölümündeki Inter tabanlı metin stilleri.
///
/// Ailesi [AppTheme.light] içinde Inter (google_fonts veya paket fontu) ile
/// ayarlanır; buradaki stiller yalnızca boyut/ağırlık/letterSpacing'i tanımlar.
abstract class AppTypography {
  AppTypography._();

  /// Hero Wallet Card üzerindeki toplam tasarruf tutarı.
  /// Mobile varyantı (36px) tercih edildi — DESIGN.md display-wallet-mobile.
  static const TextStyle displayWallet = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -1.0,
  );

  /// "Recent Activity", "AI Insights" gibi bölüm başlıkları.
  static const TextStyle headlineSection = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
  );

  /// Gövde metni — liste başlıkları, açıklamalar.
  static const TextStyle bodyMain = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22.5 / 15,
  );

  /// Gövde metni — vurgulu (kalın).
  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 22.5 / 15,
  );

  /// Kategori etiketleri, küçük meta veriler — TÜM HARFLER BÜYÜK kullanım için.
  static const TextStyle labelCaps = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.5,
  );

  /// Küçük açıklama / alt metin.
  static const TextStyle labelSubtext = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );
}
