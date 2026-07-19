import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Uygulamanın tek teması — **light only** (DESIGN.md kuralı).
///
/// Material 3 `ColorScheme` ve `TextTheme` tokenları DESIGN.md'den gelir.
class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Inter';

  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      scrim: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgSlate50,
      canvasColor: AppColors.bgSlate50,
      fontFamily: _fontFamily,
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgSlate50,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      inputDecorationTheme: _buildInputTheme(colorScheme),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.borderSlate200,
        elevation: 0,
        modalElevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSlate200,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  /// Varsayılan Material TextTheme'i DESIGN.md stilleriyleoverride eder.
  static TextTheme _buildTextTheme() {
    const base = TextStyle(fontFamily: _fontFamily, color: AppColors.textPrimary);
    return TextTheme(
      displayLarge: base.copyWith(fontSize: 36, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -1.0),
      displayMedium: base.copyWith(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5),
      headlineMedium: base.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.4),
      titleLarge: base.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
      titleMedium: base.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: base.copyWith(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: base.copyWith(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33),
      labelLarge: base.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: base.copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: base.copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  static InputDecorationTheme _buildInputTheme(ColorScheme scheme) {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderSlate200, width: 1),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.bodyMain.copyWith(color: AppColors.textSecondary),
      enabledBorder: outline,
      focusedBorder: outline.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      errorBorder: outline.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: outline.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
