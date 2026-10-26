import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

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
    this.fullWidth = true,
    this.icon,
    this.iconSize = 18,
    this.labelSize,
    this.sidePadding,
  });

  /// Overrides the space on each side of the label (24 full width, else 20).
  final double? sidePadding;

  /// Icon before the label, tinted like it (Figma "Show pickup code").
  final ZadIcons? icon;
  final double iconSize;

  /// Overrides the label size for smaller pills (Figma: 15 or 14 on 50 px).
  final double? labelSize;

  /// False = as wide as the label (with 20 px sides), for a pill that shares a
  /// row with other content, like the Meal details reserve bar.
  final bool fullWidth;

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
    final (Color? fill, BorderSide border, TextStyle baseText) = switch (style) {
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

    final text = labelSize == null ? baseText : baseText.copyWith(fontSize: labelSize);
    final labelText = Text(label, style: text, maxLines: 1, overflow: TextOverflow.ellipsis);
    // With an icon, a tight pill shrinks the label a little instead of
    // cutting it ("Show pickup co…" on narrow phones).
    final content = icon == null
        ? labelText
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZadIcon(icon!, size: iconSize, color: text.color),
                const SizedBox(width: 8),
                Text(label, style: text, maxLines: 1),
              ],
            ),
          );

    // No action (and not loading) = disabled: dimmed, like the Figma states.
    final disabled = onPressed == null && !loading;
    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: Opacity(
        opacity: disabled ? 0.45 : 1,
        child: Material(
          color: fill ?? Colors.transparent,
          shape: StadiumBorder(side: border),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: loading ? null : onPressed,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: sidePadding ?? (fullWidth ? 24 : 20)),
              child: Align(
                widthFactor: fullWidth ? null : 1,
                child: loading
                    ? SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: text.color),
                      )
                    : content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
