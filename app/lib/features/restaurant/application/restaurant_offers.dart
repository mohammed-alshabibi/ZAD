import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../domain/offer.dart';
import '../domain/restaurant_reservation.dart';
import 'restaurant_today.dart';

/// An offer that has ended, with the meals people actually picked up.
class PastOffer {
  const PastOffer({required this.offer, required this.collectedMeals});

  final Offer offer;
  final int collectedMeals;
}

/// The restaurant's Offers tab: live offers and past ones.
class RestaurantOffers {
  const RestaurantOffers({required this.live, required this.past, required this.collectedThisWeek});

  /// Still reservable or waiting for pickup, closing soonest first.
  final List<Offer> live;

  /// Ended, sold out, ended early or removed, most recent first.
  final List<PastOffer> past;

  /// Meals picked up in the last 7 days, across all offers.
  final int collectedThisWeek;
}

RestaurantOffers buildRestaurantOffers({
  required List<Offer> offers,
  required List<RestaurantReservation> reservations,
  required DateTime now,
}) {
  final collectedByOffer = <String, int>{};
  var week = 0;
  final weekAgo = now.subtract(const Duration(days: 7));
  for (final r in reservations.where((r) => r.status == ReservationStatus.collected)) {
    collectedByOffer[r.offerId] = (collectedByOffer[r.offerId] ?? 0) + r.quantity;
    if ((r.collectedAt ?? r.holdExpiresAt).isAfter(weekAgo)) week += r.quantity;
  }
  return RestaurantOffers(
    live: [for (final o in offers) if (o.isLive(now)) o]..sort((a, b) => a.pickupEnd.compareTo(b.pickupEnd)),
    past: [
      for (final o in offers)
        if (!o.isLive(now)) PastOffer(offer: o, collectedMeals: collectedByOffer[o.id] ?? 0),
    ]..sort((a, b) => b.offer.pickupEnd.compareTo(a.offer.pickupEnd)),
    collectedThisWeek: week,
  );
}

/// How a past offer ended, for its status pill.
enum PastOfferOutcome { allTaken, ended, endedEarly, removed }

PastOfferOutcome pastOfferOutcome(Offer o) => switch (o.status) {
      OfferStatus.removed => PastOfferOutcome.removed,
      OfferStatus.cancelled => PastOfferOutcome.endedEarly,
      _ when o.quantityAvailable == 0 => PastOfferOutcome.allTaken,
      _ => PastOfferOutcome.ended,
    };

/// The Offers tab at this moment, from the same data as Today (so editing an
/// offer on either tab updates both). Rebuilt on every clock tick.
final restaurantOffersViewProvider = Provider<AsyncValue<RestaurantOffers>>((ref) {
  final now = ref.now;
  return ref.watch(restaurantTodayProvider).whenData(
        (d) => buildRestaurantOffers(offers: d.offers, reservations: d.reservations, now: now),
      );
});
