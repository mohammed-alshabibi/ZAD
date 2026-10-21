import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/zad_button.dart';
import '../../core/widgets/zad_icon.dart';
import '../../core/widgets/zad_text_field.dart';
import 'application/session.dart';
import 'data/auth_repository.dart';
import 'domain/auth_validators.dart';
import 'widgets/auth_errors.dart';
import 'widgets/auth_layout.dart';

/// Figma "Auth — Login" (36:865). After login the app routes by role (§8.1).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _submitted = false;
  var _busy = false;
  String? _serverError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (AuthValidators.email(_email.text) != null || AuthValidators.existingPassword(_password.text) != null) {
      return;
    }

    setState(() => _busy = true);
    try {
      final user = await ref.read(sessionProvider.notifier).login(email: _email.text, password: _password.text);
      if (mounted) context.go(homeForRole(user.role));
    } on AuthException catch (e) {
      if (mounted) setState(() => _serverError = authErrorText(AppLocalizations.of(context), e));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(authErrorText(AppLocalizations.of(context), e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _edited(String _) => setState(() => _serverError = null);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    String? check(AuthFieldError? e) => _submitted ? fieldErrorText(l10n, e) : null;

    return AuthLayout(
      onBack: () => context.canPop() ? context.pop() : context.go(Routes.splash),
      actions: [
        ZadButton(label: l10n.logIn, loading: _busy, onPressed: _submit),
        const SizedBox(height: 14),
        AuthLinkText(
          prompt: l10n.newToZadPrompt,
          link: l10n.createAnAccount,
          onTap: () => context.pushReplacement(Routes.accountType),
        ),
      ],
      children: [
        const AuthLeafTile(),
        const SizedBox(height: 24),
        AuthTitle(l10n.loginTitle),
        const SizedBox(height: 10),
        AuthBody(l10n.loginBody),
        const SizedBox(height: 28),
        AutofillGroup(
          child: Column(
            children: [
              ZadTextField(
                label: l10n.fieldEmail,
                controller: _email,
                leadingIcon: ZadIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                errorText: check(AuthValidators.email(_email.text)),
                onChanged: _edited,
              ),
              const SizedBox(height: 16),
              ZadTextField(
                label: l10n.fieldPassword,
                controller: _password,
                leadingIcon: ZadIcons.lock,
                obscure: true,
                showPasswordLabel: l10n.showPassword,
                hidePasswordLabel: l10n.hidePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                // A wrong email/password pair is reported once, under the password.
                errorText: _serverError ?? check(AuthValidators.existingPassword(_password.text)),
                onChanged: _edited,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () => context.push(Routes.forgotPassword),
            style: TextButton.styleFrom(
              foregroundColor: z.sap,
              padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
              minimumSize: const Size(0, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.forgotPassword, style: ZadType.body(size: 14, weight: FontWeight.w500, color: z.sap)),
          ),
        ),
      ],
    );
  }
}
