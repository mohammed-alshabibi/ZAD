import '../../../core/format/muscat_time.dart';
import '../domain/forecast.dart';
import '../domain/offer.dart';
import '../domain/offer_draft.dart';
import '../domain/restaurant.dart';
import '../domain/restaurant_reservation.dart';
import 'restaurant_today_repositories.dart';

/// In-memory offers and reservations for P1, in the §4 JSON shapes, with the
/// server rules the screens depend on: lazy expiry, the hidden pickup code,
/// and the wrong-code lockout.
///
/// Demo (khubz@example.com): one live offer closing in 28 minutes, two
/// pickups waiting (codes **482913** and **610271**) and one collected.
///
/// Users near Al Khuwair (aisha@example.com) see Khubz plus four other
/// fictional kitchens: 23 meals in all, as on the Figma Home screen. A sixth
/// offer in Muttrah sits outside the 5 km radius.
///
/// Aisha also has a pickup history on offers that closed in the last ten
/// days: 5 collected (7 meals, 9.600 OMR saved, as on Figma "Pickups"),
/// 1 missed and 1 cancelled.
class FakeTodayStore {
  FakeTodayStore._(this.offers, this.reservations);

  factory FakeTodayStore.seeded(DateTime now) {
    String iso(Duration d) => now.toUtc().add(d).toIso8601String();
    final end = iso(const Duration(minutes: 28));
    // Each offer carries copies of its restaurant's name, cuisine and
    // location, so the nearby query can run on offers alone (§4).
    Map<String, dynamic> offer({
      required String id,
      required String restaurantId,
      required String restaurantName,
      required String cuisine,
      required String phone,
      required List<double> lngLat,
      required String title,
      required String description,
      required String category,
      required List<String> allergens,
      required int? originalPrice,
      required int price,
      required int total,
      required int available,
      required Duration start,
      required Duration end,
    }) =>
        {
          'id': id,
          'restaurant_id': restaurantId,
          'restaurant_name': restaurantName,
          'cuisine': cuisine,
          // Only `GET /offers/{id}` returns this (joined from the restaurant).
          'restaurant_phone': phone,
          'location': {'type': 'Point', 'coordinates': lngLat},
          'title': title,
          'description': description,
          'category': category,
          'allergens': allergens,
          'photo': null,
          'original_price_baisa': originalPrice,
          'price_baisa': price,
          'quantity_total': total,
          'quantity_available': available,
          'prepared_at': iso(start - const Duration(hours: 2)),
          'pickup_start': iso(start),
          'pickup_end': iso(end),
          'status': available == 0 ? 'sold_out' : 'active',
          'safety_attested': true,
        };

    // An offer whose pickup window ended [daysAgo] days ago.
    Map<String, dynamic> past({
      required String id,
      required String restaurantId,
      required String restaurantName,
      required String cuisine,
      required List<double> lngLat,
      required String title,
      required String category,
      required int originalPrice,
      required int price,
      required int daysAgo,
    }) =>
        {
          ...offer(
            id: id,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            cuisine: cuisine,
            phone: '+968 9000 0000',
            lngLat: lngLat,
            title: title,
            description: '',
            category: category,
            allergens: ['none'],
            originalPrice: originalPrice,
            price: price,
            total: 6,
            available: 0,
            start: Duration(days: -daysAgo, minutes: -60),
            end: Duration(days: -daysAgo, minutes: 30),
          ),
          'status': 'closed',
        };

    return FakeTodayStore._(
      [
        offer(
          id: 'o_zaatar',
          restaurantId: 'r_khubz',
          restaurantName: 'Khubz & Co. Bakery',
          cuisine: 'bakery',
          phone: '+968 9123 4567',
          lngLat: [58.3915, 23.5884],
          title: 'Zaatar manakish box',
          description: 'Six warm manakish with zaatar and olive oil, baked this afternoon.',
          category: 'bakery',
          allergens: ['gluten', 'sesame'],
          originalPrice: 2000,
          price: 800,
          total: 6,
          available: 2,
          start: const Duration(minutes: -90),
          end: const Duration(minutes: 28),
        ),
        offer(
          id: 'o_mandi',
          restaurantId: 'r_wadi',
          restaurantName: 'Wadi Grill House',
          cuisine: 'grill',
          phone: '+968 9455 1020',
          lngLat: [58.4037, 23.5870],
          title: 'Chicken mandi, half portions',
          description: 'Smoked chicken on spiced rice with tomato salsa.',
          category: 'rice_mandi',
          allergens: ['none'],
          originalPrice: 3900,
          price: 1500,
          total: 8,
          available: 6,
          start: const Duration(minutes: 15),
          end: const Duration(minutes: 75),
        ),
        offer(
          id: 'o_biryani',
          restaurantId: 'r_bait',
          restaurantName: 'Bait Al Biryani',
          cuisine: 'indian',
          phone: '+968 9877 3301',
          lngLat: [58.3823, 23.5854],
          title: 'Mutton biryani trays',
          description: 'Family trays from the dinner service, with raita on the side.',
          category: 'rice_mandi',
          allergens: ['milk'],
          originalPrice: 3000,
          price: 1200,
          total: 12,
          available: 9,
          start: const Duration(minutes: -30),
          end: const Duration(minutes: 60),
        ),
        offer(
          id: 'o_bowls',
          restaurantId: 'r_green',
          restaurantName: 'Green Bowl Café',
          cuisine: 'healthy',
          phone: '+968 7101 2290',
          lngLat: [58.3870, 23.5885],
          title: 'Falafel salad bowls',
          description: 'Falafel, hummus and greens. Free tonight.',
          category: 'healthy',
          allergens: ['sesame', 'gluten'],
          originalPrice: 2200,
          price: 0,
          total: 6,
          available: 4,
          start: const Duration(minutes: -60),
          end: const Duration(minutes: 20),
        ),
        offer(
          id: 'o_halwa',
          restaurantId: 'r_halwa',
          restaurantName: 'Al Qurm Sweets',
          cuisine: 'arabic',
          phone: '+968 9300 6612',
          lngLat: [58.4067, 23.5850],
          title: 'Omani halwa and luqaimat',
          description: 'A mixed box of halwa and date-syrup luqaimat.',
          category: 'sweets',
          allergens: ['gluten', 'nuts'],
          originalPrice: 1500,
          price: 600,
          total: 4,
          available: 2,
          start: const Duration(minutes: 60),
          end: const Duration(minutes: 150),
        ),
        offer(
          id: 'o_muttrah',
          restaurantId: 'r_muttrah',
          restaurantName: 'Corniche Shawarma',
          cuisine: 'fast_food',
          phone: '+968 9944 0187',
          lngLat: [58.5660, 23.6170],
          title: 'Chicken shawarma wraps',
          description: 'Wraps from the evening rush.',
          category: 'sandwiches',
          allergens: ['gluten', 'sesame'],
          originalPrice: 900,
          price: 400,
          total: 10,
          available: 10,
          start: const Duration(minutes: -20),
          end: const Duration(minutes: 90),
        ),
        // Closed offers behind Aisha's pickup history.
        past(id: 'o_past_mandi', restaurantId: 'r_wadi', restaurantName: 'Wadi Grill House', cuisine: 'grill',
            lngLat: [58.4037, 23.5870], title: 'Chicken mandi, half portions', category: 'rice_mandi',
            originalPrice: 3900, price: 1500, daysAgo: 1),
        past(id: 'o_past_pastry', restaurantId: 'r_qurum', restaurantName: 'Qurum Corner Café', cuisine: 'bakery',
            lngLat: [58.4120, 23.5890], title: 'Mixed pastry bag', category: 'bakery',
            originalPrice: 2000, price: 800, daysAgo: 2),
        past(id: 'o_past_veg', restaurantId: 'r_masala', restaurantName: 'Masala Street', cuisine: 'indian',
            lngLat: [58.3790, 23.5860], title: 'Veg biryani with raita', category: 'rice_mandi',
            originalPrice: 2000, price: 900, daysAgo: 3),
        past(id: 'o_past_kofta', restaurantId: 'r_wadi', restaurantName: 'Wadi Grill House', cuisine: 'grill',
            lngLat: [58.4037, 23.5870], title: 'Grilled kofta plates', category: 'grill',
            originalPrice: 2800, price: 1200, daysAgo: 4),
        past(id: 'o_past_biryani', restaurantId: 'r_bait', restaurantName: 'Bait Al Biryani', cuisine: 'indian',
            lngLat: [58.3823, 23.5854], title: 'Mutton biryani trays', category: 'rice_mandi',
            originalPrice: 2400, price: 1200, daysAgo: 5),
        past(id: 'o_past_halwa', restaurantId: 'r_halwa', restaurantName: 'Al Qurm Sweets', cuisine: 'arabic',
            lngLat: [58.4067, 23.5850], title: 'Omani halwa and luqaimat', category: 'sweets',
            originalPrice: 1500, price: 600, daysAgo: 8),
        past(id: 'o_past_hummus', restaurantId: 'r_green', restaurantName: 'Green Bowl Café', cuisine: 'healthy',
            lngLat: [58.3870, 23.5885], title: 'Hummus and pita box', category: 'healthy',
            originalPrice: 1200, price: 600, daysAgo: 10),
      ],
      [
        _reservation('res_aisha', 'Aisha', 1, '482913', 'reserved', end, null, now),
        _reservation('res_salim', 'Salim', 2, '610271', 'reserved', end, null, now),
        _reservation('res_mariam', 'Mariam', 1, '305118', 'collected', end,
            iso(const Duration(minutes: -20)), now),
        _aishaPast('res_past_1', 'o_past_mandi', 2, 'collected', 1, now),
        _aishaPast('res_past_2', 'o_past_pastry', 1, 'collected', 2, now),
        _aishaPast('res_past_3', 'o_past_veg', 1, 'expired', 3, now),
        _aishaPast('res_past_4', 'o_past_kofta', 1, 'cancelled', 4, now),
        _aishaPast('res_past_5', 'o_past_biryani', 1, 'collected', 5, now),
        _aishaPast('res_past_6', 'o_past_halwa', 2, 'collected', 8, now),
        _aishaPast('res_past_7', 'o_past_hummus', 1, 'collected', 10, now),
      ],
    );
  }

