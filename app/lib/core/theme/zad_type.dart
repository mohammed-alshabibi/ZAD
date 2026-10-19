import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// The three ZAD typefaces (CLAUDE.md §14.1).
/// Display = Bricolage Grotesque, body = Readex Pro, numbers/times = DM Mono.
/// Pass the colour from `context.zad`; never a hex value.
abstract final class ZadType {
  static TextStyle display({
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w600,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// The "zad" logo wordmark: Bricolage Grotesque 96 pt ExtraBold (bundled variable font).
  static TextStyle wordmark({required double size, required Color color}) => TextStyle(
        fontFamily: 'BricolageGrotesqueVariable',
        fontSize: size,
        height: 1,
        letterSpacing: -size * 0.05,
        color: color,
        fontVariations: const [
          FontVariation('opsz', 96),
          FontVariation('wght', 800),
          FontVariation('wdth', 100),
        ],
      );

  static TextStyle body({
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w400,
    double? height,
  }) =>
      GoogleFonts.readexPro(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle mono({
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w500,
    double? letterSpacing,
  }) =>
      GoogleFonts.dmMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}
