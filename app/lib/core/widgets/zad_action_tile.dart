import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Figma component "Action tile" (22:198): a square-ish button on detail
/// screens (Directions, Call…). Several share a row with equal widths.
class ZadActionTile extends StatelessWidget {
  const ZadActionTile({super.key, required this.icon, required this.label, required this.onTap});

  final ZadIcons icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Material(
          color: z.nightRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: z.nightHairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ZadIcon(icon, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.body(size: 12, color: z.card),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
