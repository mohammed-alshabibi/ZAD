import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Number stepper from the Figma onboarding / Daily log / Reserve screens:
/// round − and + buttons either side of a DM Mono value with a unit below.
/// A null callback disables that button (at the min or max).
class ZadStepper extends StatelessWidget {
  const ZadStepper({
    super.key,
    required this.value,
    required this.unit,
    required this.decreaseLabel,
    required this.increaseLabel,
    this.onDecrease,
    this.onIncrease,
  });

  final int value;
  final String unit;

  /// Screen-reader labels for the two buttons.
  final String decreaseLabel;
  final String increaseLabel;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StepButton(icon: ZadIcons.minus, label: decreaseLabel, onTap: onDecrease),
        Semantics(
          liveRegion: true,
          child: Column(
            children: [
              Text('$value', style: ZadType.mono(size: 34, color: z.card)),
              Text(unit, style: ZadType.body(size: 12, color: z.onFrondMuted)),
            ],
          ),
        ),
        _StepButton(icon: ZadIcons.plus, label: increaseLabel, onTap: onIncrease),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.label, required this.onTap});

  final ZadIcons icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Material(
          color: z.nightSheet,
          shape: CircleBorder(side: BorderSide(color: z.nightHairline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(dimension: 44, child: Center(child: ZadIcon(icon, size: 20))),
          ),
        ),
      ),
    );
  }
}
