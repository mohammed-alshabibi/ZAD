import '../../../core/format/money.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../restaurant/domain/restaurant_reservation.dart';
import '../application/reservations.dart';
import '../domain/user_reservation.dart';

/// ARB labels for the Pickups tab and the pickup code sheet.
extension PickupText on AppLocalizations {
  /// "7 meals rescued · 9.600 OMR saved".
  String impactLine(RescueStats s) {
    if (s.meals == 0) return pickupsImpactNone;
    if (s.savedBaisa == 0) return pickupsImpactNoSavings(s.meals);
    return pickupsImpact(s.meals, formatOmr(s.savedBaisa));
  }

  /// "28 min left" (or "28 min" without [left]); "1 h 5 min left" past an
  /// hour, for a hold made before pickup opens.
  String timeLeft(DateTime end, DateTime now, {bool left = true}) {
    final seconds = end.difference(now).inSeconds;
    final minutes = seconds <= 0 ? 0 : (seconds / 60).ceil();
    if (minutes < 60) return left ? minutesLeftTag(minutes) : minutesLeft(minutes);
    return left ? hoursMinutesLeftTag(minutes ~/ 60, minutes % 60) : hoursMinutes(minutes ~/ 60, minutes % 60);
  }

  /// "TONIGHT" for an evening pickup in Muscat, else "TODAY".
  String pickupKicker(UserReservation r) {
    final hour = toMuscat(r.holdExpiresAt).hour;
    return hour >= 17 || hour < 4 ? pickupKickerTonight : pickupKickerToday;
  }

  /// "1 meal · 0.800 OMR at the counter", or "1 meal · free".
  String pickupAmount(UserReservation r) =>
      r.amountBaisa == 0 ? pickupAmountFree(r.quantity) : pickupAmountCounter(r.quantity, formatOmr(r.amountBaisa));

  /// "Today", "Yesterday", "Tue" within a week, else "18 Oct".
  String pickupDay(DateTime instant, DateTime now) => switch (muscatDaysAgo(instant, now: now)) {
        0 => dayToday,
        1 => dayYesterday,
        < 7 => muscatWeekday(instant),
        _ => muscatDate(instant),
      };

  /// History row detail: "Wadi Grill House · Tue, 22:04",
  /// "Masala Street · Sun · hold ended", "… · cancelled".
  String pickupHistoryDetail(UserReservation r, DateTime now) {
    final at = pickupHistoryTime(r);
    if (r.status == ReservationStatus.cancelled) return pickupDetailCancelled(r.restaurantName, pickupDay(at, now));
    if (r.isMissed(now)) return pickupDetailMissed(r.restaurantName, pickupDay(at, now));
    final time = muscatClock(at);
    final when = switch (muscatDaysAgo(at, now: now)) {
      0 => todayAt(time),
      1 => yesterdayAt(time),
      < 7 => '${muscatWeekday(at)}, $time',
      _ => muscatDateTime(at),
    };
    return pickupDetailCollected(r.restaurantName, when);
  }

  String pickupHistoryStatus(UserReservation r, DateTime now) => switch (r.status) {
        ReservationStatus.collected => statusCollected,
        ReservationStatus.cancelled => statusCancelled,
        ReservationStatus.reserved || ReservationStatus.expired => statusMissed,
      };
}
