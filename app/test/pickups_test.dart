import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/l10n/generated/app_localizations.dart';
import 'package:zad/features/auth/domain/app_user.dart';
import 'package:zad/features/restaurant/data/fake_today_store.dart';
import 'package:zad/features/restaurant/domain/restaurant_reservation.dart';
import 'package:zad/features/user/application/reservations.dart';
import 'package:zad/features/user/data/user_offers_repository.dart';
import 'package:zad/features/user/data/user_reservations_repository.dart';
import 'package:zad/features/user/pickups/pickup_text.dart';

AppUser _user(String id, String name) => AppUser.fromJson({
      'id': id,
      'email': '$id@example.com',
      'role': 'user',
      'full_name': name,
      'status': 'active',
      'notify_enabled': true,
    });

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  late DateTime now;
  late FakeTodayStore store;
  late FakeUserReservationsRepository fatema;

  setUp(() {
    now = DateTime.now();
    store = FakeTodayStore.seeded(now);
    fatema = FakeUserReservationsRepository(store, () => _user('u_fatema', 'Fatema Al-Balushi'), latency: Duration.zero);
  });

  test('Fatema sees one pickup waiting and her history, as on Figma "Pickups"', () async {
    final mine = await fatema.myReservations();
    final upcoming = upcomingPickups(mine, now);
    expect(upcoming.map((r) => r.pickupCode), ['482913']);

    final history = pickupHistory(mine, now);
    expect(history.take(3).map((r) => r.offerTitle), [
      'Chicken mandi, half portions',
      'Mixed pastry bag',
      'Veg biryani with raita',
    ]);
    expect(history.take(3).map((r) => l10n.pickupHistoryStatus(r, now)), ['Collected', 'Collected', 'Missed']);
    expect(l10n.pickupHistoryDetail(history[2], now), startsWith('Masala Street · '));
    expect(l10n.pickupHistoryDetail(history[2], now), endsWith(' · hold ended'));
    expect(history.where((r) => r.status == ReservationStatus.cancelled), hasLength(1));
  });

  test('only collected meals count: 7 meals rescued, 9.600 OMR saved', () async {
    final stats = rescueStats(await fatema.myReservations());
    expect(stats.meals, 7);
    expect(stats.savedBaisa, 9600);
    expect(l10n.impactLine(stats), '7 meals rescued · 9.600 OMR saved');
    expect(l10n.impactLine((meals: 1, savedBaisa: 0)), '1 meal rescued');
    expect(l10n.impactLine((meals: 0, savedBaisa: 0)), 'Rescue your first meal tonight');
  });

  test('a hold that ran out counts as missed even before the server marks it', () async {
    final r = (await fatema.myReservations()).singleWhere((r) => r.id == 'res_fatema');
    final later = r.holdExpiresAt.add(const Duration(minutes: 1));
    expect(r.status, ReservationStatus.reserved);
    expect(r.isMissed(later), isTrue);
    expect(upcomingPickups([r], later), isEmpty);
    expect(pickupHistory([r], later), hasLength(1));
    expect(l10n.pickupHistoryStatus(r, later), 'Missed');
  });

  test('cancelling moves the pickup to History as Cancelled', () async {
    await fatema.cancel('res_fatema');
    final mine = await fatema.myReservations();
    expect(upcomingPickups(mine, now), isEmpty);
    final cancelled = mine.singleWhere((r) => r.id == 'res_fatema');
    expect(l10n.pickupHistoryStatus(cancelled, now), 'Cancelled');
    expect(l10n.pickupHistoryDetail(cancelled, now), 'Khubz & Co. Bakery · Today · cancelled');
    expect(rescueStats(mine).meals, 7);
  });

  test('the hold bar starts when the 30-minute hold started', () async {
    final r = (await fatema.myReservations()).singleWhere((r) => r.id == 'res_fatema');
    expect(r.holdExpiresAt.difference(r.holdStartsAt), const Duration(minutes: 30));
    // Reserved before pickup opens: the hold counts from the opening time.
    final omar = FakeUserReservationsRepository(store, () => _user('u_omar', 'Omar'), latency: Duration.zero);
    final early = await omar.reserve('o_mandi', 1);
    final opens = DateTime.parse(store.offerById('o_mandi')!['pickup_start'] as String);
    expect(early.holdStartsAt, opens);
  });

  test('amount line: price × meals at the counter, or free', () async {
    final r = (await fatema.myReservations()).singleWhere((r) => r.id == 'res_fatema');
    expect(l10n.pickupAmount(r), '1 meal · 0.800 OMR at the counter');
    final omar = FakeUserReservationsRepository(store, () => _user('u_omar', 'Omar'), latency: Duration.zero);
    expect(l10n.pickupAmount(await omar.reserve('o_bowls', 2)), '2 meals · free');
  });

  test('time left reads in minutes, or hours and minutes', () {
    final t = DateTime.utc(2026, 10, 26, 17);
    expect(l10n.timeLeft(t.add(const Duration(minutes: 28)), t), '28 min left');
    expect(l10n.timeLeft(t.add(const Duration(minutes: 27, seconds: 10)), t), '28 min left');
    expect(l10n.timeLeft(t.add(const Duration(minutes: 28)), t, left: false), '28 min');
    expect(l10n.timeLeft(t.add(const Duration(minutes: 65)), t), '1 h 5 min left');
    expect(l10n.timeLeft(t.subtract(const Duration(minutes: 1)), t), '0 min left');
  });

  test('history days: Today, Yesterday, weekday within a week, then the date', () {
    // Monday 26 Oct 2026, 21:00 in Muscat (17:00 UTC).
    final t = DateTime.utc(2026, 10, 26, 17);
    expect(l10n.pickupDay(t.subtract(const Duration(hours: 2)), t), 'Today');
    expect(l10n.pickupDay(t.subtract(const Duration(days: 1)), t), 'Yesterday');
    expect(l10n.pickupDay(t.subtract(const Duration(days: 2)), t), 'Sat');
    expect(l10n.pickupDay(t.subtract(const Duration(days: 8)), t), '18 Oct');
  });

  test('past offers behind the history never show on the map', () async {
    final nearby = await FakeUserOffersRepository(store, latency: Duration.zero).nearby(lat: 23.588, lng: 58.388);
    expect(nearby.where((o) => o.id.startsWith('o_past_')), isEmpty);
    expect(nearby, hasLength(5));
  });
}
