/// Restaurant review status (CLAUDE.md §4 `restaurants.status`). Set by the
/// server and the admin, never by the app.
enum RestaurantStatus {
  pending,
  approved,
  rejected,
  suspended;

  static RestaurantStatus fromJson(String value) => RestaurantStatus.values.byName(value);
}

/// Cuisine enum. The server keeps the same list in Python (§4: enums live in code).
enum Cuisine {
  bakery('bakery'),
  omani('omani'),
  arabic('arabic'),
  indian('indian'),
  cafe('cafe'),
  fastFood('fast_food'),
  healthy('healthy'),
  // Shown after "More…".
  grill('grill'),
  seafood('seafood'),
  asian('asian'),
  international('international'),
  other('other');

  const Cuisine(this.json);

  final String json;

  /// The chips shown before "More…" (Figma 38:768).
  static const main = [bakery, omani, arabic, indian, cafe, fastFood, healthy];

  static Cuisine fromJson(String value) => values.firstWhere((c) => c.json == value);
}

/// "How much is usually left at closing?" (Figma 38:1033). The API stores one
/// number, `typical_surplus_pct`; each answer sends the middle of its range.
enum SurplusBand {
  under5(0, 5, 3),
  from5To10(5, 10, 8),
  from10To20(10, 20, 15),
  over20(20, 30, 25);

  const SurplusBand(this.lowPct, this.highPct, this.typicalPct);

  final int lowPct;
  final int highPct;

  /// The value sent as `typical_surplus_pct`.
  final int typicalPct;

  static SurplusBand fromPct(num pct) => pct < 5
      ? under5
      : pct < 10
          ? from5To10
          : pct < 20
              ? from10To20
              : over20;
}

/// Preview shown before the first forecast exists: "~6–12 meals a day" for
/// 60 meals at 10–20%. The real cold-start forecast is made on the server (§7.3).
(int low, int high) firstForecastRange(int dailyMeals, SurplusBand band) =>
    ((dailyMeals * band.lowPct / 100).round(), (dailyMeals * band.highPct / 100).round());

/// Meals-per-day stepper limits.
abstract final class DailyMeals {
  static const min = 5;
  static const max = 1000;
  static const step = 5;
  static const initial = 60;
}

/// A restaurant as returned by `GET /restaurants/me` (CLAUDE.md §4).
class Restaurant {
  const Restaurant({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.cuisine,
    required this.description,
    required this.phone,
    required this.addressText,
    required this.lat,
    required this.lng,
    required this.status,
    required this.createdAt,
    this.typicalDailyMeals,
    this.typicalSurplusPct,
  });

  final String id;
  final String ownerId;
  final String name;
  final Cuisine cuisine;
  final String description;
  final String phone;
  final String addressText;
  final double lat;
  final double lng;
  final RestaurantStatus status;
  final DateTime createdAt;
  final int? typicalDailyMeals;
  final int? typicalSurplusPct;

  /// The first part of the address, e.g. "Al Khuwair" from "Al Khuwair, Way 3013".
  String get area => addressText.split(',').first.trim();

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // GeoJSON is longitude first.
    final coords = (json['location'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
    return Restaurant(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      cuisine: Cuisine.fromJson(json['cuisine'] as String),
      description: (json['description'] as String?) ?? '',
      phone: json['phone'] as String,
      addressText: json['address_text'] as String,
      lng: (coords[0] as num).toDouble(),
      lat: (coords[1] as num).toDouble(),
      status: RestaurantStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      typicalDailyMeals: json['typical_daily_meals'] as int?,
      typicalSurplusPct: (json['typical_surplus_pct'] as num?)?.toInt(),
    );
  }
}

/// What the three onboarding steps collect, sent as the body of
/// `POST /restaurants` (new) or `PATCH /restaurants/me` (edit).
class RestaurantDraft {
  const RestaurantDraft({
    this.name = '',
    this.cuisine,
    this.phone = '',
    this.description = '',
    this.lat,
    this.lng,
    this.addressText = '',
    this.typicalDailyMeals = DailyMeals.initial,
    this.surplusBand,
  });

  final String name;
  final Cuisine? cuisine;
  final String phone;
  final String description;
  final double? lat;
  final double? lng;
  final String addressText;
  final int typicalDailyMeals;
  final SurplusBand? surplusBand;

