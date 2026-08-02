import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/secondary_button.dart';

/// Ekran 1 — Karşılama / Giriş Seçimi.
///
/// Ortada marka logosu, altında slogan, iki buton (Giriş Yap / Kayıt Ol).
/// Bottom nav bu ekranda GÖRÜNMEZ (StatefulShellRoute dışında).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSlate50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Marka logosu — oran korunmuş
                        Image.asset(
                          'assets/images/logo.png',
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Vazgeçtiklerin birikime dönüşsün',
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineSection.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Vazgeçtiğin harcamaları kaydet, geleceğine yatırım olsun.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMain.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Alt butonlar
              GradientButton(
                label: 'Giriş Yap',
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: 'Kayıt Ol',
                onPressed: () => context.go('/register'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
