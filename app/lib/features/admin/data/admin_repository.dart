import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/muscat_time.dart';
import '../../restaurant/data/fake_restaurant_repository.dart';
import '../../restaurant/data/fake_today_store.dart';
import '../../restaurant/data/restaurant_repository.dart';
import '../../restaurant/data/restaurant_today_repositories.dart';
import '../../restaurant/domain/restaurant.dart';
import '../domain/admin_models.dart';

/// The in-app admin (CLAUDE.md §5.1 "Admin"). Only `role = admin` may call
/// these; the server checks with `IsAdminRole`.
abstract interface class AdminRepository {
  /// `GET /admin/overview`.
  Future<AdminOverview> overview();

  /// `GET /admin/restaurants?status=`: oldest first, so the longest wait is on top.
  Future<List<AdminRestaurant>> restaurants(RestaurantStatus status);

  /// `POST /admin/restaurants/{id}/status`: approve, reject, suspend or reinstate.
  Future<AdminRestaurant> setRestaurantStatus(String id, RestaurantStatus status);

  /// `GET /admin/offers`: live offers, closing soonest first.
  Future<List<AdminOffer>> liveOffers();

  /// `POST /admin/offers/{id}/remove`: users stop seeing it. People who
  /// already reserved can still pick up.
  Future<void> removeOffer(String id);
}

class AdminException implements Exception {
  const AdminException(this.code);

  final String code;

  static const notFound = 'not_found';

  @override
  String toString() => 'AdminException($code)';
}

/// Answers from the same demo stores the restaurant and user fakes use, so an
/// approval or a removal shows up for everyone at once.
class FakeAdminRepository implements AdminRepository {
  FakeAdminRepository(this.restaurantsStore, this.todayStore, {this.latency = const Duration(milliseconds: 300)});

  final FakeRestaurantStore restaurantsStore;
  final FakeTodayStore todayStore;
  final Duration latency;

  @override
  Future<AdminOverview> overview() async {
    await Future<void>.delayed(latency);
    final now = DateTime.now();
    todayStore.expireStale(now);
    final reservations = todayStore.reservations;
    final restaurants = restaurantsStore.byOwner.values;

    bool isToday(String? iso) => iso != null && muscatDaysAgo(DateTime.parse(iso), now: now) == 0;
    bool thisWeek(String? iso) => iso != null && muscatDaysAgo(DateTime.parse(iso), now: now) < 7;
    int meals(Iterable<Map<String, dynamic>> rs) => rs.fold(0, (sum, r) => sum + (r['quantity'] as int));

    final collected = reservations.where((r) => r['status'] == 'collected').toList();
    final missed = reservations.where((r) => r['status'] == 'expired').length;
    final finished = collected.length + missed;
    final pending = restaurants.where((r) => r['status'] == 'pending').toList()
      ..sort((a, b) => (a['created_at'] as String).compareTo(b['created_at'] as String));
    final live = todayStore.offers.where((o) {
      final open = o['status'] == 'active' || o['status'] == 'sold_out';
      return open && DateTime.parse(o['pickup_end'] as String).isAfter(now);
    }).toList();
    // P2 counts user accounts; the demo has no account list, so it counts
    // the people who have reserved.
    final users = {for (final r in reservations) r['user_id']};

    return AdminOverview.fromJson({
      'meals_rescued': meals(collected),
      'meals_today': meals(collected.where((r) => isToday(r['collected_at'] as String?))),
      'meals_this_week': meals(collected.where((r) => thisWeek(r['collected_at'] as String?))),
      'collected_pct': finished == 0 ? null : (collected.length * 100 / finished).round(),
      'restaurants_approved': restaurants.where((r) => r['status'] == 'approved').length,
      'restaurants_pending': pending.length,
      'oldest_pending_at': pending.isEmpty ? null : pending.first['created_at'],
      'live_offers': live.length,
      'meals_left': live.fold<int>(0, (sum, o) => sum + (o['quantity_available'] as int)),
      'pickups_today': collected.where((r) => isToday(r['collected_at'] as String?)).length,
      'waiting_now': reservations.where((r) => r['status'] == 'reserved').length,
      'users': users.length,
      'users_reserved_today': {
        for (final r in reservations)
          if (isToday(r['created_at'] as String?)) r['user_id'],
      }.length,
    });
  }

  @override
  Future<List<AdminRestaurant>> restaurants(RestaurantStatus status) async {
    await Future<void>.delayed(latency);
    final list = restaurantsStore.byOwner.values.where((r) => r['status'] == status.name).toList()
      ..sort((a, b) => (a['created_at'] as String).compareTo(b['created_at'] as String));
    return [for (final json in list) AdminRestaurant.fromJson(json)];
  }

  @override
  Future<AdminRestaurant> setRestaurantStatus(String id, RestaurantStatus status) async {
    await Future<void>.delayed(latency);
    final json = restaurantsStore.byId(id);
    if (json == null) throw const AdminException(AdminException.notFound);
    json['status'] = status.name;
    return AdminRestaurant.fromJson(json);
  }

  @override
  Future<List<AdminOffer>> liveOffers() async {
    await Future<void>.delayed(latency);
    final now = DateTime.now();
    todayStore.expireStale(now);
    final live = todayStore.offers.where((o) {
      final open = o['status'] == 'active' || o['status'] == 'sold_out';
      return open && DateTime.parse(o['pickup_end'] as String).isAfter(now);
    }).toList()
      ..sort((a, b) => (a['pickup_end'] as String).compareTo(b['pickup_end'] as String));
    return [for (final json in live) AdminOffer.fromJson(json)];
  }

  @override
  Future<void> removeOffer(String id) async {
    await Future<void>.delayed(latency);
    final offer = todayStore.offerById(id);
    if (offer == null) throw const AdminException(AdminException.notFound);
    offer['status'] = 'removed';
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FakeAdminRepository(ref.watch(fakeRestaurantStoreProvider), ref.watch(fakeTodayStoreProvider)),
);
