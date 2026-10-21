import 'package:flutter/material.dart';

/// Mirrors the Figma "ZAD tokens" collection one-to-one (CLAUDE.md §14.1).
/// Widgets read colours only from here: `context.zad.frond`.
@immutable
class ZadColors extends ThemeExtension<ZadColors> {
  const ZadColors({
    required this.frond,
    required this.rib,
    required this.sap,
    required this.paper,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.saffron,
    required this.danger,
    required this.onFrondSubtle,
    required this.onFrondMuted,
    required this.stem,
    required this.nightSheet,
    required this.nightRaised,
    required this.nightHairline,
    required this.nightScrim,
  });

  /// Values from Figma (color/*, color/on-frond/*, color/night/*).
  static const ZadColors brand = ZadColors(
    frond: Color(0xFF123D2C),
    rib: Color(0xFF3C7A57),
    sap: Color(0xFFCFE6C0),
    paper: Color(0xFFEEF2E9),
    card: Color(0xFFFBFCF8),
    ink: Color(0xFF15211B),
    muted: Color(0xFF5B6B61),
    line: Color(0xFFD5DDD0),
    saffron: Color(0xFFE59A2B),
    danger: Color(0xFFF06A5E),
    onFrondSubtle: Color(0x1FCFE6C0), // sap @ 12%
    onFrondMuted: Color(0xCCCFE6C0), // sap @ 80%
    stem: Color(0x733C7A57), // rib @ 45%
    nightSheet: Color(0xFF141A16),
    nightRaised: Color(0xFF1F2722),
    nightHairline: Color(0x1FFBFCF8), // card @ 12%
    nightScrim: Color(0x8C0B0F0D), // @ 55%
  );

  /// Splash "Bottom shade" gradient colour (a raw fill in Figma, not a variable).
  static const Color splashShade = Color(0xFF0B2119);

  /// Map pin drop shadow, black @ 40% (a raw effect in Figma, not a variable).
  static const Color pinShadow = Color(0x66000000);

  /// Text shadow under map pin labels, black @ 80% (a raw effect in Figma).
  static const Color labelShadow = Color(0xCC000000);

  /// Floating map button shadow, black @ 35% (a raw effect in Figma).
  static const Color buttonShadow = Color(0x59000000);

  final Color frond;
  final Color rib;
  final Color sap;
  final Color paper;
  final Color card;
  final Color ink;
  final Color muted;
  final Color line;

  /// Urgency only ("closing soon", under 30 min).
  final Color saffron;

  /// Destructive actions only.
  final Color danger;
  final Color onFrondSubtle;
  final Color onFrondMuted;
  final Color stem;
  final Color nightSheet;
  final Color nightRaised;
  final Color nightHairline;
  final Color nightScrim;

  @override
  ZadColors copyWith({
    Color? frond,
    Color? rib,
    Color? sap,
    Color? paper,
    Color? card,
    Color? ink,
    Color? muted,
    Color? line,
    Color? saffron,
    Color? danger,
    Color? onFrondSubtle,
    Color? onFrondMuted,
    Color? stem,
    Color? nightSheet,
    Color? nightRaised,
    Color? nightHairline,
    Color? nightScrim,
  }) {
    return ZadColors(
      frond: frond ?? this.frond,
      rib: rib ?? this.rib,
      sap: sap ?? this.sap,
      paper: paper ?? this.paper,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      saffron: saffron ?? this.saffron,
      danger: danger ?? this.danger,
      onFrondSubtle: onFrondSubtle ?? this.onFrondSubtle,
      onFrondMuted: onFrondMuted ?? this.onFrondMuted,
      stem: stem ?? this.stem,
      nightSheet: nightSheet ?? this.nightSheet,
      nightRaised: nightRaised ?? this.nightRaised,
      nightHairline: nightHairline ?? this.nightHairline,
      nightScrim: nightScrim ?? this.nightScrim,
    );
  }

  @override
  ZadColors lerp(ZadColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ZadColors(
      frond: l(frond, other.frond),
      rib: l(rib, other.rib),
      sap: l(sap, other.sap),
      paper: l(paper, other.paper),
      card: l(card, other.card),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      saffron: l(saffron, other.saffron),
      danger: l(danger, other.danger),
      onFrondSubtle: l(onFrondSubtle, other.onFrondSubtle),
      onFrondMuted: l(onFrondMuted, other.onFrondMuted),
      stem: l(stem, other.stem),
      nightSheet: l(nightSheet, other.nightSheet),
      nightRaised: l(nightRaised, other.nightRaised),
      nightHairline: l(nightHairline, other.nightHairline),
      nightScrim: l(nightScrim, other.nightScrim),
    );
  }
}

extension ZadColorsContext on BuildContext {
  ZadColors get zad => Theme.of(this).extension<ZadColors>()!;
}
