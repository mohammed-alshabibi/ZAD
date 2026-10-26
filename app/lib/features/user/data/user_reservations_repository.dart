import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session.dart';
import '../../auth/domain/app_user.dart';
import '../../restaurant/data/fake_today_store.dart';
import '../../restaurant/data/restaurant_today_repositories.dart';
import '../domain/user_reservation.dart';

/// The signed-in user's reservations (CLAUDE.md §5.1).
abstract interface class UserReservationsRepository {
  /// `GET /reservations`, newest first.
  Future<List<UserReservation>> myReservations();

  /// `POST /offers/{id}/reserve` with `{"quantity": n}`. Throws [ReserveException].
  Future<UserReservation> reserve(String offerId, int quantity);

  /// `POST /reservations/{id}/cancel`: the meals go back on the offer.
  Future<UserReservation> cancel(String reservationId);
}

class ReserveException implements Exception {
  const ReserveException(this.code);

  final String code;

  static const notFound = 'not_found';
  static const notLive = 'offer_not_live';
  static const soldOut = 'sold_out';
  static const notEnoughLeft = 'not_enough_left';
  static const quantityLimit = 'quantity_limit';
  static const alreadyReserved = 'already_reserved';
  static const notReserved = 'not_reserved';

  @override
  String toString() => 'ReserveException($code)';
}

/// The reservation rules (§5.2), on the shared demo store so the restaurant
/// sees new reservations and the meals left go down everywhere.
class FakeUserReservationsRepository implements UserReservationsRepository {
  FakeUserReservationsRepository(
    this.store,
    this.currentUser, {
    this.latency = const Duration(milliseconds: 400),
    math.Random? random,
  }) : _random = random ?? math.Random();

  final FakeTodayStore store;
  final AppUser? Function() currentUser;
  final Duration latency;
  final math.Random _random;

  /// At most this many meals per person per offer (§5.2).
  static const maxPerUser = 3;

  /// How long a reservation is held after pickup opens (§4).
  static const hold = UserReservation.holdLength;

  @override
  Future<List<UserReservation>> myReservations() async {
    await Future<void>.delayed(latency);
    final user = _user();
    store.expireStale(DateTime.now());
    final mine = [
      for (final r in store.reservations)
        if (r['user_id'] == user.id) _json(r),
    ]..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    return [for (final json in mine) UserReservation.fromJson(json)];
  }

  @override
  Future<UserReservation> reserve(String offerId, int quantity) async {
    await Future<void>.delayed(latency);
    final user = _user();
    final now = DateTime.now();
    store.expireStale(now);

    final offer = store.offerById(offerId);
    if (offer == null || offer['status'] == 'removed') throw const ReserveException(ReserveException.notFound);
    // Checked first (§5.2): quantity ≤ 3, and no other active hold on this offer.
    if (quantity < 1 || quantity > maxPerUser) throw const ReserveException(ReserveException.quantityLimit);
    final already = store.reservations.any(
      (r) => r['offer_id'] == offerId && r['user_id'] == user.id && r['status'] == 'reserved',
    );
    if (already) throw const ReserveException(ReserveException.alreadyReserved);

    final end = DateTime.parse(offer['pickup_end'] as String);
    if (offer['status'] == 'sold_out') throw const ReserveException(ReserveException.soldOut);
    if (offer['status'] != 'active' || !end.isAfter(now)) throw const ReserveException(ReserveException.notLive);

    // The server does this as one conditional $inc, so two people can never
    // take the same last meal.
    final available = offer['quantity_available'] as int;
    if (available < quantity) throw const ReserveException(ReserveException.notEnoughLeft);
    offer['quantity_available'] = available - quantity;
    if (available - quantity == 0) offer['status'] = 'sold_out';

    // hold_expires_at = min(max(now, pickup_start) + 30 min, pickup_end).
    final start = DateTime.parse(offer['pickup_start'] as String);
    final from = now.isAfter(start) ? now : start;
    final holdUntil = from.add(hold).isAfter(end) ? end : from.add(hold);

    final reservation = {
      'id': 'res_${now.microsecondsSinceEpoch}',
      'offer_id': offerId,
      'user_id': user.id,
      'user_first_name': user.firstName,
      'quantity': quantity,
      'pickup_code': _newCode(offer['restaurant_id'] as String),
      'status': 'reserved',
      'hold_expires_at': holdUntil.toUtc().toIso8601String(),
      'collected_at': null,
      'created_at': now.toUtc().toIso8601String(),
    };
    store.reservations.add(reservation);
    return UserReservation.fromJson(_json(reservation));
  }

  @override
  Future<UserReservation> cancel(String reservationId) async {
    await Future<void>.delayed(latency);
    final user = _user();
    store.expireStale(DateTime.now());
    final r = store.reservations.where((r) => r['id'] == reservationId && r['user_id'] == user.id).firstOrNull;
    if (r == null) throw const ReserveException(ReserveException.notFound);
    if (r['status'] != 'reserved') throw const ReserveException(ReserveException.notReserved);
    r['status'] = 'cancelled';
    final offer = store.offerById(r['offer_id'] as String);
    if (offer != null && (offer['status'] == 'active' || offer['status'] == 'sold_out')) {
      offer['quantity_available'] = (offer['quantity_available'] as int) + (r['quantity'] as int);
      offer['status'] = 'active';
    }
    return UserReservation.fromJson(_json(r));
  }

  /// A 6-digit code not used by another waiting pickup at this restaurant.
  String _newCode(String restaurantId) {
    final taken = {
      for (final r in store.reservationsFor(restaurantId))
        if (r['status'] == 'reserved') r['pickup_code'],
    };
    while (true) {
      final code = (100000 + _random.nextInt(900000)).toString();
      if (!taken.contains(code)) return code;
    }
  }

  /// The user-facing JSON: the full code, the offer and restaurant names.
  Map<String, dynamic> _json(Map<String, dynamic> r) {
    final offer = store.offerById(r['offer_id'] as String)!;
    return {
      'id': r['id'],
      'offer_id': r['offer_id'],
      'offer_title': offer['title'],
      'restaurant_name': offer['restaurant_name'],
      'restaurant_phone': offer['restaurant_phone'],
      'location': offer['location'],
      'quantity': r['quantity'],
      'pickup_code': r['pickup_code'],
      'status': r['status'],
      'price_baisa': offer['price_baisa'],
      'original_price_baisa': offer['original_price_baisa'],
      'hold_expires_at': r['hold_expires_at'],
      'pickup_end': offer['pickup_end'],
      'collected_at': r['collected_at'],
      'created_at': r['created_at'],
    };
  }

  AppUser _user() {
    final user = currentUser();
    if (user == null) throw const ReserveException(ReserveException.notFound);
    return user;
  }
}

final userReservationsRepositoryProvider = Provider<UserReservationsRepository>(
  (ref) => FakeUserReservationsRepository(ref.watch(fakeTodayStoreProvider), () => ref.read(sessionProvider)),
);
