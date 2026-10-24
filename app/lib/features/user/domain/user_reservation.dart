import '../../restaurant/domain/restaurant_reservation.dart';

/// A reservation as its user sees it (`GET /reservations`): with the full
/// 6-digit pickup code, unlike the restaurant's view.
class UserReservation {
  const UserReservation({
    required this.id,
    required this.offerId,
    required this.offerTitle,
    required this.restaurantName,
    required this.quantity,
    required this.pickupCode,
    required this.status,
    required this.priceBaisa,
    required this.holdExpiresAt,
    required this.pickupEnd,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.restaurantPhone,
    this.collectedAt,
  });

  final String id;
  final String offerId;
  final String offerTitle;
  final String restaurantName;
  final String? restaurantPhone;
  final int quantity;

  /// "482913"; shown as "482 913".
  final String pickupCode;
  final ReservationStatus status;

  /// Price per meal; [amountBaisa] is paid at the counter.
  final int priceBaisa;
  final DateTime holdExpiresAt;
  final DateTime pickupEnd;

  /// The restaurant's pickup point (for Directions).
  final double lat;
  final double lng;
  final DateTime createdAt;
  final DateTime? collectedAt;

  int get amountBaisa => priceBaisa * quantity;

  /// Still waiting to be picked up.
  bool isActive(DateTime now) => status == ReservationStatus.reserved && holdExpiresAt.isAfter(now);

  factory UserReservation.fromJson(Map<String, dynamic> json) {
    final coords = (json['location'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
    return UserReservation(
      id: json['id'] as String,
      offerId: json['offer_id'] as String,
      offerTitle: json['offer_title'] as String,
      restaurantName: json['restaurant_name'] as String,
      restaurantPhone: json['restaurant_phone'] as String?,
      quantity: json['quantity'] as int,
      pickupCode: json['pickup_code'] as String,
      status: ReservationStatus.fromJson(json['status'] as String),
      priceBaisa: json['price_baisa'] as int,
      holdExpiresAt: DateTime.parse(json['hold_expires_at'] as String),
      pickupEnd: DateTime.parse(json['pickup_end'] as String),
      lng: (coords[0] as num).toDouble(),
      lat: (coords[1] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      collectedAt: json['collected_at'] == null ? null : DateTime.parse(json['collected_at'] as String),
    );
  }
}

/// "482 913": the code split in two for reading out at the counter.
String formatPickupCode(String code) =>
    code.length == 6 ? '${code.substring(0, 3)} ${code.substring(3)}' : code;
