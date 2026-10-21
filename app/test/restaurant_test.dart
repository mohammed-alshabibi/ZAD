import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/format/muscat_time.dart';
import 'package:zad/core/location/geocoding.dart';
import 'package:zad/core/router/routes.dart';
import 'package:zad/features/auth/application/session.dart';
import 'package:zad/features/auth/data/auth_repository.dart';
import 'package:zad/features/auth/data/fake_auth_repository.dart';
import 'package:zad/features/auth/domain/app_user.dart';
import 'package:zad/features/restaurant/application/my_restaurant.dart';
import 'package:zad/features/restaurant/application/onboarding_draft.dart';
import 'package:zad/features/restaurant/data/fake_restaurant_repository.dart';
import 'package:zad/features/restaurant/data/restaurant_repository.dart';
import 'package:zad/features/restaurant/domain/restaurant.dart';

void main() {
  group('RestaurantValidators', () {
    test('name is required and at most 60 characters', () {
      expect(RestaurantValidators.name('  '), RestaurantFieldError.nameRequired);
      expect(RestaurantValidators.name('x' * 61), RestaurantFieldError.nameTooLong);
      expect(RestaurantValidators.name('Khubz & Co. Bakery'), isNull);
    });

    test('cuisine must be picked', () {
      expect(RestaurantValidators.cuisine(null), RestaurantFieldError.cuisineRequired);
      expect(RestaurantValidators.cuisine(Cuisine.bakery), isNull);
    });

    test('Omani phone numbers', () {
      expect(RestaurantValidators.phone('+968 '), RestaurantFieldError.phoneRequired);
      expect(RestaurantValidators.phone('12345678'), RestaurantFieldError.phoneInvalid);
      expect(RestaurantValidators.phone('+968 9123 456'), RestaurantFieldError.phoneInvalid);
      for (final ok in ['+968 9123 4567', '91234567', '0096891234567', '2412 3456', '+96872123344']) {
        expect(RestaurantValidators.phone(ok), isNull, reason: ok);
      }
    });

    test('phone is normalised to +968 XXXX XXXX', () {
      expect(normalizeOmanPhone('91234567'), '+968 9123 4567');
      expect(normalizeOmanPhone('00968 7212-3344'), '+968 7212 3344');
    });

    test('description and address', () {
      expect(RestaurantValidators.description('x' * 141), RestaurantFieldError.descriptionTooLong);
      expect(RestaurantValidators.description(''), isNull);
      expect(RestaurantValidators.address(' '), RestaurantFieldError.addressRequired);
    });
  });

  group('Typical day', () {
    test('first forecast preview: 60 meals at 10–20% is ~6–12', () {
      expect(firstForecastRange(60, SurplusBand.from10To20), (6, 12));
      expect(firstForecastRange(60, SurplusBand.under5), (0, 3));
    });

    test('surplus answers round-trip through typical_surplus_pct', () {
      for (final band in SurplusBand.values) {
        expect(SurplusBand.fromPct(band.typicalPct), band);
      }
    });
  });

  test('Restaurant.fromJson reads GeoJSON longitude first; draft.toJson writes it back', () {
    final draft = const RestaurantDraft()
        .withDetails(name: ' Karak Corner ', cuisine: Cuisine.cafe, phone: '72123344', description: '')
        .withLocation(lat: 23.5921, lng: 58.3712, addressText: 'Al Ghubrah, Way 2418')
        .withTypicalDay(dailyMeals: 40, band: SurplusBand.from5To10);
    final body = draft.toJson();
    expect(body['name'], 'Karak Corner');
    expect(body['cuisine'], 'cafe');
    expect(body['phone'], '+968 7212 3344');
    expect((body['location'] as Map)['coordinates'], [58.3712, 23.5921]);
    expect(body['typical_surplus_pct'], 8);

    final r = Restaurant.fromJson({
      ...body,
      'id': 'r1',
      'owner_id': 'u1',
      'status': 'pending',
      'created_at': '2026-10-21T07:05:00Z',
    });
    expect(r.lat, 23.5921);
    expect(r.lng, 58.3712);
    expect(r.area, 'Al Ghubrah');
    expect(RestaurantDraft.fromRestaurant(r).surplusBand, SurplusBand.from5To10);
  });

  group('Restaurant routing', () {
    ProviderContainer make() {
      final auth = FakeAuthRepository(latency: Duration.zero);
      late final ProviderContainer c;
      c = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        restaurantRepositoryProvider.overrideWithValue(
          FakeRestaurantRepository(currentUserId: () => c.read(sessionProvider)?.id, latency: Duration.zero),
        ),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('approved → home, pending → review screen', () async {
      final c = make();
      await c.read(sessionProvider.notifier).login(email: 'khubz@example.com', password: 'zad12345');
      expect(routeForRestaurant(await c.read(myRestaurantProvider.future)), Routes.restaurantHome);

      await c.read(sessionProvider.notifier).login(email: 'karak@example.com', password: 'zad12345');
      expect(routeForRestaurant(await c.read(myRestaurantProvider.future)), Routes.restaurantPending);
    });

    test('new restaurant account: onboarding, then submit → pending', () async {
      final c = make();
      await c.read(sessionProvider.notifier).register(
            email: 'new@example.com',
            password: 'abcdefg1',
            fullName: 'Hamed',
            role: UserRole.restaurant,
          );
      expect(routeForRestaurant(await c.read(myRestaurantProvider.future)), Routes.restaurantOnboarding);

      final draft = c.read(onboardingDraftProvider.notifier)
        ..setDetails(name: 'Sahtain', cuisine: Cuisine.omani, phone: '+968 9988 7766', description: '')
        ..setLocation(lat: 23.6, lng: 58.4, addressText: 'Qurum, Way 2801')
        ..setTypicalDay(dailyMeals: 80, band: SurplusBand.over20);
      expect(draft, isNotNull);

      final saved = await c.read(myRestaurantProvider.notifier).submit(c.read(onboardingDraftProvider));
      expect(saved.status, RestaurantStatus.pending);
      expect(saved.typicalSurplusPct, 25);
      expect(routeForRestaurant(c.read(myRestaurantProvider).value), Routes.restaurantPending);

      // Editing keeps it pending and can't change the status.
      final edited = await c
          .read(myRestaurantProvider.notifier)
          .submit(RestaurantDraft.fromRestaurant(saved).withDetails(
              name: 'Sahtain Kitchen', cuisine: Cuisine.omani, phone: saved.phone, description: ''));
      expect(edited.name, 'Sahtain Kitchen');
      expect(edited.status, RestaurantStatus.pending);
    });

    test('a user account has no restaurant', () async {
      final c = make();
      await c.read(sessionProvider.notifier).login(email: 'aisha@example.com', password: 'zad12345');
      expect(await c.read(myRestaurantProvider.future), isNull);
    });
  });

  group('Muscat time', () {
    test('UTC is shown as Muscat (UTC+4)', () {
      expect(muscatClock(DateTime.utc(2026, 10, 21, 10, 12)), '14:12');
    });

    test('today / yesterday use the Muscat calendar day', () {
      final now = DateTime.utc(2026, 10, 21, 6, 0); // 10:00 in Muscat
      expect(muscatDayOf(DateTime.utc(2026, 10, 20, 21, 0), now: now), MuscatDay.today); // 01:00 on the 21st
      expect(muscatDayOf(DateTime.utc(2026, 10, 20, 19, 0), now: now), MuscatDay.yesterday); // 23:00 on the 20th
      expect(muscatDayOf(DateTime.utc(2026, 10, 18, 10, 0), now: now), MuscatDay.earlier);
      expect(muscatDateTime(DateTime.utc(2026, 10, 18, 10, 12)), '18 Oct, 14:12');
    });
  });

  test('Mapbox reverse geocoding: area first, then street; city kept apart', () {
    final withArea = parseMapboxProperties({
      'name': 'Way 3013',
      'context': {
        'neighborhood': {'name': 'Al Khuwair'},
        'place': {'name': 'Muscat'},
      },
    });
    expect(withArea!.line, 'Al Khuwair, Way 3013');
    expect(withArea.city, 'Muscat');

    // What Mapbox actually returns for most of Muscat: street only.
    final streetOnly = parseMapboxProperties({
      'name': 'Way 4212',
      'context': {
        'place': {'name': 'Muscat'},
      },
    });
    expect(streetOnly!.line, 'Way 4212');
    expect(parseMapboxProperties({'context': <String, dynamic>{}}), isNull);
  });
}
