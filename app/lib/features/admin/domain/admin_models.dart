import '../../restaurant/domain/offer.dart';
import '../../restaurant/domain/restaurant.dart';

/// Food saved per rescued meal. An assumption, and the screens say so (§12).
const kgPerMeal = 0.4;

/// `GET /admin/overview` (Figma 47:956).
class AdminOverview {
  const AdminOverview({
    required this.mealsRescued,
    required this.mealsToday,
    required this.mealsThisWeek,
    required this.collectedPct,
    required this.restaurantsApproved,
    required this.restaurantsPending,
    required this.oldestPendingAt,
    required this.liveOffers,
    required this.mealsLeft,
    required this.pickupsToday,
    required this.waitingNow,
    required this.users,
    required this.usersReservedToday,
  });

  /// Meals collected, all time.
  final int mealsRescued;
  final int mealsToday;
  final int mealsThisWeek;

  /// Collected ÷ (collected + missed) reservations; null with no finished ones.
  final int? collectedPct;
  final int restaurantsApproved;
  final int restaurantsPending;
  final DateTime? oldestPendingAt;
  final int liveOffers;
  final int mealsLeft;

  /// Reservations collected today, and ones still waiting at a counter.
  final int pickupsToday;
  final int waitingNow;
  final int users;
  final int usersReservedToday;

  /// Rounded estimate, e.g. 514 for 1,284 meals.
  int get kgSaved => (mealsRescued * kgPerMeal).round();

  factory AdminOverview.fromJson(Map<String, dynamic> json) => AdminOverview(
        mealsRescued: json['meals_rescued'] as int,
        mealsToday: json['meals_today'] as int,
        mealsThisWeek: json['meals_this_week'] as int,
        collectedPct: json['collected_pct'] as int?,
        restaurantsApproved: json['restaurants_approved'] as int,
        restaurantsPending: json['restaurants_pending'] as int,
        oldestPendingAt:
            json['oldest_pending_at'] == null ? null : DateTime.parse(json['oldest_pending_at'] as String),
        liveOffers: json['live_offers'] as int,
        mealsLeft: json['meals_left'] as int,
        pickupsToday: json['pickups_today'] as int,
        waitingNow: json['waiting_now'] as int,
        users: json['users'] as int,
        usersReservedToday: json['users_reserved_today'] as int,
      );
}

/// A restaurant as admins see it (`GET /admin/restaurants`): with the owner's name.
class AdminRestaurant {
  const AdminRestaurant({required this.restaurant, required this.ownerName});

  final Restaurant restaurant;
  final String ownerName;

  String get id => restaurant.id;

  factory AdminRestaurant.fromJson(Map<String, dynamic> json) =>
      AdminRestaurant(restaurant: Restaurant.fromJson(json), ownerName: (json['owner_name'] as String?) ?? '');
}

/// A live offer in the admin list (`GET /admin/offers`).
class AdminOffer {
  const AdminOffer({required this.offer, required this.restaurantName});

  final Offer offer;
  final String restaurantName;

  String get id => offer.id;

  factory AdminOffer.fromJson(Map<String, dynamic> json) =>
      AdminOffer(offer: Offer.fromJson(json), restaurantName: json['restaurant_name'] as String);
}
