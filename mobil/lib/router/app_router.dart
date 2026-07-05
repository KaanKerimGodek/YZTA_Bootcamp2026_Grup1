import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/add_transaction/add_transaction_sheet.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/stats/stats_screen.dart';
import '../shared/layouts/main_scaffold.dart';

/// Uygulamanın tek router sağlayıcısı.
///
/// StatefulShellRoute ile 4 ana sekme (Ana Sayfa, İstatistik, İçgörüler, Profil) ayrı
/// navigator'lara sahiptir; her sekme kendi yığınını korur. Vazgeçiş Ekle
/// ekranı modal olarak tüm router üzerine biner.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'home',
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'stats',
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'insights',
                path: '/insights',
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'profile',
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Vazgeçiş Ekle — modal bottom sheet route.
      GoRoute(
        name: 'add-transaction',
        path: '/add-transaction',
        pageBuilder: (context, state) {
          return ModalBottomSheetPage(
            child: const AddTransactionSheet(),
          );
        },
      ),
    ],
  );
});

/// Modal bottom sheet olarak render edilen bir [Page].
class ModalBottomSheetPage<T> extends Page<T> {
  const ModalBottomSheetPage({required this.child, super.key});
  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      isScrollControlled: true,
      useSafeArea: true,
      barrierLabel: 'Vazgeçiş Ekle',
      builder: (context) => child,
    ) as Route<T>;
  }
}
