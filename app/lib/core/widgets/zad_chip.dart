import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';

/// Figma component "Chip" (Default / Active): a tappable pill.
/// Active = sap fill + frond label; Default = subtle sap tint + sap label.
class ZadChip extends StatelessWidget {
  const ZadChip({super.key, required this.label, this.active = false, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: onTap != null,
      selected: active,
      child: Material(
        color: active ? z.sap : z.onFrondSubtle,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: ZadType.body(size: 13, weight: FontWeight.w500, color: active ? z.frond : z.sap),
            ),
          ),
        ),
      ),
    );
  }
}
