import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../restaurant/data/fake_today_store.dart';
import '../../restaurant/data/restaurant_today_repositories.dart';
import '../domain/nearby_offer.dart';

/// Offers as users see them (CLAUDE.md §5.1).
abstract interface class UserOffersRepository {
  /// `GET /offers/nearby?lat&lng&radius_km=5`: live offers (`active` or
  /// `sold_out`, pickup not over) within [radiusKm], nearest first, at most 50.
  Future<List<NearbyOffer>> nearby({required double lat, required double lng, double radiusKm = 5});

  /// `GET /offers/{id}?lat&lng`: one offer with the restaurant's phone and
  /// the distance from the user. Throws [OfferNotFound] for removed offers.
  Future<NearbyOffer> offer(String id, {required double lat, required double lng});
}

class OfferNotFound implements Exception {
  const OfferNotFound();
}

/// Answers from the shared demo store, so a meal reserved here is gone for
/// the restaurant too. Mirrors the server's `$geoNear` query (§6).
class FakeUserOffersRepository implements UserOffersRepository {
  FakeUserOffersRepository(this.store, {this.latency = const Duration(milliseconds: 300)});

  final FakeTodayStore store;
  final Duration latency;

  static const limit = 50;

  @override
  Future<List<NearbyOffer>> nearby({required double lat, required double lng, double radiusKm = 5}) async {
    await Future<void>.delayed(latency);
    final now = DateTime.now();
    store.expireStale(now);
    final results = <Map<String, dynamic>>[];
    for (final o in store.offers) {
      final live = o['status'] == 'active' || o['status'] == 'sold_out';
      if (!live || !DateTime.parse(o['pickup_end'] as String).isAfter(now)) continue;
      final coords = (o['location'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
      final d = distanceMeters(lat, lng, (coords[1] as num).toDouble(), (coords[0] as num).toDouble());
      if (d <= radiusKm * 1000) results.add({...o, 'distance_m': d.round()}..remove('restaurant_phone'));
    }
    results.sort((a, b) => (a['distance_m'] as int).compareTo(b['distance_m'] as int));
    return [for (final json in results.take(limit)) NearbyOffer.fromJson(json)];
  }

  @override
  Future<NearbyOffer> offer(String id, {required double lat, required double lng}) async {
    await Future<void>.delayed(latency);
    store.expireStale(DateTime.now());
    final o = store.offerById(id);
    if (o == null || o['status'] == 'removed') throw const OfferNotFound();
    final coords = (o['location'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
    final d = distanceMeters(lat, lng, (coords[1] as num).toDouble(), (coords[0] as num).toDouble());
    return NearbyOffer.fromJson({...o, 'distance_m': d.round()});
  }
}

/// Great-circle distance in metres (haversine), what `$geoNear` returns.
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371000.0;
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadius * math.asin(math.sqrt(a));
}

final userOffersRepositoryProvider = Provider<UserOffersRepository>(
  (ref) => FakeUserOffersRepository(ref.watch(fakeTodayStoreProvider)),
);
