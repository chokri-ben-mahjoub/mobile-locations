import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Couleur d'accent de la marque LocaTrack (bleu-teal immobilier).
const accentColor = Color(0xFF1F6F78);

/// Or discret pour les accents « premium » (alertes douces, étincelles).
const goldColor = Color(0xFFE9B44C);

/// Couleurs de statut : payé / actif et à surveiller.
const okColor = Color(0xFF2EAD6B);
const warnColor = Color(0xFFF08A24);

class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: brightness,
    );
    // Fonds plus profonds (sombre) / plus lumineux (clair) pour un rendu premium.
    final colorScheme = dark
        ? base.copyWith(
            surface: const Color(0xFF0B1214),
            surfaceContainerLow: const Color(0xFF121C1F),
            surfaceContainer: const Color(0xFF162225),
            surfaceContainerHigh: const Color(0xFF1B2A2E),
            surfaceContainerHighest: const Color(0xFF223338),
          )
        : base.copyWith(
            surface: const Color(0xFFF5F8F8),
            surfaceContainerLow: Colors.white,
            surfaceContainer: const Color(0xFFEEF3F3),
            surfaceContainerHigh: const Color(0xFFE8EFEF),
            surfaceContainerHighest: const Color(0xFFDDE7E7),
          );

    // `Inter` ne couvre pas les glyphes arabes : sans repli explicite, un nom
    // de locataire ou un libellé en arabe s'affiche en carrés vides ("tofu"),
    // surtout sur le web (CanvasKit n'a pas le même repli automatique vers
    // une police système que les plateformes natives).
    const fontFamilyFallback = ['NotoNaskhArabic'];

    final textTheme =
        (dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme).apply(
          fontFamily: 'Inter',
          fontFamilyFallback: fontFamilyFallback,
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    final transitions = PageTransitionsTheme(
      builders: {
        for (final p in TargetPlatform.values)
          p: p == TargetPlatform.iOS || p == TargetPlatform.macOS
              ? const CupertinoPageTransitionsBuilder()
              : const FadeForwardsPageTransitionsBuilder(),
      },
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: fontFamilyFallback,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: transitions,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: 'Inter', fontFamilyFallback: fontFamilyFallback,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.primary,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        labelStyle: TextStyle(fontFamily: 'Inter', fontFamilyFallback: fontFamilyFallback,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        highlightElevation: 8,
        extendedTextStyle: TextStyle(fontFamily: 'Inter', fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: TextStyle(fontFamily: 'Inter', fontFamilyFallback: fontFamilyFallback,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colorScheme.surfaceContainerLow,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark
            ? const Color(0xFFE6EEEE)
            : const Color(0xFF14262A),
        contentTextStyle: TextStyle(fontFamily: 'Inter', fontFamilyFallback: fontFamilyFallback,
          color: dark ? const Color(0xFF0B1214) : Colors.white,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: dark ? accentColor : const Color(0xFF7CF5E4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.25),
        space: 1,
      ),
    );
  }
}
