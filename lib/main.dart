import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Uygulama bootstrap noktası.
///
/// [.env] dosyasını yükler (bulunamazsa uyarı verip demo modunda devam eder)
/// ve tüm widget ağacını bir [ProviderScope] ile sarar.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
