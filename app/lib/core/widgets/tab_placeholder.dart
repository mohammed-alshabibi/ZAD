import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/session.dart';
import '../l10n/generated/app_localizations.dart';
import '../router/routes.dart';
import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_button.dart';

/// Stand-in for tabs not built yet (restaurant Offers, Insights, Profile;
/// user Pickups, Profile). Profile keeps a working "Log out" so demo
/// accounts can switch.
class TabPlaceholder extends ConsumerWidget {
  const TabPlaceholder({super.key, required this.name, this.showLogOut = false});

  final String name;
  final bool showLogOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: ZadType.display(size: 26, letterSpacing: -0.26, color: z.card)),
            const SizedBox(height: 8),
            Text(l10n.comingSoon(name), style: ZadType.body(size: 15, color: z.onFrondMuted)),
            const Spacer(),
            if (showLogOut)
              ZadButton(
                label: l10n.logOut,
                style: ZadButtonStyle.secondary,
                onPressed: () async {
                  await ref.read(sessionProvider.notifier).logout();
                  if (context.mounted) context.go(Routes.splash);
                },
              ),
          ],
        ),
      ),
    );
  }
}
