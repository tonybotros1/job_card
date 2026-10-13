import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../web/web_theme.dart';

/// Mobile theme: the same tokens as the web portal ([WebColors]) applied to
/// the phone layout - white app bars, light grey background, white surfaces.
ThemeData buildMobileTheme() {
  final web = buildWebTheme();
  return web.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: WebColors.surface,
      foregroundColor: WebColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: WebColors.text,
      ),
      iconTheme: const IconThemeData(color: WebColors.text),
      shape: const Border(bottom: BorderSide(color: WebColors.border)),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: WebColors.brand,
      thumbColor: WebColors.brand,
      inactiveTrackColor: WebColors.border,
      valueIndicatorColor: WebColors.text,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : WebColors.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? WebColors.green : WebColors.border,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: WebColors.muted,
      textColor: WebColors.text,
    ),
    snackBarTheme: web.snackBarTheme.copyWith(width: null),
  );
}
