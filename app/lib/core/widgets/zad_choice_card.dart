import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Figma component "Choice card" (35:717): large single-choice card.
/// Selected = sap outline, rib icon tile, filled radio.
class ZadChoiceCard extends StatelessWidget {
  const ZadChoiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final ZadIcons icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final radius = BorderRadius.circular(22);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: z.nightRaised,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: selected ? BorderSide(color: z.sap, width: 1.5) : BorderSide(color: z.nightHairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? z.rib : z.onFrondSubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ZadIcon(icon, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: ZadType.body(size: 17, weight: FontWeight.w600, height: 22 / 17, color: z.card)),
                      const SizedBox(height: 4),
                      Text(description, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                selected
                    ? SvgPicture.asset('assets/icons/radio_on.svg', width: 24, height: 24)
                    : Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: z.onFrondMuted, width: 1.5),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
