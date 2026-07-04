import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Para birimi, tarih ve sayı formatlama yardımcıları.
///
/// Tüm uygulamada tutarlı gösterim için bu fonksiyonlar kullanılır.
class Formatting {
  Formatting._();

  static final NumberFormat _currencyFmt = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _intCurrencyFmt = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final DateFormat _dateFmt = DateFormat('d MMM yyyy', 'tr_TR');
  static final DateFormat _timeFmt = DateFormat('HH:mm', 'tr_TR');
  static final DateFormat _shortDateFmt = DateFormat('d MMM', 'tr_TR');

  /// `120.5` → `₺120,50`
  static String currency(num value, {bool decimal = true}) {
    return decimal ? _currencyFmt.format(value) : _intCurrencyFmt.format(value);
  }

  /// "Vazgeçilen" miktarlar için önekiyle: `+₺120,50`
  /// Renk çağırıcıda Emerald-500 olarak ayarlanır.
  static String saved(num value) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign${_currencyFmt.format(value.abs())}';
  }

  /// `2026-07-04` → `4 Tem 2026`
  static String date(DateTime value) => _dateFmt.format(value);

  /// `4 Tem` gibi kısa tarih.
  static String shortDate(DateTime value) => _shortDateFmt.format(value);

  /// `14:30` saat formatı.
  static String time(DateTime value) => _timeFmt.format(value);

  /// "Bugün", "Dün" veya kısa tarih — aktivite listesinde kullanılır.
  static String relativeDay(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(value.year, value.month, value.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Bugün';
    if (diff == 1) return 'Dün';
    if (diff < 7) return '$diff gün önce';
    return shortDate(value);
  }
}
