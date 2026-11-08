import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/location/geo.dart';
import 'package:zad/core/router/routes.dart';
import 'package:zad/features/auth/application/session.dart';
import 'package:zad/features/auth/data/auth_repository.dart';
import 'package:zad/features/auth/data/fake_auth_repository.dart';
import 'package:zad/features/auth/domain/app_user.dart';
import 'package:zad/features/auth/domain/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('full name must not be blank', () {
      expect(AuthValidators.fullName('   '), AuthFieldError.nameRequired);
      expect(AuthValidators.fullName('Fatema'), isNull);
    });

    test('email', () {
      expect(AuthValidators.email(''), AuthFieldError.emailRequired);
      expect(AuthValidators.email('fatema'), AuthFieldError.emailInvalid);
      expect(AuthValidators.email('fatema@example'), AuthFieldError.emailInvalid);
      expect(AuthValidators.email(' fatema@example.com '), isNull);
    });

    test('new password: 8+ characters including a number', () {
      expect(AuthValidators.newPassword(''), AuthFieldError.passwordRequired);
      expect(AuthValidators.newPassword('abc1'), AuthFieldError.passwordTooWeak);
      expect(AuthValidators.newPassword('abcdefgh'), AuthFieldError.passwordTooWeak);
      expect(AuthValidators.newPassword('abcdefg1'), isNull);
    });

    test('login password only needs to be filled in', () {
      expect(AuthValidators.existingPassword(''), AuthFieldError.passwordRequired);
      expect(AuthValidators.existingPassword('x'), isNull);
    });
  });

  test('roundCoord keeps 3 decimals (~100 m)', () {
    expect(roundCoord(23.58849), 23.588);
    expect(roundCoord(58.39151), 58.392);
  });

  test('AppUser.fromJson reads GeoJSON longitude first', () {
    final user = AppUser.fromJson({
      'id': 'u1',
      'email': 'a@b.om',
      'role': 'user',
      'full_name': 'Fatema Al-Balushi',
      'phone': null,
      'status': 'active',
      'notify_enabled': true,
      'location': {'type': 'Point', 'coordinates': [58.391, 23.588]},
    });
    expect(user.lng, 58.391);
    expect(user.lat, 23.588);
    expect(user.firstName, 'Fatema');
  });

  group('Session with the fake repository', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(latency: Duration.zero)),
      ]);
    });
    tearDown(() => container.dispose());

    SessionNotifier session() => container.read(sessionProvider.notifier);

    test('demo accounts log in and route by role', () async {
      final restaurant =
          await session().login(email: 'Khubz@Example.com', password: FakeAuthRepository.demoPassword);
      expect(restaurant.role, UserRole.restaurant);
      expect(homeForRole(restaurant.role), Routes.restaurantHome);
      expect(container.read(sessionProvider)?.email, 'khubz@example.com');
    });

    test('wrong password is rejected and nobody is signed in', () async {
      await expectLater(
        session().login(email: 'fatema@example.com', password: 'nope'),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', AuthException.invalidCredentials)),
      );
      expect(container.read(sessionProvider), isNull);
    });

    test('register signs in; a taken email is rejected', () async {
      final user = await session().register(
        email: 'new@example.com',
        password: 'secret123',
        fullName: ' Salma ',
        role: UserRole.user,
      );
      expect(user.fullName, 'Salma');
      expect(nextAfterSignup(user.role), Routes.locationPermission);
      expect(nextAfterSignup(UserRole.restaurant), Routes.restaurantOnboarding);

      await expectLater(
        session().register(email: 'fatema@example.com', password: 'x1234567', fullName: 'A', role: UserRole.user),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', AuthException.emailTaken)),
      );
    });

    test('location is stored rounded', () async {
      await session().login(email: 'fatema@example.com', password: FakeAuthRepository.demoPassword);
      await session().updateLocation(lat: 23.61234, lng: 58.54567);
      final me = container.read(sessionProvider)!;
      expect(me.lat, 23.612);
      expect(me.lng, 58.546);
    });

    test('logout clears the session', () async {
      await session().login(email: 'admin@zad.om', password: FakeAuthRepository.demoPassword);
      await session().logout();
      expect(container.read(sessionProvider), isNull);
    });
  });
}
