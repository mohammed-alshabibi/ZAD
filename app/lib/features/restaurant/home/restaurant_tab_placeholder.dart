import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../auth/application/session.dart';

/// Stand-in for restaurant tabs not built yet (Offers, Insights, Profile).
/// Profile keeps a working "Log out" so restaurant accounts can switch.
class RestaurantTabPlaceholder extends ConsumerWidget {
  const RestaurantTabPlaceholder({super.key, required this.name, this.showLogOut = false});

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
