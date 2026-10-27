/// One row of the in-app inbox (`GET /notifications`, CLAUDE.md §4
/// `notifications`). The server writes the title and body, so the app shows
/// them as they are.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.offerId,
    this.readAt,
  });

  /// "Restaurant posted surplus near you" (§6 `notify_nearby`). Opens Meal details.
  static const typeNewOffer = 'new_offer';

  /// The admin approved, rejected or suspended the owner's restaurant.
  static const typeRestaurantStatus = 'restaurant_status';

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? offerId;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        offerId: json['offer_id'] as String?,
        readAt: json['read_at'] == null ? null : DateTime.parse(json['read_at'] as String),
      );
}
