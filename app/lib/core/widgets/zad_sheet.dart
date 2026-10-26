import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';

/// Opens a Zesty-style bottom sheet (Figma "Reserve", "Pickup code",
/// "Confirm pickup"): night-raised, 32 px top corners, grabber, and it rides
/// above the keyboard. It opens on the root navigator, so inside a tab it
/// covers and dims the tab bar too, as in Figma.
Future<T?> showZadSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.zad.nightRaised,
    barrierColor: context.zad.nightScrim,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
    builder: builder,
  );
}

/// Content frame for [showZadSheet]: grabber, heading, optional subtitle, body.
class ZadSheet extends StatelessWidget {
  const ZadSheet({super.key, required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final bottom = math.max(MediaQuery.viewInsetsOf(context).bottom, MediaQuery.viewPaddingOf(context).bottom);
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(color: z.nightHairline, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 18),
          Text(title, style: ZadType.display(size: 26, letterSpacing: -0.26, color: z.card)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
          ],
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
