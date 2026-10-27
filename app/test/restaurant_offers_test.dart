import 'package:flutter_test/flutter_test.dart';
import 'package:zad/features/restaurant/application/restaurant_offers.dart';
import 'package:zad/features/restaurant/data/fake_today_store.dart';
import 'package:zad/features/restaurant/domain/offer.dart';

void main() {
  late FakeTodayStore store;
  late FakeRestaurantOffersRepository offers;
  late FakePickupsRepository pickups;

  setUp(() {
    store = FakeTodayStore.seeded(DateTime.now());
    offers = FakeRestaurantOffersRepository(store, () async => 'r_khubz', latency: Duration.zero);
    pickups = FakePickupsRepository(store, () async => 'r_khubz', latency: Duration.zero);
  });

  Future<RestaurantOffers> load([DateTime? now]) async => buildRestaurantOffers(
        offers: await offers.myOffers(),
        reservations: await pickups.myReservations(),
        now: now ?? DateTime.now(),
      );

  test('Khubz: one live offer and four past ones, most recent first', () async {
    final view = await load();
    expect(view.live.single.id, 'o_zaatar');
    expect(view.past.map((p) => p.offer.id), ['o_kh_zaatar', 'o_kh_fatayer', 'o_kh_maamoul', 'o_kh_bread']);
  });

  test('past offers count only collected meals (an expired hold is not one)', () async {
    final past = {for (final p in (await load()).past) p.offer.id: p.collectedMeals};
    expect(past, {'o_kh_zaatar': 6, 'o_kh_fatayer': 2, 'o_kh_maamoul': 0, 'o_kh_bread': 6});
  });

  test('meals collected this week: tonight + the last 7 days', () async {
    // Mariam tonight (1) + 6 yesterday + 2 two days ago + 6 six days ago.
    expect((await load()).collectedThisWeek, 15);
  });

  test('each past offer says how it ended', () async {
    final outcome = {for (final p in (await load()).past) p.offer.id: pastOfferOutcome(p.offer)};
    expect(outcome, {
      'o_kh_zaatar': PastOfferOutcome.allTaken,
      'o_kh_fatayer': PastOfferOutcome.ended,
      'o_kh_maamoul': PastOfferOutcome.endedEarly,
      'o_kh_bread': PastOfferOutcome.ended,
    });
  });

  test('ending an offer early moves it from Live to Past', () async {
    await offers.endEarly('o_zaatar');
    final view = await load();
    expect(view.live, isEmpty);
    final ended = view.past.firstWhere((p) => p.offer.id == 'o_zaatar');
    expect(ended.offer.status, OfferStatus.cancelled);
    expect(pastOfferOutcome(ended.offer), PastOfferOutcome.endedEarly);
  });

  test('once its pickup window ends, the live offer becomes past', () async {
    final view = await load(DateTime.now().add(const Duration(hours: 1)));
    expect(view.live, isEmpty);
    expect(view.past.first.offer.id, 'o_zaatar');
  });
}
