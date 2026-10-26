import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/my_restaurant.dart';
import '../domain/forecast.dart';
import '../domain/offer.dart';
import '../domain/offer_draft.dart';
import '../domain/restaurant_reservation.dart';
import 'fake_forecast.dart';
import 'fake_today_store.dart';

/// The restaurant's own offers (CLAUDE.md §5.1).
abstract interface class RestaurantOffersRepository {
  /// `GET /restaurants/me/offers`.
  Future<List<Offer>> myOffers();

  /// `POST /offers`: approved restaurants only. The server copies the
  /// restaurant's name, cuisine and location onto the offer and alerts
  /// people nearby (§6). Throws [OfferException].
  Future<Offer> create(OfferDraft draft);

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

/// `GET /forecasts`: the signed-in restaurant's last 14 days and next 7 (§7.5).
/// Past days are what the forecast said at the time, kept so the app can
/// compare them with the daily logs (accuracy line, Daily log feedback).
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
  static const invalid = 'invalid_offer';
  static const notApproved = 'restaurant_not_approved';

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
  (ref) => FakeRestaurantOffersRepository(
    ref.watch(fakeTodayStoreProvider),
    () => _restaurantId(ref),
    restaurant: () => ref.read(myRestaurantProvider.future),
  ),
);

final pickupsRepositoryProvider = Provider<PickupsRepository>(
  (ref) => FakePickupsRepository(ref.watch(fakeTodayStoreProvider), () => _restaurantId(ref)),
);

final forecastRepositoryProvider = Provider<ForecastRepository>(
  (ref) => FakeForecastRepository(() => ref.read(myRestaurantProvider.future)),
);
