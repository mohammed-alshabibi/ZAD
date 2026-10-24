import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Number stepper from the Figma onboarding / Daily log / Reserve screens:
/// round − and + buttons either side of a DM Mono value with a unit below.
/// A null callback disables that button (at the min or max).
///
/// [ZadStepper.compact] is the Reserve sheet's inline version: − value + in
/// one row, DM Mono 20, no unit.
class ZadStepper extends StatelessWidget {
  const ZadStepper({
    super.key,
    required this.value,
    required String this.unit,
    required this.decreaseLabel,
    required this.increaseLabel,
    this.onDecrease,
    this.onIncrease,
  }) : compact = false;

  const ZadStepper.compact({
    super.key,
    required this.value,
    required this.decreaseLabel,
    required this.increaseLabel,
    this.onDecrease,
    this.onIncrease,
  })  : unit = null,
        compact = true;

  final int value;
  final String? unit;
  final bool compact;

  /// Screen-reader labels for the two buttons.
  final String decreaseLabel;
  final String increaseLabel;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    if (compact) {
      // Figma Reserve sheet (24:263): raised 44 px buttons, 18 px icons, 4 px gaps.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: ZadIcons.minus, label: decreaseLabel, onTap: onDecrease, raised: true),
          const SizedBox(width: 4),
          Semantics(
            liveRegion: true,
            child: SizedBox(
              width: 40,
              child: Text('$value', textAlign: TextAlign.center, style: ZadType.mono(size: 20, color: z.card)),
            ),
          ),
          const SizedBox(width: 4),
          _StepButton(icon: ZadIcons.plus, label: increaseLabel, onTap: onIncrease, raised: true),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StepButton(icon: ZadIcons.minus, label: decreaseLabel, onTap: onDecrease),
        Semantics(
          liveRegion: true,
          child: Column(
            children: [
              Text('$value', style: ZadType.mono(size: 34, color: z.card)),
              Text(unit!, style: ZadType.body(size: 12, color: z.onFrondMuted)),
            ],
          ),
        ),
        _StepButton(icon: ZadIcons.plus, label: increaseLabel, onTap: onIncrease),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.label, required this.onTap, this.raised = false});

  final ZadIcons icon;
  final String label;
  final VoidCallback? onTap;

  /// Night-raised fill and an 18 px icon (compact), else night-sheet and 20 px.
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Opacity(
        opacity: onTap == null ? (raised ? 0.45 : 0.4) : 1,
        child: Material(
          color: raised ? z.nightRaised : z.nightSheet,
          shape: CircleBorder(side: BorderSide(color: z.nightHairline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(dimension: 44, child: Center(child: ZadIcon(icon, size: raised ? 18 : 20))),
          ),
        ),
      ),
    );
  }
}