  bool get hasLocation => lat != null && lng != null;

  factory RestaurantDraft.fromRestaurant(Restaurant r) => RestaurantDraft(
        name: r.name,
        cuisine: r.cuisine,
        phone: r.phone,
        description: r.description,
        lat: r.lat,
        lng: r.lng,
        addressText: r.addressText,
        typicalDailyMeals: r.typicalDailyMeals ?? DailyMeals.initial,
        surplusBand: r.typicalSurplusPct == null ? null : SurplusBand.fromPct(r.typicalSurplusPct!),
      );

  RestaurantDraft withDetails({
    required String name,
    required Cuisine cuisine,
    required String phone,
    required String description,
  }) =>
      _copy(name: name, cuisine: cuisine, phone: phone, description: description);

  RestaurantDraft withLocation({required double lat, required double lng, required String addressText}) =>
      _copy(lat: lat, lng: lng, addressText: addressText);

  RestaurantDraft withTypicalDay({required int dailyMeals, required SurplusBand band}) =>
      _copy(typicalDailyMeals: dailyMeals, surplusBand: band);

  RestaurantDraft _copy({
    String? name,
    Cuisine? cuisine,
    String? phone,
    String? description,
    double? lat,
    double? lng,
    String? addressText,
    int? typicalDailyMeals,
    SurplusBand? surplusBand,
  }) =>
      RestaurantDraft(
        name: name ?? this.name,
        cuisine: cuisine ?? this.cuisine,
        phone: phone ?? this.phone,
        description: description ?? this.description,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        addressText: addressText ?? this.addressText,
        typicalDailyMeals: typicalDailyMeals ?? this.typicalDailyMeals,
        surplusBand: surplusBand ?? this.surplusBand,
      );

  /// Request body in the §4 field names. Call only when every step is done.
  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'cuisine': cuisine!.json,
        'description': description.trim(),
        'phone': normalizeOmanPhone(phone),
        'address_text': addressText.trim(),
        // GeoJSON: [lng, lat]. Restaurant pins are not rounded (users' are).
        'location': {
          'type': 'Point',
          'coordinates': [lng, lat],
        },
        'typical_daily_meals': typicalDailyMeals,
        'typical_surplus_pct': surplusBand!.typicalPct,
      };
}

enum RestaurantFieldError {
  nameRequired,
  nameTooLong,
  cuisineRequired,
  phoneRequired,
  phoneInvalid,
  descriptionTooLong,
  addressRequired,
}

/// Form checks for onboarding. The server repeats them.
abstract final class RestaurantValidators {
  static const nameMax = 60;
  static const descriptionMax = 140;

  static RestaurantFieldError? name(String value) {
    final v = value.trim();
    if (v.isEmpty) return RestaurantFieldError.nameRequired;
    if (v.length > nameMax) return RestaurantFieldError.nameTooLong;
    return null;
  }

  static RestaurantFieldError? cuisine(Cuisine? value) =>
      value == null ? RestaurantFieldError.cuisineRequired : null;

  static RestaurantFieldError? phone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty || digits == '968') return RestaurantFieldError.phoneRequired;
    return _omanLocal(digits) == null ? RestaurantFieldError.phoneInvalid : null;
  }

  static RestaurantFieldError? description(String value) =>
      value.trim().length > descriptionMax ? RestaurantFieldError.descriptionTooLong : null;

  static RestaurantFieldError? address(String value) =>
      value.trim().isEmpty ? RestaurantFieldError.addressRequired : null;
}

/// Omani numbers have 8 digits starting with 2 (landline), 7 or 9 (mobile),
/// with an optional +968 / 00968 prefix. Returns the 8 local digits or null.
String? _omanLocal(String digits) {
  var d = digits;
  if (d.startsWith('00968')) {
    d = d.substring(5);
  } else if (d.startsWith('968') && d.length == 11) {
    d = d.substring(3);
  }
  return RegExp(r'^[279]\d{7}$').hasMatch(d) ? d : null;
}

/// "+968 9123 4567" from any accepted spelling; unchanged if it isn't valid.
String normalizeOmanPhone(String value) {
  final local = _omanLocal(value.replaceAll(RegExp(r'\D'), ''));
  if (local == null) return value.trim();
  return '+968 ${local.substring(0, 4)} ${local.substring(4)}';
}
