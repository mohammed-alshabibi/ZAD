import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/money.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/pickup_window_bar.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_reservation_row.dart';
import '../application/my_restaurant.dart';
import '../application/restaurant_today.dart';
import '../domain/forecast.dart';
import '../domain/offer.dart';
import '../domain/restaurant_reservation.dart';
import 'confirm_pickup_sheet.dart';
import 'offer_sheets.dart';

/// Figma "Restaurant home" (29:400), the Today tab: tonight's numbers, the
/// live offer, pickups waiting at the counter and tomorrow's forecast, with a
/// floating "Confirm pickup" button.
class RestaurantHomeScreen extends ConsumerStatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  ConsumerState<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends ConsumerState<RestaurantHomeScreen> {
  /// Rows shown before "See all".
  static const _collapsedRows = 3;
  var _showAll = false;

  Future<void> _confirmPickup({RestaurantReservation? expected}) async {
    final l10n = AppLocalizations.of(context);
    final collected = await showConfirmPickupSheet(context, expected: expected);
    if (collected == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.pickupCollectedToast(collected.userFirstName, collected.quantity))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final now = ref.now;
    final restaurant = ref.watch(myRestaurantProvider).value;
    final todayAsync = ref.watch(restaurantTodayViewProvider);
    final today = todayAsync.value;

    return Stack(
      children: [
        RefreshIndicator(
          color: z.frond,
          backgroundColor: z.sap,
          onRefresh: () => ref.read(restaurantTodayProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 6, 20, 110),
            children: [
              _Header(
                name: restaurant?.name ?? '',
                area: restaurant?.area ?? '',
                onBell: () => context.push(Routes.notifications),
              ),
              const SizedBox(height: 18),
              if (today == null)
                _Loading(error: todayAsync.hasError ? l10n.errorLoadToday : null)
              else ...[
                _Stats(posted: today.postedMeals, reserved: today.reservedMeals, collected: today.collectedMeals),
                const SizedBox(height: 18),
                if (today.liveOffers.isEmpty)
                  _NothingLive(onPost: () => context.push(Routes.restaurantNewOffer))
                else
                  for (final (i, offer) in today.liveOffers.indexed) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _LiveOfferCard(
                      offer: offer,
                      now: now,
                      onEditQuantity: () => showEditQuantitySheet(context, offer),
                      onEndEarly: () => showEndEarlySheet(context, offer),
                    ),
                  ],
                const SizedBox(height: 18),
                ..._pickups(l10n, z, today),
                if (today.tomorrow != null) ...[
                  const SizedBox(height: 18),
                  _ForecastCard(forecast: today.tomorrow!, onTap: () => context.go(Routes.restaurantInsights)),
                ],
              ],
            ],
          ),
        ),
        // Figma "Bottom fade" behind the floating button.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 114,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [z.nightSheet.withValues(alpha: 0), z.nightSheet.withValues(alpha: 0.95), z.nightSheet],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: 16,
          end: 16,
          bottom: 16,
          child: _ConfirmPickupPill(label: l10n.confirmPickup, onTap: () => _confirmPickup()),
        ),
      ],
    );
  }

  List<Widget> _pickups(AppLocalizations l10n, ZadColors z, RestaurantToday today) {
    final rows = [...today.waiting, ...today.collected];
    final visible = _showAll ? rows : rows.take(_collapsedRows).toList();
    return [
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.waitingForPickup(today.waiting.length),
              style: ZadType.body(size: 16, weight: FontWeight.w600, color: z.card),
            ),
          ),
          if (rows.length > _collapsedRows)
            TextButton(
              onPressed: () => setState(() => _showAll = !_showAll),
              style: TextButton.styleFrom(
                foregroundColor: z.onFrondMuted,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
              ),
              child: Text(_showAll ? l10n.showLess : l10n.seeAll,
                  style: ZadType.body(size: 14, color: z.onFrondMuted)),
            ),
        ],
      ),
      if (rows.isEmpty)
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
          child: Text(l10n.noPickupsYet, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
        )
      else
        for (final r in visible)
          ZadReservationRow(
            initial: r.initial,
            name: l10n.reservationName(r.userFirstName, r.quantity),
            detail: r.status == ReservationStatus.collected
                ? l10n.reservationCollectedDetail(muscatClock(r.collectedAt ?? r.holdExpiresAt))
                : l10n.reservationWaitingDetail(r.codeHint, muscatClock(r.holdExpiresAt)),
            collected: r.status == ReservationStatus.collected,
            confirmLabel: l10n.confirm,
            collectedLabel: l10n.collected,
            onConfirm: () => _confirmPickup(expected: r),
          ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.area, required this.onBell});

  final String name;
  final String area;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.tonightAt, style: ZadType.body(size: 13, color: z.onFrondMuted)),
              const SizedBox(height: 4),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZadType.display(size: 26, letterSpacing: -0.26, color: z.card),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const ZadIcon(ZadIcons.checkSmall, size: 14),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      l10n.verifiedArea(area),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZadType.body(size: 13, color: z.sap),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: l10n.notifications,
          child: Material(
            color: z.nightRaised,
            shape: CircleBorder(side: BorderSide(color: z.nightHairline)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onBell,
              child: const SizedBox.square(dimension: 42, child: Center(child: ZadIcon(ZadIcons.bell, size: 18))),
            ),
          ),
        ),
      ],
    );
  }
}

