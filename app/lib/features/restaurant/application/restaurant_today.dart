import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/muscat_time.dart';
import '../../../core/time/clock.dart';
import '../data/restaurant_today_repositories.dart';
import '../domain/forecast.dart';
import '../domain/offer.dart';
import '../domain/offer_draft.dart';
import '../domain/restaurant_reservation.dart';
import 'my_restaurant.dart';

/// Everything on the restaurant's "Today" tab (Figma 29:400).
class RestaurantToday {
  const RestaurantToday({
    required this.liveOffers,
    required this.waiting,
    required this.collected,
    required this.postedMeals,
    required this.reservedMeals,
    required this.collectedMeals,
    required this.tomorrow,
  });

  /// Offers people can still reserve or pick up, closing soonest first.
  final List<Offer> liveOffers;

  /// Reservations waiting at the counter, hold ending soonest first.
  final List<RestaurantReservation> waiting;

  /// Tonight's collected pickups, most recent first.
  final List<RestaurantReservation> collected;

  /// Stat tiles: meals posted tonight, still reserved, and collected.
  final int postedMeals;
  final int reservedMeals;
  final int collectedMeals;
  final Forecast? tomorrow;
}

/// Builds the Today view. "Tonight" = offers whose pickup starts on today's
/// Muscat date, plus anything still live.
RestaurantToday buildRestaurantToday({
  required List<Offer> offers,
  required List<RestaurantReservation> reservations,
  required List<Forecast> forecasts,
  required DateTime now,
}) {
  final tonight = [
    for (final o in offers)
      if (o.status != OfferStatus.removed &&
          (o.isLive(now) || muscatDayOf(o.pickupStart, now: now) == MuscatDay.today))
        o,
  ];
  final ids = {for (final o in tonight) o.id};
  final mine = [for (final r in reservations) if (ids.contains(r.offerId)) r];
  int meals(Iterable<RestaurantReservation> rs) => rs.fold(0, (sum, r) => sum + r.quantity);

  // A hold that has run out is no longer waiting (the server marks it
  // expired on its next read).
  final waiting = [
    for (final r in mine)
      if (r.status == ReservationStatus.reserved && r.holdExpiresAt.isAfter(now)) r,
  ]
    ..sort((a, b) => a.holdExpiresAt.compareTo(b.holdExpiresAt));
  final collected = [for (final r in mine) if (r.status == ReservationStatus.collected) r]
    ..sort((a, b) => (b.collectedAt ?? now).compareTo(a.collectedAt ?? now));

  final today = toMuscat(now);
  final tomorrowDate = DateTime.utc(today.year, today.month, today.day + 1);
  final tomorrow = forecasts.where((f) => _sameDay(f.targetDate, tomorrowDate)).firstOrNull;

  return RestaurantToday(
    liveOffers: [for (final o in tonight) if (o.isLive(now)) o]..sort((a, b) => a.pickupEnd.compareTo(b.pickupEnd)),
    waiting: waiting,
    collected: collected,
    postedMeals: tonight.fold(0, (sum, o) => sum + o.quantityTotal),
    reservedMeals: meals(waiting),
    collectedMeals: meals(collected),
    tomorrow: tomorrow,
  );
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// What `GET /restaurants/me/offers`, `/reservations` and `/forecasts`
/// returned. [restaurantTodayViewProvider] turns it into the Today view.
typedef RestaurantTodayData = ({
  List<Offer> offers,
  List<RestaurantReservation> reservations,
  List<Forecast> forecasts,
});

class RestaurantTodayNotifier extends AsyncNotifier<RestaurantTodayData> {
  @override
  Future<RestaurantTodayData> build() {
    // Reload when a different restaurant signs in.
    ref.watch(myRestaurantProvider.select((r) => r.value?.id));
    return _load();
  }

  Future<RestaurantTodayData> _load() async {
    final (offers, reservations, forecasts) = await (
      ref.read(restaurantOffersRepositoryProvider).myOffers(),
      ref.read(pickupsRepositoryProvider).myReservations(),
      ref.read(forecastRepositoryProvider).myForecasts(),
    ).wait;
    return (offers: offers, reservations: reservations, forecasts: forecasts);
  }

  /// Reloads, keeping the current data on screen until the new data arrives.
  Future<void> refresh() async => state = await AsyncValue.guard(_load);

  /// "Edit quantity": [mealsLeft] is what the owner sees; the API takes the total.
  Future<void> setMealsLeft(Offer offer, int mealsLeft) async {
    await ref.read(restaurantOffersRepositoryProvider).updateQuantity(offer.id, offer.taken + mealsLeft);
    await refresh();
  }

  /// "Post surplus": throws [OfferException]; Today reloads on success.
  Future<Offer> post(OfferDraft draft) async {
    final offer = await ref.read(restaurantOffersRepositoryProvider).create(draft);
    await refresh();
    return offer;
  }

  Future<void> endEarly(Offer offer) async {
    await ref.read(restaurantOffersRepositoryProvider).endEarly(offer.id);
    await refresh();
  }

  Future<RestaurantReservation> checkCode(String code) => ref.read(pickupsRepositoryProvider).check(code);

  Future<RestaurantReservation> confirmPickup(String code) async {
    final collected = await ref.read(pickupsRepositoryProvider).confirm(code);
    await refresh();
    return collected;
  }
}

final restaurantTodayProvider =
    AsyncNotifierProvider<RestaurantTodayNotifier, RestaurantTodayData>(RestaurantTodayNotifier.new);

/// The Today view at this moment. Rebuilt on every clock tick (30 s), so an
/// offer drops out of "Live now" when its pickup ends and a hold that runs
/// out leaves "Waiting for pickup", without a reload.
final restaurantTodayViewProvider = Provider<AsyncValue<RestaurantToday>>((ref) {
  final now = ref.now;
  return ref.watch(restaurantTodayProvider).whenData(
        (d) => buildRestaurantToday(offers: d.offers, reservations: d.reservations, forecasts: d.forecasts, now: now),
      );
});
