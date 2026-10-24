import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/my_restaurant.dart';
import '../domain/forecast.dart';
import '../domain/offer.dart';
import '../domain/restaurant_reservation.dart';
import 'fake_today_store.dart';

/// The restaurant's own offers (CLAUDE.md §5.1).
abstract interface class RestaurantOffersRepository {
  /// `GET /restaurants/me/offers`.
  Future<List<Offer>> myOffers();

  /// `PATCH /offers/{id}` with a new `quantity_total`. The server keeps
  /// `quantity_available = total − already taken`. Throws [OfferException].
  Future<Offer> updateQuantity(String offerId, int quantityTotal);

  /// `POST /offers/{id}/cancel` ("End early"): nobody new can reserve, and
  /// people who already reserved can still pick up.
  Future<Offer> endEarly(String offerId);
}

/// Pickups at the counter (CLAUDE.md §5.1).
abstract interface class PickupsRepository {
  /// `GET /restaurants/me/reservations` (first names and code hints only).
  Future<List<RestaurantReservation>> myReservations();

  /// `POST /pickups/check`: who a 6-digit code belongs to, without collecting
  /// it yet, so staff can see the match before handing food over.
  /// Throws [PickupException].
  Future<RestaurantReservation> check(String code);

  /// `POST /pickups/confirm`: marks the reservation `collected`.
  Future<RestaurantReservation> confirm(String code);
}

/// `GET /forecasts`: the next 7 days for the signed-in restaurant (§7.5).
abstract interface class ForecastRepository {
  Future<List<Forecast>> myForecasts();
}

class OfferException implements Exception {
  const OfferException(this.code);

  final String code;

  static const notFound = 'not_found';
  static const notLive = 'offer_not_live';
  static const belowTaken = 'quantity_below_taken';
  static const outOfRange = 'quantity_out_of_range';

  @override
  String toString() => 'OfferException($code)';
}

class PickupException implements Exception {
  const PickupException(this.code, {this.retryAfter});

  final String code;

  /// Set for [locked]: when entry opens again.
  final DateTime? retryAfter;

  static const codeNotFound = 'code_not_found';
  static const alreadyCollected = 'already_collected';
  static const expired = 'hold_expired';
  static const locked = 'too_many_attempts';

  @override
  String toString() => 'PickupException($code)';
}

/// One in-memory demo store shared by the three fakes, so collecting a
/// pickup shows up everywhere. P2 swaps in API repositories here.
final fakeTodayStoreProvider = Provider<FakeTodayStore>((ref) => FakeTodayStore.seeded(DateTime.now()));

Future<String?> _restaurantId(Ref ref) async => (await ref.read(myRestaurantProvider.future))?.id;

final restaurantOffersRepositoryProvider = Provider<RestaurantOffersRepository>(
  (ref) => FakeRestaurantOffersRepository(ref.watch(fakeTodayStoreProvider), () => _restaurantId(ref)),
);

final pickupsRepositoryProvider = Provider<PickupsRepository>(
  (ref) => FakePickupsRepository(ref.watch(fakeTodayStoreProvider), () => _restaurantId(ref)),
);

final forecastRepositoryProvider = Provider<ForecastRepository>(
  (ref) => FakeForecastRepository(() => ref.read(myRestaurantProvider.future)),
);
