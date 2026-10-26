import 'package:flutter_test/flutter_test.dart';
import 'package:zad/features/auth/domain/app_user.dart';
import 'package:zad/features/restaurant/data/fake_today_store.dart';
import 'package:zad/features/restaurant/domain/restaurant_reservation.dart';
import 'package:zad/features/user/application/reservations.dart';
import 'package:zad/features/user/data/user_offers_repository.dart';
import 'package:zad/features/user/data/user_reservations_repository.dart';
import 'package:zad/features/user/domain/user_reservation.dart';

AppUser _user(String id, String name) => AppUser.fromJson({
      'id': id,
      'email': '$id@example.com',
      'role': 'user',
      'full_name': name,
      'status': 'active',
      'notify_enabled': true,
    });

void main() {
  late FakeTodayStore store;
  late FakeUserReservationsRepository aisha;
  late FakeUserReservationsRepository omar;

  setUp(() {
    store = FakeTodayStore.seeded(DateTime.now());
    aisha = FakeUserReservationsRepository(store, () => _user('u_aisha', 'Aisha Al-Balushi'), latency: Duration.zero);
    omar = FakeUserReservationsRepository(store, () => _user('u_omar', 'Omar Al-Said'), latency: Duration.zero);
  });

  int left(String offerId) => store.offerById(offerId)!['quantity_available'] as int;
  String status(String offerId) => store.offerById(offerId)!['status'] as String;

  test('Aisha already holds the seeded Khubz pickup (code 482 913)', () async {
    final mine = await aisha.myReservations();
    final khubz = mine.singleWhere((r) => r.offerId == 'o_zaatar');
    expect(khubz.pickupCode, '482913');
    expect(formatPickupCode(khubz.pickupCode), '482 913');
    expect(activeReservationFor(mine, 'o_zaatar', DateTime.now()), isNotNull);
  });

  test('reserving takes the meals off the offer and makes a 6-digit code', () async {
    final r = await omar.reserve('o_biryani', 2);
    expect(left('o_biryani'), 7);
    expect(r.pickupCode, matches(RegExp(r'^\d{6}$')));
    expect(r.status, ReservationStatus.reserved);
    expect(r.restaurantName, 'Bait Al Biryani');
  });

  test('the last meals sell out, and nobody can take more than is left', () async {
    await omar.reserve('o_zaatar', 2); // Khubz has 2 left
    expect(left('o_zaatar'), 0);
    expect(status('o_zaatar'), 'sold_out');
    await expectLater(
      FakeUserReservationsRepository(store, () => _user('u_x', 'X'), latency: Duration.zero).reserve('o_zaatar', 1),
      throwsA(isA<ReserveException>().having((e) => e.code, 'code', ReserveException.soldOut)),
    );
  });

  test('asking for more than is left fails without touching the offer', () async {
    await expectLater(
      omar.reserve('o_halwa', 3), // 2 left
      throwsA(isA<ReserveException>().having((e) => e.code, 'code', ReserveException.notEnoughLeft)),
    );
    expect(left('o_halwa'), 2);
  });

  test('at most 3 per person, and one active reservation per offer', () async {
    await expectLater(
      omar.reserve('o_biryani', 4),
      throwsA(isA<ReserveException>().having((e) => e.code, 'code', ReserveException.quantityLimit)),
    );
    await omar.reserve('o_biryani', 1);
    await expectLater(
      omar.reserve('o_biryani', 1),
      throwsA(isA<ReserveException>().having((e) => e.code, 'code', ReserveException.alreadyReserved)),
    );
    expect(left('o_biryani'), 8);
  });

  test('hold = min(max(now, pickup start) + 30 min, pickup end)', () async {
    final now = DateTime.now();
    // Wadi opens in 15 min: held until 30 min after it opens.
    final wadi = await omar.reserve('o_mandi', 1);
    final wadiStart = DateTime.parse(store.offerById('o_mandi')!['pickup_start'] as String);
    expect(wadi.holdExpiresAt.difference(wadiStart).inMinutes, 30);
    // Green Bowl closes in 20 min: the hold stops at pickup end.
    final bowls = await omar.reserve('o_bowls', 1);
    final bowlsEnd = DateTime.parse(store.offerById('o_bowls')!['pickup_end'] as String);
    expect(bowls.holdExpiresAt, bowlsEnd);
    // Biryani is open with an hour to go: 30 min from now.
    final biryani = await omar.reserve('o_biryani', 1);
    expect(biryani.holdExpiresAt.difference(now).inMinutes, inInclusiveRange(29, 30));
  });

  test('cancelling puts the meals back, even after a sell-out', () async {
    final r = await omar.reserve('o_zaatar', 2);
    expect(status('o_zaatar'), 'sold_out');
    final cancelled = await omar.cancel(r.id);
    expect(cancelled.status, ReservationStatus.cancelled);
    expect(left('o_zaatar'), 2);
    expect(status('o_zaatar'), 'active');
  });

  test('a user cannot cancel someone else’s reservation', () async {
    await expectLater(omar.cancel('res_aisha'), throwsA(isA<ReserveException>()));
  });

  test('the restaurant sees the new pickup with first name and last 3 digits only', () async {
    final r = await omar.reserve('o_zaatar', 1);
    final row = store.reservationsFor('r_khubz').singleWhere((x) => x['id'] == r.id);
    final json = store.reservationJson(row);
    expect(json['user_first_name'], 'Omar');
    expect(json['code_hint'], r.pickupCode.substring(3));
    expect(json.containsKey('pickup_code'), isFalse);
  });

  test('meal details include the phone; the nearby list does not', () async {
    final offers = FakeUserOffersRepository(store, latency: Duration.zero);
    final details = await offers.offer('o_zaatar', lat: 23.583, lng: 58.396);
    expect(details.restaurantPhone, '+968 9123 4567');
    final nearby = await offers.nearby(lat: 23.583, lng: 58.396);
    expect(nearby.every((o) => o.restaurantPhone == null), isTrue);
  });

  test('max reservable is 3, or what is left', () {
    expect(maxReservable(9), 3);
    expect(maxReservable(2), 2);
    expect(maxReservable(0), 0);
  });
}
