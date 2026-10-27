import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/router/app_router.dart';
import 'package:zad/core/router/routes.dart';
import 'package:zad/features/auth/domain/app_user.dart';

void main() {
  AppUser as(UserRole role) => AppUser(
        id: 'u_test',
        email: 'test@example.com',
        role: role,
        fullName: 'Test',
        status: 'active',
        notifyEnabled: true,
      );

  test('public screens are open to everyone', () {
    for (final path in [Routes.splash, Routes.login, Routes.accountType, Routes.registerAs('user'), Routes.terms]) {
      expect(roleRedirect(path, null), isNull, reason: path);
    }
  });

  test('signed out: any role screen or the inbox goes to the splash', () {
    for (final path in [Routes.userHome, Routes.mealDetails('o_1'), Routes.restaurantOffers, Routes.adminHome, Routes.notifications]) {
      expect(roleRedirect(path, null), Routes.splash, reason: path);
    }
  });

  test('each role stays inside its own screens', () {
    expect(roleRedirect(Routes.userPickups, as(UserRole.user)), isNull);
    expect(roleRedirect(Routes.restaurantDailyLog, as(UserRole.restaurant)), isNull);
    expect(roleRedirect(Routes.adminRestaurants, as(UserRole.admin)), isNull);
    expect(roleRedirect(Routes.notifications, as(UserRole.restaurant)), isNull);
  });

  test('a wrong role is sent to its own home', () {
    expect(roleRedirect(Routes.adminOffers, as(UserRole.user)), Routes.userHome);
    expect(roleRedirect(Routes.restaurantHome, as(UserRole.admin)), Routes.adminHome);
    expect(roleRedirect('${Routes.userHome}?tab=1', as(UserRole.restaurant)), Routes.restaurantHome);
  });

  test('"/users" is not mistaken for the /user prefix', () {
    expect(roleRedirect('/users', null), isNull);
  });
}
