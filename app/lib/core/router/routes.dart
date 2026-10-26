/// Route paths. Three groups, one per role (CLAUDE.md §2): /user, /restaurant, /admin.
abstract final class Routes {
  static const splash = '/';
  static const accountType = '/account-type';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const locationPermission = '/location-permission';
  static const terms = '/terms';
  static const privacy = '/privacy';

  /// Register with the account type chosen on the previous screen.
  static const register = '/register';
  static String registerAs(String role) => '$register?role=$role';

  /// User tabs: Home · Pickups · Profile.
  static const userHome = '/user';
  static const userPickups = '/user/pickups';
  static const userProfile = '/user/profile';
  static const setArea = '/user/set-area';

  /// Meal details for one offer (`GET /offers/{id}`).
  static const mealDetailsPattern = '/user/offers/:id';
  static String mealDetails(String offerId) => '/user/offers/$offerId';
  static const notifications = '/notifications';

  /// Restaurant tabs: Today · Offers · (+ New surplus) · Insights · Profile.
  static const restaurantHome = '/restaurant';
  static const restaurantOffers = '/restaurant/offers';
  static const restaurantInsights = '/restaurant/insights';
  static const restaurantProfile = '/restaurant/profile';
  static const restaurantNewOffer = '/restaurant/new-offer';

  /// Daily log for yesterday (`PUT /daily-logs/{date}`); earlier days are
  /// picked on the screen.
  static const restaurantDailyLog = '/restaurant/daily-log';

  /// Restaurant setup: details → pickup location → typical day → pending.
  static const restaurantOnboarding = '/restaurant/onboarding';
  static const restaurantOnboardingLocation = '/restaurant/onboarding/location';
  static const restaurantOnboardingTypicalDay = '/restaurant/onboarding/typical-day';
  static const restaurantPending = '/restaurant/pending';

  /// Admin tabs: Overview · Restaurants · Offers · Profile.
  static const adminHome = '/admin';
  static const adminRestaurants = '/admin/restaurants';
  static const adminOffers = '/admin/offers';
  static const adminProfile = '/admin/profile';
}
