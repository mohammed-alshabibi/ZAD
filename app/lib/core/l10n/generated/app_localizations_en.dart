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
}
