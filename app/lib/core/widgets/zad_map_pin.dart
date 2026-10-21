import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Figma component "Map pin", Default state (7:52): white leaf disc with a sap
/// meals-left badge on its top-end corner. The 10 px end / 8 px top padding
/// leaves room for the badge, as in Figma.
class ZadMapPin extends StatelessWidget {
  const ZadMapPin({super.key, required this.meals});

  /// Meals left, shown in the badge. Null hides the badge.
  final int? meals;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10, top: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: z.card,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: ZadColors.pinShadow, offset: Offset(0, 4), blurRadius: 6)],
            ),
            child: const ZadIcon(ZadIcons.leafPin, size: 16),
          ),
          if (meals != null)
            PositionedDirectional(
              start: 22,
              top: -6,
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: z.sap, borderRadius: BorderRadius.circular(999)),
                child: Text('$meals', style: ZadType.mono(size: 10, color: z.frond)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Figma component "Map pin", Selected state: a larger frond disc with a card
/// ring, the leaf, and the place name underneath. Used as the fixed centre pin
/// on the restaurant "Pickup location" screen.
class ZadSelectedMapPin extends StatelessWidget {
  const ZadSelectedMapPin({super.key, this.label});

  final String? label;

  /// Disc diameter; the location point is the bottom of the disc.
  static const double disc = 46;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: disc,
          height: disc,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: z.frond,
            shape: BoxShape.circle,
            border: Border.all(color: z.card, width: 3),
            boxShadow: const [BoxShadow(color: ZadColors.pinShadow, offset: Offset(0, 4), blurRadius: 6)],
          ),
          child: const ZadIcon(ZadIcons.leafPinSelected, size: 22),
        ),
        if (label != null && label!.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ZadType.body(size: 12, weight: FontWeight.w600, color: z.card).copyWith(
              shadows: const [Shadow(color: ZadColors.labelShadow, blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ],
      ],
    );
  }
}
