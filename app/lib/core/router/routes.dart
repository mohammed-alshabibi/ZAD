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

  static const userHome = '/user';
  static const setArea = '/user/set-area';
  static const restaurantHome = '/restaurant';
  static const restaurantOnboarding = '/restaurant/onboarding';
  static const adminHome = '/admin';
}
