import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_tabs.dart';

/// Restaurant tab bar from Figma 29:400: Today · Offers · (+) · Insights · Profile.
/// The middle button opens "Add surplus" full screen instead of switching tabs.
class RestaurantShell extends StatelessWidget {
  const RestaurantShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    // Branch order matches the router: Today, Offers, Insights, Profile.
    Widget tab(int branch, ZadIcons icon, String label) => ZadTabItem(
          icon: icon,
          label: label,
          width: 62,
          active: shell.currentIndex == branch,
          onTap: () => shell.goBranch(branch, initialLocation: branch == shell.currentIndex),
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.nightSheet,
        body: shell,
        bottomNavigationBar: Container(
          padding: EdgeInsetsDirectional.fromSTEB(18, 8, 18, math.max(12, bottomInset)),
          decoration: BoxDecoration(
            color: z.nightSheet,
            border: Border(top: BorderSide(color: z.nightHairline)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tab(0, ZadIcons.tabHome, l10n.tabToday),
              tab(1, ZadIcons.tabGrid, l10n.tabOffers),
              _NewSurplusButton(label: l10n.newSurplus, onTap: () => context.push(Routes.restaurantNewOffer)),
              tab(2, ZadIcons.tabChart, l10n.tabInsights),
              tab(3, ZadIcons.tabUser, l10n.tabProfile),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 48 px sap circle with a plus in the middle of the tab bar.
class _NewSurplusButton extends StatelessWidget {
  const _NewSurplusButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.zad.sap,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox.square(dimension: 48, child: Center(child: ZadIcon(ZadIcons.tabPlus, size: 24))),
        ),
      ),
    );
  }
}
