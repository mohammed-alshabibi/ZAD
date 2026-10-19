import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/splash_screen.dart';
import '../widgets/placeholder_screen.dart';
import 'routes.dart';

/// Screens not built yet show a placeholder; each is replaced as P1 progresses.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.accountType, builder: (_, _) => const PlaceholderScreen(name: 'Account type')),
      GoRoute(path: Routes.login, builder: (_, _) => const PlaceholderScreen(name: 'Log in')),
      GoRoute(path: Routes.userHome, builder: (_, _) => const PlaceholderScreen(name: 'User home')),
      GoRoute(path: Routes.restaurantHome, builder: (_, _) => const PlaceholderScreen(name: 'Restaurant home')),
      GoRoute(path: Routes.adminHome, builder: (_, _) => const PlaceholderScreen(name: 'Admin overview')),
    ],
  );
});
