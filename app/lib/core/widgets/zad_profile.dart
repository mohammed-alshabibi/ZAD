import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';

/// Top of a Profile tab (no Figma frame; built from the Approval row avatar
/// and the grouped Zesty settings rows): a sap initial disc, the name and one
/// line of detail. [kicker] adds a small mono tag above the name.
class ZadProfileHeader extends StatelessWidget {
  const ZadProfileHeader({super.key, required this.name, required this.detail, this.kicker, this.badge});

  final String name;
  final String detail;
  final String? kicker;

  /// Shown under the detail, e.g. the restaurant's "Verified" line.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: z.nightRaised,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: z.nightHairline),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: z.sap, shape: BoxShape.circle),
                child: Text(initial, style: ZadType.display(size: 26, color: z.frond)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kicker != null) ...[
                    Text(kicker!, style: ZadType.mono(size: 11, letterSpacing: 1.1, color: z.sap)),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.display(size: 21, letterSpacing: -0.21, color: z.card),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.body(size: 13, color: z.onFrondMuted),
                  ),
                  if (badge != null) ...[const SizedBox(height: 4), badge!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small heading above a group of Form rows.
class ZadSectionLabel extends StatelessWidget {
  const ZadSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(top: 24, bottom: 2),
        child: Semantics(
          header: true,
          child: Text(text, style: ZadType.body(size: 13, weight: FontWeight.w600, color: context.zad.onFrondMuted)),
        ),
      );
}

/// On/off switch in ZAD colours (sap track when on).
class ZadSwitch extends StatelessWidget {
  const ZadSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: z.frond,
      activeTrackColor: z.sap,
      inactiveThumbColor: z.onFrondMuted,
      inactiveTrackColor: z.nightRaised,
      trackOutlineColor: WidgetStatePropertyAll(z.nightHairline),
    );
  }
}
