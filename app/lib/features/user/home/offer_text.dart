import '../../../core/format/distance.dart';
import '../../../core/format/money.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/pickup_window_bar.dart';
import '../../restaurant/domain/offer.dart';
import '../domain/nearby_offer.dart';

/// ARB labels for offers as users see them.
extension OfferText on AppLocalizations {
  String categoryLabel(OfferCategory? c) => switch (c) {
        OfferCategory.bakery => categoryBakery,
        OfferCategory.riceMandi => categoryRiceMandi,
        OfferCategory.grill => categoryGrill,
        OfferCategory.sandwiches => categorySandwiches,
        OfferCategory.sweets => categorySweets,
        OfferCategory.healthy => categoryHealthy,
        OfferCategory.mixed || null => categoryMixed,
      };

  /// "0.800 OMR", or "Free" when the price is 0.
  String priceLabel(int baisa) => baisa == 0 ? free : formatOmr(baisa);

  /// The crossed-out original price ("2.400"), only when it is higher.
  String? wasPriceLabel(Offer o) {
    final was = o.originalPriceBaisa;
    return was != null && was > o.priceBaisa ? formatOmrAmount(was) : null;
  }

  /// "Zaatar manakish box · 0.6 km · 8 min walk".
  String cardDetails(NearbyOffer o) => offerCardDetails(o.offer.title, formatKm(o.distanceM), o.walkMinutes);

  /// "Pickup now" once the window has opened, else "Pickup from 21:15".
  String pickupStatus(Offer o, DateTime now) =>
      now.isBefore(o.pickupStart) ? pickupFrom(muscatClock(o.pickupStart)) : pickupNow;

  /// Saffron "28 min left" tag, or null when not closing soon.
  String? closingTag(Offer o, DateTime now) {
    if (!isClosingSoon(o.pickupEnd, now)) return null;
    return minutesLeftTag((o.pickupEnd.difference(now).inSeconds / 60).ceil());
  }
}