/// Night-raised card used across the Today tab.
BoxDecoration _card(ZadColors z, {double radius = 24}) => BoxDecoration(
      color: z.nightRaised,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: z.nightHairline),
    );

class _Stats extends StatelessWidget {
  const _Stats({required this.posted, required this.reserved, required this.collected});

  final int posted;
  final int reserved;
  final int collected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    Widget tile(int value, String label, Color color) => Expanded(
          child: MergeSemantics(
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
              decoration: _card(z, radius: 20),
              child: Column(
                children: [
                  Text('$value', style: ZadType.mono(size: 26, color: color)),
                  const SizedBox(height: 2),
                  Text(label, style: ZadType.body(size: 12, color: z.onFrondMuted)),
                ],
              ),
            ),
          ),
        );
    return Row(
      children: [
        tile(posted, l10n.statPosted, z.card),
        const SizedBox(width: 10),
        tile(reserved, l10n.statReserved, z.card),
        const SizedBox(width: 10),
        tile(collected, l10n.statCollected, z.sap),
      ],
    );
  }
}

/// "28 min" / "1 h 12 min" until [end].
String timeLeftLabel(AppLocalizations l10n, DateTime end, DateTime now) {
  final minutes = end.difference(now).inMinutes.clamp(0, 24 * 60);
  return minutes < 60 ? l10n.minutesLeft(minutes) : l10n.hoursMinutesLeft(minutes ~/ 60, minutes % 60);
}

class _LiveOfferCard extends StatelessWidget {
  const _LiveOfferCard({
    required this.offer,
    required this.now,
    required this.onEditQuantity,
    required this.onEndEarly,
  });

  final Offer offer;
  final DateTime now;
  final VoidCallback onEditQuantity;
  final VoidCallback onEndEarly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final urgent = isClosingSoon(offer.pickupEnd, now);
    final price = offer.priceBaisa == 0 ? l10n.free : formatOmr(offer.priceBaisa);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(z),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: z.sap, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(l10n.liveNow, style: ZadType.mono(size: 11, letterSpacing: 1.1, color: z.sap)),
            ],
          ),
          const SizedBox(height: 10),
          Text(offer.title, style: ZadType.display(size: 21, letterSpacing: -0.21, color: z.card)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.offerMeta(offer.quantityAvailable, offer.quantityTotal, price, muscatClock(offer.pickupEnd)),
                  style: ZadType.body(size: 14, color: z.card),
                ),
              ),
              const SizedBox(width: 8),
              // Saffron only when closing soon (under 30 min).
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: urgent ? z.saffron : z.onFrondSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeLeftLabel(l10n, offer.pickupEnd, now),
                  style: ZadType.mono(size: 11, color: urgent ? z.ink : z.sap),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PickupWindowBar(start: offer.pickupStart, end: offer.pickupEnd, now: now),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _OutlinePill(label: l10n.editQuantity, color: z.card, onTap: onEditQuantity)),
              const SizedBox(width: 10),
              Expanded(child: _OutlinePill(label: l10n.endEarly, color: z.danger, onTap: onEndEarly)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 42 px hairline pill (Figma "Edit quantity" / "End early").
class _OutlinePill extends StatelessWidget {
  const _OutlinePill({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: context.zad.nightHairline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 42,
          child: Center(child: Text(label, style: ZadType.body(size: 14, weight: FontWeight.w500, color: color))),
        ),
      ),
    );
  }
}

class _NothingLive extends StatelessWidget {
  const _NothingLive({required this.onPost});

  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(z),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.nothingLiveTitle, style: ZadType.display(size: 21, letterSpacing: -0.21, color: z.card)),
          const SizedBox(height: 6),
          Text(l10n.nothingLiveBody, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
          const SizedBox(height: 14),
          ZadButton(label: l10n.postSurplus, style: ZadButtonStyle.secondary, height: 46, onPressed: onPost),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.forecast, required this.onTap});

  final Forecast forecast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final confidence = forecast.isRoughEstimate
        ? l10n.roughEstimate
        : switch (forecast.confidence) {
            ForecastConfidence.low => l10n.confidenceLow,
            ForecastConfidence.medium => l10n.confidenceMedium,
            ForecastConfidence.high => l10n.confidenceHigh,
          };
    final day = DateFormat('EEE').format(forecast.targetDate);

    return Semantics(
      button: true,
      child: Material(
        color: z.nightRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: z.nightHairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: z.onFrondSubtle, borderRadius: BorderRadius.circular(14)),
                  child: const ZadIcon(ZadIcons.sparkles, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.forecastTomorrow(day, forecast.predicted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ZadType.body(size: 15, weight: FontWeight.w500, color: z.card),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.forecastRange(forecast.low, forecast.high, confidence),
                        style: ZadType.body(size: 13, color: z.onFrondMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                const ZadIcon(ZadIcons.chevronRight, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating white pill with the scan icon (Figma "Confirm pickup").
class _ConfirmPickupPill extends StatelessWidget {
  const _ConfirmPickupPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        boxShadow: [BoxShadow(color: ZadColors.pinShadow, offset: Offset(0, 8), blurRadius: 24)],
      ),
      child: Material(
        color: z.card,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ZadIcon(ZadIcons.scan, size: 20),
                const SizedBox(width: 10),
                Text(label, style: ZadType.body(size: 16, weight: FontWeight.w600, color: z.frond)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: error != null
            ? Text(error!, textAlign: TextAlign.center, style: ZadType.body(size: 14, color: z.danger))
            : CircularProgressIndicator(color: z.sap),
      ),
    );
  }
}
