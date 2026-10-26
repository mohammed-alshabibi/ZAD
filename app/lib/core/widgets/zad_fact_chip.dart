import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';

/// Figma component "Fact chip" (22:203): small outlined pill for a fact such
/// as meals left, the category or an allergen. Pass [child] for mixed
/// content (the price with its crossed-out "was" price).
class ZadFactChip extends StatelessWidget {
  const ZadFactChip({super.key, this.label, this.child}) : assert(label != null || child != null);

  final String? label;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: z.nightHairline),
      ),
      child: child ?? Text(label!, style: ZadType.body(size: 13, color: z.card)),
    );
  }
}
