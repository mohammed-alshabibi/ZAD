import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/zad_icon.dart';
import '../application/reservations.dart';

/// User tab bar from Figma 8:48: Home · Pickups · Profile (§14.3: three tabs,
/// the Map tab was folded into Home). It has the same night colour as the
/// Home sheet, so on Home the two read as one surface.
class UserShell extends ConsumerWidget {
  const UserShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.now;
    // Figma "Active reservation": a saffron dot on Pickups while a hold runs.
    final hasActive = (ref.watch(myReservationsProvider).value ?? const []).any((r) => r.isActive(now));
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    // Branch order matches the router: Home, Pickups, Profile.
    Widget tab(int branch, ZadIcons icon, String label, {bool dot = false}) => _TabItem(
          icon: icon,
          label: label,
          dot: dot,
          active: shell.currentIndex == branch,
          onTap: () => shell.goBranch(branch, initialLocation: branch == shell.currentIndex),
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.nightSheet,
        // The Home sheet slides up over the map, not the keyboard over the tabs.
        resizeToAvoidBottomInset: false,
        body: shell,
        bottomNavigationBar: ColoredBox(
          color: z.nightSheet,
          child: Padding(
            // Figma: 2 px top, 34 px sides; the bottom clears the gesture bar.
            padding: EdgeInsetsDirectional.fromSTEB(34, 2, 34, math.max(12, bottomInset)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tab(0, ZadIcons.tabHome, l10n.tabHome),
                tab(1, ZadIcons.tabTicket, l10n.tabPickups, dot: hasActive),
                tab(2, ZadIcons.tabUser, l10n.tabProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label, required this.active, required this.onTap, this.dot = false});

  final ZadIcons icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final color = active ? z.sap : z.onFrondMuted;
    return Semantics(
      button: true,
      selected: active,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ZadIcon(icon, size: 22, color: color),
                  if (dot)
                    // 8 px saffron dot with a 2 px ring in the bar colour (Figma 8:229).
                    PositionedDirectional(
                      start: 19,
                      top: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: z.saffron,
                          shape: BoxShape.circle,
                          border: Border.all(color: z.nightSheet, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZadType.body(size: 11, weight: active ? FontWeight.w600 : FontWeight.w400, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
