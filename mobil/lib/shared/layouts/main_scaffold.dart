import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/bottom_nav_bar.dart';
import '../../core/theme/app_colors.dart';

/// 3 ana sekme (Ana Sayfa, İstatistik, Profil) arasında geçiş yapan ve
/// ortadaki FAB ile Vazgeçiş Ekle bottom sheet'ini açan iskelet.
///
/// go_router StatefulShellRoute ile uyumlu: sekmeler [navigationShell]
/// üzerinden yönetilir.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgSlate50,
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: VazgectimBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        onFab: () => context.pushNamed('add-transaction'),
      ),
    );
  }
}
