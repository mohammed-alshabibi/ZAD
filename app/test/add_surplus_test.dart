import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/format/money.dart';
import 'package:zad/core/format/muscat_time.dart';
import 'package:zad/features/restaurant/data/fake_today_store.dart';
import 'package:zad/features/restaurant/data/restaurant_today_repositories.dart';
import 'package:zad/features/restaurant/domain/offer.dart';
import 'package:zad/features/restaurant/domain/offer_draft.dart';
import 'package:zad/features/restaurant/domain/restaurant.dart';
import 'package:zad/features/user/data/user_offers_repository.dart';

Restaurant _khubz(String status) => Restaurant.fromJson({
      'id': 'r_khubz',
      'owner_id': 'u_khubz',
      'name': 'Khubz & Co. Bakery',
      'cuisine': 'bakery',
      'description': '',
      'phone': '+968 9123 4567',
      'address_text': 'Al Khuwair, Way 3013',
      'location': {
        'type': 'Point',
        'coordinates': [58.3915, 23.5884],
      },
      'status': status,
      'created_at': '2026-10-01T10:00:00Z',
    });

void main() {
  final now = DateTime.now();

  /// A draft that passes every rule.
  OfferDraft good() => OfferDraft(
        title: 'Zaatar manakish box',
        description: 'Six from tonight’s 18:00 batch.',
        category: OfferCategory.bakery,
        quantity: 6,
        priceBaisa: 800,
        originalPriceBaisa: 2400,
        pickupStart: now,
        pickupEnd: now.add(const Duration(hours: 1)),
        preparedAt: now.subtract(const Duration(hours: 2)),
        allergens: const ['gluten', 'sesame'],
        safetyAttested: true,
      );

  group('Offer draft rules (§4, §8.2)', () {
    test('a complete draft is valid', () => expect(good().validate(now), isEmpty));

    test('a fresh form needs name, category, price, prepared time, allergens and the safety check', () {
      expect(OfferDraft.start(now).validate(now), {
        OfferDraftError.title,
        OfferDraftError.category,
        OfferDraftError.price,
        OfferDraftError.preparedAt,
        OfferDraftError.allergens,
        OfferDraftError.safety,
      });
    });

    test('the starting pickup window is the next quarter hour, for an hour', () {
      final d = OfferDraft.start(now);
      expect(d.pickupStart!.isAfter(now), isTrue);
      expect(d.pickupStart!.difference(now).inMinutes, lessThanOrEqualTo(15));
      expect(toMuscat(d.pickupStart!).minute % 15, 0);
      expect(d.pickupEnd!.difference(d.pickupStart!), const Duration(hours: 1));
    });

    test('quantity 1–100', () {
      expect(good().copyWith(quantity: 0).validate(now), {OfferDraftError.quantity});
      expect(good().copyWith(quantity: 101).validate(now), {OfferDraftError.quantity});
      expect(good().copyWith(quantity: 100).validate(now), isEmpty);
    });

    test('free is a price; the normal price must be higher', () {
      expect(good().copyWith(priceBaisa: () => 0, originalPriceBaisa: () => null).validate(now), isEmpty);
      expect(good().copyWith(originalPriceBaisa: () => 800).validate(now), {OfferDraftError.wasPrice});
    });

    test('pickup ends after it starts, is not over, and ends within 12 hours', () {
      final start = now.add(const Duration(hours: 1));
      expect(good().copyWith(pickupStart: start, pickupEnd: start).validate(now), {OfferDraftError.pickupOrder});
      expect(
        good()
            .copyWith(
              pickupStart: now.subtract(const Duration(hours: 2)),
              pickupEnd: now.subtract(const Duration(minutes: 1)),
            )
            .validate(now),
        {OfferDraftError.pickupOver},
      );
      expect(good().copyWith(pickupEnd: now.add(const Duration(hours: 13))).validate(now),
          {OfferDraftError.pickupTooLate});
    });

    test('prepared earlier today, not in the future', () {
      expect(good().copyWith(preparedAt: now.add(const Duration(minutes: 5))).validate(now),
          {OfferDraftError.preparedAt});
      expect(good().copyWith(preparedAt: now.subtract(const Duration(hours: 13))).validate(now),
          {OfferDraftError.preparedAt});
    });

    test('allergens: a list, or "none" alone', () {
      expect(good().copyWith(allergens: const ['none']).validate(now), isEmpty);
      expect(good().copyWith(allergens: const ['none', 'milk']).validate(now), {OfferDraftError.allergens});
      expect(good().copyWith(allergens: const ['glitter']).validate(now), {OfferDraftError.allergens});
    });

    test('the food-safety check is required', () {
      expect(good().copyWith(safetyAttested: false).validate(now), {OfferDraftError.safety});
    });

    test('the POST body uses the §4 field names, baisa and UTC', () {
      final json = good().toJson();
      expect(json['category'], 'bakery');
      expect(json['price_baisa'], 800);
      expect(json['original_price_baisa'], 2400);
      expect(json['quantity_total'], 6);
      expect(json['pickup_end'] as String, endsWith('Z'));
      expect(json.containsKey('status'), isFalse);
    });
  });

  test('prices typed in OMR become baisa', () {
    expect(parseOmr('0.8'), 800);
    expect(parseOmr('0.800'), 800);
    expect(parseOmr('1,25'), 1250);
    expect(parseOmr('2'), 2000);
    expect(parseOmr(' 1.5 '), 1500);
    expect(parseOmr('0.8001'), isNull);
    expect(parseOmr('-1'), isNull);
    expect(parseOmr('abc'), isNull);
    expect(parseOmr(''), isNull);
  });

  test('a Muscat clock time today is UTC+4', () {
    final t = muscatTodayAt(20, 30, now: DateTime.utc(2026, 10, 26, 12));
    expect(t, DateTime.utc(2026, 10, 26, 16, 30));
  });

  group('Fake POST /offers', () {
    late FakeTodayStore store;

    FakeRestaurantOffersRepository repo(String status) => FakeRestaurantOffersRepository(
          store,
          () async => 'r_khubz',
          restaurant: () async => _khubz(status),
          latency: Duration.zero,
        );

    setUp(() => store = FakeTodayStore.seeded(DateTime.now()));

    test('an approved restaurant posts; the offer is live with all meals left', () async {
      final offer = await repo('approved').create(good());
      expect(offer.status, OfferStatus.active);
      expect(offer.quantityAvailable, 6);
      expect(offer.restaurantId, 'r_khubz');
      expect((await repo('approved').myOffers()).map((o) => o.id), contains(offer.id));
    });

    test('people nearby see it on Home, with the restaurant copied onto it', () async {
      final offer = await repo('approved').create(good());
      final nearby = await FakeUserOffersRepository(store, latency: Duration.zero).nearby(lat: 23.588, lng: 58.388);
      final seen = nearby.singleWhere((o) => o.id == offer.id);
      expect(seen.restaurantName, 'Khubz & Co. Bakery');
      expect(seen.offer.title, 'Zaatar manakish box');
    });

    test('a pending restaurant cannot post', () async {
      await expectLater(
        repo('pending').create(good()),
        throwsA(isA<OfferException>().having((e) => e.code, 'code', OfferException.notApproved)),
      );
    });

    test('the server checks the rules too', () async {
      await expectLater(
        repo('approved').create(good().copyWith(safetyAttested: false)),
        throwsA(isA<OfferException>().having((e) => e.code, 'code', OfferException.invalid)),
      );
    });
  });
}
