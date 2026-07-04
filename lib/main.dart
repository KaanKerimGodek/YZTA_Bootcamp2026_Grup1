import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

/// Uygulama bootstrap noktası.
///
/// [.env] dosyasını yükler (bulunamazsa uyarı verip demo modunda devam eder)
/// ve tüm widget ağacını bir [ProviderScope] ile sarar.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih/saat formatlaması için locale başlatma.
  await initializeDateFormatting('tr_TR', null);

  // .env opsiyonel — yoksa mock modunda çalışmaya devam et.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env yoksa demo/varsayılan değerlerle devam edilir.
    debugPrint('[main] .env bulunamadı — APP_MODE=mock ile devam ediliyor.');
  }

  runApp(
    const ProviderScope(
      child: VazgectimApp(),
    ),
  );
}
