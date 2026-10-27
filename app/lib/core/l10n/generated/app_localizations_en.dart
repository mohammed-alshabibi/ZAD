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

  @override
  String get tabHome => 'Home';

  @override
  String get tabPickups => 'Pickups';

  @override
  String get homeAreaUnset => 'Set my area';

  @override
  String get homeAreaNearYou => 'Near you';

  @override
  String homeMealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String homeMealsTitle(String meals) {
    return '$meals left near you tonight';
  }

  @override
  String get homeNoMealsTitle => 'Nothing left near you right now';

  @override
  String get homeNoMealsBody =>
      'Restaurants post what’s left around closing time. We’ll send you an alert when one within 3 km does.';

  @override
  String get homeNoMatchesTitle => 'No meals match';

  @override
  String get homeNoMatchesBody => 'Try another filter or clear the search.';

  @override
  String get homeLoadError => 'We couldn’t load meals near you.';

  @override
  String get homeLoading => 'Looking for meals near you…';

  @override
  String get tryAgain => 'Try again';

  @override
  String get filterClosingSoon => 'Closing soon';

  @override
  String get filterUnderOneOmr => 'Under 1 OMR';

  @override
  String get categoryBakery => 'Bakery';

  @override
  String get categoryRiceMandi => 'Rice & mandi';

  @override
  String get categoryGrill => 'Grill';

  @override
  String get categorySandwiches => 'Sandwiches';

  @override
  String get categorySweets => 'Sweets';

  @override
  String get categoryHealthy => 'Healthy';

  @override
  String get categoryMixed => 'Mixed';

  @override
  String get searchMealsHint => 'Search meals or restaurants';

  @override
  String offerCardDetails(String title, String distance, int minutes) {
    return '$title · $distance · $minutes min walk';
  }

  @override
  String offerRowDetails(String restaurant, String distance) {
    return '$restaurant · $distance';
  }

  @override
  String get pickupNow => 'Pickup now';

  @override
  String pickupFrom(String time) {
    return 'Pickup from $time';
  }

  @override
  String pickupUntil(String time) {
    return 'until $time';
  }

  @override
  String minutesLeftTag(int minutes) {
    return '$minutes min left';
  }

  @override
  String mealsLeftShort(int count) {
    return '$count left';
  }

  @override
  String get closingFirst => 'Closing first';

  @override
  String get showMyLocation => 'Show my location';

  @override
  String mapPinLabel(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals left',
      one: '1 meal left',
    );
    return '$name, $_temp0';
  }

  @override
  String get mealDetails => 'Meal details';

  @override
  String get close => 'Close';

  @override
  String get directions => 'Directions';

  @override
  String get call => 'Call';

  @override
  String mealDetailsLine(String restaurant, String distance, int minutes) {
    return '$restaurant · $distance · $minutes min walk';
  }

  @override
  String get allergensSafety => 'Allergens & safety';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenMilk => 'Dairy';

  @override
  String get allergenEggs => 'Eggs';

  @override
  String get allergenNuts => 'Nuts';

  @override
  String get allergenPeanuts => 'Peanuts';

  @override
  String get allergenSesame => 'Sesame';

  @override
  String get allergenSoy => 'Soy';

  @override
  String get allergenFish => 'Fish';

  @override
  String get allergenShellfish => 'Shellfish';

  @override
  String get allergenNone => 'No common allergens';

  @override
  String safetyNote(String time) {
    return 'Prepared today at $time and stored safely. The restaurant is responsible for food safety. Eat promptly or refrigerate, and ask staff if you are unsure about allergens.';
  }

  @override
  String get payAtPickup => 'Pay at pickup · cash or card';

  @override
  String get nothingToPay => 'Nothing to pay at pickup';

  @override
  String get reserve => 'Reserve';

  @override
  String get reserved => 'Reserved';

  @override
  String reservedHeldUntil(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0 · held until $time';
  }

  @override
  String get showPickupCode => 'Show pickup code';

  @override
  String get soldOut => 'Sold out';

  @override
  String get soldOutHint => 'Meals come back if someone cancels.';

  @override
  String get pickupEnded => 'Pickup has ended';

  @override
  String get pickupEndedHint => 'This offer is closed.';

  @override
  String get mealLoadError => 'We couldn’t load this meal.';

  @override
  String get reserveSheetTitle => 'Reserve this meal?';

  @override
  String reserveSheetSubtitle(String title, String restaurant) {
    return '$title · $restaurant';
  }

  @override
  String get howMany => 'How many?';

  @override
  String howManyHint(int left) {
    return 'Up to 3 per person · $left left';
  }

  @override
  String get decreaseQuantity => 'Fewer meals';

  @override
  String get increaseQuantity => 'More meals';

  @override
  String holdUntilTitle(String time) {
    return 'We’ll hold it until $time';
  }

  @override
  String get holdUntilBody =>
      'Can’t make it? Cancel so someone else can have it.';

  @override
  String payCounterTitle(String price) {
    return '$price · pay at the counter';
  }

  @override
  String get payCounterBody => 'Cash or card. No payment in the app.';

  @override
  String get freeCounterTitle => 'Free · nothing to pay';

  @override
  String get freeCounterBody => 'Just show your code at the counter.';

  @override
  String reserveMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reserve $count meals',
      one: 'Reserve 1 meal',
    );
    return '$_temp0';
  }

  @override
  String get notNow => 'Not now';

  @override
  String get reserveSafetyNote =>
      'The restaurant is responsible for food safety. Check allergens before eating.';

  @override
  String reservedToastTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reserved. $count meals are yours.',
      one: 'Reserved. 1 meal is yours.',
    );
    return '$_temp0';
  }

  @override
  String reservedToastBody(String code, String time) {
    return 'Show code $code at the counter by $time.';
  }

  @override
  String get errorSoldOut =>
      'Someone just took the last one, so it’s sold out.';

  @override
  String get errorNotEnoughLeft => 'Not that many left now. Pick fewer.';

  @override
  String get errorAlreadyReserved =>
      'You already reserved this meal. Find it in Pickups.';

  @override
  String get errorOfferNotLive => 'This offer has ended.';

  @override
  String get errorReserveFailed => 'We couldn’t reserve it. Try again.';

  @override
  String get errorCantOpen => 'We couldn’t open that on this phone.';

  @override
  String pickupsImpact(int meals, String saved) {
    String _temp0 = intl.Intl.pluralLogic(
      meals,
      locale: localeName,
      other: '$meals meals rescued',
      one: '1 meal rescued',
    );
    return '$_temp0 · $saved saved';
  }

  @override
  String pickupsImpactNoSavings(int meals) {
    String _temp0 = intl.Intl.pluralLogic(
      meals,
      locale: localeName,
      other: '$meals meals rescued',
      one: '1 meal rescued',
    );
    return '$_temp0';
  }

  @override
  String get pickupsImpactNone => 'Rescue your first meal tonight';

  @override
  String get pickupsTabUpcoming => 'Upcoming';

  @override
  String pickupsTabUpcomingCount(int count) {
    return 'Upcoming · $count';
  }

  @override
  String get pickupsTabHistory => 'History';

  @override
  String get pickupKickerTonight => 'TONIGHT';

  @override
  String get pickupKickerToday => 'TODAY';

  @override
  String pickupRestaurantDistance(String restaurant, String distance) {
    return '$restaurant · $distance';
  }

  @override
  String pickupAmountCounter(int count, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0 · $price at the counter';
  }

  @override
  String pickupAmountFree(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0 · free';
  }

  @override
  String heldUntil(String time) {
    return 'Held until $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String hoursMinutesLeftTag(int hours, int minutes) {
    return '$hours h $minutes min left';
  }

  @override
  String get pickupsRecent => 'Recent';

  @override
  String get dayToday => 'Today';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String pickupDetailCollected(String restaurant, String when) {
    return '$restaurant · $when';
  }

  @override
  String pickupDetailMissed(String restaurant, String day) {
    return '$restaurant · $day · hold ended';
  }

  @override
  String pickupDetailCancelled(String restaurant, String day) {
    return '$restaurant · $day · cancelled';
  }

  @override
  String get statusCollected => 'Collected';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get pickupsEmptyTitle => 'No pickups waiting';

  @override
  String get pickupsEmptyBody =>
      'Reserve a meal on the map and its pickup code shows up here.';

  @override
  String get findMeals => 'Find meals near you';

  @override
  String get historyEmpty => 'Meals you pick up will show here.';

  @override
  String get pickupsLoadError =>
      'We couldn’t load your pickups. Pull down to try again.';

  @override
  String get pickupCodeTitle => 'Show this at the counter';

  @override
  String pickupCodeSubtitle(String title, int count, String restaurant) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$title · $_temp0 · $restaurant';
  }

  @override
  String get pickupCodeCaption => 'Pickup code · staff enter it to confirm';

  @override
  String pickupCodeSemantics(String digits) {
    return 'Pickup code $digits';
  }

  @override
  String heldUntilPay(String time) {
    return 'Held until $time · pay at the counter';
  }

  @override
  String heldUntilFree(String time) {
    return 'Held until $time · nothing to pay';
  }

  @override
  String holdEnded(String time) {
    return 'The hold ended at $time. Reserve again if meals are left.';
  }

  @override
  String get callRestaurant => 'Call restaurant';

  @override
  String get cancelReservation => 'Cancel reservation';

  @override
  String get cancelConfirmTitle => 'Cancel this reservation?';

  @override
  String get cancelConfirmBody =>
      'The meal goes back on the map for someone else.';

  @override
  String get keepIt => 'Keep it';

  @override
  String get yesCancel => 'Yes, cancel';

  @override
  String get reservationCancelled =>
      'Reservation cancelled. The meal is back for others.';

  @override
  String get errorCancelFailed => 'We couldn’t cancel it. Try again.';

  @override
  String get newSurplusTitle => 'New surplus';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get addPhotoHint => 'Optional · meals with photos get reserved faster';

  @override
  String get photosComingSoon => 'Adding photos comes in a later version.';

  @override
  String get mealNameHint => 'Meal name';

  @override
  String get mealNoteHint => 'Add a short note (optional)';

  @override
  String get errorMealName => 'Give the meal a name.';

  @override
  String get rowCategory => 'Category';

  @override
  String get rowQuantity => 'Quantity';

  @override
  String get rowPrice => 'Price';

  @override
  String get rowPickupWindow => 'Pickup window';

  @override
  String get rowPreparedAt => 'Prepared at';

  @override
  String get rowAllergens => 'Allergens';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String quantityValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0 · up to 3 per person';
  }

  @override
  String get setPrice => 'Set a price, or make it free';

  @override
  String priceWithWas(String price, String was) {
    return '$price · was $was';
  }

  @override
  String pickupWindowValue(String start, String end) {
    return 'Today, $start – $end';
  }

  @override
  String get pickupWindowOrder => 'Pickup must end after it starts';

  @override
  String get pickupWindowOver => 'This pickup time has already passed';

  @override
  String get pickupWindowTooLate => 'Pickup must end within 12 hours';

  @override
  String preparedAtValue(String time) {
    return 'Today, $time';
  }

  @override
  String get preparedAtMissing => 'When was it cooked?';

  @override
  String get preparedAtInvalid => 'Pick a time earlier today';

  @override
  String get allergensMissing => 'Pick allergens, or None';

  @override
  String get safetyCheckText =>
      'This food was prepared today, stored at safe temperatures, has not been served to customers, and is safe to eat.';

  @override
  String get whatCantBePosted => 'What can’t be posted?';

  @override
  String get notifyNote => 'People within 3 km get one alert when you post.';

  @override
  String get fixHighlighted => 'Fill in the parts marked in red.';

  @override
  String get posted => 'Posted. People nearby can reserve it now.';

  @override
  String get errorNotApproved =>
      'Your restaurant needs approval before you can post.';

  @override
  String get errorPostFailed => 'We couldn’t post it. Try again.';

  @override
  String get categorySheetTitle => 'What kind of food?';

  @override
  String get quantitySheetTitle => 'How many meals?';

  @override
  String get quantitySheetHint => 'Each person can reserve up to 3.';

  @override
  String get done => 'Done';

  @override
  String get priceSheetTitle => 'Price';

  @override
  String get priceSheetHint =>
      'People pay this at the counter. There’s no payment in the app.';

  @override
  String get priceField => 'Price (OMR)';

  @override
  String get wasPriceField => 'Normal price (OMR, optional)';

  @override
  String get wasPriceHelper => 'Shown crossed out next to your price.';

  @override
  String get makeItFree => 'Make it free';

  @override
  String get errorPriceFormat => 'Type a price like 0.800';

  @override
  String get errorWasPrice =>
      'The normal price must be higher than your price.';

  @override
  String get pickupSheetTitle => 'Pickup window';

  @override
  String get pickupSheetHint => 'Pickup has to end within 12 hours.';

  @override
  String get pickupFromLabel => 'From';

  @override
  String get pickupUntilLabel => 'Until';

  @override
  String get allergenSheetTitle => 'Allergens';

  @override
  String get allergenSheetHint =>
      'Pick everything in this meal. People with allergies rely on it.';

  @override
  String get cantPostTitle => 'What can’t be posted?';

  @override
  String get cantPostPlate => 'Leftovers from customers’ plates';

  @override
  String get cantPostOpened => 'Dishes that were opened or partly served';

  @override
  String get cantPostExpired => 'Food past its use-by date';

  @override
  String get cantPostHomemade => 'Home-made food';

  @override
  String get gotIt => 'Got it';

  @override
  String get adminKicker => 'ZAD ADMIN';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabRestaurants => 'Restaurants';

  @override
  String adminUpdated(String time) {
    return 'Muscat · today · updated $time';
  }

  @override
  String get mealsRescuedKicker => 'MEALS RESCUED';

  @override
  String mealsTodayDelta(int count) {
    return '+$count today';
  }

  @override
  String mealsWeekRate(int week, int pct) {
    return '$week this week · $pct% of reservations collected';
  }

  @override
  String mealsWeek(int week) {
    return '$week this week';
  }

  @override
  String kgSaved(int kg) {
    return '≈ $kg kg of food saved (estimate: 0.4 kg per meal)';
  }

  @override
  String get statRestaurants => 'Restaurants';

  @override
  String statRestaurantsDetail(int pending) {
    return 'approved · $pending waiting';
  }

  @override
  String get statLiveOffers => 'Live offers';

  @override
  String statLiveOffersDetail(int meals) {
    String _temp0 = intl.Intl.pluralLogic(
      meals,
      locale: localeName,
      other: '$meals meals',
      one: '1 meal',
    );
    return '$_temp0 left right now';
  }

  @override
  String get statPickupsToday => 'Pickups today';

  @override
  String statPickupsDetail(int count) {
    return '$count waiting at the counter';
  }

  @override
  String get statUsers => 'Users';

  @override
  String statUsersDetail(int count) {
    return '$count reserved today';
  }

  @override
  String get needsAttention => 'Needs attention';

  @override
  String get attentionApprovals => 'Restaurant approvals';

  @override
  String attentionApprovalsValue(int count, String age) {
    return '$count waiting · oldest $age';
  }

  @override
  String get attentionApprovalsNone => 'Nothing waiting';

  @override
  String get attentionOffers => 'Live offers';

  @override
  String attentionOffersValue(int count) {
    return '$count active · review or remove';
  }

  @override
  String get adminLoadError => 'We couldn’t load this. Pull down to try again.';

  @override
  String get adminRestaurantsTitle => 'Restaurants';

  @override
  String pendingSummary(int count) {
    return '$count waiting for review · reply within a day';
  }

  @override
  String get pendingSummaryNone => 'Nothing waiting for review';

  @override
  String tabPendingCount(int count) {
    return 'Pending · $count';
  }

  @override
  String tabApprovedCount(int count) {
    return 'Approved · $count';
  }

  @override
  String tabSuspendedCount(int count) {
    return 'Suspended · $count';
  }

  @override
  String reviewKickerNew(String age) {
    return 'NEW · WAITING $age';
  }

  @override
  String get reviewKickerApproved => 'APPROVED';

  @override
  String get reviewKickerSuspended => 'SUSPENDED';

  @override
  String cuisineArea(String cuisine, String area) {
    return '$cuisine · $area';
  }

  @override
  String get rowOwner => 'Owner';

  @override
  String ownerValue(String name, String phone) {
    return '$name · $phone';
  }

  @override
  String get rowPickupPoint => 'Pickup point';

  @override
  String get rowTypicalDay => 'Typical day';

  @override
  String typicalDayValue(int meals, int low, int high) {
    return '$meals meals · usually $low–$high% left';
  }

  @override
  String get typicalDayNone => 'Not given';

  @override
  String termsAccepted(String when) {
    return 'Restaurant Terms accepted · $when';
  }

  @override
  String get adminReject => 'Reject';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminSuspend => 'Suspend';

  @override
  String get adminReinstate => 'Reinstate';

  @override
  String get ownerNotified => 'The owner is notified either way.';

  @override
  String alsoWaiting(int count) {
    return 'Also waiting · $count';
  }

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get nonePending => 'Nothing waiting. New sign-ups show up here.';

  @override
  String get noneApproved => 'No approved restaurants yet.';

  @override
  String get noneSuspended => 'No suspended restaurants.';

  @override
  String rejectTitle(String name) {
    return 'Reject $name?';
  }

  @override
  String get rejectBody => 'They can fix their details and send them again.';

  @override
  String suspendTitle(String name) {
    return 'Suspend $name?';
  }

  @override
  String get suspendBody =>
      'They can’t post new surplus until you reinstate them.';

  @override
  String approvedToast(String name) {
    return 'Approved. $name can post surplus now.';
  }

  @override
  String rejectedToast(String name) {
    return 'Rejected. $name has been told.';
  }

  @override
  String suspendedToast(String name) {
    return '$name is suspended.';
  }

  @override
  String reinstatedToast(String name) {
    return '$name can post again.';
  }

  @override
  String get errorAdminAction => 'That didn’t work. Try again.';

  @override
  String ageMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String ageHours(int hours) {
    return '$hours h';
  }

  @override
  String ageDays(int days) {
    return '$days d';
  }

  @override
  String get adminOffersTitle => 'Offers';

  @override
  String adminOffersSummary(int count, int meals) {
    return '$count live · $meals meals left';
  }

  @override
  String get adminOffersNone => 'No live offers right now.';

  @override
  String adminOfferLine(int left, int total, String time) {
    return '$left of $total left · until $time';
  }

  @override
  String get adminRemove => 'Remove';

  @override
  String get removeTitle => 'Remove this offer?';

  @override
  String removeBody(String title, String restaurant) {
    return '$title from $restaurant stops showing to users. People who already reserved can still pick up.';
  }

  @override
  String get removedToast => 'Offer removed.';

  @override
  String get insightsTabForecast => 'Forecast';

  @override
  String get insightsTabImpact => 'Impact';

  @override
  String get insightsImpactSoon =>
      'Impact stats come later: meals rescued, money saved and food kept out of the bin.';

  @override
  String insightsTomorrowKicker(String day) {
    return 'TOMORROW · $day';
  }

  @override
  String get confidencePillLow => 'Low confidence';

  @override
  String get confidencePillMedium => 'Medium confidence';

  @override
  String get confidencePillHigh => 'High confidence';

  @override
  String get confidencePillRough => 'Rough estimate';

  @override
  String insightsExpected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'surplus meals expected',
      one: 'surplus meal expected',
    );
    return '$_temp0';
  }

  @override
  String insightsLikelyRange(int low, int high) {
    return 'Likely between $low and $high';
  }

  @override
  String get insightsNext7Title => 'Next 7 days';

  @override
  String get insightsNext7Note =>
      'Expected surplus meals · band = likely range · shaded = weekend';

  @override
  String get insightsViewAsList => 'View as list';

  @override
  String get insightsViewAsChart => 'View as chart';

  @override
  String get insightsListDay => 'Day';

  @override
  String get insightsListExpected => 'Expected';

  @override
  String get insightsListRange => 'Likely range';

  @override
  String get insightsListWeekend => 'Weekend';

  @override
  String insightsTooltipExpected(int count) {
    return '~$count meals';
  }

  @override
  String insightsTooltipRange(int low, int high) {
    return 'likely $low–$high';
  }

  @override
  String get insightsChartHint => 'Tap a bar for details.';

  @override
  String insightsChartDay(String day, int count, int low, int high) {
    return '$day: about $count, likely $low to $high.';
  }

  @override
  String get insightsWhyTitle => 'Why this forecast';

  @override
  String reasonWeekdayHigher(String weekday, int pct) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'mon': 'Mondays',
      'tue': 'Tuesdays',
      'wed': 'Wednesdays',
      'thu': 'Thursdays',
      'fri': 'Fridays',
      'sat': 'Saturdays',
      'sun': 'Sundays',
      'other': 'This day',
    });
    return '$_temp0 are usually $pct% higher';
  }

  @override
  String reasonWeekdayLower(String weekday, int pct) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'mon': 'Mondays',
      'tue': 'Tuesdays',
      'wed': 'Wednesdays',
      'thu': 'Thursdays',
      'fri': 'Fridays',
      'sat': 'Saturdays',
      'sun': 'Sundays',
      'other': 'This day',
    });
    return '$_temp0 are usually $pct% lower';
  }

  @override
  String reasonDaysLogged(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Based on $_temp0 of your logs';
  }

  @override
  String reasonWeekdayAverage(int weeks) {
    return '$weeks-week weekday average';
  }

  @override
  String get reasonRamadan => 'Ramadan pattern applied';

  @override
  String get reasonHoliday => 'Public holiday pattern applied';

  @override
  String get reasonColdStart => 'Rough estimate from your typical day';

  @override
  String insightsSuggestion(int count, String day) {
    return 'Consider preparing about $count fewer portions on $day, or plan a surplus offer for closing time.';
  }

  @override
  String insightsSuggestionLow(String day) {
    return 'Little surplus expected on $day. Post anything left at closing.';
  }

  @override
  String get insightsPostNow => 'Post surplus now';

  @override
  String get insightsNeverPosts =>
      'A forecast never posts meals for you. You confirm the real quantity.';

  @override
  String insightsAccuracy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return 'Last 2 weeks: off by about $_temp0 a day';
  }

  @override
  String get insightsAccuracyUnderOne =>
      'Last 2 weeks: off by less than 1 meal a day';

  @override
  String get insightsAccuracyNotYet =>
      'Log a few more days to see how close the forecast gets.';

  @override
  String insightsLogYesterday(String day) {
    return 'Log yesterday ($day)';
  }

  @override
  String get insightsLogYesterdayNote =>
      'Prepared and left over · about 10 seconds';

  @override
  String get insightsLogNow => 'Log now';

  @override
  String insightsYesterdayLogged(String day) {
    return 'Yesterday is logged ($day)';
  }

  @override
  String loggedNumbers(int prepared, int surplus) {
    return '$prepared prepared · $surplus left over';
  }

  @override
  String get insightsEditLog => 'Edit log';

  @override
  String get insightsNoForecast =>
      'No forecast yet. It appears after the next nightly run.';

  @override
  String get errorLoadInsights =>
      'Couldn’t load your forecast. Pull down to try again.';

  @override
  String get dailyLogHeader => 'Daily log';

  @override
  String get dailyLogTitleYesterday => 'Log yesterday';

  @override
  String dailyLogTitleDay(String day) {
    return 'Log $day';
  }

  @override
  String dailyLogIntro(String date) {
    return '$date · about 10 seconds. Each log makes your forecast more accurate.';
  }

  @override
  String get dailyLogPreparedYesterday => 'Meals prepared yesterday';

  @override
  String dailyLogPreparedOn(String day) {
    return 'Meals prepared on $day';
  }

  @override
  String get dailyLogLeftOver => 'Left over at closing';

  @override
  String get dailyLogLeftOverHelp =>
      'Count everything not sold to regular customers, including meals you posted on ZAD.';

  @override
  String dailyLogShare(int surplus, int prepared, int pct) {
    return '$surplus of $prepared left · $pct%';
  }

  @override
  String get dailyLogFewerPrepared => 'Fewer meals prepared';

  @override
  String get dailyLogMorePrepared => 'More meals prepared';

  @override
  String get dailyLogFewerLeft => 'Fewer left over';

  @override
  String get dailyLogMoreLeft => 'More left over';

  @override
  String get dailyLogLeftOverMax => 'Left over can’t be more than prepared.';

  @override
  String dailyLogGuessed(int count, String day) {
    return 'The forecast guessed ~$count for $day';
  }

  @override
  String get dailyLogYesterdayWord => 'yesterday';

  @override
  String dailyLogOffBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Off by $count meals.',
      one: 'Off by 1 meal.',
      zero: 'Spot on.',
    );
    return '$_temp0';
  }

  @override
  String dailyLogLearning(int days) {
    return '$days days logged, so it now learns from your own numbers.';
  }

  @override
  String dailyLogWarmingUp(int days) {
    return '$days of 14 days logged. After that it learns from your own numbers.';
  }

  @override
  String dailyLogNoGuessTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days logged',
      one: '1 day logged',
      zero: 'Your first log',
    );
    return '$_temp0';
  }

  @override
  String get dailyLogNoGuessBody =>
      'There was no forecast for this day to compare with.';

  @override
  String get dailyLogEarlier => 'Earlier days';

  @override
  String get dailyLogEarlierNote => 'Fix a missed or wrong day';

  @override
  String get dailyLogEarlierSubtitle =>
      'The last 2 weeks. Tap a day to log or fix it.';

  @override
  String get dailyLogNotLogged => 'Not logged';

  @override
  String get dailyLogSave => 'Save log';

  @override
  String dailyLogSaved(String day) {
    return 'Saved. $day is logged.';
  }

  @override
  String get dailyLogSaveError => 'Couldn’t save the log. Try again.';

  @override
  String get dailyLogAfter14 =>
      'After 14 days, the forecast learns from your own numbers.';

  @override
  String get insightsListNote =>
      'Expected surplus meals and the likely range for each day';

  @override
  String get errorLoadOffers =>
      'We couldn’t load your offers. Pull down to try again.';

  @override
  String offersCollectedWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals collected this week',
      one: '1 meal collected this week',
      zero: 'No meals collected this week yet',
    );
    return '$_temp0';
  }

  @override
  String get offersTabLive => 'Live';

  @override
  String offersTabLiveCount(int count) {
    return 'Live · $count';
  }

  @override
  String get offersTabPast => 'Past';

  @override
  String get offersPastEmpty => 'Offers that have ended will show here.';

  @override
  String offerPastDetail(String day, int collected, int total) {
    return '$day · $collected of $total collected';
  }

  @override
  String get offerStatusAllTaken => 'All taken';

  @override
  String get offerStatusEnded => 'Ended';

  @override
  String get offerStatusEndedEarly => 'Ended early';

  @override
  String get offerStatusRemoved => 'Removed';

  @override
  String get notificationsLoadError =>
      'We couldn’t load your notifications. Pull down to try again.';

  @override
  String get notificationsEmptyTitle => 'You’re all caught up';

  @override
  String get notificationsEmptyUser =>
      'We’ll let you know when a restaurant near you posts meals.';

  @override
  String get notificationsEmptyRestaurant =>
      'News about your restaurant will show here.';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsAllRead => 'Nothing new';

  @override
  String notificationsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new',
      one: '1 new',
    );
    return '$_temp0';
  }

  @override
  String get notificationJustNow => 'Just now';

  @override
  String notificationMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String notificationHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String memberSince(String month) {
    return 'Rescuing meals since $month';
  }

  @override
  String get profileStatMeals => 'Meals rescued';

  @override
  String get profileStatSaved => 'OMR saved';

  @override
  String get profileStatPickups => 'Pickups';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileSectionPickups => 'Pickups';

  @override
  String get profileSectionNotifications => 'Notifications';

  @override
  String get profileSectionRestaurant => 'Restaurant';

  @override
  String get profileEditName => 'Your name';

  @override
  String get profilePickupHistory => 'Pickup history';

  @override
  String profilePickupHistoryValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pickups so far',
      one: '1 pickup so far',
      zero: 'No pickups yet',
    );
    return '$_temp0';
  }

  @override
  String get profileMyArea => 'My area';

  @override
  String get profileAreaUnset => 'Not set · showing Muscat';

  @override
  String get profileAlerts => 'New meals nearby';

  @override
  String get profileAlertsValue => 'Up to 3 alerts a day, within 3 km';

  @override
  String get profileVerified => 'Verified by ZAD';

  @override
  String get profileEditRestaurant => 'Edit restaurant details';

  @override
  String get profileEditRestaurantValue =>
      'Name, phone, pickup point and typical day';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profilePickupPoint => 'Pickup point';

  @override
  String get profileTypicalDay => 'Typical day';

  @override
  String profileTypicalDayValue(int meals, String share) {
    return '$meals meals a day · $share left over';
  }

  @override
  String get profileOwner => 'Owner';

  @override
  String get profileRole => 'Role';

  @override
  String get profileRoleAdmin => 'Admin';

  @override
  String get profileAdminNote =>
      'Admin accounts are made on the server. Restaurants and offers are in the other tabs.';

  @override
  String get setAreaTitle => 'Set your area';

  @override
  String get setAreaBody =>
      'Move the map to your neighbourhood. We show meals within 5 km of the pin.';

  @override
  String get setAreaHint => 'Move the map to your area';

  @override
  String get setAreaFinding => 'Finding the area…';

  @override
  String get setAreaPinned => 'Pinned area';

  @override
  String get setAreaPrivacy =>
      'Saved to about 100 m. Restaurants never see it.';

  @override
  String get setAreaSave => 'Use this area';

  @override
  String get setAreaSaved => 'Area saved. Showing meals near it.';
}