  /// One of Aisha's earlier reservations, made [daysAgo] days ago once pickup
  /// had opened; collected ones were picked up 15 minutes later.
  static Map<String, dynamic> _aishaPast(
      String id, String offerId, int quantity, String status, int daysAgo, DateTime now) {
    final created = now.toUtc().subtract(Duration(days: daysAgo, minutes: 40));
    return {
      'id': id,
      'offer_id': offerId,
      'user_id': 'u_aisha',
      'user_first_name': 'Aisha',
      'quantity': quantity,
      'pickup_code': (100000 + daysAgo * 7919).toString(),
      'status': status,
      'hold_expires_at': created.add(const Duration(minutes: 30)).toIso8601String(),
      'collected_at': status == 'collected' ? created.add(const Duration(minutes: 15)).toIso8601String() : null,
      'created_at': created.toIso8601String(),
    };
  }

  static Map<String, dynamic> _reservation(String id, String firstName, int quantity, String code,
          String status, String holdUntil, String? collectedAt, DateTime now) =>
      {
        'id': id,
        'offer_id': 'o_zaatar',
        // Demo users: res_aisha belongs to aisha@example.com (u_aisha).
        'user_id': 'u_${firstName.toLowerCase()}',
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
  FakeRestaurantOffersRepository(
    this.store,
    this.restaurantId, {
    this.restaurant,
    this.latency = const Duration(milliseconds: 300),
  });

  final FakeTodayStore store;
  final Future<String?> Function() restaurantId;

  /// The signed-in restaurant, for posting (name, cuisine and location are
  /// copied onto the offer).
  final Future<Restaurant?> Function()? restaurant;
  final Duration latency;

  @override
  Future<Offer> create(OfferDraft draft) async {
    await Future<void>.delayed(latency);
    final r = await restaurant?.call();
    if (r == null || r.status != RestaurantStatus.approved) throw const OfferException(OfferException.notApproved);
    final now = DateTime.now();
    if (draft.validate(now).isNotEmpty) throw const OfferException(OfferException.invalid);
    final offer = {
      ...draft.toJson(),
      'id': 'o_${now.microsecondsSinceEpoch}',
      'restaurant_id': r.id,
      'restaurant_name': r.name,
      'cuisine': r.cuisine.json,
      'restaurant_phone': r.phone,
      // GeoJSON is longitude first.
      'location': {
        'type': 'Point',
        'coordinates': [r.lng, r.lat],
      },
      'photo': null,
      'quantity_available': draft.quantity,
      'status': 'active',
    };
    store.offers.add(offer);
    return Offer.fromJson(offer);
  }

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
