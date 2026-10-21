import '../../../core/l10n/generated/app_localizations.dart';
import '../data/auth_repository.dart';
import '../domain/auth_validators.dart';

/// ARB text for a form check result.
String? fieldErrorText(AppLocalizations l10n, AuthFieldError? error) => switch (error) {
      null => null,
      AuthFieldError.nameRequired => l10n.errorNameRequired,
      AuthFieldError.emailRequired => l10n.errorEmailRequired,
      AuthFieldError.emailInvalid => l10n.errorEmailInvalid,
      AuthFieldError.passwordRequired => l10n.errorPasswordRequired,
      AuthFieldError.passwordTooWeak => l10n.errorPasswordTooWeak,
    };

/// ARB text for an API error code.
String authErrorText(AppLocalizations l10n, Object error) => switch (error) {
      AuthException(code: AuthException.emailTaken) => l10n.errorEmailTaken,
      AuthException(code: AuthException.invalidCredentials) => l10n.errorInvalidCredentials,
      _ => l10n.errorGeneric,
    };
