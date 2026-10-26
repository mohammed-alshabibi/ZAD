import '../domain/restaurant.dart';
import 'restaurant_repository.dart';

/// Every restaurant in the P1 demo, keyed by owner id, in the §4 JSON shape.
/// Shared by the owner-side fake (`/restaurants/me`) and the admin fake
/// (`/admin/restaurants`), so an approval shows up for the owner at once.
///
/// Matches the demo accounts in `FakeAuthRepository`: khubz@example.com is
/// approved and karak@example.com is waiting for review (the oldest of three,
/// as on Figma "Admin: Restaurant approvals"). The kitchens behind the demo
/// offers are approved, and one restaurant is suspended. `owner_name` is only
/// sent to admins.
class FakeRestaurantStore {
  FakeRestaurantStore._(this.byOwner);

  factory FakeRestaurantStore.seeded(DateTime now) {
    String ago(Duration d) => now.toUtc().subtract(d).toIso8601String();
    Map<String, dynamic> r({
      required String id,
      required String owner,
      required String ownerName,
      required String name,
      required String cuisine,
      required String description,
      required String phone,
      required String address,
      required List<double> lngLat,
      required String status,
      required String createdAt,
      int? meals,
      int? pct,
    }) =>
        {
          'id': id,
          'owner_id': owner,
          'owner_name': ownerName,
          'name': name,
          'cuisine': cuisine,
          'description': description,
          'phone': phone,
          'address_text': address,
          'location': {'type': 'Point', 'coordinates': lngLat},
          'status': status,
          'typical_daily_meals': meals,
          'typical_surplus_pct': pct,
          'created_at': createdAt,
        };
    final all = [
      r(id: 'r_khubz', owner: 'u_khubz', ownerName: 'Salim Al-Hinai', name: 'Khubz & Co. Bakery', cuisine: 'bakery',
          description: 'Fresh bread and manakish all day', phone: '+968 9123 4567', address: 'Al Khuwair, Way 3013, Building 214',
          lngLat: [58.3915, 23.5884], status: 'approved', createdAt: '2026-09-02T10:12:00Z', meals: 60, pct: 15),
      // Waiting for review, oldest first: 7 h, 5 h, 3 h.
      r(id: 'r_karak', owner: 'u_karak', ownerName: 'Maryam Al-Rawahi', name: 'Karak Corner', cuisine: 'cafe',
          description: 'Karak tea, chapati and sandwiches', phone: '+968 7212 3344', address: 'Al Ghubrah, Way 2418',
          lngLat: [58.3712, 23.5921], status: 'pending', createdAt: ago(const Duration(hours: 7)), meals: 40, pct: 8),
      r(id: 'r_sur', owner: 'u_sur', ownerName: 'Khalid Al-Mukhaini', name: 'Sur Harbour Grill', cuisine: 'omani',
          description: 'Grilled fish and shuwa', phone: '+968 9555 0142', address: 'Mutrah, Corniche Street',
          lngLat: [58.564, 23.618], status: 'pending', createdAt: ago(const Duration(hours: 5)), meals: 80, pct: 12),
      r(id: 'r_leaf', owner: 'u_leaf', ownerName: 'Noor Al-Habsi', name: 'Leaf & Bean Café', cuisine: 'cafe',
          description: 'Coffee, cakes and salads', phone: '+968 9188 7720', address: 'Madinat Qaboos, Way 1832',
          lngLat: [58.43, 23.596], status: 'pending', createdAt: ago(const Duration(hours: 3)), meals: 30, pct: 18),
      // The kitchens behind the demo offers.
      r(id: 'r_wadi', owner: 'u_wadi', ownerName: 'Said Al-Amri', name: 'Wadi Grill House', cuisine: 'grill',
          description: 'Mandi and grills', phone: '+968 9455 1020', address: 'Al Khuwair, Way 3022',
          lngLat: [58.4037, 23.587], status: 'approved', createdAt: '2026-09-10T09:00:00Z', meals: 90, pct: 10),
      r(id: 'r_bait', owner: 'u_bait', ownerName: 'Ravi Menon', name: 'Bait Al Biryani', cuisine: 'indian',
          description: 'Biryani trays', phone: '+968 9877 3301', address: 'Al Khuwair, Way 3109',
          lngLat: [58.3823, 23.5854], status: 'approved', createdAt: '2026-09-12T11:30:00Z', meals: 120, pct: 9),
      r(id: 'r_green', owner: 'u_green', ownerName: 'Huda Al-Kindi', name: 'Green Bowl Café', cuisine: 'healthy',
          description: 'Bowls and salads', phone: '+968 7101 2290', address: 'Al Khuwair, Way 3015',
          lngLat: [58.387, 23.5885], status: 'approved', createdAt: '2026-09-18T08:45:00Z', meals: 50, pct: 14),
      r(id: 'r_halwa', owner: 'u_halwa', ownerName: 'Ali Al-Busaidi', name: 'Al Qurm Sweets', cuisine: 'arabic',
          description: 'Omani halwa and luqaimat', phone: '+968 9300 6612', address: 'Al Qurm, Way 2601',
          lngLat: [58.4067, 23.585], status: 'approved', createdAt: '2026-09-21T15:10:00Z', meals: 40, pct: 10),
      r(id: 'r_muttrah', owner: 'u_muttrah', ownerName: 'Yousuf Al-Lawati', name: 'Corniche Shawarma', cuisine: 'fast_food',
          description: 'Shawarma and wraps', phone: '+968 9944 0187', address: 'Mutrah, Corniche Street',
          lngLat: [58.566, 23.617], status: 'approved', createdAt: '2026-09-25T17:20:00Z', meals: 150, pct: 6),
      r(id: 'r_qurum', owner: 'u_qurum', ownerName: 'Laila Al-Farsi', name: 'Qurum Corner Café', cuisine: 'cafe',
          description: 'Pastries and coffee', phone: '+968 9233 4410', address: 'Al Qurm, Way 2702',
          lngLat: [58.412, 23.589], status: 'approved', createdAt: '2026-10-01T07:30:00Z', meals: 35, pct: 15),
      r(id: 'r_masala', owner: 'u_masala', ownerName: 'Arjun Nair', name: 'Masala Street', cuisine: 'indian',
          description: 'Street food and curries', phone: '+968 9711 5023', address: 'Al Khuwair, Way 3104',
          lngLat: [58.379, 23.586], status: 'approved', createdAt: '2026-10-04T12:00:00Z', meals: 70, pct: 11),
      r(id: 'r_oldtown', owner: 'u_oldtown', ownerName: 'Fahad Al-Siyabi', name: 'Old Town Kitchen', cuisine: 'omani',
          description: 'Home-style Omani dishes', phone: '+968 9620 3381', address: 'Ruwi, Way 3508',
          lngLat: [58.545, 23.598], status: 'suspended', createdAt: '2026-09-05T10:00:00Z', meals: 60, pct: 12),
    ];
    return FakeRestaurantStore._({for (final json in all) json['owner_id'] as String: json});
  }

  /// owner_id → restaurant JSON.
  final Map<String, Map<String, dynamic>> byOwner;

  Map<String, dynamic>? byId(String id) => byOwner.values.where((r) => r['id'] == id).firstOrNull;
}

/// In-memory stand-in for the owner-side restaurant API during P1, answering
/// in the §4 JSON shapes.
class FakeRestaurantRepository implements RestaurantRepository {
  FakeRestaurantRepository({
    required this.currentUserId,
    FakeRestaurantStore? store,
    this.latency = const Duration(milliseconds: 400),
  }) : store = store ?? FakeRestaurantStore.seeded(DateTime.now());

  final String? Function() currentUserId;
  final FakeRestaurantStore store;
  final Duration latency;

  Map<String, Map<String, dynamic>> get _byOwner => store.byOwner;

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
