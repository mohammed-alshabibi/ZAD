import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_shell.dart';
import '../../features/admin/offers_screen.dart';
import '../../features/admin/overview_screen.dart';
import '../../features/admin/restaurants_screen.dart';
import '../../features/auth/account_type_screen.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/location_permission_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/restaurant/add_surplus/add_surplus_screen.dart';
import '../../features/restaurant/home/restaurant_home_screen.dart';
import '../../features/restaurant/home/restaurant_shell.dart';
import '../../features/restaurant/onboarding/pending_approval_screen.dart';
import '../../features/restaurant/onboarding/pickup_location_screen.dart';
import '../../features/restaurant/onboarding/restaurant_details_screen.dart';
import '../../features/restaurant/onboarding/typical_day_screen.dart';
import '../../features/user/home/user_home_screen.dart';
import '../../features/user/home/user_shell.dart';
import '../../features/user/meal/meal_details_screen.dart';
import '../../features/user/pickups/pickups_screen.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/tab_placeholder.dart';
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
      // User tabs keep their own state (indexed stack), like the restaurant's.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => UserShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.userHome, builder: (_, _) => const UserHomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.userPickups, builder: (_, _) => const PickupsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.userProfile,
              builder: (context, _) => TabPlaceholder(name: AppLocalizations.of(context).tabProfile, showLogOut: true),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: Routes.mealDetailsPattern,
        builder: (_, state) => MealDetailsScreen(offerId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.setArea, builder: (_, _) => const PlaceholderScreen(name: 'Set my area')),
      GoRoute(path: Routes.notifications, builder: (_, _) => const PlaceholderScreen(name: 'Notifications')),
      // Restaurant tabs keep their own state (indexed stack).
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => RestaurantShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.restaurantHome, builder: (_, _) => const RestaurantHomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.restaurantOffers,
              builder: (context, _) => TabPlaceholder(name: AppLocalizations.of(context).tabOffers),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.restaurantInsights,
              builder: (context, _) => TabPlaceholder(name: AppLocalizations.of(context).tabInsights),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.restaurantProfile,
              builder: (context, _) =>
                  TabPlaceholder(name: AppLocalizations.of(context).tabProfile, showLogOut: true),
            ),
          ]),
        ],
      ),
      GoRoute(path: Routes.restaurantNewOffer, builder: (_, _) => const AddSurplusScreen()),
      GoRoute(path: Routes.restaurantOnboarding, builder: (_, _) => const RestaurantDetailsScreen()),
      GoRoute(path: Routes.restaurantOnboardingLocation, builder: (_, _) => const PickupLocationScreen()),
      GoRoute(path: Routes.restaurantOnboardingTypicalDay, builder: (_, _) => const TypicalDayScreen()),
      GoRoute(path: Routes.restaurantPending, builder: (_, _) => const PendingApprovalScreen()),
      // Admin tabs keep their own state (indexed stack).
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AdminShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.adminHome, builder: (_, _) => const AdminOverviewScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.adminRestaurants, builder: (_, _) => const AdminRestaurantsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.adminOffers, builder: (_, _) => const AdminOffersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.adminProfile,
              builder: (context, _) => TabPlaceholder(name: AppLocalizations.of(context).tabProfile, showLogOut: true),
            ),
          ]),
        ],
      ),
    ],
  );
});
