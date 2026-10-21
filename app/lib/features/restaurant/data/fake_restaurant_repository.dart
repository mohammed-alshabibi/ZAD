import '../domain/restaurant.dart';
import 'restaurant_repository.dart';

/// In-memory stand-in for the restaurant API during P1, answering in the §4
/// JSON shapes. Seeded to match the demo accounts in `FakeAuthRepository`:
/// khubz@example.com is approved, karak@example.com is waiting for review.
class FakeRestaurantRepository implements RestaurantRepository {
  FakeRestaurantRepository({
    required this.currentUserId,
    this.latency = const Duration(milliseconds: 400),
  });

  final String? Function() currentUserId;
  final Duration latency;

  /// owner_id → restaurant JSON.
  final Map<String, Map<String, dynamic>> _byOwner = {
    'u_khubz': {
      'id': 'r_khubz',
      'owner_id': 'u_khubz',
      'name': 'Khubz & Co. Bakery',
      'cuisine': 'bakery',
      'description': 'Fresh bread and manakish all day',
      'phone': '+968 9123 4567',
      'address_text': 'Al Khuwair, Way 3013, Building 214',
      'location': {'type': 'Point', 'coordinates': [58.3915, 23.5884]},
      'status': 'approved',
      'typical_daily_meals': 60,
      'typical_surplus_pct': 15,
      'created_at': '2026-09-02T10:12:00Z',
    },
    'u_karak': {
      'id': 'r_karak',
      'owner_id': 'u_karak',
      'name': 'Karak Corner',
      'cuisine': 'cafe',
      'description': 'Karak tea, chapati and sandwiches',
      'phone': '+968 7212 3344',
      'address_text': 'Al Ghubrah, Way 2418',
      'location': {'type': 'Point', 'coordinates': [58.3712, 23.5921]},
      'status': 'pending',
      'typical_daily_meals': 40,
      'typical_surplus_pct': 8,
      'created_at': '2026-10-21T07:05:00Z',
    },
  };

  var _nextId = 1;

  @override
  Future<Restaurant?> mine() async {
    await Future<void>.delayed(latency ~/ 2);
    final json = _byOwner[_owner()];
    return json == null ? null : Restaurant.fromJson(json);
  }

  @override
  Future<Restaurant> create(Map<String, dynamic> body) async {
    await Future<void>.delayed(latency);
    final owner = _owner();
    if (_byOwner.containsKey(owner)) throw const RestaurantException(RestaurantException.alreadyExists);
    final json = {
      ...body,
      'id': 'r_new_${_nextId++}',
      'owner_id': owner,
      'status': 'pending',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    _byOwner[owner] = json;
    return Restaurant.fromJson(json);
  }

  @override
  Future<Restaurant> update(Map<String, dynamic> body) async {
    await Future<void>.delayed(latency);
    final json = _byOwner[_owner()];
    if (json == null) throw const RestaurantException(RestaurantException.notFound);
    // status, owner_id and created_at are read-only (§5.1); id is kept.
    json.addAll(Map.of(body)..removeWhere((k, _) => const {'id', 'owner_id', 'status', 'created_at'}.contains(k)));
    if (json['status'] == 'rejected') json['status'] = 'pending';
    return Restaurant.fromJson(json);
  }

  String _owner() {
    final id = currentUserId();
    if (id == null) throw const RestaurantException(RestaurantException.notFound);
    return id;
  }
}
