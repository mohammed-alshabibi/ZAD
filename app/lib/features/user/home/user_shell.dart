import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_icon.dart';

/// User tab bar from Figma 8:48: Home · Pickups · Profile (§14.3: three tabs,
/// the Map tab was folded into Home). It has the same night colour as the
/// Home sheet, so on Home the two read as one surface.
class UserShell extends StatelessWidget {
  const UserShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    // Branch order matches the router: Home, Pickups, Profile.
    Widget tab(int branch, ZadIcons icon, String label) => _TabItem(
          icon: icon,
          label: label,
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
                tab(1, ZadIcons.tabTicket, l10n.tabPickups),
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
  const _TabItem({required this.icon, required this.label, required this.active, required this.onTap});

  final ZadIcons icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

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
              ZadIcon(icon, size: 22, color: color),
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
