import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour tokens for the web portal. Mobile screens keep using `const.dart`.
class WebColors {
  static const brand = Color(0xFFEA2027);
  static const brandDark = Color(0xFFC4151B);
  static const brandTint = Color(0xFFFDECEC);

  static const bg = Color(0xFFF5F6F8);
  static const surface = Colors.white;
  static const border = Color(0xFFE6E8EC);
  static const hover = Color(0xFFF9FAFB);

  static const text = Color(0xFF141A24);
  static const muted = Color(0xFF6B7280);
  static const subtle = Color(0xFF9AA3AF);

  static const green = Color(0xFF16A34A);
  static const greenTint = Color(0xFFE7F6EC);
  static const blue = Color(0xFF2563EB);
  static const blueTint = Color(0xFFE8EFFF);
  static const amber = Color(0xFFD97706);
  static const amberTint = Color(0xFFFEF3E2);
}

class WebSpace {
  static const page = 24.0;
  static const gap = 16.0;
  static const radius = 12.0;
  static const contentMaxWidth = 1440.0;
}

/// Breakpoints shared by the shell and the pages.
class WebBreakpoints {
  /// Side navigation shown expanded with labels.
  static const wide = 1100.0;

  /// Side navigation shown as an icon rail; below this it becomes a drawer.
  static const medium = 760.0;
}

ThemeData buildWebTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: WebColors.brand,
    scaffoldBackgroundColor: WebColors.bg,
  );
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: WebColors.text,
    displayColor: WebColors.text,
  );
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  return base.copyWith(
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      primary: WebColors.brand,
      onPrimary: Colors.white,
      surface: WebColors.surface,
      onSurface: WebColors.text,
      outline: WebColors.border,
    ),
    dividerColor: WebColors.border,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: WebColors.surface,
      foregroundColor: WebColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: WebColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WebSpace.radius),
        side: const BorderSide(color: WebColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WebColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: WebColors.subtle),
      labelStyle: const TextStyle(color: WebColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: WebColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: WebColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: WebColors.brand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: WebColors.brand),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WebColors.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: WebColors.brand.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        shape: rounded,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: WebColors.text,
        side: const BorderSide(color: WebColors.border),
        shape: rounded,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: WebColors.brand,
        shape: rounded,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: WebColors.muted),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: WebColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: WebColors.text,
      ),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: WebColors.muted),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: WebColors.text,
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      shape: rounded,
      width: 420,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: WebColors.surface,
      shape: RoundedRectangleBorder(),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: WebColors.text,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
    ),
  );
}
