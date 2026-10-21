import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/account_type_screen.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/location_permission_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../widgets/placeholder_screen.dart';
import 'routes.dart';

/// Screens not built yet show a placeholder; each is replaced as P1 progresses.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.accountType, builder: (_, _) => const AccountTypeScreen()),
      GoRoute(
        path: Routes.register,
        builder: (_, state) => RegisterScreen(
          role: state.uri.queryParameters['role'] == UserRole.restaurant.toJson()
              ? UserRole.restaurant
              : UserRole.user,
        ),
      ),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.forgotPassword, builder: (_, _) => const PlaceholderScreen(name: 'Forgot password')),
      GoRoute(path: Routes.locationPermission, builder: (_, _) => const LocationPermissionScreen()),
      GoRoute(path: Routes.terms, builder: (_, _) => const PlaceholderScreen(name: 'Terms of Use')),
      GoRoute(path: Routes.privacy, builder: (_, _) => const PlaceholderScreen(name: 'Privacy Policy')),
      GoRoute(path: Routes.userHome, builder: (_, _) => const PlaceholderScreen(name: 'User home')),
      GoRoute(path: Routes.setArea, builder: (_, _) => const PlaceholderScreen(name: 'Set my area')),
      GoRoute(path: Routes.restaurantHome, builder: (_, _) => const PlaceholderScreen(name: 'Restaurant home')),
      GoRoute(
        path: Routes.restaurantOnboarding,
        builder: (_, _) => const PlaceholderScreen(name: 'Restaurant setup'),
      ),
      GoRoute(path: Routes.adminHome, builder: (_, _) => const PlaceholderScreen(name: 'Admin overview')),
    ],
  );
});
