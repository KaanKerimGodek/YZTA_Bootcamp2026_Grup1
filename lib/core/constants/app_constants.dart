/// Uygulama genelinde sabitler.
abstract class AppConstants {
  AppConstants._();

  /// Uygulama adı.
  static const String appName = 'Vazgeçtim';

  /// Para birimi sembolü (Türk Lirası).
  static const String currencySymbol = '₺';

  /// Para birimi ISO kodu.
  static const String currencyCode = 'TRY';

  /// Kullanıcının yerel saati — Backend Steering "Zaman Damgaları" kuralı:
  /// sunucu saati yerine frontend'in yerel timestamp'i payload'da taşınır.
  ///
  /// LLM kategorizasyonu için kullanılan sabit kategori seti
  /// (n8n Workflow 1 prompt'u ile aynı sıra).
  static const List<String> knownCategories = [
    'Yemek',
    'İçecek',
    'Giyim',
    'Eğlence',
    'Ulaşım',
    'Teknoloji',
    'Kişisel Bakım',
    'Diğer',
  ];

  /// LLM başarısız olduğunda fallback olarak yazılan kategori
  /// (Backend Steering → Hata Yönetimi).
  static const String fallbackCategory = 'Diğer';
}
