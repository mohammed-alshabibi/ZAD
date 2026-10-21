import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/widgets/zad_button.dart';
import '../../core/widgets/zad_choice_card.dart';
import '../../core/widgets/zad_icon.dart';
import 'domain/app_user.dart';
import 'widgets/auth_layout.dart';

/// Figma "Auth — Account type" (36:643), signup step 1 of 2.
class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  var _role = UserRole.user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthLayout(
      onBack: () => context.canPop() ? context.pop() : context.go(Routes.splash),
      stepLabel: l10n.stepOf(1, 2),
      actions: [
        ZadButton(
          label: l10n.continueLabel,
          onPressed: () => context.push(Routes.registerAs(_role.toJson())),
        ),
        const SizedBox(height: 14),
        AuthLinkText(
          prompt: l10n.alreadyHaveAccountPrompt,
          link: l10n.logIn,
          onTap: () => context.pushReplacement(Routes.login),
        ),
      ],
      children: [
        const AuthLeafTile(),
        const SizedBox(height: 24),
        AuthTitle(l10n.accountTypeTitle),
        const SizedBox(height: 10),
        AuthBody(l10n.accountTypeBody),
        const SizedBox(height: 28),
        ZadChoiceCard(
          title: l10n.accountTypeUserTitle,
          description: l10n.accountTypeUserBody,
          icon: ZadIcons.user,
          selected: _role == UserRole.user,
          onTap: () => setState(() => _role = UserRole.user),
        ),
        const SizedBox(height: 12),
        ZadChoiceCard(
          title: l10n.accountTypeRestaurantTitle,
          description: l10n.accountTypeRestaurantBody,
          icon: ZadIcons.store,
          selected: _role == UserRole.restaurant,
          onTap: () => setState(() => _role = UserRole.restaurant),
        ),
      ],
    );
  }
}
