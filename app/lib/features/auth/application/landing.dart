import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../restaurant/application/my_restaurant.dart';
import '../domain/app_user.dart';
import 'session.dart';

/// Where an account lands after logging in: users and admins go to their home;
/// restaurant accounts go by their restaurant's status (CLAUDE.md §8.1).
Future<String> landingRouteFor(WidgetRef ref, AppUser user) async {
  if (user.role != UserRole.restaurant) return homeForRole(user.role);
  final restaurant = await ref.read(myRestaurantProvider.future);
  return routeForRestaurant(restaurant);
}
