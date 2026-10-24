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

  @override
  String onboardingStep(int step, int total) {
    return 'Restaurant setup · $step of $total';
  }

  @override
  String get detailsTitle => 'About your restaurant';

  @override
  String get detailsBody => 'This is what people see next to your meals.';

  @override
  String get addLogo => 'Add a logo';

  @override
  String get addLogoHint => 'Optional · a square image works best';

  @override
  String get logoComingSoon =>
      'Logo upload is coming soon. You can skip it for now.';

  @override
  String get fieldRestaurantName => 'Restaurant name';

  @override
  String get fieldCuisine => 'Cuisine';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get phoneHelper => 'Shown on your meals so people can call you.';

  @override
  String get fieldDescription => 'Short description (optional)';

  @override
  String get cuisineMore => 'More…';

  @override
  String get cuisineBakery => 'Bakery & sweets';

  @override
  String get cuisineOmani => 'Omani';

  @override
  String get cuisineArabic => 'Arabic';

  @override
  String get cuisineIndian => 'Indian';

  @override
  String get cuisineCafe => 'Café';

  @override
  String get cuisineFastFood => 'Fast food';

  @override
  String get cuisineHealthy => 'Healthy';

  @override
  String get cuisineGrill => 'Grill & shawarma';

  @override
  String get cuisineSeafood => 'Seafood';

  @override
  String get cuisineAsian => 'Asian';

  @override
  String get cuisineInternational => 'International';

  @override
  String get cuisineOther => 'Other';

  @override
  String get errorRestaurantNameRequired => 'Enter your restaurant’s name.';

  @override
  String get errorRestaurantNameTooLong => 'Keep the name under 60 characters.';

  @override
  String get errorCuisineRequired => 'Pick the cuisine that fits best.';

  @override
  String get errorPhoneRequired => 'Enter a number people can call.';

  @override
  String get errorPhoneInvalid => 'Enter an Omani number, like +968 9123 4567.';

  @override
  String get errorDescriptionTooLong => 'Keep it under 140 characters.';

  @override
  String get errorAddressRequired => 'Add the pickup address.';

  @override
  String get pickupTitle => 'Where do people pick up?';

  @override
  String get pickupBody =>
      'People see this pin on the map and get directions to it.';

  @override
  String get pickupMoveHint => 'Move the map to put the pin on your entrance';

  @override
  String pickupFromPin(String city) {
    return '$city · filled in from the pin';
  }

  @override
  String get pickupEditHint => 'Tap to add the building or a landmark';

  @override
  String get pickupFindingAddress => 'Finding the address…';

  @override
  String get pickupNoAddress => 'Add the pickup address';

  @override
  String get pickupLocateMe => 'Go to my location';

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get pickupAddressTitle => 'Pickup address';

  @override
  String get pickupAddressField => 'Street, building, landmark';

  @override
  String get pickupAddressHelper =>
      'Anything that helps people find your entrance.';

  @override
  String get save => 'Save';

  @override
  String get mapUnavailable =>
      'The map isn’t available in this build, so the pin is set to Al Khuwair, Muscat. Run on Android with the Mapbox token to move it.';

  @override
  String get typicalDayTitle => 'Your typical day';

  @override
  String get typicalDayBody =>
      'Two rough answers give you a first surplus forecast. You can change them later in Settings.';

  @override
  String get mealsPerDayQuestion => 'Meals you prepare on a normal day';

  @override
  String get mealsUnit => 'meals';

  @override
  String get fewerMeals => 'Fewer meals';

  @override
  String get moreMeals => 'More meals';

  @override
  String get leftOverQuestion => 'How much is usually left at closing?';

  @override
  String get surplusUnder5 => 'Under 5%';

  @override
  String get surplus5to10 => '5–10%';

  @override
  String get surplus10to20 => '10–20%';

  @override
  String get surplusOver20 => 'Over 20%';

  @override
  String firstForecast(int low, int high) {
    return 'First forecast: ~$low–$high meals a day';
  }

  @override
  String get firstForecastNote =>
      'A rough estimate until you’ve logged 14 days of real numbers.';

  @override
  String get firstForecastEmptyTitle => 'Your first forecast';

  @override
  String get firstForecastEmptyNote =>
      'Pick how much is usually left to see it.';

  @override
  String get errorSurplusRequired => 'Pick the closest answer.';

  @override
  String get restaurantTermsPrefix => 'I accept the ';

  @override
  String get restaurantTerms => 'Restaurant Terms';

  @override
  String get restaurantTermsSuffix =>
      '. We are responsible for the safety, labelling and allergen information of the food we post.';

  @override
  String get errorRestaurantTermsRequired =>
      'Please accept the Restaurant Terms to continue.';

  @override
  String get submitForReview => 'Submit for review';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get pendingTitle => 'Thanks! We’re checking your restaurant';

  @override
  String get pendingBody =>
      'Our team usually reviews new restaurants within a day. We’ll send you a notification when you can post meals.';

  @override
  String get rejectedTitle => 'We couldn’t approve your restaurant';

  @override
  String get rejectedBody =>
      'Check your details and send them again. Our team will take another look.';

  @override
  String get suspendedTitle => 'Your restaurant is paused';

  @override
  String get suspendedBody =>
      'The ZAD team has paused your meals for now. Contact us to find out why.';

  @override
  String get pendingStepAccount => 'Account created';

  @override
  String get pendingStepDetails => 'Restaurant details sent';

  @override
  String get pendingStepReview => 'Review by the ZAD team';

  @override
  String get pendingInProgress => 'In progress';

  @override
  String get pendingNotApproved => 'Not approved';

  @override
  String get pendingPaused => 'Paused';

  @override
  String get pendingStepFirstSurplus => 'Post your first surplus';

  @override
  String get pendingUnlocks => 'Unlocks after approval';

  @override
  String get editRestaurantDetails => 'Edit restaurant details';

  @override
  String get logOut => 'Log out';

  @override
  String todayAt(String time) {
    return 'Today, $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday, $time';
  }

  @override
  String get errorLoadRestaurant =>
      'We couldn’t load your restaurant. Pull down to try again.';

  @override
  String get tonightAt => 'Tonight at';

  @override
  String verifiedArea(String area) {
    return 'Verified · $area';
  }

  @override
  String get statPosted => 'posted';

  @override
  String get statReserved => 'reserved';

  @override
  String get statCollected => 'collected';

  @override
  String get liveNow => 'LIVE NOW';

  @override
  String offerMeta(int left, int total, String price, String time) {
    return '$left of $total left · $price · until $time';
  }

  @override
  String get free => 'Free';

  @override
  String minutesLeft(int minutes) {
    return '$minutes min';
  }

  @override
  String hoursMinutesLeft(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get editQuantity => 'Edit quantity';

  @override
  String get endEarly => 'End early';

  @override
  String waitingForPickup(int count) {
    return 'Waiting for pickup · $count';
  }

  @override
  String get seeAll => 'See all';

  @override
  String get showLess => 'Show less';

  @override
  String reservationName(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$name · $_temp0';
  }

  @override
  String reservationWaitingDetail(String hint, String time) {
    return 'Code ••$hint · held until $time';
  }

  @override
  String reservationCollectedDetail(String time) {
    return 'Collected at $time';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get collected => 'Collected';

  @override
  String get noPickupsYet =>
      'No pickups waiting. New reservations show up here.';

  @override
  String get nothingLiveTitle => 'Nothing live right now';

  @override
  String get nothingLiveBody =>
      'Post what’s left tonight and people within 3 km get an alert.';

  @override
  String get postSurplus => 'Post surplus';

  @override
  String forecastTomorrow(String day, int count) {
    return 'Tomorrow ($day): ~$count surplus meals';
  }

  @override
  String forecastRange(int low, int high, String confidence) {
    return 'Range $low–$high · $confidence';
  }

  @override
  String get confidenceLow => 'low confidence';

  @override
  String get confidenceMedium => 'medium confidence';

  @override
  String get confidenceHigh => 'high confidence';

  @override
  String get roughEstimate => 'rough estimate';

  @override
  String get confirmPickup => 'Confirm pickup';

  @override
  String get notifications => 'Notifications';

  @override
  String get tabToday => 'Today';

  @override
  String get tabOffers => 'Offers';

  @override
  String get tabInsights => 'Insights';

  @override
  String get tabProfile => 'Profile';

  @override
  String get newSurplus => 'New surplus';

  @override
  String get errorLoadToday =>
      'We couldn’t load tonight’s pickups. Pull down to try again.';

  @override
  String get confirmPickupBody => 'Ask the customer for their 6-digit code.';

  @override
  String confirmPickupBodyFor(String name) {
    return 'Ask $name for their 6-digit code.';
  }

  @override
  String get pickupCodeLabel => 'Pickup code';

  @override
  String codeMatches(String name) {
    return 'Code matches · $name';
  }

  @override
  String codeMatchDetail(int count, String title, String amount) {
    return '$count × $title · collect $amount';
  }

  @override
  String codeMatchDetailFree(int count, String title) {
    return '$count × $title · free';
  }

  @override
  String get codeNotFound => 'No pickup matches this code. Check the digits.';

  @override
  String get codeAlreadyCollected => 'This code was already collected.';

  @override
  String get codeExpired =>
      'This hold has expired, so the meals went back on the offer.';

  @override
  String codeLocked(String time) {
    return 'Too many wrong codes. Try again at $time.';
  }

  @override
  String get codeLockNote => 'Too many wrong codes locks entry for 10 minutes.';

  @override
  String pickupCollectedToast(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return 'Collected · $name · $_temp0';
  }

  @override
  String get editQuantityTitle => 'Edit meals left';

  @override
  String editQuantityBody(int taken) {
    String _temp0 = intl.Intl.pluralLogic(
      taken,
      locale: localeName,
      other: '$taken meals are already reserved or collected.',
      one: '1 meal is already reserved or collected.',
      zero: 'Nobody has reserved yet.',
    );
    return '$_temp0';
  }

  @override
  String get mealsLeftUnit => 'meals left';

  @override
  String get errorQuantityBelowTaken =>
      'You can’t go below what’s already reserved.';

  @override
  String get endEarlyTitle => 'End this offer now?';

  @override
  String get endEarlyBody =>
      'Nobody new can reserve it. People who already reserved can still pick up.';

  @override
  String get endOffer => 'End offer';

  @override
  String get keepLive => 'Keep it live';

  @override
  String get offerEnded => 'Offer ended. Waiting pickups are still valid.';
}
