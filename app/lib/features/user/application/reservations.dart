import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session.dart';
import '../../restaurant/domain/restaurant_reservation.dart';
import '../data/user_offers_repository.dart';
import '../data/user_reservations_repository.dart';
import '../domain/nearby_offer.dart';
import '../domain/user_reservation.dart';
import 'home_offers.dart';

/// `GET /offers/{id}` for Meal details, with the distance from the user.
final offerDetailsProvider = FutureProvider.autoDispose.family<NearbyOffer, String>((ref, id) {
  final center = ref.watch(homeCenterProvider);
  return ref.watch(userOffersRepositoryProvider).offer(id, lat: center.lat, lng: center.lng);
});

/// The signed-in user's reservations (`GET /reservations`). Reserving and
/// cancelling go through here so Home, Meal details and Pickups stay in step.
class MyReservationsNotifier extends AsyncNotifier<List<UserReservation>> {
  UserReservationsRepository get _repo => ref.read(userReservationsRepositoryProvider);

  @override
  Future<List<UserReservation>> build() {
    // Reload when a different user signs in.
    ref.watch(sessionProvider.select((u) => u?.id));
    return _repo.myReservations();
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_repo.myReservations);

  /// Throws [ReserveException]; on success the meals-left numbers reload.
  Future<UserReservation> reserve(String offerId, int quantity) async {
    final reservation = await _repo.reserve(offerId, quantity);
    _offerChanged(offerId);
    await refresh();
    return reservation;
  }

  Future<void> cancel(UserReservation reservation) async {
    await _repo.cancel(reservation.id);
    _offerChanged(reservation.offerId);
    await refresh();
  }

  void _offerChanged(String offerId) {
    ref.invalidate(nearbyOffersProvider);
    ref.invalidate(offerDetailsProvider(offerId));
  }
}

final myReservationsProvider =
    AsyncNotifierProvider<MyReservationsNotifier, List<UserReservation>>(MyReservationsNotifier.new);

/// Which Pickups tab is open: 0 = Upcoming, 1 = History. A provider (not
/// screen state) so Profile's "Pickup history" row can open History.
class PickupsTabNotifier extends Notifier<int> {
  @override
  int build() {
    ref.watch(sessionProvider.select((u) => u?.id));
    return 0;
  }

  void select(int tab) => state = tab;
}

final pickupsTabProvider = NotifierProvider<PickupsTabNotifier, int>(PickupsTabNotifier.new);

/// The user's waiting reservation on [offerId], if any.
UserReservation? activeReservationFor(List<UserReservation> reservations, String offerId, DateTime now) =>
    reservations.where((r) => r.offerId == offerId && r.isActive(now)).firstOrNull;

/// Most meals the user may reserve now: 3 per person, and no more than are left.
int maxReservable(int mealsLeft) =>
    mealsLeft < FakeUserReservationsRepository.maxPerUser ? mealsLeft : FakeUserReservationsRepository.maxPerUser;

/// Pickups "Upcoming": holds still running, the one ending soonest first.
List<UserReservation> upcomingPickups(List<UserReservation> reservations, DateTime now) =>
    reservations.where((r) => r.isActive(now)).toList()..sort((a, b) => a.holdExpiresAt.compareTo(b.holdExpiresAt));

/// Pickups "History": collected, missed and cancelled, most recent first.
List<UserReservation> pickupHistory(List<UserReservation> reservations, DateTime now) =>
    reservations.where((r) => !r.isActive(now)).toList()
      ..sort((a, b) => pickupHistoryTime(b).compareTo(pickupHistoryTime(a)));

/// When a past reservation ended: picked up, or the hold ran out, or (for a
/// cancelled one) when it was made, since the cancel time is not stored.
DateTime pickupHistoryTime(UserReservation r) => switch (r.status) {
      ReservationStatus.collected => r.collectedAt ?? r.holdExpiresAt,
      ReservationStatus.cancelled => r.createdAt,
      ReservationStatus.reserved || ReservationStatus.expired => r.holdExpiresAt,
    };

/// "7 meals rescued · 9.600 OMR saved": only collected meals count.
typedef RescueStats = ({int meals, int savedBaisa});

RescueStats rescueStats(List<UserReservation> reservations) {
  var meals = 0;
  var saved = 0;
  for (final r in reservations.where((r) => r.status == ReservationStatus.collected)) {
    meals += r.quantity;
    saved += r.savedBaisa;
  }
  return (meals: meals, savedBaisa: saved);
}

/// How far the restaurant is from the user's saved location (or Muscat).
int distanceToPickup(HomeCenter center, UserReservation r) =>
    distanceMeters(center.lat, center.lng, r.lat, r.lng).round();
