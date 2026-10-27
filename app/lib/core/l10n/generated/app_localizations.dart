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

  /// No description provided for @pickupsImpact.
  ///
  /// In en, this message translates to:
  /// **'{meals, plural, =1{1 meal rescued} other{{meals} meals rescued}} · {saved} saved'**
  String pickupsImpact(int meals, String saved);

  /// No description provided for @pickupsImpactNoSavings.
  ///
  /// In en, this message translates to:
  /// **'{meals, plural, =1{1 meal rescued} other{{meals} meals rescued}}'**
  String pickupsImpactNoSavings(int meals);

  /// No description provided for @pickupsImpactNone.
  ///
  /// In en, this message translates to:
  /// **'Rescue your first meal tonight'**
  String get pickupsImpactNone;

  /// No description provided for @pickupsTabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get pickupsTabUpcoming;

  /// No description provided for @pickupsTabUpcomingCount.
  ///
  /// In en, this message translates to:
  /// **'Upcoming · {count}'**
  String pickupsTabUpcomingCount(int count);

  /// No description provided for @pickupsTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get pickupsTabHistory;

  /// No description provided for @pickupKickerTonight.
  ///
  /// In en, this message translates to:
  /// **'TONIGHT'**
  String get pickupKickerTonight;

  /// No description provided for @pickupKickerToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get pickupKickerToday;

  /// No description provided for @pickupRestaurantDistance.
  ///
  /// In en, this message translates to:
  /// **'{restaurant} · {distance}'**
  String pickupRestaurantDistance(String restaurant, String distance);

  /// No description provided for @pickupAmountCounter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}} · {price} at the counter'**
  String pickupAmountCounter(int count, String price);

  /// No description provided for @pickupAmountFree.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}} · free'**
  String pickupAmountFree(int count);

  /// No description provided for @heldUntil.
  ///
  /// In en, this message translates to:
  /// **'Held until {time}'**
  String heldUntil(String time);

  /// No description provided for @hoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String hoursMinutes(int hours, int minutes);

  /// No description provided for @hoursMinutesLeftTag.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min left'**
  String hoursMinutesLeftTag(int hours, int minutes);

  /// No description provided for @pickupsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get pickupsRecent;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @pickupDetailCollected.
  ///
  /// In en, this message translates to:
  /// **'{restaurant} · {when}'**
  String pickupDetailCollected(String restaurant, String when);

  /// No description provided for @pickupDetailMissed.
  ///
  /// In en, this message translates to:
  /// **'{restaurant} · {day} · hold ended'**
  String pickupDetailMissed(String restaurant, String day);

  /// No description provided for @pickupDetailCancelled.
  ///
  /// In en, this message translates to:
  /// **'{restaurant} · {day} · cancelled'**
  String pickupDetailCancelled(String restaurant, String day);

  /// No description provided for @statusCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get statusCollected;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @pickupsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pickups waiting'**
  String get pickupsEmptyTitle;

  /// No description provided for @pickupsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Reserve a meal on the map and its pickup code shows up here.'**
  String get pickupsEmptyBody;

  /// No description provided for @findMeals.
  ///
  /// In en, this message translates to:
  /// **'Find meals near you'**
  String get findMeals;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Meals you pick up will show here.'**
  String get historyEmpty;

  /// No description provided for @pickupsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your pickups. Pull down to try again.'**
  String get pickupsLoadError;

  /// No description provided for @pickupCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Show this at the counter'**
  String get pickupCodeTitle;

  /// No description provided for @pickupCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{title} · {count, plural, =1{1 meal} other{{count} meals}} · {restaurant}'**
  String pickupCodeSubtitle(String title, int count, String restaurant);

  /// No description provided for @pickupCodeCaption.
  ///
  /// In en, this message translates to:
  /// **'Pickup code · staff enter it to confirm'**
  String get pickupCodeCaption;

  /// No description provided for @pickupCodeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pickup code {digits}'**
  String pickupCodeSemantics(String digits);

  /// No description provided for @heldUntilPay.
  ///
  /// In en, this message translates to:
  /// **'Held until {time} · pay at the counter'**
  String heldUntilPay(String time);

  /// No description provided for @heldUntilFree.
  ///
  /// In en, this message translates to:
  /// **'Held until {time} · nothing to pay'**
  String heldUntilFree(String time);

  /// No description provided for @holdEnded.
  ///
  /// In en, this message translates to:
  /// **'The hold ended at {time}. Reserve again if meals are left.'**
  String holdEnded(String time);

  /// No description provided for @callRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Call restaurant'**
  String get callRestaurant;

  /// No description provided for @cancelReservation.
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation'**
  String get cancelReservation;

  /// No description provided for @cancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this reservation?'**
  String get cancelConfirmTitle;

  /// No description provided for @cancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The meal goes back on the map for someone else.'**
  String get cancelConfirmBody;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get yesCancel;

  /// No description provided for @reservationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Reservation cancelled. The meal is back for others.'**
  String get reservationCancelled;

  /// No description provided for @errorCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t cancel it. Try again.'**
  String get errorCancelFailed;

  /// No description provided for @newSurplusTitle.
  ///
  /// In en, this message translates to:
  /// **'New surplus'**
  String get newSurplusTitle;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @addPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Optional · meals with photos get reserved faster'**
  String get addPhotoHint;

  /// No description provided for @photosComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Adding photos comes in a later version.'**
  String get photosComingSoon;

  /// No description provided for @mealNameHint.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get mealNameHint;

  /// No description provided for @mealNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short note (optional)'**
  String get mealNoteHint;

  /// No description provided for @errorMealName.
  ///
  /// In en, this message translates to:
  /// **'Give the meal a name.'**
  String get errorMealName;

  /// No description provided for @rowCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get rowCategory;

  /// No description provided for @rowQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get rowQuantity;

  /// No description provided for @rowPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get rowPrice;

  /// No description provided for @rowPickupWindow.
  ///
  /// In en, this message translates to:
  /// **'Pickup window'**
  String get rowPickupWindow;

  /// No description provided for @rowPreparedAt.
  ///
  /// In en, this message translates to:
  /// **'Prepared at'**
  String get rowPreparedAt;

  /// No description provided for @rowAllergens.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get rowAllergens;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @quantityValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}} · up to 3 per person'**
  String quantityValue(int count);

  /// No description provided for @setPrice.
  ///
  /// In en, this message translates to:
  /// **'Set a price, or make it free'**
  String get setPrice;

  /// No description provided for @priceWithWas.
  ///
  /// In en, this message translates to:
  /// **'{price} · was {was}'**
  String priceWithWas(String price, String was);

  /// No description provided for @pickupWindowValue.
  ///
  /// In en, this message translates to:
  /// **'Today, {start} – {end}'**
  String pickupWindowValue(String start, String end);

  /// No description provided for @pickupWindowOrder.
  ///
  /// In en, this message translates to:
  /// **'Pickup must end after it starts'**
  String get pickupWindowOrder;

  /// No description provided for @pickupWindowOver.
  ///
  /// In en, this message translates to:
  /// **'This pickup time has already passed'**
  String get pickupWindowOver;

  /// No description provided for @pickupWindowTooLate.
  ///
  /// In en, this message translates to:
  /// **'Pickup must end within 12 hours'**
  String get pickupWindowTooLate;

  /// No description provided for @preparedAtValue.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String preparedAtValue(String time);

  /// No description provided for @preparedAtMissing.
  ///
  /// In en, this message translates to:
  /// **'When was it cooked?'**
  String get preparedAtMissing;

  /// No description provided for @preparedAtInvalid.
  ///
  /// In en, this message translates to:
  /// **'Pick a time earlier today'**
  String get preparedAtInvalid;

  /// No description provided for @allergensMissing.
  ///
  /// In en, this message translates to:
  /// **'Pick allergens, or None'**
  String get allergensMissing;

  /// No description provided for @safetyCheckText.
  ///
  /// In en, this message translates to:
  /// **'This food was prepared today, stored at safe temperatures, has not been served to customers, and is safe to eat.'**
  String get safetyCheckText;

  /// No description provided for @whatCantBePosted.
  ///
  /// In en, this message translates to:
  /// **'What can’t be posted?'**
  String get whatCantBePosted;

  /// No description provided for @notifyNote.
  ///
  /// In en, this message translates to:
  /// **'People within 3 km get one alert when you post.'**
  String get notifyNote;

  /// No description provided for @fixHighlighted.
  ///
  /// In en, this message translates to:
  /// **'Fill in the parts marked in red.'**
  String get fixHighlighted;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'Posted. People nearby can reserve it now.'**
  String get posted;

  /// No description provided for @errorNotApproved.
  ///
  /// In en, this message translates to:
  /// **'Your restaurant needs approval before you can post.'**
  String get errorNotApproved;

  /// No description provided for @errorPostFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t post it. Try again.'**
  String get errorPostFailed;

  /// No description provided for @categorySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'What kind of food?'**
  String get categorySheetTitle;

  /// No description provided for @quantitySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'How many meals?'**
  String get quantitySheetTitle;

  /// No description provided for @quantitySheetHint.
  ///
  /// In en, this message translates to:
  /// **'Each person can reserve up to 3.'**
  String get quantitySheetHint;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @priceSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceSheetTitle;

  /// No description provided for @priceSheetHint.
  ///
  /// In en, this message translates to:
  /// **'People pay this at the counter. There’s no payment in the app.'**
  String get priceSheetHint;

  /// No description provided for @priceField.
  ///
  /// In en, this message translates to:
  /// **'Price (OMR)'**
  String get priceField;

  /// No description provided for @wasPriceField.
  ///
  /// In en, this message translates to:
  /// **'Normal price (OMR, optional)'**
  String get wasPriceField;

  /// No description provided for @wasPriceHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown crossed out next to your price.'**
  String get wasPriceHelper;

  /// No description provided for @makeItFree.
  ///
  /// In en, this message translates to:
  /// **'Make it free'**
  String get makeItFree;

  /// No description provided for @errorPriceFormat.
  ///
  /// In en, this message translates to:
  /// **'Type a price like 0.800'**
  String get errorPriceFormat;

  /// No description provided for @errorWasPrice.
  ///
  /// In en, this message translates to:
  /// **'The normal price must be higher than your price.'**
  String get errorWasPrice;

  /// No description provided for @pickupSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup window'**
  String get pickupSheetTitle;

  /// No description provided for @pickupSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Pickup has to end within 12 hours.'**
  String get pickupSheetHint;

  /// No description provided for @pickupFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get pickupFromLabel;

  /// No description provided for @pickupUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get pickupUntilLabel;

  /// No description provided for @allergenSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergenSheetTitle;

  /// No description provided for @allergenSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Pick everything in this meal. People with allergies rely on it.'**
  String get allergenSheetHint;

  /// No description provided for @cantPostTitle.
  ///
  /// In en, this message translates to:
  /// **'What can’t be posted?'**
  String get cantPostTitle;

  /// No description provided for @cantPostPlate.
  ///
  /// In en, this message translates to:
  /// **'Leftovers from customers’ plates'**
  String get cantPostPlate;

  /// No description provided for @cantPostOpened.
  ///
  /// In en, this message translates to:
  /// **'Dishes that were opened or partly served'**
  String get cantPostOpened;

  /// No description provided for @cantPostExpired.
  ///
  /// In en, this message translates to:
  /// **'Food past its use-by date'**
  String get cantPostExpired;

  /// No description provided for @cantPostHomemade.
  ///
  /// In en, this message translates to:
  /// **'Home-made food'**
  String get cantPostHomemade;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @adminKicker.
  ///
  /// In en, this message translates to:
  /// **'ZAD ADMIN'**
  String get adminKicker;

  /// No description provided for @tabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// No description provided for @tabRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get tabRestaurants;

  /// No description provided for @adminUpdated.
  ///
  /// In en, this message translates to:
  /// **'Muscat · today · updated {time}'**
  String adminUpdated(String time);

  /// No description provided for @mealsRescuedKicker.
  ///
  /// In en, this message translates to:
  /// **'MEALS RESCUED'**
  String get mealsRescuedKicker;

  /// No description provided for @mealsTodayDelta.
  ///
  /// In en, this message translates to:
  /// **'+{count} today'**
  String mealsTodayDelta(int count);

  /// No description provided for @mealsWeekRate.
  ///
  /// In en, this message translates to:
  /// **'{week} this week · {pct}% of reservations collected'**
  String mealsWeekRate(int week, int pct);

  /// No description provided for @mealsWeek.
  ///
  /// In en, this message translates to:
  /// **'{week} this week'**
  String mealsWeek(int week);

  /// No description provided for @kgSaved.
  ///
  /// In en, this message translates to:
  /// **'≈ {kg} kg of food saved (estimate: 0.4 kg per meal)'**
  String kgSaved(int kg);

  /// No description provided for @statRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get statRestaurants;

  /// No description provided for @statRestaurantsDetail.
  ///
  /// In en, this message translates to:
  /// **'approved · {pending} waiting'**
  String statRestaurantsDetail(int pending);

  /// No description provided for @statLiveOffers.
  ///
  /// In en, this message translates to:
  /// **'Live offers'**
  String get statLiveOffers;

  /// No description provided for @statLiveOffersDetail.
  ///
  /// In en, this message translates to:
  /// **'{meals, plural, =1{1 meal} other{{meals} meals}} left right now'**
  String statLiveOffersDetail(int meals);

  /// No description provided for @statPickupsToday.
  ///
  /// In en, this message translates to:
  /// **'Pickups today'**
  String get statPickupsToday;

  /// No description provided for @statPickupsDetail.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting at the counter'**
  String statPickupsDetail(int count);

  /// No description provided for @statUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get statUsers;

  /// No description provided for @statUsersDetail.
  ///
  /// In en, this message translates to:
  /// **'{count} reserved today'**
  String statUsersDetail(int count);

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// No description provided for @attentionApprovals.
  ///
  /// In en, this message translates to:
  /// **'Restaurant approvals'**
  String get attentionApprovals;

  /// No description provided for @attentionApprovalsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting · oldest {age}'**
  String attentionApprovalsValue(int count, String age);

  /// No description provided for @attentionApprovalsNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting'**
  String get attentionApprovalsNone;

  /// No description provided for @attentionOffers.
  ///
  /// In en, this message translates to:
  /// **'Live offers'**
  String get attentionOffers;

  /// No description provided for @attentionOffersValue.
  ///
  /// In en, this message translates to:
  /// **'{count} active · review or remove'**
  String attentionOffersValue(int count);

  /// No description provided for @adminLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load this. Pull down to try again.'**
  String get adminLoadError;

  /// No description provided for @adminRestaurantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get adminRestaurantsTitle;

  /// No description provided for @pendingSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting for review · reply within a day'**
  String pendingSummary(int count);

  /// No description provided for @pendingSummaryNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for review'**
  String get pendingSummaryNone;

  /// No description provided for @tabPendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending · {count}'**
  String tabPendingCount(int count);

  /// No description provided for @tabApprovedCount.
  ///
  /// In en, this message translates to:
  /// **'Approved · {count}'**
  String tabApprovedCount(int count);

  /// No description provided for @tabSuspendedCount.
  ///
  /// In en, this message translates to:
  /// **'Suspended · {count}'**
  String tabSuspendedCount(int count);

  /// No description provided for @reviewKickerNew.
  ///
  /// In en, this message translates to:
  /// **'NEW · WAITING {age}'**
  String reviewKickerNew(String age);

  /// No description provided for @reviewKickerApproved.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get reviewKickerApproved;

  /// No description provided for @reviewKickerSuspended.
  ///
  /// In en, this message translates to:
  /// **'SUSPENDED'**
  String get reviewKickerSuspended;

  /// No description provided for @cuisineArea.
  ///
  /// In en, this message translates to:
  /// **'{cuisine} · {area}'**
  String cuisineArea(String cuisine, String area);

  /// No description provided for @rowOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get rowOwner;

  /// No description provided for @ownerValue.
  ///
  /// In en, this message translates to:
  /// **'{name} · {phone}'**
  String ownerValue(String name, String phone);

  /// No description provided for @rowPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pickup point'**
  String get rowPickupPoint;

  /// No description provided for @rowTypicalDay.
  ///
  /// In en, this message translates to:
  /// **'Typical day'**
  String get rowTypicalDay;

  /// No description provided for @typicalDayValue.
  ///
  /// In en, this message translates to:
  /// **'{meals} meals · usually {low}–{high}% left'**
  String typicalDayValue(int meals, int low, int high);

  /// No description provided for @typicalDayNone.
  ///
  /// In en, this message translates to:
  /// **'Not given'**
  String get typicalDayNone;

  /// No description provided for @termsAccepted.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Terms accepted · {when}'**
  String termsAccepted(String when);

  /// No description provided for @adminReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminReject;

  /// No description provided for @adminApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApprove;

  /// No description provided for @adminSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get adminSuspend;

  /// No description provided for @adminReinstate.
  ///
  /// In en, this message translates to:
  /// **'Reinstate'**
  String get adminReinstate;

  /// No description provided for @ownerNotified.
  ///
  /// In en, this message translates to:
  /// **'The owner is notified either way.'**
  String get ownerNotified;

  /// No description provided for @alsoWaiting.
  ///
  /// In en, this message translates to:
  /// **'Also waiting · {count}'**
  String alsoWaiting(int count);

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @nonePending.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting. New sign-ups show up here.'**
  String get nonePending;

  /// No description provided for @noneApproved.
  ///
  /// In en, this message translates to:
  /// **'No approved restaurants yet.'**
  String get noneApproved;

  /// No description provided for @noneSuspended.
  ///
  /// In en, this message translates to:
  /// **'No suspended restaurants.'**
  String get noneSuspended;

  /// No description provided for @rejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject {name}?'**
  String rejectTitle(String name);

  /// No description provided for @rejectBody.
  ///
  /// In en, this message translates to:
  /// **'They can fix their details and send them again.'**
  String get rejectBody;

  /// No description provided for @suspendTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspend {name}?'**
  String suspendTitle(String name);

  /// No description provided for @suspendBody.
  ///
  /// In en, this message translates to:
  /// **'They can’t post new surplus until you reinstate them.'**
  String get suspendBody;

  /// No description provided for @approvedToast.
  ///
  /// In en, this message translates to:
  /// **'Approved. {name} can post surplus now.'**
  String approvedToast(String name);

  /// No description provided for @rejectedToast.
  ///
  /// In en, this message translates to:
  /// **'Rejected. {name} has been told.'**
  String rejectedToast(String name);

  /// No description provided for @suspendedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} is suspended.'**
  String suspendedToast(String name);

  /// No description provided for @reinstatedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} can post again.'**
  String reinstatedToast(String name);

  /// No description provided for @errorAdminAction.
  ///
  /// In en, this message translates to:
  /// **'That didn’t work. Try again.'**
  String get errorAdminAction;

  /// No description provided for @ageMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String ageMinutes(int minutes);

  /// No description provided for @ageHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String ageHours(int hours);

  /// No description provided for @ageDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String ageDays(int days);

  /// No description provided for @adminOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get adminOffersTitle;

  /// No description provided for @adminOffersSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} live · {meals} meals left'**
  String adminOffersSummary(int count, int meals);

  /// No description provided for @adminOffersNone.
  ///
  /// In en, this message translates to:
  /// **'No live offers right now.'**
  String get adminOffersNone;

  /// No description provided for @adminOfferLine.
  ///
  /// In en, this message translates to:
  /// **'{left} of {total} left · until {time}'**
  String adminOfferLine(int left, int total, String time);

  /// No description provided for @adminRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminRemove;

  /// No description provided for @removeTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this offer?'**
  String get removeTitle;

  /// No description provided for @removeBody.
  ///
  /// In en, this message translates to:
  /// **'{title} from {restaurant} stops showing to users. People who already reserved can still pick up.'**
  String removeBody(String title, String restaurant);

  /// No description provided for @removedToast.
  ///
  /// In en, this message translates to:
  /// **'Offer removed.'**
  String get removedToast;

  /// No description provided for @insightsTabForecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get insightsTabForecast;

  /// No description provided for @insightsTabImpact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get insightsTabImpact;

  /// No description provided for @insightsImpactSoon.
  ///
  /// In en, this message translates to:
  /// **'Impact stats come later: meals rescued, money saved and food kept out of the bin.'**
  String get insightsImpactSoon;

  /// No description provided for @insightsTomorrowKicker.
  ///
  /// In en, this message translates to:
  /// **'TOMORROW · {day}'**
  String insightsTomorrowKicker(String day);

  /// No description provided for @confidencePillLow.
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get confidencePillLow;

  /// No description provided for @confidencePillMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium confidence'**
  String get confidencePillMedium;

  /// No description provided for @confidencePillHigh.
  ///
  /// In en, this message translates to:
  /// **'High confidence'**
  String get confidencePillHigh;

  /// No description provided for @confidencePillRough.
  ///
  /// In en, this message translates to:
  /// **'Rough estimate'**
  String get confidencePillRough;

  /// No description provided for @insightsExpected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{surplus meal expected} other{surplus meals expected}}'**
  String insightsExpected(int count);

  /// No description provided for @insightsLikelyRange.
  ///
  /// In en, this message translates to:
  /// **'Likely between {low} and {high}'**
  String insightsLikelyRange(int low, int high);

  /// No description provided for @insightsNext7Title.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get insightsNext7Title;

  /// No description provided for @insightsNext7Note.
  ///
  /// In en, this message translates to:
  /// **'Expected surplus meals · band = likely range · shaded = weekend'**
  String get insightsNext7Note;

  /// No description provided for @insightsViewAsList.
  ///
  /// In en, this message translates to:
  /// **'View as list'**
  String get insightsViewAsList;

  /// No description provided for @insightsViewAsChart.
  ///
  /// In en, this message translates to:
  /// **'View as chart'**
  String get insightsViewAsChart;

  /// No description provided for @insightsListDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get insightsListDay;

  /// No description provided for @insightsListExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get insightsListExpected;

  /// No description provided for @insightsListRange.
  ///
  /// In en, this message translates to:
  /// **'Likely range'**
  String get insightsListRange;

  /// No description provided for @insightsListWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get insightsListWeekend;

  /// No description provided for @insightsTooltipExpected.
  ///
  /// In en, this message translates to:
  /// **'~{count} meals'**
  String insightsTooltipExpected(int count);

  /// No description provided for @insightsTooltipRange.
  ///
  /// In en, this message translates to:
  /// **'likely {low}–{high}'**
  String insightsTooltipRange(int low, int high);

  /// No description provided for @insightsChartHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a bar for details.'**
  String get insightsChartHint;

  /// No description provided for @insightsChartDay.
  ///
  /// In en, this message translates to:
  /// **'{day}: about {count}, likely {low} to {high}.'**
  String insightsChartDay(String day, int count, int low, int high);

  /// No description provided for @insightsWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this forecast'**
  String get insightsWhyTitle;

  /// No description provided for @reasonWeekdayHigher.
  ///
  /// In en, this message translates to:
  /// **'{weekday, select, mon{Mondays} tue{Tuesdays} wed{Wednesdays} thu{Thursdays} fri{Fridays} sat{Saturdays} sun{Sundays} other{This day}} are usually {pct}% higher'**
  String reasonWeekdayHigher(String weekday, int pct);

  /// No description provided for @reasonWeekdayLower.
  ///
  /// In en, this message translates to:
  /// **'{weekday, select, mon{Mondays} tue{Tuesdays} wed{Wednesdays} thu{Thursdays} fri{Fridays} sat{Saturdays} sun{Sundays} other{This day}} are usually {pct}% lower'**
  String reasonWeekdayLower(String weekday, int pct);

  /// No description provided for @reasonDaysLogged.
  ///
  /// In en, this message translates to:
  /// **'Based on {days, plural, =1{1 day} other{{days} days}} of your logs'**
  String reasonDaysLogged(int days);

  /// No description provided for @reasonWeekdayAverage.
  ///
  /// In en, this message translates to:
  /// **'{weeks}-week weekday average'**
  String reasonWeekdayAverage(int weeks);

  /// No description provided for @reasonRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan pattern applied'**
  String get reasonRamadan;

  /// No description provided for @reasonHoliday.
  ///
  /// In en, this message translates to:
  /// **'Public holiday pattern applied'**
  String get reasonHoliday;

  /// No description provided for @reasonColdStart.
  ///
  /// In en, this message translates to:
  /// **'Rough estimate from your typical day'**
  String get reasonColdStart;

  /// No description provided for @insightsSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Consider preparing about {count} fewer portions on {day}, or plan a surplus offer for closing time.'**
  String insightsSuggestion(int count, String day);

  /// No description provided for @insightsSuggestionLow.
  ///
  /// In en, this message translates to:
  /// **'Little surplus expected on {day}. Post anything left at closing.'**
  String insightsSuggestionLow(String day);

  /// No description provided for @insightsPostNow.
  ///
  /// In en, this message translates to:
  /// **'Post surplus now'**
  String get insightsPostNow;

  /// No description provided for @insightsNeverPosts.
  ///
  /// In en, this message translates to:
  /// **'A forecast never posts meals for you. You confirm the real quantity.'**
  String get insightsNeverPosts;

  /// No description provided for @insightsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Last 2 weeks: off by about {count, plural, =1{1 meal} other{{count} meals}} a day'**
  String insightsAccuracy(int count);

  /// No description provided for @insightsAccuracyUnderOne.
  ///
  /// In en, this message translates to:
  /// **'Last 2 weeks: off by less than 1 meal a day'**
  String get insightsAccuracyUnderOne;

  /// No description provided for @insightsAccuracyNotYet.
  ///
  /// In en, this message translates to:
  /// **'Log a few more days to see how close the forecast gets.'**
  String get insightsAccuracyNotYet;

  /// No description provided for @insightsLogYesterday.
  ///
  /// In en, this message translates to:
  /// **'Log yesterday ({day})'**
  String insightsLogYesterday(String day);

  /// No description provided for @insightsLogYesterdayNote.
  ///
  /// In en, this message translates to:
  /// **'Prepared and left over · about 10 seconds'**
  String get insightsLogYesterdayNote;

  /// No description provided for @insightsLogNow.
  ///
  /// In en, this message translates to:
  /// **'Log now'**
  String get insightsLogNow;

  /// No description provided for @insightsYesterdayLogged.
  ///
  /// In en, this message translates to:
  /// **'Yesterday is logged ({day})'**
  String insightsYesterdayLogged(String day);

  /// No description provided for @loggedNumbers.
  ///
  /// In en, this message translates to:
  /// **'{prepared} prepared · {surplus} left over'**
  String loggedNumbers(int prepared, int surplus);

  /// No description provided for @insightsEditLog.
  ///
  /// In en, this message translates to:
  /// **'Edit log'**
  String get insightsEditLog;

  /// No description provided for @insightsNoForecast.
  ///
  /// In en, this message translates to:
  /// **'No forecast yet. It appears after the next nightly run.'**
  String get insightsNoForecast;

  /// No description provided for @errorLoadInsights.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your forecast. Pull down to try again.'**
  String get errorLoadInsights;

  /// No description provided for @dailyLogHeader.
  ///
  /// In en, this message translates to:
  /// **'Daily log'**
  String get dailyLogHeader;

  /// No description provided for @dailyLogTitleYesterday.
  ///
  /// In en, this message translates to:
  /// **'Log yesterday'**
  String get dailyLogTitleYesterday;

  /// No description provided for @dailyLogTitleDay.
  ///
  /// In en, this message translates to:
  /// **'Log {day}'**
  String dailyLogTitleDay(String day);

  /// No description provided for @dailyLogIntro.
  ///
  /// In en, this message translates to:
  /// **'{date} · about 10 seconds. Each log makes your forecast more accurate.'**
  String dailyLogIntro(String date);

  /// No description provided for @dailyLogPreparedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Meals prepared yesterday'**
  String get dailyLogPreparedYesterday;

  /// No description provided for @dailyLogPreparedOn.
  ///
  /// In en, this message translates to:
  /// **'Meals prepared on {day}'**
  String dailyLogPreparedOn(String day);

  /// No description provided for @dailyLogLeftOver.
  ///
  /// In en, this message translates to:
  /// **'Left over at closing'**
  String get dailyLogLeftOver;

  /// No description provided for @dailyLogLeftOverHelp.
  ///
  /// In en, this message translates to:
  /// **'Count everything not sold to regular customers, including meals you posted on ZAD.'**
  String get dailyLogLeftOverHelp;

  /// No description provided for @dailyLogShare.
  ///
  /// In en, this message translates to:
  /// **'{surplus} of {prepared} left · {pct}%'**
  String dailyLogShare(int surplus, int prepared, int pct);

  /// No description provided for @dailyLogFewerPrepared.
  ///
  /// In en, this message translates to:
  /// **'Fewer meals prepared'**
  String get dailyLogFewerPrepared;

  /// No description provided for @dailyLogMorePrepared.
  ///
  /// In en, this message translates to:
  /// **'More meals prepared'**
  String get dailyLogMorePrepared;

  /// No description provided for @dailyLogFewerLeft.
  ///
  /// In en, this message translates to:
  /// **'Fewer left over'**
  String get dailyLogFewerLeft;

  /// No description provided for @dailyLogMoreLeft.
  ///
  /// In en, this message translates to:
  /// **'More left over'**
  String get dailyLogMoreLeft;

  /// No description provided for @dailyLogLeftOverMax.
  ///
  /// In en, this message translates to:
  /// **'Left over can’t be more than prepared.'**
  String get dailyLogLeftOverMax;

  /// No description provided for @dailyLogGuessed.
  ///
  /// In en, this message translates to:
  /// **'The forecast guessed ~{count} for {day}'**
  String dailyLogGuessed(int count, String day);

  /// No description provided for @dailyLogYesterdayWord.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get dailyLogYesterdayWord;

  /// No description provided for @dailyLogOffBy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Spot on.} =1{Off by 1 meal.} other{Off by {count} meals.}}'**
  String dailyLogOffBy(int count);

  /// No description provided for @dailyLogLearning.
  ///
  /// In en, this message translates to:
  /// **'{days} days logged, so it now learns from your own numbers.'**
  String dailyLogLearning(int days);

  /// No description provided for @dailyLogWarmingUp.
  ///
  /// In en, this message translates to:
  /// **'{days} of 14 days logged. After that it learns from your own numbers.'**
  String dailyLogWarmingUp(int days);

  /// No description provided for @dailyLogNoGuessTitle.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Your first log} =1{1 day logged} other{{days} days logged}}'**
  String dailyLogNoGuessTitle(int days);

  /// No description provided for @dailyLogNoGuessBody.
  ///
  /// In en, this message translates to:
  /// **'There was no forecast for this day to compare with.'**
  String get dailyLogNoGuessBody;

  /// No description provided for @dailyLogEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier days'**
  String get dailyLogEarlier;

  /// No description provided for @dailyLogEarlierNote.
  ///
  /// In en, this message translates to:
  /// **'Fix a missed or wrong day'**
  String get dailyLogEarlierNote;

  /// No description provided for @dailyLogEarlierSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The last 2 weeks. Tap a day to log or fix it.'**
  String get dailyLogEarlierSubtitle;

  /// No description provided for @dailyLogNotLogged.
  ///
  /// In en, this message translates to:
  /// **'Not logged'**
  String get dailyLogNotLogged;

  /// No description provided for @dailyLogSave.
  ///
  /// In en, this message translates to:
  /// **'Save log'**
  String get dailyLogSave;

  /// No description provided for @dailyLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. {day} is logged.'**
  String dailyLogSaved(String day);

  /// No description provided for @dailyLogSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the log. Try again.'**
  String get dailyLogSaveError;

  /// No description provided for @dailyLogAfter14.
  ///
  /// In en, this message translates to:
  /// **'After 14 days, the forecast learns from your own numbers.'**
  String get dailyLogAfter14;

  /// No description provided for @insightsListNote.
  ///
  /// In en, this message translates to:
  /// **'Expected surplus meals and the likely range for each day'**
  String get insightsListNote;

  /// No description provided for @errorLoadOffers.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your offers. Pull down to try again.'**
  String get errorLoadOffers;

  /// No description provided for @offersCollectedWeek.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No meals collected this week yet} =1{1 meal collected this week} other{{count} meals collected this week}}'**
  String offersCollectedWeek(int count);

  /// No description provided for @offersTabLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get offersTabLive;

  /// No description provided for @offersTabLiveCount.
  ///
  /// In en, this message translates to:
  /// **'Live · {count}'**
  String offersTabLiveCount(int count);

  /// No description provided for @offersTabPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get offersTabPast;

  /// No description provided for @offersPastEmpty.
  ///
  /// In en, this message translates to:
  /// **'Offers that have ended will show here.'**
  String get offersPastEmpty;

  /// No description provided for @offerPastDetail.
  ///
  /// In en, this message translates to:
  /// **'{day} · {collected} of {total} collected'**
  String offerPastDetail(String day, int collected, int total);

  /// No description provided for @offerStatusAllTaken.
  ///
  /// In en, this message translates to:
  /// **'All taken'**
  String get offerStatusAllTaken;

  /// No description provided for @offerStatusEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get offerStatusEnded;

  /// No description provided for @offerStatusEndedEarly.
  ///
  /// In en, this message translates to:
  /// **'Ended early'**
  String get offerStatusEndedEarly;

  /// No description provided for @offerStatusRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get offerStatusRemoved;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your notifications. Pull down to try again.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all caught up'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyUser.
  ///
  /// In en, this message translates to:
  /// **'We’ll let you know when a restaurant near you posts meals.'**
  String get notificationsEmptyUser;

  /// No description provided for @notificationsEmptyRestaurant.
  ///
  /// In en, this message translates to:
  /// **'News about your restaurant will show here.'**
  String get notificationsEmptyRestaurant;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsAllRead.
  ///
  /// In en, this message translates to:
  /// **'Nothing new'**
  String get notificationsAllRead;

  /// No description provided for @notificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new} other{{count} new}}'**
  String notificationsUnread(int count);

  /// No description provided for @notificationJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationJustNow;

  /// No description provided for @notificationMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String notificationMinutesAgo(int minutes);

  /// No description provided for @notificationHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String notificationHoursAgo(int hours);

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Rescuing meals since {month}'**
  String memberSince(String month);

  /// No description provided for @profileStatMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals rescued'**
  String get profileStatMeals;

  /// No description provided for @profileStatSaved.
  ///
  /// In en, this message translates to:
  /// **'OMR saved'**
  String get profileStatSaved;

  /// No description provided for @profileStatPickups.
  ///
  /// In en, this message translates to:
  /// **'Pickups'**
  String get profileStatPickups;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionPickups.
  ///
  /// In en, this message translates to:
  /// **'Pickups'**
  String get profileSectionPickups;

  /// No description provided for @profileSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileSectionNotifications;

  /// No description provided for @profileSectionRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get profileSectionRestaurant;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileEditName;

  /// No description provided for @profilePickupHistory.
  ///
  /// In en, this message translates to:
  /// **'Pickup history'**
  String get profilePickupHistory;

  /// No description provided for @profilePickupHistoryValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pickups yet} =1{1 pickup so far} other{{count} pickups so far}}'**
  String profilePickupHistoryValue(int count);

  /// No description provided for @profileMyArea.
  ///
  /// In en, this message translates to:
  /// **'My area'**
  String get profileMyArea;

  /// No description provided for @profileAreaUnset.
  ///
  /// In en, this message translates to:
  /// **'Not set · showing Muscat'**
  String get profileAreaUnset;

  /// No description provided for @profileAlerts.
  ///
  /// In en, this message translates to:
  /// **'New meals nearby'**
  String get profileAlerts;

  /// No description provided for @profileAlertsValue.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 alerts a day, within 3 km'**
  String get profileAlertsValue;

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified by ZAD'**
  String get profileVerified;

  /// No description provided for @profileEditRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Edit restaurant details'**
  String get profileEditRestaurant;

  /// No description provided for @profileEditRestaurantValue.
  ///
  /// In en, this message translates to:
  /// **'Name, phone, pickup point and typical day'**
  String get profileEditRestaurantValue;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profilePickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pickup point'**
  String get profilePickupPoint;

  /// No description provided for @profileTypicalDay.
  ///
  /// In en, this message translates to:
  /// **'Typical day'**
  String get profileTypicalDay;

  /// No description provided for @profileTypicalDayValue.
  ///
  /// In en, this message translates to:
  /// **'{meals} meals a day · {share} left over'**
  String profileTypicalDayValue(int meals, String share);

  /// No description provided for @profileOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get profileOwner;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get profileRoleAdmin;

  /// No description provided for @profileAdminNote.
  ///
  /// In en, this message translates to:
  /// **'Admin accounts are made on the server. Restaurants and offers are in the other tabs.'**
  String get profileAdminNote;

  /// No description provided for @setAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your area'**
  String get setAreaTitle;

  /// No description provided for @setAreaBody.
  ///
  /// In en, this message translates to:
  /// **'Move the map to your neighbourhood. We show meals within 5 km of the pin.'**
  String get setAreaBody;

  /// No description provided for @setAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map to your area'**
  String get setAreaHint;

  /// No description provided for @setAreaFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding the area…'**
  String get setAreaFinding;

  /// No description provided for @setAreaPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned area'**
  String get setAreaPinned;

  /// No description provided for @setAreaPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Saved to about 100 m. Restaurants never see it.'**
  String get setAreaPrivacy;

  /// No description provided for @setAreaSave.
  ///
  /// In en, this message translates to:
  /// **'Use this area'**
  String get setAreaSave;

  /// No description provided for @setAreaSaved.
  ///
  /// In en, this message translates to:
  /// **'Area saved. Showing meals near it.'**
  String get setAreaSaved;
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
