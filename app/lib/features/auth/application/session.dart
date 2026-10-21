import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/geo.dart';
import '../../../core/router/routes.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

/// The signed-in account, or null when signed out.
/// Tokens stay inside the repository; screens only see the [AppUser].
class SessionNotifier extends Notifier<AppUser?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AppUser? build() => null;

  Future<AppUser> login({required String email, required String password}) async {
    await _repo.login(email: email, password: password);
    return state = await _repo.me();
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    await _repo.register(email: email, password: password, fullName: fullName, role: role);
    return state = await _repo.me();
  }

  /// Saves the phone's location, rounded to ~100 m (CLAUDE.md §6).
  Future<void> updateLocation({required double lat, required double lng}) async {
    state = await _repo.updateLocation(lat: roundCoord(lat), lng: roundCoord(lng));
  }

  Future<void> logout() async {
    await _repo.logout();
    state = null;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, AppUser?>(SessionNotifier.new);

/// Where an account lands after logging in (CLAUDE.md §8.1: route by role).
String homeForRole(UserRole role) => switch (role) {
      UserRole.user => Routes.userHome,
      UserRole.restaurant => Routes.restaurantHome,
      UserRole.admin => Routes.adminHome,
    };

/// Where a brand-new account goes next: users are asked for location,
/// restaurants fill in onboarding and wait for approval.
String nextAfterSignup(UserRole role) => switch (role) {
      UserRole.user => Routes.locationPermission,
      UserRole.restaurant => Routes.restaurantOnboarding,
      UserRole.admin => Routes.adminHome,
    };
