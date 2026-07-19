import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/auth_providers.dart';
import '../features/add_transaction/add_transaction_sheet.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/stats/stats_screen.dart';
import '../shared/layouts/main_scaffold.dart';

/// Oturum açma gerekli rotalar (auth gate tarafından korunan).
const _protectedRoutes = {'/home', '/stats', '/insights', '/profile'};

/// Henüz giriş yapmamış kullanıcıların görebileceği rotalar.
const _authRoutes = {'/welcome', '/login', '/register'};

/// Uygulamanın tek router sağlayıcısı.
///
/// [sessionProvider]'ı izler; oturum durumu değiştiğinde provider otomatik
/// yeniden inşa edilir ve yeni [GoRouter] redirect'i baştan değerlendirir.
///
/// StatefulShellRoute ile 4 ana sekme (Ana Sayfa, İstatistik, İçgörüler, Profil)
/// ayrı navigator'lara sahiptir. Vazgeçiş Ekle ekranı modal olarak tüm router
/// üzerine biner. Auth ekranları (Karşılama/Giriş/Kayıt) shell dışındadır ve
/// alt navigasyon çubuğu GÖRÜNMEZ.
final appRouterProvider = Provider<GoRouter>((ref) {
  // session değişince bu provider yeniden inşa edilir → redirect yeniden çalışır.
  final session = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = session != null;
      final goingTo = state.matchedLocation;

      if (!isLoggedIn && _protectedRoutes.contains(goingTo)) {
        return '/welcome';
      }
      if (isLoggedIn && _authRoutes.contains(goingTo)) {
        return '/home';
      }
      return null;
    },
    routes: [
      // --- Auth akışı (bottom nav yok) ---
      GoRoute(
        name: 'welcome',
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // --- Ana uygulama (bottom nav'lı shell) ---
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
