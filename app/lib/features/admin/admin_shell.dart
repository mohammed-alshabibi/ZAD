import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/widgets/zad_icon.dart';
import '../../core/widgets/zad_tabs.dart';

/// Admin tab bar from Figma 43:867 / 47:956: Overview · Restaurants · Offers · Profile.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    // Branch order matches the router.
    Widget tab(int branch, ZadIcons icon, String label) => ZadTabItem(
          icon: icon,
          label: label,
          width: 76,
          active: shell.currentIndex == branch,
          onTap: () => shell.goBranch(branch, initialLocation: branch == shell.currentIndex),
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.nightSheet,
        body: shell,
        bottomNavigationBar: Container(
          // Figma: 10 px top, 24 px sides; the bottom clears the gesture bar.
          padding: EdgeInsetsDirectional.fromSTEB(24, 10, 24, math.max(12, bottomInset)),
          decoration: BoxDecoration(
            color: z.nightSheet,
            border: Border(top: BorderSide(color: z.nightHairline)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tab(0, ZadIcons.tabGrid, l10n.tabOverview),
              tab(1, ZadIcons.store, l10n.tabRestaurants),
              tab(2, ZadIcons.tag, l10n.tabOffers),
              tab(3, ZadIcons.tabUser, l10n.tabProfile),
            ],
          ),
        ),
      ),
    );
  }
}
