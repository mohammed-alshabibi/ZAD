import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'zad_colors.dart';

/// App-wide Material 3 theme. The UI is dark (night sheet) like the Figma screens.
ThemeData buildZadTheme() {
  const z = ZadColors.brand;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // Readex Pro is the body font; screens still style text through ZadType.
    fontFamily: GoogleFonts.readexPro().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: z.frond,
      brightness: Brightness.dark,
      primary: z.sap,
      onPrimary: z.frond,
      surface: z.nightSheet,
      onSurface: z.card,
      error: z.danger,
    ),
    scaffoldBackgroundColor: z.nightSheet,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: z.nightRaised,
      contentTextStyle: GoogleFonts.readexPro(fontSize: 14, color: z.card),
      actionTextColor: z.sap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: z.nightHairline),
      ),
    ),
    extensions: const [z],
  );
}
