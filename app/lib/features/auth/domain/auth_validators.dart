/// Form checks for the auth screens. They return a problem code (or null when
/// the value is fine), so they stay testable without a BuildContext; the screen
/// turns the code into an ARB string.
enum AuthFieldError { nameRequired, emailRequired, emailInvalid, passwordRequired, passwordTooWeak }

abstract final class AuthValidators {
  // Deliberately loose: something@something.tld. The server has the final say.
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static AuthFieldError? fullName(String value) =>
      value.trim().isEmpty ? AuthFieldError.nameRequired : null;

  static AuthFieldError? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return AuthFieldError.emailRequired;
    if (!_email.hasMatch(v)) return AuthFieldError.emailInvalid;
    return null;
  }

  /// New passwords: at least 8 characters, including a number (Register helper text).
  static AuthFieldError? newPassword(String value) {
    if (value.isEmpty) return AuthFieldError.passwordRequired;
    if (value.length < 8 || !value.contains(RegExp(r'\d'))) return AuthFieldError.passwordTooWeak;
    return null;
  }

  /// Login only checks that something was typed; the server checks the rest.
  static AuthFieldError? existingPassword(String value) =>
      value.isEmpty ? AuthFieldError.passwordRequired : null;
}
