/// Offer status (CLAUDE.md §4). Changed only by the server's service functions.
enum OfferStatus {
  active,
  soldOut('sold_out'),
  closed,
  cancelled,
  removed;

  const OfferStatus([this._json]);

  final String? _json;

  String get json => _json ?? name;

  static OfferStatus fromJson(String value) => values.firstWhere((s) => s.json == value);
}

/// A surplus offer as the owning restaurant sees it (`GET /restaurants/me/offers`).
class Offer {
  const Offer({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.category,
    required this.allergens,
    required this.priceBaisa,
    required this.quantityTotal,
    required this.quantityAvailable,
    required this.preparedAt,
    required this.pickupStart,
    required this.pickupEnd,
    required this.status,
    this.originalPriceBaisa,
  });

  final String id;
  final String restaurantId;
  final String title;
  final String description;
  final String category;
  final List<String> allergens;

  /// 0 = free.
  final int priceBaisa;
  final int? originalPriceBaisa;
  final int quantityTotal;
  final int quantityAvailable;
  final DateTime preparedAt;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final OfferStatus status;

  /// Meals already reserved or collected.
  int get taken => quantityTotal - quantityAvailable;

  /// Visible to users and still inside its pickup window.
  bool isLive(DateTime now) =>
      (status == OfferStatus.active || status == OfferStatus.soldOut) && pickupEnd.isAfter(now);

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        id: json['id'] as String,
        restaurantId: json['restaurant_id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        category: json['category'] as String,
        allergens: [for (final a in (json['allergens'] as List<dynamic>? ?? const [])) a as String],
        priceBaisa: json['price_baisa'] as int,
        originalPriceBaisa: json['original_price_baisa'] as int?,
        quantityTotal: json['quantity_total'] as int,
        quantityAvailable: json['quantity_available'] as int,
        preparedAt: DateTime.parse(json['prepared_at'] as String),
        pickupStart: DateTime.parse(json['pickup_start'] as String),
        pickupEnd: DateTime.parse(json['pickup_end'] as String),
        status: OfferStatus.fromJson(json['status'] as String),
      );
}

/// Quantity rules (CLAUDE.md §4: 1–100 per offer).
abstract final class OfferQuantity {
  static const min = 1;
  static const max = 100;
}
