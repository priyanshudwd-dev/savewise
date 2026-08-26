import 'package:flutter/material.dart';

class C {
  static const green = Color(0xFF10B981);
  static const greenDark = Color(0xFF059669);
  static const greenSoft = Color(0xFFD6F5E7);
  static const amber = Color(0xFFF59E0B);
  static const amberSoft = Color(0xFFFDEBD2);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFFDD8DA);
  static const blue = Color(0xFF3B82F6);
  static const blueSoft = Color(0xFFDBEAFE);
  static const violet = Color(0xFF8B5CF6);
  static const violetSoft = Color(0xFFEDE4FE);
  static const pink = Color(0xFFEC4899);
  static const pinkSoft = Color(0xFFFCE1EF);
  static const teal = Color(0xFF14B8A6);
  static const orange = Color(0xFFF97316);

  static const bgLight = Color(0xFFF3F6FA);
  static const cardLight = Color(0xFFFFFFFF);
  static const textLight = Color(0xFF101828);
  static const subLight = Color(0xFF667085);
  static const lineLight = Color(0xFFE6EBF1);

  static const bgDark = Color(0xFF0B1220);
  static const cardDark = Color(0xFF151F31);
  static const textDark = Color(0xFFF2F5F9);
  static const subDark = Color(0xFF94A3B8);
  static const lineDark = Color(0xFF243247);
}

class AppTheme {
  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness b) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: C.green,
      brightness: b,
    );
    final fg = isDark ? C.textDark : C.textLight;
    final sub = isDark ? C.subDark : C.subLight;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? C.bgDark : C.bgLight,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: fg,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? C.cardDark : C.cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? C.lineDark : C.lineLight,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? C.bgDark : C.bgLight,
        hintStyle: TextStyle(color: sub.withOpacity(.7)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: C.green, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: C.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: isDark ? C.lineDark : C.lineLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: C.green),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? C.cardDark : C.textLight,
        contentTextStyle: TextStyle(
          color: isDark ? C.textDark : Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? C.cardDark : C.cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? C.cardDark : C.cardLight,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? C.green : null,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: fg),
        bodyMedium: TextStyle(color: fg, height: 1.35),
        bodySmall: TextStyle(color: sub, height: 1.35),
        labelLarge: TextStyle(fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
