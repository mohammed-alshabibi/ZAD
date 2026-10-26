import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';

/// Figma component "Stat tile" (47:952): label, big DM Mono number, one line
/// of detail on a night-raised card. Two share a row on Admin overview.
class ZadStatTile extends StatelessWidget {
  const ZadStatTile({super.key, required this.label, required this.value, required this.detail, this.onTap});

  final String label;
  final String value;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return MergeSemantics(
      child: Material(
        color: z.nightRaised,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ZadType.body(size: 13, color: z.onFrondMuted)),
                const SizedBox(height: 4),
                Text(value, style: ZadType.mono(size: 28, color: z.card)),
                const SizedBox(height: 4),
                Text(detail, style: ZadType.body(size: 12, height: 16 / 12, color: z.onFrondMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
