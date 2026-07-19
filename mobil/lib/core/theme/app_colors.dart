import 'package:flutter/material.dart';

/// DESIGN.md'deki tüm renk tokenları.
///
/// Uygulama tek bir ışık temalı renk paleti kullanır (No Dark Mode kuralı).
/// Renk değerleri birebir DESIGN.md'den alınmıştır.
abstract class AppColors {
  AppColors._();

  // --- Surfaces ---
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceDim = Color(0xFFD9D9E5);
  static const Color surfaceBright = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3FE);
  static const Color surfaceContainer = Color(0xFFEDEDF9);
  static const Color surfaceContainerHigh = Color(0xFFE7E7F3);
  static const Color surfaceContainerHighest = Color(0xFFE1E2ED);
  static const Color surfaceVariant = Color(0xFFE1E2ED);

  // --- Foreground / Text ---
  static const Color onSurface = Color(0xFF191B23);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color inverseSurface = Color(0xFF2E3039);
  static const Color inverseOnSurface = Color(0xFFF0F0FB);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);

  // --- Tonal / Tint ---
  static const Color surfaceTint = Color(0xFF0053DB);

  // --- Primary (blue) ---
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);
  static const Color inversePrimary = Color(0xFFB4C5FF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);
  static const Color onPrimaryFixedVariant = Color(0xFF003EA8);

  // --- Secondary (green) ---
  static const Color secondary = Color(0xFF006C49);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF6CF8BB);
  static const Color onSecondaryContainer = Color(0xFF00714D);
  static const Color secondaryFixed = Color(0xFF6FFBBE);
  static const Color secondaryFixedDim = Color(0xFF4EDEA3);
  static const Color onSecondaryFixed = Color(0xFF002113);
  static const Color onSecondaryFixedVariant = Color(0xFF005236);

  // --- Tertiary (orange/amber) ---
  static const Color tertiary = Color(0xFF943700);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFBC4800);
  static const Color onTertiaryContainer = Color(0xFFFFEDE6);
  static const Color tertiaryFixed = Color(0xFFFFDBCD);
  static const Color tertiaryFixedDim = Color(0xFFFFB596);
  static const Color onTertiaryFixed = Color(0xFF360F00);
  static const Color onTertiaryFixedVariant = Color(0xFF7D2D00);

  // --- Error ---
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // --- Background ---
  static const Color background = Color(0xFFFAF8FF);
  static const Color onBackground = Color(0xFF191B23);

  // --- Tailwind-derived utilities (DESIGN.md typography/bg section) ---
  static const Color bgSlate50 = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderSlate200 = Color(0xFFE2E8F0);

  /// Semantic "saved/vazgeçilen" miktarı — her zaman bu renk + "+" öneki.
  static const Color successEmerald = Color(0xFF10B981);

  // --- Brand signature gradient (135° blue → emerald) ---
  /// Hero Wallet Card, FAB ve primary action butonlarında kullanılır.
  static const Color gradientStart = Color(0xFF2563EB);
  static const Color gradientEnd = Color(0xFF10B981);

  /// Tinted glow shadow rengi — Hero Card arka planı için.
  static const Color heroGlow = Color(0x262563EB); // rgba(37,99,235,0.15)
}

/// Brand primary gradient'ini (135°, blue → emerald) döndürür.
LinearGradient primaryGradient({AlignmentGeometry begin = Alignment.topLeft, AlignmentGeometry end = Alignment.bottomRight}) {
  return LinearGradient(
    begin: begin,
    end: end,
    // 135° = sol-üst → sağ-alt
    stops: const [0.0, 1.0],
    colors: const [AppColors.gradientStart, AppColors.gradientEnd],
  );
}
