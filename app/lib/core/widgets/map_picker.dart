import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';
import 'zad_map_pin.dart';

// Pieces of a "move the map under a fixed pin" screen, shared by the
// restaurant's Pickup location (Figma 38:873) and the user's Set my area.

/// Fixed centre pin with its ground shadow and the "Move the map…" hint.
/// The point being chosen is the bottom of the pin's disc, at the exact
/// centre of the map.
class MapCentrePin extends StatelessWidget {
  const MapCentrePin({super.key, this.label, required this.hint});

  /// Name under the pin; null shows the pin alone.
  final String? label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    const disc = ZadSelectedMapPin.disc;
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) {
          final cx = box.maxWidth / 2;
          final cy = box.maxHeight / 2;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Figma: hint pill 54 px above the disc.
              Positioned(
                left: 16,
                right: 16,
                top: cy - disc - 54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: z.nightRaised,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: z.nightHairline),
                    ),
                    child: Text(hint, textAlign: TextAlign.center, style: ZadType.body(size: 13, color: z.card)),
                  ),
                ),
              ),
              Positioned(
                left: cx - 13,
                top: cy - 4,
                child: SvgPicture.asset('assets/onboarding/pin_shadow.svg', width: 26, height: 8),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: cy - disc,
                child: Center(child: ZadSelectedMapPin(label: label)),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shown instead of the map on the web preview, in tests, or without a token.
class MapFallback extends StatelessWidget {
  const MapFallback({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return ColoredBox(
      color: z.nightRaised,
      child: Align(
        alignment: const Alignment(0, 0.55),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: ZadType.body(size: 12, height: 16 / 12, color: z.onFrondMuted),
          ),
        ),
      ),
    );
  }
}

class MapRoundButton extends StatelessWidget {
  const MapRoundButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.zad.nightRaised,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox.square(dimension: 40, child: Center(child: ZadIcon(ZadIcons.chevronLeft, size: 20))),
        ),
      ),
    );
  }
}

/// Figma "Locate me": 42 px raised circle with the locate arrow.
class MapLocateButton extends StatelessWidget {
  const MapLocateButton({super.key, required this.label, required this.busy, required this.onTap});

  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      label: label,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: ZadColors.buttonShadow, offset: Offset(0, 4), blurRadius: 14)],
        ),
        child: Material(
          color: z.nightRaised,
          shape: CircleBorder(side: BorderSide(color: z.nightHairline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: busy ? null : onTap,
            child: SizedBox.square(
              dimension: 42,
              child: Center(
                child: busy
                    ? SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: z.card),
                      )
                    : const ZadIcon(ZadIcons.locate, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reports its child's height after layout (used to sit the map behind the sheet).
class MeasureHeight extends StatefulWidget {
  const MeasureHeight({super.key, required this.onHeight, required this.child});

  final ValueChanged<double> onHeight;
  final Widget child;

  @override
  State<MeasureHeight> createState() => _MeasureHeightState();
}

class _MeasureHeightState extends State<MeasureHeight> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      if (mounted && box != null && box.hasSize) widget.onHeight(box.size.height);
    });
    return widget.child;
  }
}
