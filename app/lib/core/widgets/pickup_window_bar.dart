import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';

/// Under this many minutes an offer is "closing soon" and turns saffron
/// (CLAUDE.md §14.1: saffron always means closing soon).
const closingSoon = Duration(minutes: 30);

bool isClosingSoon(DateTime end, DateTime now) {
  final left = end.difference(now);
  return !left.isNegative && left < closingSoon;
}

/// ZAD's signature pickup-window bar: the whole bar is the pickup window and
/// the filled part on the end side is the time still left. Saffron when
/// closing soon, sap otherwise.
class PickupWindowBar extends StatelessWidget {
  const PickupWindowBar({super.key, required this.start, required this.end, required this.now});

  final DateTime start;
  final DateTime end;
  final DateTime now;

  /// Share of the window still left, 0–1.
  static double leftFraction(DateTime start, DateTime end, DateTime now) {
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0;
    final left = end.difference(now.isBefore(start) ? start : now).inSeconds;
    return (left / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final fraction = leftFraction(start, end, now);
    return ExcludeSemantics(
      child: Container(
        height: 4,
        decoration: BoxDecoration(color: z.nightHairline, borderRadius: BorderRadius.circular(2)),
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerEnd,
          widthFactor: fraction,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isClosingSoon(end, now) ? z.saffron : z.sap,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
