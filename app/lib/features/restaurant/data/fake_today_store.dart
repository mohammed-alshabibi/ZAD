import '../../../core/format/muscat_time.dart';
import '../domain/forecast.dart';
import '../domain/offer.dart';
import '../domain/restaurant.dart';
import '../domain/restaurant_reservation.dart';
import 'restaurant_today_repositories.dart';

/// In-memory offers and reservations for P1, in the §4 JSON shapes, with the
/// server rules the screens depend on: lazy expiry, the hidden pickup code,
/// and the wrong-code lockout.
///
/// Demo (khubz@example.com): one live offer closing in 28 minutes, two
/// pickups waiting (codes **482913** and **610271**) and one collected.
class FakeTodayStore {
  FakeTodayStore._(this.offers, this.reservations);

  factory FakeTodayStore.seeded(DateTime now) {
    String iso(Duration d) => now.toUtc().add(d).toIso8601String();
    final end = iso(const Duration(minutes: 28));
    return FakeTodayStore._(
      [
        {
          'id': 'o_zaatar',
          'restaurant_id': 'r_khubz',
          'title': 'Zaatar manakish box',
          'description': 'Six warm manakish with zaatar and olive oil, baked this afternoon.',
          'category': 'bakery',
          'allergens': ['gluten', 'sesame'],
          'photo': null,
          'original_price_baisa': 2000,
          'price_baisa': 800,
          'quantity_total': 6,
          'quantity_available': 2,
          'prepared_at': iso(const Duration(hours: -3)),
          'pickup_start': iso(const Duration(minutes: -90)),
          'pickup_end': end,
          'status': 'active',
          'safety_attested': true,
        },
      ],
      [
        _reservation('res_aisha', 'Aisha', 1, '482913', 'reserved', end, null, now),
        _reservation('res_salim', 'Salim', 2, '610271', 'reserved', end, null, now),
        _reservation('res_mariam', 'Mariam', 1, '305118', 'collected', end,
            iso(const Duration(minutes: -20)), now),
      ],
    );
  }

  static Map<String, dynamic> _reservation(String id, String firstName, int quantity, String code,
          String status, String holdUntil, String? collectedAt, DateTime now) =>
      {
        'id': id,
        'offer_id': 'o_zaatar',
        'user_first_name': firstName,
        'quantity': quantity,
        // Server-only field: the restaurant API never returns the full code.
        'pickup_code': code,
        'status': status,
        'hold_expires_at': holdUntil,
        'collected_at': collectedAt,
        'created_at': now.toUtc().subtract(const Duration(minutes: 40)).toIso8601String(),
      };

  final List<Map<String, dynamic>> offers;
  final List<Map<String, dynamic>> reservations;

  /// restaurant_id → wrong codes in a row, and when entry is locked until.
  final Map<String, int> _wrongCodes = {};
  final Map<String, DateTime> _lockedUntil = {};

  static const maxWrongCodes = 5;
  static const lockout = Duration(minutes: 10);

  Map<String, dynamic>? offerById(String id) => offers.where((o) => o['id'] == id).firstOrNull;

  /// CLAUDE.md §3 flow 5: before reading, old holds become `expired` (their
  /// meals go back on the offer) and finished offers become `closed`.
  void expireStale(DateTime now) {
    for (final r in reservations) {
      if (r['status'] == 'reserved' && DateTime.parse(r['hold_expires_at'] as String).isBefore(now)) {
        r['status'] = 'expired';
        final offer = offerById(r['offer_id'] as String);
        if (offer != null && (offer['status'] == 'active' || offer['status'] == 'sold_out')) {
          offer['quantity_available'] = (offer['quantity_available'] as int) + (r['quantity'] as int);
          offer['status'] = 'active';
        }
      }
    }
    for (final o in offers) {
      final live = o['status'] == 'active' || o['status'] == 'sold_out';
      if (live && DateTime.parse(o['pickup_end'] as String).isBefore(now)) o['status'] = 'closed';
    }
  }

  /// The restaurant-facing JSON for a reservation (§5.1: first name + code hint).
  Map<String, dynamic> reservationJson(Map<String, dynamic> r) {
    final offer = offerById(r['offer_id'] as String)!;
    return {
      'id': r['id'],
      'offer_id': r['offer_id'],
      'offer_title': offer['title'],
      'user_first_name': r['user_first_name'],
      'quantity': r['quantity'],
      'code_hint': (r['pickup_code'] as String).substring(3),
      'status': r['status'],
      'price_baisa': offer['price_baisa'],
      'hold_expires_at': r['hold_expires_at'],
      'collected_at': r['collected_at'],
    };
  }

  Iterable<Map<String, dynamic>> reservationsFor(String restaurantId) => reservations.where(
      (r) => offerById(r['offer_id'] as String)?['restaurant_id'] == restaurantId);

  /// Finds the reservation for [code] at [restaurantId], with the lockout.
  Map<String, dynamic> matchCode(String restaurantId, String code, DateTime now) {
    final locked = _lockedUntil[restaurantId];
    if (locked != null && locked.isAfter(now)) {
      throw PickupException(PickupException.locked, retryAfter: locked);
    }
    final match = reservationsFor(restaurantId).where((r) => r['pickup_code'] == code).firstOrNull;
    if (match == null) {
      final wrong = (_wrongCodes[restaurantId] ?? 0) + 1;
      if (wrong >= maxWrongCodes) {
        _wrongCodes[restaurantId] = 0;
        _lockedUntil[restaurantId] = now.add(lockout);
        throw PickupException(PickupException.locked, retryAfter: now.add(lockout));
      }
      _wrongCodes[restaurantId] = wrong;
      throw const PickupException(PickupException.codeNotFound);
    }
    _wrongCodes[restaurantId] = 0;
    switch (match['status']) {
      case 'collected':
        throw const PickupException(PickupException.alreadyCollected);
      case 'expired' || 'cancelled':
        throw const PickupException(PickupException.expired);
    }
    return match;
  }
}

