import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/format/distance.dart';
import 'package:flutter/painting.dart';
import 'package:zad/core/format/money.dart';
import 'package:zad/core/location/map_fit.dart';
import 'package:zad/features/restaurant/data/fake_today_store.dart';
import 'package:zad/features/restaurant/domain/offer.dart';
import 'package:zad/features/user/application/home_offers.dart';
import 'package:zad/features/user/data/user_offers_repository.dart';
import 'package:zad/features/user/domain/nearby_offer.dart';

void main() {
  // aisha@example.com's demo location in Al Khuwair.
  const lat = 23.583;
  const lng = 58.396;

  test('distances are shown in km with one decimal', () {
    expect(formatKm(640), '0.6 km');
    expect(formatKm(1180), '1.2 km');
    expect(formatKm(30), '0.1 km');
    expect(formatKm(12345), '12.3 km');
  });

  test('the crossed-out price has no currency', () {
    expect(formatOmrAmount(2400), '2.400');
    expect(formatOmr(2400), '2.400 OMR');
  });

  test('haversine distance matches a known pair (~0.68 km)', () {
    expect(distanceMeters(23.585, 58.386, 23.5884, 58.3915), closeTo(675, 15));
  });

  group('Map fit', () {
    const view = Size(402, 802);
    final box = Rect.fromLTRB(32, 136, 338, 320);
    final points = [(23.583, 58.396), (23.5884, 58.3915), (23.5854, 58.3823), (23.5885, 58.3870), (23.5870, 58.4037)];

    test('every point lands inside the box', () {
      final camera = fitCamera(points, box, view);
      for (final (lat, lng) in points) {
        final px = projectToView(lat, lng, camera, view);
        expect(box.inflate(0.5).contains(px), isTrue, reason: '$lat,$lng → $px');
      }
    });

    test('the points fill the box in at least one direction', () {
      final camera = fitCamera(points, box, view);
      final pxs = [for (final (lat, lng) in points) projectToView(lat, lng, camera, view)];
      final w = pxs.map((p) => p.dx).reduce((a, b) => a > b ? a : b) - pxs.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
      final h = pxs.map((p) => p.dy).reduce((a, b) => a > b ? a : b) - pxs.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
      expect(w > box.width - 1 || h > box.height - 1, isTrue);
    });

    test('one point zooms to street level, far points stop at city level', () {
      expect(fitCamera([points.first], box, view).zoom, 15);
      expect(fitCamera([points.first, (23.617, 58.566)], box, view, minZoom: 11.5).zoom, 11.5);
    });
  });

  group('Fake GET /offers/nearby', () {
    late FakeTodayStore store;
    late FakeUserOffersRepository repo;

    setUp(() {
      store = FakeTodayStore.seeded(DateTime.now());
      repo = FakeUserOffersRepository(store, latency: Duration.zero);
    });

    test('returns the five Al Khuwair offers, nearest first, 23 meals in all', () async {
      final offers = await repo.nearby(lat: lat, lng: lng);
      expect(offers, hasLength(5));
      expect(offers.map((o) => o.id), isNot(contains('o_muttrah'))); // 18 km away
      final distances = offers.map((o) => o.distanceM).toList();
      expect(distances, [...distances]..sort());
      expect(mealsLeft(offers), 23);
      expect(offers.firstWhere((o) => o.id == 'o_zaatar').restaurantName, 'Khubz & Co. Bakery');
    });

    test('a bigger radius reaches Muttrah', () async {
      final offers = await repo.nearby(lat: lat, lng: lng, radiusKm: 25);
      expect(offers.map((o) => o.id), contains('o_muttrah'));
    });

    test('closed, cancelled and finished offers are not returned', () async {
      store.offerById('o_mandi')!['status'] = 'cancelled';
      store.offerById('o_bowls')!['pickup_end'] =
          DateTime.now().toUtc().subtract(const Duration(minutes: 1)).toIso8601String();
      final ids = (await repo.nearby(lat: lat, lng: lng)).map((o) => o.id);
      expect(ids, isNot(contains('o_mandi')));
      expect(ids, isNot(contains('o_bowls')));
    });
  });

  group('Home filters', () {
    late List<NearbyOffer> offers;
    final now = DateTime.now();

    setUp(() async {
      final repo = FakeUserOffersRepository(FakeTodayStore.seeded(now), latency: Duration.zero);
      offers = await repo.nearby(lat: lat, lng: lng);
    });

    List<String> ids(HomeFilters f) => applyHomeFilters(offers, f, now).map((o) => o.id).toList()..sort();

    test('no filters shows everything with meals left', () {
      expect(ids(const HomeFilters()), hasLength(5));
    });

    test('closing soon = pickup ends within 30 minutes', () {
      expect(ids(const HomeFilters(closingSoon: true)), ['o_bowls', 'o_zaatar']);
    });

    test('free and under 1 OMR', () {
      expect(ids(const HomeFilters(free: true)), ['o_bowls']);
      expect(ids(const HomeFilters(underOneOmr: true)), ['o_bowls', 'o_halwa', 'o_zaatar']);
    });

    test('category and search', () {
      expect(ids(const HomeFilters(category: OfferCategory.riceMandi)), ['o_biryani', 'o_mandi']);
      expect(ids(const HomeFilters(query: 'khubz')), ['o_zaatar']);
      expect(ids(const HomeFilters(query: 'MANDI')), ['o_mandi']);
    });

    test('sold-out offers are hidden on Home', () {
      offers = [
        for (final o in offers)
          o.id == 'o_zaatar'
              ? NearbyOffer.fromJson({..._json(o), 'quantity_available': 0, 'status': 'sold_out'})
              : o,
      ];
      expect(ids(const HomeFilters()), isNot(contains('o_zaatar')));
    });

    test('pins group offers by restaurant and add up their meals', () {
      final places = groupByRestaurant(offers);
      expect(places, hasLength(5));
      expect(places.firstWhere((p) => p.restaurantId == 'r_bait').mealsLeft, 9);
    });

    test('the sheet list is sorted by pickup end', () {
      final ends = byPickupEnd(offers).map((o) => o.offer.pickupEnd).toList();
      expect(ends, [...ends]..sort());
      expect(byPickupEnd(offers).first.id, 'o_bowls');
    });
  });
}

Map<String, dynamic> _json(NearbyOffer o) => {
      'id': o.id,
      'restaurant_id': o.restaurantId,
      'restaurant_name': o.restaurantName,
      'cuisine': o.cuisine,
      'location': {
        'type': 'Point',
        'coordinates': [o.lng, o.lat],
      },
      'distance_m': o.distanceM,
      'title': o.offer.title,
      'description': o.offer.description,
      'category': o.offer.category,
      'allergens': o.offer.allergens,
      'original_price_baisa': o.offer.originalPriceBaisa,
      'price_baisa': o.offer.priceBaisa,
      'quantity_total': o.offer.quantityTotal,
      'quantity_available': o.offer.quantityAvailable,
      'prepared_at': o.offer.preparedAt.toIso8601String(),
      'pickup_start': o.offer.pickupStart.toIso8601String(),
      'pickup_end': o.offer.pickupEnd.toIso8601String(),
      'status': o.offer.status.json,
    };
