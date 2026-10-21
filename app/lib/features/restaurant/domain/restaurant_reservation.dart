/// Reservation status (CLAUDE.md §4 reservation lifecycle).
enum ReservationStatus {
  reserved,
  collected,
  cancelled,
  expired;

  static ReservationStatus fromJson(String value) => values.byName(value);
}

/// A reservation as the restaurant sees it (`GET /restaurants/me/reservations`).
/// Per §5.1 the restaurant gets only the customer's first name and the last
/// three digits of the code, never their phone, location or full code.
class RestaurantReservation {
  const RestaurantReservation({
    required this.id,
    required this.offerId,
    required this.offerTitle,
    required this.userFirstName,
    required this.quantity,
    required this.codeHint,
    required this.status,
    required this.priceBaisa,
    required this.holdExpiresAt,
    this.collectedAt,
  });

  final String id;
  final String offerId;
  final String offerTitle;
  final String userFirstName;
  final int quantity;

  /// Last three digits of the pickup code, e.g. "913".
  final String codeHint;
  final ReservationStatus status;

  /// Price per meal; the customer pays [amountBaisa] at the counter.
  final int priceBaisa;
  final DateTime holdExpiresAt;
  final DateTime? collectedAt;

  int get amountBaisa => priceBaisa * quantity;

  String get initial => userFirstName.isEmpty ? '?' : String.fromCharCode(userFirstName.runes.first).toUpperCase();

  factory RestaurantReservation.fromJson(Map<String, dynamic> json) => RestaurantReservation(
        id: json['id'] as String,
        offerId: json['offer_id'] as String,
        offerTitle: json['offer_title'] as String,
        userFirstName: json['user_first_name'] as String,
        quantity: json['quantity'] as int,
        codeHint: json['code_hint'] as String,
        status: ReservationStatus.fromJson(json['status'] as String),
        priceBaisa: json['price_baisa'] as int,
        holdExpiresAt: DateTime.parse(json['hold_expires_at'] as String),
        collectedAt: json['collected_at'] == null ? null : DateTime.parse(json['collected_at'] as String),
      );
}
