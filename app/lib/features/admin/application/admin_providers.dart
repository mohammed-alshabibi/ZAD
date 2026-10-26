import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session.dart';
import '../../restaurant/domain/restaurant.dart';
import '../../user/application/home_offers.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';

/// `GET /admin/overview`, with when it was loaded ("updated 21:05").
final adminOverviewProvider = FutureProvider<({AdminOverview overview, DateTime loadedAt})>((ref) async {
  ref.watch(sessionProvider.select((u) => u?.id));
  final overview = await ref.watch(adminRepositoryProvider).overview();
  return (overview: overview, loadedAt: DateTime.now());
});

/// `GET /admin/restaurants?status=` for one tab.
final adminRestaurantsProvider = FutureProvider.family<List<AdminRestaurant>, RestaurantStatus>((ref, status) {
  ref.watch(sessionProvider.select((u) => u?.id));
  return ref.watch(adminRepositoryProvider).restaurants(status);
});

/// `GET /admin/offers`.
final adminOffersProvider = FutureProvider<List<AdminOffer>>((ref) {
  ref.watch(sessionProvider.select((u) => u?.id));
  return ref.watch(adminRepositoryProvider).liveOffers();
});

/// The admin's actions. Each one reloads the lists and counts it changes.
class AdminActions {
  const AdminActions(this.ref);

  final Ref ref;

  Future<AdminRestaurant> setStatus(AdminRestaurant r, RestaurantStatus status) async {
    final updated = await ref.read(adminRepositoryProvider).setRestaurantStatus(r.id, status);
    ref
      ..invalidate(adminRestaurantsProvider)
      ..invalidate(adminOverviewProvider);
    return updated;
  }

  Future<void> removeOffer(AdminOffer o) async {
    await ref.read(adminRepositoryProvider).removeOffer(o.id);
    ref
      ..invalidate(adminOffersProvider)
      ..invalidate(adminOverviewProvider)
      // Users' Home stops showing it.
      ..invalidate(nearbyOffersProvider);
  }
}

final adminActionsProvider = Provider<AdminActions>(AdminActions.new);
