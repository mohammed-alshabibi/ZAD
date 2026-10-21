import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/zad_button.dart';
import '../../core/widgets/zad_checkbox.dart';
import '../../core/widgets/zad_icon.dart';
import '../../core/widgets/zad_text_field.dart';
import 'application/session.dart';
import 'data/auth_repository.dart';
import 'domain/app_user.dart';
import 'domain/auth_validators.dart';
import 'widgets/auth_errors.dart';
import 'widgets/auth_layout.dart';

/// Figma "Auth — Register" (36:706), signup step 2 of 2.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _acceptedTerms = false;
  var _submitted = false;
  var _busy = false;
  String? _emailServerError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    final invalid = AuthValidators.fullName(_name.text) != null ||
        AuthValidators.email(_email.text) != null ||
        AuthValidators.newPassword(_password.text) != null ||
        !_acceptedTerms;
    if (invalid) return;

    setState(() => _busy = true);
    try {
      final user = await ref.read(sessionProvider.notifier).register(
            email: _email.text,
            password: _password.text,
            fullName: _name.text,
            role: widget.role,
          );
      if (mounted) context.go(nextAfterSignup(user.role));
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code == AuthException.emailTaken) {
        setState(() => _emailServerError = authErrorText(AppLocalizations.of(context), e));
      } else {
        _showError(e);
      }
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(authErrorText(AppLocalizations.of(context), e))));
  }

  void _changeType() => context.canPop() ? context.pop() : context.go(Routes.accountType);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    String? check(AuthFieldError? e) => _submitted ? fieldErrorText(l10n, e) : null;

    return AuthLayout(
      glow: false,
      onBack: _changeType,
      stepLabel: l10n.stepOf(2, 2),
      actions: [
        ZadButton(label: l10n.createAccount, loading: _busy, onPressed: _submit),
        const SizedBox(height: 14),
        AuthLinkText(
          prompt: l10n.alreadyHaveAccountPrompt,
          link: l10n.logIn,
          onTap: () => context.pushReplacement(Routes.login),
        ),
      ],
      children: [
        AuthTitle(l10n.registerTitle, size: 28),
        const SizedBox(height: 8),
        AuthLinkText(
          prompt: widget.role == UserRole.restaurant
              ? l10n.registerSigningUpAsRestaurant
              : l10n.registerSigningUpAsUser,
          separator: ' · ',
          link: l10n.registerChangeType,
          textAlign: TextAlign.start,
          onTap: _changeType,
        ),
        const SizedBox(height: 22),
        AutofillGroup(
          child: Column(
            children: [
              ZadTextField(
                label: l10n.fieldFullName,
                controller: _name,
                leadingIcon: ZadIcons.userSmall,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                errorText: check(AuthValidators.fullName(_name.text)),
                onChanged: (_) => _submitted ? setState(() {}) : null,
              ),
              const SizedBox(height: 16),
              ZadTextField(
                label: l10n.fieldEmail,
                controller: _email,
                leadingIcon: ZadIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                helperText: l10n.registerEmailHelper,
                errorText: _emailServerError ?? check(AuthValidators.email(_email.text)),
                onChanged: (_) => setState(() => _emailServerError = null),
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
                autofillHints: const [AutofillHints.newPassword],
                helperText: l10n.registerPasswordHelper,
                errorText: check(AuthValidators.newPassword(_password.text)),
                onChanged: (_) => _submitted ? setState(() {}) : null,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _TermsRow(
          accepted: _acceptedTerms,
          onChanged: (v) => setState(() => _acceptedTerms = v),
        ),
        if (_submitted && !_acceptedTerms) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 36),
            child: Text(l10n.registerTermsRequired, style: ZadType.body(size: 12, height: 16 / 12, color: z.danger)),
          ),
        ],
      ],
    );
  }
}

/// Checkbox + "I agree to ZAD's Terms of Use and Privacy Policy." with both links.
class _TermsRow extends StatefulWidget {
  const _TermsRow({required this.accepted, required this.onChanged});

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  State<_TermsRow> createState() => _TermsRowState();
}

class _TermsRowState extends State<_TermsRow> {
  late final _termsTap = TapGestureRecognizer()..onTap = () => context.push(Routes.terms);
  late final _privacyTap = TapGestureRecognizer()..onTap = () => context.push(Routes.privacy);

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final link = ZadType.body(size: 14, weight: FontWeight.w500, height: 20 / 14, color: z.sap)
        .copyWith(decoration: TextDecoration.underline, decorationColor: z.sap);

    // Tapping the row toggles the box; the two links open their pages.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onChanged(!widget.accepted),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(checked: widget.accepted, child: ZadCheckbox(value: widget.accepted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted),
                children: [
                  TextSpan(text: l10n.registerTermsPrefix),
                  TextSpan(text: l10n.termsOfUse, style: link, recognizer: _termsTap),
                  TextSpan(text: l10n.registerTermsAnd),
                  TextSpan(text: l10n.privacyPolicy, style: link, recognizer: _privacyTap),
                  TextSpan(text: l10n.registerTermsSuffix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
