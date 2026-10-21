import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';

enum ZadButtonStyle { primary, secondary, ghost }

/// Figma component "Button" (35:661): full-width pill.
/// Primary = white pill + frond label (one per screen) · Secondary = raised dark
/// pill with hairline · Ghost = text action under a primary.
class ZadButton extends StatelessWidget {
  const ZadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = ZadButtonStyle.primary,
    this.height = 56,
    this.labelColor,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ZadButtonStyle style;
  final double height;

  /// Overrides the label colour, e.g. `zad.danger` for a destructive Secondary.
  final Color? labelColor;

  /// Shows a spinner in place of the label and ignores taps (request in flight).
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final (Color? fill, BorderSide border, TextStyle text) = switch (style) {
      ZadButtonStyle.primary => (
          z.card,
          BorderSide.none,
          ZadType.body(size: 16, weight: FontWeight.w600, color: labelColor ?? z.frond),
        ),
      ZadButtonStyle.secondary => (
          z.nightRaised,
          BorderSide(color: z.nightHairline),
          ZadType.body(size: 16, weight: FontWeight.w600, color: labelColor ?? z.card),
        ),
      ZadButtonStyle.ghost => (
          null,
          BorderSide.none,
          ZadType.body(size: 15, weight: FontWeight.w500, color: labelColor ?? z.card),
        ),
    };

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: fill ?? Colors.transparent,
        shape: StadiumBorder(side: border),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            child: Center(
              child: loading
                  ? SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: text.color),
                    )
                  : Text(label, style: text, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}
