import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/widgets/zad_button.dart';
import '../application/session.dart';

/// "Log out" at the bottom of every Profile tab. Logout = forget the tokens
/// on the phone (§2), then back to the splash.
class LogOutButton extends ConsumerWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ZadButton(
      label: AppLocalizations.of(context).logOut,
      style: ZadButtonStyle.secondary,
      labelColor: context.zad.danger,
      onPressed: () async {
        await ref.read(sessionProvider.notifier).logout();
        if (context.mounted) context.go(Routes.splash);
      },
    );
  }
}
