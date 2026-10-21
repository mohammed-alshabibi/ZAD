import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ZAD'**
  String get appName;

  /// Two-line tagline under the logo on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'Good meals from kitchens near you,\nsaved before closing time.'**
  String get splashTagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccount;

  /// No description provided for @splashLegal.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to ZAD\'s Terms and Privacy Policy.'**
  String get splashLegal;

  /// Placeholder body for screens that are not built yet.
  ///
  /// In en, this message translates to:
  /// **'{screen} is coming soon.'**
  String comingSoon(String screen);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Progress label at the top of the signup screens.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(int step, int total);

  /// Followed by the 'Log in' link.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @accountTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use ZAD?'**
  String get accountTypeTitle;

  /// No description provided for @accountTypeBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the account that fits you. Restaurant accounts are checked by our team before their meals go live.'**
  String get accountTypeBody;

  /// No description provided for @accountTypeUserTitle.
  ///
  /// In en, this message translates to:
  /// **'I want to rescue meals'**
  String get accountTypeUserTitle;

  /// No description provided for @accountTypeUserBody.
  ///
  /// In en, this message translates to:
  /// **'Find surplus meals near you tonight and pick them up at the counter.'**
  String get accountTypeUserBody;

  /// No description provided for @accountTypeRestaurantTitle.
  ///
  /// In en, this message translates to:
  /// **'I run a restaurant'**
  String get accountTypeRestaurantTitle;

  /// No description provided for @accountTypeRestaurantBody.
  ///
  /// In en, this message translates to:
  /// **'Post what’s left at closing time, confirm pickups and see tomorrow’s forecast.'**
  String get accountTypeRestaurantBody;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSigningUpAsUser.
  ///
  /// In en, this message translates to:
  /// **'Signing up to rescue meals'**
  String get registerSigningUpAsUser;

  /// No description provided for @registerSigningUpAsRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Signing up as a restaurant'**
  String get registerSigningUpAsRestaurant;

  /// Link after 'Signing up to rescue meals ·' that goes back to the account type.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get registerChangeType;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @registerEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'We’ll email you a link to verify it.'**
  String get registerEmailHelper;

  /// No description provided for @registerPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, including a number.'**
  String get registerPasswordHelper;

  /// No description provided for @registerTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to ZAD’s '**
  String get registerTermsPrefix;

  /// No description provided for @registerTermsAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get registerTermsAnd;

  /// No description provided for @registerTermsSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get registerTermsSuffix;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @registerTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Use to continue.'**
  String get registerTermsRequired;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginBody.
  ///
  /// In en, this message translates to:
  /// **'Log in to see what’s left near you tonight.'**
  String get loginBody;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Followed by the 'Create an account' link.
  ///
  /// In en, this message translates to:
  /// **'New to ZAD?'**
  String get newToZadPrompt;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get errorNameRequired;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get errorEmailRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look like an email address.'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters, including a number.'**
  String get errorPasswordTooWeak;

  /// No description provided for @errorEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'There’s already an account with this email. Log in instead?'**
  String get errorEmailTaken;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'That email and password don’t match.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'See meals near you'**
  String get locationTitle;

  /// No description provided for @locationBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on location to find surplus meals close by, and get an alert when a restaurant nearby posts.'**
  String get locationBody;

  /// No description provided for @locationRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'3 km'**
  String get locationRadiusLabel;

  /// No description provided for @locationWhileUsing.
  ///
  /// In en, this message translates to:
  /// **'Only while you’re using the app'**
  String get locationWhileUsing;

  /// No description provided for @locationRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded to about 100 m. Restaurants never see it.'**
  String get locationRounded;

  /// No description provided for @locationAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts only within 3 km. Change it anytime.'**
  String get locationAlerts;

  /// No description provided for @locationTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get locationTurnOn;

  /// No description provided for @locationSetArea.
  ///
  /// In en, this message translates to:
  /// **'Set my area instead'**
  String get locationSetArea;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location is off for ZAD. You can set your area instead.'**
  String get locationDenied;

  /// No description provided for @locationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked for ZAD. Turn it on in Settings, or set your area instead.'**
  String get locationBlocked;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Your phone’s location is switched off.'**
  String get locationServiceOff;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find your location. Try again or set your area.'**
  String get locationFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
