import '../../restaurant/domain/offer.dart';

/// One result of `GET /offers/nearby` (CLAUDE.md §6): the offer, the copied
/// restaurant fields, and how far it is from the user.
class NearbyOffer {
  const NearbyOffer({
    required this.offer,
    required this.restaurantName,
    required this.cuisine,
    required this.lat,
    required this.lng,
    required this.distanceM,
    this.restaurantPhone,
  });

  /// Only on `GET /offers/{id}` (for the Call tile).
  final String? restaurantPhone;

  final Offer offer;
  final String restaurantName;
  final String cuisine;
  final double lat;
  final double lng;

  /// Straight-line distance from the user, from `$geoNear`.
  final int distanceM;

  String get id => offer.id;
  String get restaurantId => offer.restaurantId;

  /// Walking time at about 4.5 km/h (75 m a minute), at least 1 minute.
  int get walkMinutes => (distanceM / 75).ceil().clamp(1, 999);

  factory NearbyOffer.fromJson(Map<String, dynamic> json) {
    // GeoJSON is longitude first.
    final coords = (json['location'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
    return NearbyOffer(
      offer: Offer.fromJson(json),
      restaurantName: json['restaurant_name'] as String,
      cuisine: json['cuisine'] as String,
      lng: (coords[0] as num).toDouble(),
      lat: (coords[1] as num).toDouble(),
      distanceM: (json['distance_m'] as num).round(),
      restaurantPhone: json['restaurant_phone'] as String?,
    );
  }
}
