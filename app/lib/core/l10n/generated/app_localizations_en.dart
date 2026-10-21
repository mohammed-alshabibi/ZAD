// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ZAD';

  @override
  String get splashTagline =>
      'Good meals from kitchens near you,\nsaved before closing time.';

  @override
  String get getStarted => 'Get started';

  @override
  String get haveAccount => 'I already have an account';

  @override
  String get splashLegal =>
      'By continuing, you agree to ZAD\'s Terms and Privacy Policy.';

  @override
  String comingSoon(String screen) {
    return '$screen is coming soon.';
  }

  @override
  String get back => 'Back';

  @override
  String get continueLabel => 'Continue';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get logIn => 'Log in';

  @override
  String get accountTypeTitle => 'How will you use ZAD?';

  @override
  String get accountTypeBody =>
      'Pick the account that fits you. Restaurant accounts are checked by our team before their meals go live.';

  @override
  String get accountTypeUserTitle => 'I want to rescue meals';

  @override
  String get accountTypeUserBody =>
      'Find surplus meals near you tonight and pick them up at the counter.';

  @override
  String get accountTypeRestaurantTitle => 'I run a restaurant';

  @override
  String get accountTypeRestaurantBody =>
      'Post what’s left at closing time, confirm pickups and see tomorrow’s forecast.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSigningUpAsUser => 'Signing up to rescue meals';

  @override
  String get registerSigningUpAsRestaurant => 'Signing up as a restaurant';

  @override
  String get registerChangeType => 'Change';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get registerEmailHelper => 'We’ll email you a link to verify it.';

  @override
  String get registerPasswordHelper =>
      'At least 8 characters, including a number.';

  @override
  String get registerTermsPrefix => 'I agree to ZAD’s ';

  @override
  String get registerTermsAnd => ' and ';

  @override
  String get registerTermsSuffix => '.';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get registerTermsRequired =>
      'Please accept the Terms of Use to continue.';

  @override
  String get createAccount => 'Create account';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginBody => 'Log in to see what’s left near you tonight.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get newToZadPrompt => 'New to ZAD?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get errorNameRequired => 'Enter your name.';

  @override
  String get errorEmailRequired => 'Enter your email.';

  @override
  String get errorEmailInvalid => 'That doesn’t look like an email address.';

  @override
  String get errorPasswordRequired => 'Enter your password.';

  @override
  String get errorPasswordTooWeak =>
      'Use at least 8 characters, including a number.';

  @override
  String get errorEmailTaken =>
      'There’s already an account with this email. Log in instead?';

  @override
  String get errorInvalidCredentials => 'That email and password don’t match.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get locationTitle => 'See meals near you';

  @override
  String get locationBody =>
      'Turn on location to find surplus meals close by, and get an alert when a restaurant nearby posts.';

  @override
  String get locationRadiusLabel => '3 km';

  @override
  String get locationWhileUsing => 'Only while you’re using the app';

  @override
  String get locationRounded =>
      'Rounded to about 100 m. Restaurants never see it.';

  @override
  String get locationAlerts => 'Alerts only within 3 km. Change it anytime.';

  @override
  String get locationTurnOn => 'Turn on location';

  @override
  String get locationSetArea => 'Set my area instead';

  @override
  String get locationDenied =>
      'Location is off for ZAD. You can set your area instead.';

  @override
  String get locationBlocked =>
      'Location is blocked for ZAD. Turn it on in Settings, or set your area instead.';

  @override
  String get locationServiceOff => 'Your phone’s location is switched off.';

  @override
  String get openSettings => 'Settings';

  @override
  String get locationFailed =>
      'We couldn’t find your location. Try again or set your area.';
}
