/// Route paths. Three groups, one per role (CLAUDE.md §2): /user, /restaurant, /admin.
abstract final class Routes {
  static const splash = '/';
  static const accountType = '/account-type';
  static const login = '/login';

  static const userHome = '/user';
  static const restaurantHome = '/restaurant';
  static const adminHome = '/admin';
}
