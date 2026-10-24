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
/// closing soon, sap otherwise. With [showNow] (Offer photo card), a small
/// card-coloured dot marks "now" where the time left begins.
class PickupWindowBar extends StatelessWidget {
  const PickupWindowBar({super.key, required this.start, required this.end, required this.now, this.showNow = false});

  final DateTime start;
  final DateTime end;
  final DateTime now;
  final bool showNow;

  /// Figma "Now": 8 px dot with a 2 px night-raised ring, 10 px across.
  static const double _nowDot = 10;

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
    final bar = Container(
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
    );
    if (!showNow) return ExcludeSemantics(child: bar);
    return ExcludeSemantics(
      child: SizedBox(
        height: _nowDot,
        child: LayoutBuilder(
          builder: (context, box) {
            final x = (box.maxWidth * (1 - fraction) - _nowDot / 2).clamp(0.0, box.maxWidth - _nowDot);
            return Stack(
              children: [
                Positioned(left: 0, right: 0, top: (_nowDot - 4) / 2, child: bar),
                PositionedDirectional(
                  start: x,
                  top: 0,
                  child: Container(
                    width: _nowDot,
                    height: _nowDot,
                    decoration: BoxDecoration(
                      color: z.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: z.nightRaised, width: 2),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
