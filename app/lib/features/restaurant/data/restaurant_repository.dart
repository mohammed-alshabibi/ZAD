import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session.dart';
import '../domain/restaurant.dart';
import 'fake_restaurant_repository.dart';

/// The signed-in owner's restaurant (CLAUDE.md §5.1). Screens go through
/// `myRestaurantProvider`, never this directly. P2 adds an `ApiRestaurantRepository`.
abstract interface class RestaurantRepository {
  /// `GET /restaurants/me`. Null when the owner hasn't finished onboarding (404).
  Future<Restaurant?> mine();

  /// `POST /restaurants`. The server sets `status = pending`.
  /// Throws [RestaurantException] `already_exists`.
  Future<Restaurant> create(Map<String, dynamic> body);

  /// `PATCH /restaurants/me`. Editing a rejected restaurant sends it back for review.
  Future<Restaurant> update(Map<String, dynamic> body);
}

class RestaurantException implements Exception {
  const RestaurantException(this.code);

  final String code;

  static const alreadyExists = 'already_exists';
  static const notFound = 'not_found';

  @override
  String toString() => 'RestaurantException($code)';
}

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  // The real API knows the owner from the JWT; the fake asks the session.
  return FakeRestaurantRepository(currentUserId: () => ref.read(sessionProvider)?.id);
});
