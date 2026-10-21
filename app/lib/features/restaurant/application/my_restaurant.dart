import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../auth/application/session.dart';
import '../../auth/domain/app_user.dart';
import '../data/restaurant_repository.dart';
import '../domain/restaurant.dart';

/// The signed-in owner's restaurant, or null if onboarding isn't finished.
/// Reloads when a different account signs in.
class MyRestaurantNotifier extends AsyncNotifier<Restaurant?> {
  @override
  Future<Restaurant?> build() async {
    final user = ref.watch(sessionProvider.select((u) => (id: u?.id, role: u?.role)));
    if (user.id == null || user.role != UserRole.restaurant) return null;
    return ref.read(restaurantRepositoryProvider).mine();
  }

  /// Sends the onboarding answers: `POST /restaurants` the first time,
  /// `PATCH /restaurants/me` when editing.
  Future<Restaurant> submit(RestaurantDraft draft) async {
    final repo = ref.read(restaurantRepositoryProvider);
    final existing = await future;
    final saved = existing == null ? await repo.create(draft.toJson()) : await repo.update(draft.toJson());
    state = AsyncData(saved);
    return saved;
  }

  /// Asks the server again, e.g. to see if the admin has approved it.
  Future<Restaurant?> reload() async {
    // Keeps showing the current data while it loads; errors replace it.
    state = await AsyncValue.guard(() => ref.read(restaurantRepositoryProvider).mine());
    return state.value;
  }
}

final myRestaurantProvider =
    AsyncNotifierProvider<MyRestaurantNotifier, Restaurant?>(MyRestaurantNotifier.new);

/// Where a restaurant account goes (CLAUDE.md §8.1): onboarding if it has no
/// restaurant yet, the home screen once approved, otherwise the review screen.
String routeForRestaurant(Restaurant? restaurant) => switch (restaurant?.status) {
      null => Routes.restaurantOnboarding,
      RestaurantStatus.approved => Routes.restaurantHome,
      RestaurantStatus.pending || RestaurantStatus.rejected || RestaurantStatus.suspended =>
        Routes.restaurantPending,
    };
