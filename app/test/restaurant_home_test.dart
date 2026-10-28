import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/format/money.dart';
import 'package:zad/core/widgets/pickup_window_bar.dart';
import 'package:zad/features/restaurant/application/restaurant_today.dart';
import 'package:zad/features/restaurant/data/fake_today_store.dart';
import 'package:zad/features/restaurant/data/restaurant_today_repositories.dart';
import 'package:zad/features/restaurant/domain/offer.dart';
import 'package:zad/features/restaurant/domain/restaurant_reservation.dart';

void main() {
  test('money is shown in OMR with three decimals', () {
    expect(formatOmr(800), '0.800 OMR');
    expect(formatOmr(1500), '1.500 OMR');
    expect(formatOmr(12005), '12.005 OMR');
    expect(formatOmr(0), '0.000 OMR');
  });

  group('Pickup window bar', () {
    final start = DateTime.utc(2026, 10, 21, 16, 0);
    final end = DateTime.utc(2026, 10, 21, 18, 0);

    test('shows the share of the window still left', () {
      expect(PickupWindowBar.leftFraction(start, end, start.subtract(const Duration(hours: 1))), 1.0);
      expect(PickupWindowBar.leftFraction(start, end, DateTime.utc(2026, 10, 21, 17, 30)), 0.25);
      expect(PickupWindowBar.leftFraction(start, end, end.add(const Duration(minutes: 5))), 0.0);
    });

    test('saffron only under 30 minutes', () {
      expect(isClosingSoon(end, end.subtract(const Duration(minutes: 28))), isTrue);
      expect(isClosingSoon(end, end.subtract(const Duration(minutes: 30))), isFalse);
      expect(isClosingSoon(end, end.add(const Duration(minutes: 1))), isFalse);
    });
  });

  group('Fake restaurant demo (khubz)', () {
    late FakeTodayStore store;
    late FakeRestaurantOffersRepository offers;
    late FakePickupsRepository pickups;

    setUp(() {
      store = FakeTodayStore.seeded(DateTime.now());
      offers = FakeRestaurantOffersRepository(store, () async => 'r_khubz', latency: Duration.zero);
      pickups = FakePickupsRepository(store, () async => 'r_khubz', latency: Duration.zero);
    });

    test('Today matches the Figma screen: 6 posted · 3 reserved · 1 collected', () async {
      final today = buildRestaurantToday(
        offers: await offers.myOffers(),
        reservations: await pickups.myReservations(),
        forecasts: const [],
        now: DateTime.now(),
      );
      expect(today.liveOffers.single.title, 'Zaatar manakish box');
      expect(today.liveOffers.single.quantityAvailable, 2);
      expect((today.postedMeals, today.reservedMeals, today.collectedMeals), (6, 3, 1));
      expect(today.waiting.map((r) => r.userFirstName), ['Fatema', 'Salim']);
      expect(today.collected.single.userFirstName, 'Mariam');
    });

    test('once pickup ends, the offer leaves Live now and its holds leave Waiting', () async {
      final o = await offers.myOffers();
      final r = await pickups.myReservations();
      // The seeded Khubz offer and both holds end in 28 minutes.
      final later = DateTime.now().add(const Duration(minutes: 29));
      final today = buildRestaurantToday(offers: o, reservations: r, forecasts: const [], now: later);
      expect(today.liveOffers, isEmpty);
      expect(today.waiting, isEmpty);
      expect(today.reservedMeals, 0);
      // Tonight's totals still count it.
      expect((today.postedMeals, today.collectedMeals), (6, 1));
    });

    test('the restaurant sees only the last 3 digits of a code', () async {
      final fatema = (await pickups.myReservations()).firstWhere((r) => r.userFirstName == 'Fatema');
      expect(fatema.codeHint, '913');
    });

    test('check shows the match without collecting; confirm collects', () async {
      final match = await pickups.check('482913');
      expect(match.userFirstName, 'Fatema');
      expect(match.status, ReservationStatus.reserved);
      expect(match.amountBaisa, 800);

      final collected = await pickups.confirm('482913');
      expect(collected.status, ReservationStatus.collected);
      expect(collected.collectedAt, isNotNull);
      await expectLater(
        pickups.check('482913'),
        throwsA(isA<PickupException>().having((e) => e.code, 'code', PickupException.alreadyCollected)),
      );
    });

    test('5 wrong codes lock entry for 10 minutes', () async {
      for (var i = 0; i < 4; i++) {
        await expectLater(
          pickups.check('000000'),
          throwsA(isA<PickupException>().having((e) => e.code, 'code', PickupException.codeNotFound)),
        );
      }
      await expectLater(
        pickups.check('000000'),
        throwsA(isA<PickupException>().having((e) => e.code, 'code', PickupException.locked)),
      );
      // Even the right code is refused while locked.
      await expectLater(
        pickups.check('482913'),
        throwsA(isA<PickupException>().having((e) => e.retryAfter, 'retryAfter', isNotNull)),
      );
    });

    test('another restaurant cannot use a Khubz code', () async {
      final other = FakePickupsRepository(store, () async => 'r_karak', latency: Duration.zero);
      await expectLater(other.check('482913'), throwsA(isA<PickupException>()));
    });

    test('edit quantity keeps what is already taken; end early stops new reservations', () async {
      final offer = (await offers.myOffers()).firstWhere((o) => o.id == 'o_zaatar');
      expect(offer.taken, 4);
      await expectLater(
        offers.updateQuantity(offer.id, 3),
        throwsA(isA<OfferException>().having((e) => e.code, 'code', OfferException.belowTaken)),
      );

      final soldOut = await offers.updateQuantity(offer.id, 4);
      expect((soldOut.quantityAvailable, soldOut.status), (0, OfferStatus.soldOut));
      final more = await offers.updateQuantity(offer.id, 7);
      expect((more.quantityAvailable, more.status), (3, OfferStatus.active));

      final ended = await offers.endEarly(offer.id);
      expect(ended.status, OfferStatus.cancelled);
      // Waiting pickups still work after ending early.
      expect((await pickups.confirm('610271')).status, ReservationStatus.collected);
    });

    test('lazy expiry: an old hold expires and its meals go back on the offer', () async {
      final r = store.reservations.firstWhere((r) => r['id'] == 'res_salim');
      r['hold_expires_at'] = DateTime.now().toUtc().subtract(const Duration(minutes: 1)).toIso8601String();

      final offer = (await offers.myOffers()).firstWhere((o) => o.id == 'o_zaatar');
      expect(offer.quantityAvailable, 4); // 2 + Salim's 2
      final salim = (await pickups.myReservations()).firstWhere((r) => r.userFirstName == 'Salim');
      expect(salim.status, ReservationStatus.expired);
      await expectLater(
        pickups.check('610271'),
        throwsA(isA<PickupException>().having((e) => e.code, 'code', PickupException.expired)),
      );
    });
  });
}
