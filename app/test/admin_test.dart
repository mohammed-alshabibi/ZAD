import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/l10n/generated/app_localizations.dart';
import 'package:zad/features/admin/admin_widgets.dart';
import 'package:zad/features/admin/data/admin_repository.dart';
import 'package:zad/features/admin/domain/admin_models.dart';
import 'package:zad/features/restaurant/data/fake_restaurant_repository.dart';
import 'package:zad/features/restaurant/data/fake_today_store.dart';
import 'package:zad/features/restaurant/domain/restaurant.dart';
import 'package:zad/features/user/data/user_offers_repository.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  late FakeRestaurantStore restaurants;
  late FakeTodayStore today;
  late FakeAdminRepository admin;

  setUp(() {
    final now = DateTime.now();
    restaurants = FakeRestaurantStore.seeded(now);
    today = FakeTodayStore.seeded(now);
    admin = FakeAdminRepository(restaurants, today, latency: Duration.zero);
  });

  test('overview counts come from the demo data', () async {
    final o = await admin.overview();
    // Mariam's pickup tonight + Fatema's 7 meals + 14 at Khubz on earlier days.
    expect(o.mealsRescued, 22);
    // 11 collected of 13 finished (Fatema and Mariam each missed one; a
    // cancel doesn't count).
    expect(o.collectedPct, 85);
    expect(o.restaurantsApproved, 8);
    expect(o.restaurantsPending, 3);
    // Six live offers, including the one in Muttrah outside users' 5 km.
    expect(o.liveOffers, 6);
    expect(o.mealsLeft, 33);
    expect(o.waitingNow, 2);
    expect(o.users, 3);
  });

  test('food saved is an estimate at 0.4 kg per meal', () {
    AdminOverview withMeals(int meals) => AdminOverview(
          mealsRescued: meals,
          mealsToday: 0,
          mealsThisWeek: 0,
          collectedPct: null,
          restaurantsApproved: 0,
          restaurantsPending: 0,
          oldestPendingAt: null,
          liveOffers: 0,
          mealsLeft: 0,
          pickupsToday: 0,
          waitingNow: 0,
          users: 0,
          usersReservedToday: 0,
        );
    expect(withMeals(1284).kgSaved, 514);
    expect(l10n.kgSaved(514), '≈ 514 kg of food saved (estimate: 0.4 kg per meal)');
  });

  test('pending requests come oldest first, with the owner name', () async {
    final pending = await admin.restaurants(RestaurantStatus.pending);
    expect(pending.map((r) => r.restaurant.name), ['Karak Corner', 'Sur Harbour Grill', 'Leaf & Bean Café']);
    expect(pending.first.ownerName, 'Maryam Al-Rawahi');
    expect((await admin.restaurants(RestaurantStatus.suspended)).single.restaurant.name, 'Old Town Kitchen');
  });

  test('approving Karak Corner: the owner sees it approved at once', () async {
    final owner = FakeRestaurantRepository(currentUserId: () => 'u_karak', store: restaurants, latency: Duration.zero);
    expect((await owner.mine())!.status, RestaurantStatus.pending);

    await admin.setRestaurantStatus('r_karak', RestaurantStatus.approved);

    expect((await owner.mine())!.status, RestaurantStatus.approved);
    expect((await admin.restaurants(RestaurantStatus.pending)).map((r) => r.id), isNot(contains('r_karak')));
    expect((await admin.restaurants(RestaurantStatus.approved)).map((r) => r.id), contains('r_karak'));
  });

  test('a rejected request leaves every tab until the owner sends it again', () async {
    await admin.setRestaurantStatus('r_sur', RestaurantStatus.rejected);
    for (final s in [RestaurantStatus.pending, RestaurantStatus.approved, RestaurantStatus.suspended]) {
      expect((await admin.restaurants(s)).map((r) => r.id), isNot(contains('r_sur')));
    }
    // Editing the details sends it back for review (§8.1).
    final owner = FakeRestaurantRepository(currentUserId: () => 'u_sur', store: restaurants, latency: Duration.zero);
    await owner.update({'description': 'Now with lunch boxes'});
    expect((await owner.mine())!.status, RestaurantStatus.pending);
  });

  test('a removed offer disappears for users; its reservations stay', () async {
    await admin.removeOffer('o_zaatar');
    final nearby = await FakeUserOffersRepository(today, latency: Duration.zero).nearby(lat: 23.588, lng: 58.388);
    expect(nearby.map((o) => o.id), isNot(contains('o_zaatar')));
    expect((await admin.liveOffers()).map((o) => o.id), isNot(contains('o_zaatar')));
    expect(today.reservations.where((r) => r['offer_id'] == 'o_zaatar' && r['status'] == 'reserved'), hasLength(2));
  });

  test('admin labels: waiting time, typical day', () {
    final now = DateTime.utc(2026, 10, 26, 17);
    expect(l10n.age(now.subtract(const Duration(minutes: 40)), now), '40 min');
    expect(l10n.age(now.subtract(const Duration(hours: 7)), now), '7 h');
    expect(l10n.age(now.subtract(const Duration(days: 3)), now), '3 d');
    final khubz = Restaurant.fromJson(restaurants.byId('r_khubz')!);
    expect(l10n.typicalDay(khubz), '60 meals · usually 10–20% left');
  });
}