class FakeRestaurantOffersRepository implements RestaurantOffersRepository {
  FakeRestaurantOffersRepository(this.store, this.restaurantId, {this.latency = const Duration(milliseconds: 300)});

  final FakeTodayStore store;
  final Future<String?> Function() restaurantId;
  final Duration latency;

  @override
  Future<List<Offer>> myOffers() async {
    await Future<void>.delayed(latency);
    final id = await restaurantId();
    store.expireStale(DateTime.now());
    return [
      for (final o in store.offers)
        if (o['restaurant_id'] == id) Offer.fromJson(o),
    ];
  }

  @override
  Future<Offer> updateQuantity(String offerId, int quantityTotal) async {
    await Future<void>.delayed(latency);
    final offer = await _own(offerId);
    final taken = (offer['quantity_total'] as int) - (offer['quantity_available'] as int);
    if (quantityTotal < OfferQuantity.min || quantityTotal > OfferQuantity.max) {
      throw const OfferException(OfferException.outOfRange);
    }
    if (quantityTotal < taken) throw const OfferException(OfferException.belowTaken);
    final available = quantityTotal - taken;
    offer
      ..['quantity_total'] = quantityTotal
      ..['quantity_available'] = available
      ..['status'] = available == 0 ? 'sold_out' : 'active';
    return Offer.fromJson(offer);
  }

  @override
  Future<Offer> endEarly(String offerId) async {
    await Future<void>.delayed(latency);
    final offer = await _own(offerId);
    offer['status'] = 'cancelled';
    return Offer.fromJson(offer);
  }

  Future<Map<String, dynamic>> _own(String offerId) async {
    final id = await restaurantId();
    store.expireStale(DateTime.now());
    final offer = store.offerById(offerId);
    if (offer == null || offer['restaurant_id'] != id) throw const OfferException(OfferException.notFound);
    if (offer['status'] != 'active' && offer['status'] != 'sold_out') {
      throw const OfferException(OfferException.notLive);
    }
    return offer;
  }
}

class FakePickupsRepository implements PickupsRepository {
  FakePickupsRepository(this.store, this.restaurantId, {this.latency = const Duration(milliseconds: 300)});

  final FakeTodayStore store;
  final Future<String?> Function() restaurantId;
  final Duration latency;

  @override
  Future<List<RestaurantReservation>> myReservations() async {
    await Future<void>.delayed(latency);
    final id = await restaurantId();
    if (id == null) return const [];
    store.expireStale(DateTime.now());
    return [for (final r in store.reservationsFor(id)) RestaurantReservation.fromJson(store.reservationJson(r))];
  }

  @override
  Future<RestaurantReservation> check(String code) async {
    await Future<void>.delayed(latency);
    final match = await _match(code);
    return RestaurantReservation.fromJson(store.reservationJson(match));
  }

  @override
  Future<RestaurantReservation> confirm(String code) async {
    await Future<void>.delayed(latency);
    final match = await _match(code);
    match
      ..['status'] = 'collected'
      ..['collected_at'] = DateTime.now().toUtc().toIso8601String();
    return RestaurantReservation.fromJson(store.reservationJson(match));
  }

  Future<Map<String, dynamic>> _match(String code) async {
    final id = await restaurantId();
    if (id == null) throw const PickupException(PickupException.codeNotFound);
    final now = DateTime.now();
    store.expireStale(now);
    return store.matchCode(id, code, now);
  }
}

/// Answers like `run_forecast` would (§7.3): Khubz has 23 days of logs and
/// gets the seasonal model; a new restaurant gets the cold-start estimate
/// from its onboarding answers.
class FakeForecastRepository implements ForecastRepository {
  FakeForecastRepository(this.restaurant, {this.latency = const Duration(milliseconds: 300)});

  final Future<Restaurant?> Function() restaurant;
  final Duration latency;

  /// Generic weekday pattern, Monday first. Fri–Sat is the Omani weekend.
  static const _weekday = [0.9, 0.95, 1.0, 1.1, 1.35, 1.2, 0.9];

  @override
  Future<List<Forecast>> myForecasts() async {
    await Future<void>.delayed(latency);
    final r = await restaurant();
    if (r == null) return const [];
    final hasHistory = r.id == 'r_khubz';
    final meals = r.typicalDailyMeals ?? 40;
    final pct = r.typicalSurplusPct ?? 10;
    final base = meals * pct / 100;
    final today = toMuscat(DateTime.now());
    return [
      for (var i = 1; i <= 7; i++)
        () {
          final day = DateTime.utc(today.year, today.month, today.day + i);
          final predicted = (base * _weekday[day.weekday - 1]).round();
          final spread = hasHistory ? (predicted * 0.34).round() : (predicted * 0.5).round();
          return Forecast.fromJson({
            'target_date': '${day.year}-${_two(day.month)}-${_two(day.day)}',
            'predicted': predicted,
            'low': (predicted - spread).clamp(0, predicted),
            'high': predicted + spread,
            'confidence': hasHistory ? 'medium' : 'low',
            'model': hasHistory ? 'm1' : 'cold_start',
            'explanations': hasHistory
                ? ['Fridays are usually higher', 'Based on 23 days of your data']
                : ['Rough estimate from your typical day'],
          });
        }(),
    ];
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
