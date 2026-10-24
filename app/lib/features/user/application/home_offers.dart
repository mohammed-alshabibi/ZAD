import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/mapbox_config.dart';
import '../../../core/location/geocoding.dart';
import '../../../core/widgets/pickup_window_bar.dart';
import '../../auth/application/session.dart';
import '../../restaurant/domain/offer.dart';
import '../data/user_offers_repository.dart';
import '../domain/nearby_offer.dart';

/// Where the Home map is centred and offers are searched from: the user's
/// saved location (rounded to ~100 m), or Al Khuwair when there is none yet.
typedef HomeCenter = ({double lat, double lng, bool isUserLocation});

final homeCenterProvider = Provider<HomeCenter>((ref) {
  final (lat, lng) = ref.watch(sessionProvider.select((u) => (u?.lat, u?.lng)));
  if (lat == null || lng == null) return (lat: muscatLat, lng: muscatLng, isUserLocation: false);
  return (lat: lat, lng: lng, isUserLocation: true);
});

/// "Al Khuwair, Muscat" for the area pill, from the saved location. Null when
/// there is no location yet or the lookup fails (no token, offline).
final homeAreaNameProvider = FutureProvider<String?>((ref) async {
  final center = ref.watch(homeCenterProvider);
  if (!center.isUserLocation) return null;
  final place = await ref.watch(geocoderProvider).addressAt(lat: center.lat, lng: center.lng);
  if (place == null) return null;
  // Muscat data often has a street but no neighbourhood; the city is then
  // more useful in the pill than "Way 3709".
  final area = place.area;
  final city = place.city;
  if (area == null) return city;
  return city == null || city == area ? area : '$area, $city';
});

/// `GET /offers/nearby` around [homeCenterProvider]. Reloads when the user's
/// location changes; pull-to-refresh calls `ref.refresh`.
final nearbyOffersProvider = FutureProvider<List<NearbyOffer>>((ref) {
  final center = ref.watch(homeCenterProvider);
  return ref.watch(userOffersRepositoryProvider).nearby(lat: center.lat, lng: center.lng);
});

/// The filter chips and search text on the Home sheet. Filtering happens in
/// the app: at most 50 offers come back, so there is no need to ask again.
class HomeFilters {
  const HomeFilters({
    this.closingSoon = false,
    this.free = false,
    this.underOneOmr = false,
    this.category,
    this.query = '',
  });

  final bool closingSoon;
  final bool free;
  final bool underOneOmr;

  /// One category at a time; null = all.
  final OfferCategory? category;
  final String query;

  bool get isEmpty => !closingSoon && !free && !underOneOmr && category == null && query.trim().isEmpty;

  HomeFilters copyWith({
    bool? closingSoon,
    bool? free,
    bool? underOneOmr,
    OfferCategory? Function()? category,
    String? query,
  }) =>
      HomeFilters(
        closingSoon: closingSoon ?? this.closingSoon,
        free: free ?? this.free,
        underOneOmr: underOneOmr ?? this.underOneOmr,
        category: category != null ? category() : this.category,
        query: query ?? this.query,
      );
}

class HomeFiltersNotifier extends Notifier<HomeFilters> {
  @override
  HomeFilters build() => const HomeFilters();

  void toggleClosingSoon() => state = state.copyWith(closingSoon: !state.closingSoon);
  void toggleFree() => state = state.copyWith(free: !state.free);
  void toggleUnderOneOmr() => state = state.copyWith(underOneOmr: !state.underOneOmr);
  void toggleCategory(OfferCategory c) => state = state.copyWith(category: () => state.category == c ? null : c);
  void setQuery(String q) => state = state.copyWith(query: q);
}

final homeFiltersProvider = NotifierProvider<HomeFiltersNotifier, HomeFilters>(HomeFiltersNotifier.new);

/// Offers shown on Home: still reservable (sold-out ones are hidden) and
/// matching the filters, nearest first as the API returns them.
List<NearbyOffer> applyHomeFilters(List<NearbyOffer> offers, HomeFilters f, DateTime now) {
  final q = f.query.trim().toLowerCase();
  return [
    for (final o in offers)
      if (o.offer.quantityAvailable > 0 &&
          o.offer.pickupEnd.isAfter(now) &&
          (!f.closingSoon || isClosingSoon(o.offer.pickupEnd, now)) &&
          (!f.free || o.offer.priceBaisa == 0) &&
          (!f.underOneOmr || o.offer.priceBaisa < 1000) &&
          (f.category == null || o.offer.categoryEnum == f.category) &&
          (q.isEmpty || o.offer.title.toLowerCase().contains(q) || o.restaurantName.toLowerCase().contains(q)))
        o,
  ];
}

/// Meals left across [offers] (the sheet title, "23 meals left near you").
int mealsLeft(Iterable<NearbyOffer> offers) => offers.fold(0, (sum, o) => sum + o.offer.quantityAvailable);

/// One map pin: a restaurant with its offers (the app groups pins by
/// restaurant, §3 flow 2).
class MapPlace {
  const MapPlace({required this.restaurantId, required this.name, required this.lat, required this.lng, required this.offers});

  final String restaurantId;
  final String name;
  final double lat;
  final double lng;

  /// Nearest first, as in the card row.
  final List<NearbyOffer> offers;

  int get mealsLeft => offers.fold(0, (sum, o) => sum + o.offer.quantityAvailable);
}

List<MapPlace> groupByRestaurant(List<NearbyOffer> offers) {
  final byId = <String, List<NearbyOffer>>{};
  for (final o in offers) {
    (byId[o.restaurantId] ??= []).add(o);
  }
  return [
    for (final MapEntry(key: id, value: list) in byId.entries)
      MapPlace(restaurantId: id, name: list.first.restaurantName, lat: list.first.lat, lng: list.first.lng, offers: list),
  ];
}

/// The list inside the expanded sheet: closing soonest first, so urgency is
/// easy to scan (§14.3 design decisions).
List<NearbyOffer> byPickupEnd(List<NearbyOffer> offers) =>
    [...offers]..sort((a, b) => a.offer.pickupEnd.compareTo(b.offer.pickupEnd));
