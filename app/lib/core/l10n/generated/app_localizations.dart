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

  /// Progress label at the top of the restaurant onboarding screens.
  ///
  /// In en, this message translates to:
  /// **'Restaurant setup · {step} of {total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'About your restaurant'**
  String get detailsTitle;

  /// No description provided for @detailsBody.
  ///
  /// In en, this message translates to:
  /// **'This is what people see next to your meals.'**
  String get detailsBody;

  /// No description provided for @addLogo.
  ///
  /// In en, this message translates to:
  /// **'Add a logo'**
  String get addLogo;

  /// No description provided for @addLogoHint.
  ///
  /// In en, this message translates to:
  /// **'Optional · a square image works best'**
  String get addLogoHint;

  /// No description provided for @logoComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Logo upload is coming soon. You can skip it for now.'**
  String get logoComingSoon;

  /// No description provided for @fieldRestaurantName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant name'**
  String get fieldRestaurantName;

  /// No description provided for @fieldCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get fieldCuisine;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @phoneHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown on your meals so people can call you.'**
  String get phoneHelper;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description (optional)'**
  String get fieldDescription;

  /// Last cuisine chip; shows the rest of the cuisines.
  ///
  /// In en, this message translates to:
  /// **'More…'**
  String get cuisineMore;

  /// No description provided for @cuisineBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery & sweets'**
  String get cuisineBakery;

  /// No description provided for @cuisineOmani.
  ///
  /// In en, this message translates to:
  /// **'Omani'**
  String get cuisineOmani;

  /// No description provided for @cuisineArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get cuisineArabic;

  /// No description provided for @cuisineIndian.
  ///
  /// In en, this message translates to:
  /// **'Indian'**
  String get cuisineIndian;

  /// No description provided for @cuisineCafe.
  ///
  /// In en, this message translates to:
  /// **'Café'**
  String get cuisineCafe;

  /// No description provided for @cuisineFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast food'**
  String get cuisineFastFood;

  /// No description provided for @cuisineHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get cuisineHealthy;

  /// No description provided for @cuisineGrill.
  ///
  /// In en, this message translates to:
  /// **'Grill & shawarma'**
  String get cuisineGrill;

  /// No description provided for @cuisineSeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get cuisineSeafood;

  /// No description provided for @cuisineAsian.
  ///
  /// In en, this message translates to:
  /// **'Asian'**
  String get cuisineAsian;

  /// No description provided for @cuisineInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get cuisineInternational;

  /// No description provided for @cuisineOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cuisineOther;

  /// No description provided for @errorRestaurantNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your restaurant’s name.'**
  String get errorRestaurantNameRequired;

  /// No description provided for @errorRestaurantNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the name under 60 characters.'**
  String get errorRestaurantNameTooLong;

  /// No description provided for @errorCuisineRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick the cuisine that fits best.'**
  String get errorCuisineRequired;

  /// No description provided for @errorPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a number people can call.'**
  String get errorPhoneRequired;

  /// No description provided for @errorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an Omani number, like +968 9123 4567.'**
  String get errorPhoneInvalid;

  /// No description provided for @errorDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under 140 characters.'**
  String get errorDescriptionTooLong;

  /// No description provided for @errorAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Add the pickup address.'**
  String get errorAddressRequired;

  /// No description provided for @pickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do people pick up?'**
  String get pickupTitle;

  /// No description provided for @pickupBody.
  ///
  /// In en, this message translates to:
  /// **'People see this pin on the map and get directions to it.'**
  String get pickupBody;

  /// No description provided for @pickupMoveHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map to put the pin on your entrance'**
  String get pickupMoveHint;

  /// Under the address, e.g. 'Muscat · filled in from the pin'.
  ///
  /// In en, this message translates to:
  /// **'{city} · filled in from the pin'**
  String pickupFromPin(String city);

  /// No description provided for @pickupEditHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add the building or a landmark'**
  String get pickupEditHint;

  /// No description provided for @pickupFindingAddress.
  ///
  /// In en, this message translates to:
  /// **'Finding the address…'**
  String get pickupFindingAddress;

  /// No description provided for @pickupNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Add the pickup address'**
  String get pickupNoAddress;

  /// No description provided for @pickupLocateMe.
  ///
  /// In en, this message translates to:
  /// **'Go to my location'**
  String get pickupLocateMe;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocation;

  /// No description provided for @pickupAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get pickupAddressTitle;

  /// No description provided for @pickupAddressField.
  ///
  /// In en, this message translates to:
  /// **'Street, building, landmark'**
  String get pickupAddressField;

  /// No description provided for @pickupAddressHelper.
  ///
  /// In en, this message translates to:
  /// **'Anything that helps people find your entrance.'**
  String get pickupAddressHelper;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @mapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The map isn’t available in this build, so the pin is set to Al Khuwair, Muscat. Run on Android with the Mapbox token to move it.'**
  String get mapUnavailable;

  /// No description provided for @typicalDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your typical day'**
  String get typicalDayTitle;

  /// No description provided for @typicalDayBody.
  ///
  /// In en, this message translates to:
  /// **'Two rough answers give you a first surplus forecast. You can change them later in Settings.'**
  String get typicalDayBody;

  /// No description provided for @mealsPerDayQuestion.
  ///
  /// In en, this message translates to:
  /// **'Meals you prepare on a normal day'**
  String get mealsPerDayQuestion;

  /// No description provided for @mealsUnit.
  ///
  /// In en, this message translates to:
  /// **'meals'**
  String get mealsUnit;

  /// No description provided for @fewerMeals.
  ///
  /// In en, this message translates to:
  /// **'Fewer meals'**
  String get fewerMeals;

  /// No description provided for @moreMeals.
  ///
  /// In en, this message translates to:
  /// **'More meals'**
  String get moreMeals;

  /// No description provided for @leftOverQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much is usually left at closing?'**
  String get leftOverQuestion;

  /// No description provided for @surplusUnder5.
  ///
  /// In en, this message translates to:
  /// **'Under 5%'**
  String get surplusUnder5;

  /// No description provided for @surplus5to10.
  ///
  /// In en, this message translates to:
  /// **'5–10%'**
  String get surplus5to10;

  /// No description provided for @surplus10to20.
  ///
  /// In en, this message translates to:
  /// **'10–20%'**
  String get surplus10to20;

  /// No description provided for @surplusOver20.
  ///
  /// In en, this message translates to:
  /// **'Over 20%'**
  String get surplusOver20;

  /// No description provided for @firstForecast.
  ///
  /// In en, this message translates to:
  /// **'First forecast: ~{low}–{high} meals a day'**
  String firstForecast(int low, int high);

  /// No description provided for @firstForecastNote.
  ///
  /// In en, this message translates to:
  /// **'A rough estimate until you’ve logged 14 days of real numbers.'**
  String get firstForecastNote;

  /// No description provided for @firstForecastEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first forecast'**
  String get firstForecastEmptyTitle;

  /// No description provided for @firstForecastEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'Pick how much is usually left to see it.'**
  String get firstForecastEmptyNote;

  /// No description provided for @errorSurplusRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick the closest answer.'**
  String get errorSurplusRequired;

  /// No description provided for @restaurantTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get restaurantTermsPrefix;

  /// No description provided for @restaurantTerms.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Terms'**
  String get restaurantTerms;

  /// No description provided for @restaurantTermsSuffix.
  ///
  /// In en, this message translates to:
  /// **'. We are responsible for the safety, labelling and allergen information of the food we post.'**
  String get restaurantTermsSuffix;

  /// No description provided for @errorRestaurantTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Restaurant Terms to continue.'**
  String get errorRestaurantTermsRequired;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitForReview;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks! We’re checking your restaurant'**
  String get pendingTitle;

  /// No description provided for @pendingBody.
  ///
  /// In en, this message translates to:
  /// **'Our team usually reviews new restaurants within a day. We’ll send you a notification when you can post meals.'**
  String get pendingBody;

  /// No description provided for @rejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t approve your restaurant'**
  String get rejectedTitle;

  /// No description provided for @rejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Check your details and send them again. Our team will take another look.'**
  String get rejectedBody;

  /// No description provided for @suspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your restaurant is paused'**
  String get suspendedTitle;

  /// No description provided for @suspendedBody.
  ///
  /// In en, this message translates to:
  /// **'The ZAD team has paused your meals for now. Contact us to find out why.'**
  String get suspendedBody;

  /// No description provided for @pendingStepAccount.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get pendingStepAccount;

  /// No description provided for @pendingStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Restaurant details sent'**
  String get pendingStepDetails;

  /// No description provided for @pendingStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review by the ZAD team'**
  String get pendingStepReview;

  /// No description provided for @pendingInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get pendingInProgress;

  /// No description provided for @pendingNotApproved.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get pendingNotApproved;

  /// No description provided for @pendingPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pendingPaused;

  /// No description provided for @pendingStepFirstSurplus.
  ///
  /// In en, this message translates to:
  /// **'Post your first surplus'**
  String get pendingStepFirstSurplus;

  /// No description provided for @pendingUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Unlocks after approval'**
  String get pendingUnlocks;

  /// No description provided for @editRestaurantDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit restaurant details'**
  String get editRestaurantDetails;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String todayAt(String time);

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String yesterdayAt(String time);

  /// No description provided for @errorLoadRestaurant.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your restaurant. Pull down to try again.'**
  String get errorLoadRestaurant;

  /// No description provided for @tonightAt.
  ///
  /// In en, this message translates to:
  /// **'Tonight at'**
  String get tonightAt;

  /// No description provided for @verifiedArea.
  ///
  /// In en, this message translates to:
  /// **'Verified · {area}'**
  String verifiedArea(String area);

  /// No description provided for @statPosted.
  ///
  /// In en, this message translates to:
  /// **'posted'**
  String get statPosted;

  /// No description provided for @statReserved.
  ///
  /// In en, this message translates to:
  /// **'reserved'**
  String get statReserved;

  /// No description provided for @statCollected.
  ///
  /// In en, this message translates to:
  /// **'collected'**
  String get statCollected;

  /// No description provided for @liveNow.
  ///
  /// In en, this message translates to:
  /// **'LIVE NOW'**
  String get liveNow;

  /// Live offer line, e.g. '2 of 6 left · 0.800 OMR · until 21:40'.
  ///
  /// In en, this message translates to:
  /// **'{left} of {total} left · {price} · until {time}'**
  String offerMeta(int left, int total, String price, String time);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @minutesLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesLeft(int minutes);

  /// No description provided for @hoursMinutesLeft.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String hoursMinutesLeft(int hours, int minutes);

  /// No description provided for @editQuantity.
  ///
  /// In en, this message translates to:
  /// **'Edit quantity'**
  String get editQuantity;

  /// No description provided for @endEarly.
  ///
  /// In en, this message translates to:
  /// **'End early'**
  String get endEarly;

  /// No description provided for @waitingForPickup.
  ///
  /// In en, this message translates to:
  /// **'Waiting for pickup · {count}'**
  String waitingForPickup(int count);

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @reservationName.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =1{1 meal} other{{count} meals}}'**
  String reservationName(String name, int count);

  /// No description provided for @reservationWaitingDetail.
  ///
  /// In en, this message translates to:
  /// **'Code ••{hint} · held until {time}'**
  String reservationWaitingDetail(String hint, String time);

  /// No description provided for @reservationCollectedDetail.
  ///
  /// In en, this message translates to:
  /// **'Collected at {time}'**
  String reservationCollectedDetail(String time);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @noPickupsYet.
  ///
  /// In en, this message translates to:
  /// **'No pickups waiting. New reservations show up here.'**
  String get noPickupsYet;

  /// No description provided for @nothingLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing live right now'**
  String get nothingLiveTitle;

  /// No description provided for @nothingLiveBody.
  ///
  /// In en, this message translates to:
  /// **'Post what’s left tonight and people within 3 km get an alert.'**
  String get nothingLiveBody;

  /// No description provided for @postSurplus.
  ///
  /// In en, this message translates to:
  /// **'Post surplus'**
  String get postSurplus;

  /// No description provided for @forecastTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow ({day}): ~{count} surplus meals'**
  String forecastTomorrow(String day, int count);

  /// No description provided for @forecastRange.
  ///
  /// In en, this message translates to:
  /// **'Range {low}–{high} · {confidence}'**
  String forecastRange(int low, int high, String confidence);

  /// No description provided for @confidenceLow.
  ///
  /// In en, this message translates to:
  /// **'low confidence'**
  String get confidenceLow;

  /// No description provided for @confidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'medium confidence'**
  String get confidenceMedium;

  /// No description provided for @confidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'high confidence'**
  String get confidenceHigh;

  /// No description provided for @roughEstimate.
  ///
  /// In en, this message translates to:
  /// **'rough estimate'**
  String get roughEstimate;

  /// No description provided for @confirmPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm pickup'**
  String get confirmPickup;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get tabOffers;

  /// No description provided for @tabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tabInsights;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @newSurplus.
  ///
  /// In en, this message translates to:
  /// **'New surplus'**
  String get newSurplus;

  /// No description provided for @errorLoadToday.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load tonight’s pickups. Pull down to try again.'**
  String get errorLoadToday;

  /// No description provided for @confirmPickupBody.
  ///
  /// In en, this message translates to:
  /// **'Ask the customer for their 6-digit code.'**
  String get confirmPickupBody;

  /// No description provided for @confirmPickupBodyFor.
  ///
  /// In en, this message translates to:
  /// **'Ask {name} for their 6-digit code.'**
  String confirmPickupBodyFor(String name);

  /// No description provided for @pickupCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup code'**
  String get pickupCodeLabel;

  /// No description provided for @codeMatches.
  ///
  /// In en, this message translates to:
  /// **'Code matches · {name}'**
  String codeMatches(String name);

  /// No description provided for @codeMatchDetail.
  ///
  /// In en, this message translates to:
  /// **'{count} × {title} · collect {amount}'**
  String codeMatchDetail(int count, String title, String amount);

  /// No description provided for @codeMatchDetailFree.
  ///
  /// In en, this message translates to:
  /// **'{count} × {title} · free'**
  String codeMatchDetailFree(int count, String title);

  /// No description provided for @codeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No pickup matches this code. Check the digits.'**
  String get codeNotFound;

  /// No description provided for @codeAlreadyCollected.
  ///
  /// In en, this message translates to:
  /// **'This code was already collected.'**
  String get codeAlreadyCollected;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'This hold has expired, so the meals went back on the offer.'**
  String get codeExpired;

  /// No description provided for @codeLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong codes. Try again at {time}.'**
  String codeLocked(String time);

  /// No description provided for @codeLockNote.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong codes locks entry for 10 minutes.'**
  String get codeLockNote;

  /// No description provided for @pickupCollectedToast.
  ///
  /// In en, this message translates to:
  /// **'Collected · {name} · {count, plural, =1{1 meal} other{{count} meals}}'**
  String pickupCollectedToast(String name, int count);

  /// No description provided for @editQuantityTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit meals left'**
  String get editQuantityTitle;

  /// No description provided for @editQuantityBody.
  ///
  /// In en, this message translates to:
  /// **'{taken, plural, =0{Nobody has reserved yet.} =1{1 meal is already reserved or collected.} other{{taken} meals are already reserved or collected.}}'**
  String editQuantityBody(int taken);

  /// No description provided for @mealsLeftUnit.
  ///
  /// In en, this message translates to:
  /// **'meals left'**
  String get mealsLeftUnit;

  /// No description provided for @errorQuantityBelowTaken.
  ///
  /// In en, this message translates to:
  /// **'You can’t go below what’s already reserved.'**
  String get errorQuantityBelowTaken;

  /// No description provided for @endEarlyTitle.
  ///
  /// In en, this message translates to:
  /// **'End this offer now?'**
  String get endEarlyTitle;

  /// No description provided for @endEarlyBody.
  ///
  /// In en, this message translates to:
  /// **'Nobody new can reserve it. People who already reserved can still pick up.'**
  String get endEarlyBody;

  /// No description provided for @endOffer.
  ///
  /// In en, this message translates to:
  /// **'End offer'**
  String get endOffer;

  /// No description provided for @keepLive.
  ///
  /// In en, this message translates to:
  /// **'Keep it live'**
  String get keepLive;

  /// No description provided for @offerEnded.
  ///
  /// In en, this message translates to:
  /// **'Offer ended. Waiting pickups are still valid.'**
  String get offerEnded;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabPickups.
  ///
  /// In en, this message translates to:
  /// **'Pickups'**
  String get tabPickups;

  /// No description provided for @homeAreaUnset.
  ///
  /// In en, this message translates to:
  /// **'Set my area'**
  String get homeAreaUnset;

  /// No description provided for @homeAreaNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get homeAreaNearYou;

  /// No description provided for @homeMealsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}}'**
  String homeMealsCount(int count);

  /// Home sheet title. {meals} is homeMealsCount and is shown in green.
  ///
  /// In en, this message translates to:
  /// **'{meals} left near you tonight'**
  String homeMealsTitle(String meals);

  /// No description provided for @homeNoMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing left near you right now'**
  String get homeNoMealsTitle;

  /// No description provided for @homeNoMealsBody.
  ///
  /// In en, this message translates to:
  /// **'Restaurants post what’s left around closing time. We’ll send you an alert when one within 3 km does.'**
  String get homeNoMealsBody;

  /// No description provided for @homeNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No meals match'**
  String get homeNoMatchesTitle;

  /// No description provided for @homeNoMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or clear the search.'**
  String get homeNoMatchesBody;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load meals near you.'**
  String get homeLoadError;

  /// No description provided for @homeLoading.
  ///
  /// In en, this message translates to:
  /// **'Looking for meals near you…'**
  String get homeLoading;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @filterClosingSoon.
  ///
  /// In en, this message translates to:
  /// **'Closing soon'**
  String get filterClosingSoon;

  /// No description provided for @filterUnderOneOmr.
  ///
  /// In en, this message translates to:
  /// **'Under 1 OMR'**
  String get filterUnderOneOmr;

  /// No description provided for @categoryBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get categoryBakery;

  /// No description provided for @categoryRiceMandi.
  ///
  /// In en, this message translates to:
  /// **'Rice & mandi'**
  String get categoryRiceMandi;

  /// No description provided for @categoryGrill.
  ///
  /// In en, this message translates to:
  /// **'Grill'**
  String get categoryGrill;

  /// No description provided for @categorySandwiches.
  ///
  /// In en, this message translates to:
  /// **'Sandwiches'**
  String get categorySandwiches;

  /// No description provided for @categorySweets.
  ///
  /// In en, this message translates to:
  /// **'Sweets'**
  String get categorySweets;

  /// No description provided for @categoryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get categoryHealthy;

  /// No description provided for @categoryMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get categoryMixed;

  /// No description provided for @searchMealsHint.
  ///
  /// In en, this message translates to:
  /// **'Search meals or restaurants'**
  String get searchMealsHint;

  /// Offer card line, e.g. 'Zaatar manakish box · 0.6 km · 8 min walk'.
  ///
  /// In en, this message translates to:
  /// **'{title} · {distance} · {minutes} min walk'**
  String offerCardDetails(String title, String distance, int minutes);

  /// No description provided for @offerRowDetails.
  ///
  /// In en, this message translates to:
  /// **'{restaurant} · {distance}'**
  String offerRowDetails(String restaurant, String distance);

  /// No description provided for @pickupNow.
  ///
  /// In en, this message translates to:
  /// **'Pickup now'**
  String get pickupNow;

  /// No description provided for @pickupFrom.
  ///
  /// In en, this message translates to:
  /// **'Pickup from {time}'**
  String pickupFrom(String time);

  /// No description provided for @pickupUntil.
  ///
  /// In en, this message translates to:
  /// **'until {time}'**
  String pickupUntil(String time);

  /// No description provided for @minutesLeftTag.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String minutesLeftTag(int minutes);

  /// No description provided for @mealsLeftShort.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String mealsLeftShort(int count);

  /// No description provided for @closingFirst.
  ///
  /// In en, this message translates to:
  /// **'Closing first'**
  String get closingFirst;

  /// No description provided for @showMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Show my location'**
  String get showMyLocation;

  /// Screen reader label for a map pin.
  ///
  /// In en, this message translates to:
  /// **'{name}, {count, plural, =1{1 meal left} other{{count} meals left}}'**
  String mapPinLabel(String name, int count);

  /// No description provided for @mealDetails.
  ///
  /// In en, this message translates to:
  /// **'Meal details'**
  String get mealDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @mealDetailsLine.
  ///
  /// In en, this message translates to:
  /// **'{restaurant} · {distance} · {minutes} min walk'**
  String mealDetailsLine(String restaurant, String distance, int minutes);

  /// No description provided for @allergensSafety.
  ///
  /// In en, this message translates to:
  /// **'Allergens & safety'**
  String get allergensSafety;

  /// No description provided for @allergenGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get allergenGluten;

  /// No description provided for @allergenMilk.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get allergenMilk;

  /// No description provided for @allergenEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergenEggs;

  /// No description provided for @allergenNuts.
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get allergenNuts;

  /// No description provided for @allergenPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergenPeanuts;

  /// No description provided for @allergenSesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get allergenSesame;

  /// No description provided for @allergenSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergenSoy;

  /// No description provided for @allergenFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergenFish;

  /// No description provided for @allergenShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergenShellfish;

  /// No description provided for @allergenNone.
  ///
  /// In en, this message translates to:
  /// **'No common allergens'**
  String get allergenNone;

  /// No description provided for @safetyNote.
  ///
  /// In en, this message translates to:
  /// **'Prepared today at {time} and stored safely. The restaurant is responsible for food safety. Eat promptly or refrigerate, and ask staff if you are unsure about allergens.'**
  String safetyNote(String time);

  /// No description provided for @payAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Pay at pickup · cash or card'**
  String get payAtPickup;

  /// No description provided for @nothingToPay.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pay at pickup'**
  String get nothingToPay;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// Under 'Reserved' on the Meal details bar. Figma puts the count on the first line, which doesn't fit narrow phones.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}} · held until {time}'**
  String reservedHeldUntil(int count, String time);

  /// No description provided for @showPickupCode.
  ///
  /// In en, this message translates to:
  /// **'Show pickup code'**
  String get showPickupCode;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @soldOutHint.
  ///
  /// In en, this message translates to:
  /// **'Meals come back if someone cancels.'**
  String get soldOutHint;

  /// No description provided for @pickupEnded.
  ///
  /// In en, this message translates to:
  /// **'Pickup has ended'**
  String get pickupEnded;

  /// No description provided for @pickupEndedHint.
  ///
  /// In en, this message translates to:
  /// **'This offer is closed.'**
  String get pickupEndedHint;

  /// No description provided for @mealLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load this meal.'**
  String get mealLoadError;

  /// No description provided for @reserveSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reserve this meal?'**
  String get reserveSheetTitle;

  /// No description provided for @reserveSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{title} · {restaurant}'**
  String reserveSheetSubtitle(String title, String restaurant);

  /// No description provided for @howMany.
  ///
  /// In en, this message translates to:
  /// **'How many?'**
  String get howMany;

  /// No description provided for @howManyHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 per person · {left} left'**
  String howManyHint(int left);

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Fewer meals'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'More meals'**
  String get increaseQuantity;

  /// No description provided for @holdUntilTitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll hold it until {time}'**
  String holdUntilTitle(String time);

  /// No description provided for @holdUntilBody.
  ///
  /// In en, this message translates to:
  /// **'Can’t make it? Cancel so someone else can have it.'**
  String get holdUntilBody;

  /// No description provided for @payCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'{price} · pay at the counter'**
  String payCounterTitle(String price);

  /// No description provided for @payCounterBody.
  ///
  /// In en, this message translates to:
  /// **'Cash or card. No payment in the app.'**
  String get payCounterBody;

  /// No description provided for @freeCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'Free · nothing to pay'**
  String get freeCounterTitle;

  /// No description provided for @freeCounterBody.
  ///
  /// In en, this message translates to:
  /// **'Just show your code at the counter.'**
  String get freeCounterBody;

  /// No description provided for @reserveMeals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Reserve 1 meal} other{Reserve {count} meals}}'**
  String reserveMeals(int count);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @reserveSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'The restaurant is responsible for food safety. Check allergens before eating.'**
  String get reserveSafetyNote;

  /// No description provided for @reservedToastTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Reserved. 1 meal is yours.} other{Reserved. {count} meals are yours.}}'**
  String reservedToastTitle(int count);

  /// No description provided for @reservedToastBody.
  ///
  /// In en, this message translates to:
  /// **'Show code {code} at the counter by {time}.'**
  String reservedToastBody(String code, String time);

  /// No description provided for @errorSoldOut.
  ///
  /// In en, this message translates to:
  /// **'Someone just took the last one, so it’s sold out.'**
  String get errorSoldOut;

  /// No description provided for @errorNotEnoughLeft.
  ///
  /// In en, this message translates to:
  /// **'Not that many left now. Pick fewer.'**
  String get errorNotEnoughLeft;

  /// No description provided for @errorAlreadyReserved.
  ///
  /// In en, this message translates to:
  /// **'You already reserved this meal. Find it in Pickups.'**
  String get errorAlreadyReserved;

  /// No description provided for @errorOfferNotLive.
  ///
  /// In en, this message translates to:
  /// **'This offer has ended.'**
  String get errorOfferNotLive;

  /// No description provided for @errorReserveFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t reserve it. Try again.'**
  String get errorReserveFailed;

  /// No description provided for @errorCantOpen.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t open that on this phone.'**
  String get errorCantOpen;
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
