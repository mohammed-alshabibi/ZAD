import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/distance.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/launch/external_links.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/pickup_window_bar.dart';
import '../../../core/widgets/zad_action_tile.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_fact_chip.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../restaurant/domain/offer.dart';
import '../application/reservations.dart';
import '../domain/nearby_offer.dart';
import '../domain/user_reservation.dart';
import '../home/offer_text.dart';
import '../pickups/pickup_code_sheet.dart';
import 'reserve_sheet.dart';

/// Figma "Meal details" (23:135) with its "Reserved" state (24:332): photo
/// (a placeholder until meal photos exist), title, pickup window, facts,
/// description, Directions / Call, allergens and the food-safety note, and a
/// floating bar that reserves or shows the reservation.
///
/// Save, share, Restaurant, Report and the rating from Figma are left out:
/// they are out of scope (CLAUDE.md §1.3) or extras.
class MealDetailsScreen extends ConsumerStatefulWidget {
  const MealDetailsScreen({super.key, required this.offerId});

  final String offerId;

  @override
  ConsumerState<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends ConsumerState<MealDetailsScreen> {
  /// The "Reserved. 1 meal is yours." toast, shown for a few seconds.
  UserReservation? _toast;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _reserve(NearbyOffer offer) async {
    final reservation = await showReserveSheet(context, offer);
    if (reservation == null || !mounted) return;
    _toastTimer?.cancel();
    setState(() => _toast = reservation);
    _toastTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  void _directions(NearbyOffer o) => openDirections(context, lat: o.lat, lng: o.lng);

  void _call(String phone) => callPhone(context, phone);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final now = ref.now;
    final details = ref.watch(offerDetailsProvider(widget.offerId));
    final reservations = ref.watch(myReservationsProvider).value ?? const [];
    final offer = details.value;
    final reservation = activeReservationFor(reservations, widget.offerId, now);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.nightSheet,
        body: Stack(
          children: [
            if (offer != null)
              _Content(offer: offer, now: now, onDirections: () => _directions(offer), onCall: _call)
            else
              _Placeholder(
                error: details.hasError,
                onRetry: () => ref.invalidate(offerDetailsProvider(widget.offerId)),
              ),
            // Figma "Bottom fade" behind the floating bar.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 150,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [z.nightSheet.withValues(alpha: 0), z.nightSheet.withValues(alpha: 0.95), z.nightSheet],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
              ),
            ),
            if (offer != null)
              PositionedDirectional(
                start: 16,
                end: 16,
                bottom: math.max(16, bottom),
                child: _ReserveBar(
                  offer: offer,
                  reservation: reservation,
                  now: now,
                  onReserve: () => _reserve(offer),
                  onShowCode: () => showPickupCodeSheet(context, reservation!),
                ),
              ),
            PositionedDirectional(
              start: 16,
              top: top + 10,
              child: _CloseButton(label: l10n.close, onTap: () => context.pop()),
            ),
            PositionedDirectional(
              start: 16,
              end: 16,
              top: top + 10,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, -0.3), end: Offset.zero).animate(a),
                    child: child,
                  ),
                ),
                child: _toast == null
                    ? const SizedBox.shrink()
                    : _ReservedToast(
                        key: ValueKey(_toast!.id),
                        reservation: _toast!,
                        onTap: () => setState(() => _toast = null),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.offer, required this.now, required this.onDirections, required this.onCall});

  final NearbyOffer offer;
  final DateTime now;
  final VoidCallback onDirections;
  final ValueChanged<String> onCall;

  /// Figma: the 372 px photo runs 64 px under the details.
  static const _photo = 372.0;
  static const _overlap = 64.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final o = offer.offer;
    final tag = l10n.closingTag(o, now);
    final started = !now.isBefore(o.pickupStart);
    final mono11 = ZadType.mono(size: 11, weight: FontWeight.w400, color: z.onFrondMuted);
    final phone = offer.restaurantPhone;

    return SingleChildScrollView(
      child: Stack(
        children: [
          _Photo(label: l10n.categoryLabel(o.categoryEnum), height: _photo),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, _photo - _overlap, 20, 150 + MediaQuery.viewPaddingOf(context).bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.title, style: ZadType.display(size: 30, height: 34 / 30, letterSpacing: -0.45, color: z.card)),
                const SizedBox(height: 6),
                Text(
                  l10n.mealDetailsLine(offer.restaurantName, formatKm(offer.distanceM), offer.walkMinutes),
                  style: ZadType.body(size: 15, color: z.card),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.pickupStatus(o, now),
                      style: ZadType.body(size: 15, weight: FontWeight.w500, color: started ? z.sap : z.card),
                    ),
                    Text('·', style: ZadType.body(size: 15, color: z.onFrondMuted)),
                    Text(l10n.pickupUntil(muscatClock(o.pickupEnd)), style: ZadType.body(size: 15, color: z.card)),
                    if (tag != null)
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: z.saffron, borderRadius: BorderRadius.circular(6)),
                        child: Text(tag, style: ZadType.mono(size: 11, color: z.ink)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(muscatClock(o.pickupStart), style: mono11),
                    const SizedBox(width: 8),
                    Expanded(child: PickupWindowBar(start: o.pickupStart, end: o.pickupEnd, now: now, showNow: true)),
                    const SizedBox(width: 8),
                    Text(muscatClock(o.pickupEnd), style: mono11),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ZadFactChip(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.priceLabel(o.priceBaisa), style: ZadType.mono(size: 13, color: z.card)),
                          if (l10n.wasPriceLabel(o) case final was?) ...[
                            const SizedBox(width: 6),
                            Text(
                              was,
                              style: ZadType.mono(size: 12, weight: FontWeight.w400, color: z.onFrondMuted).copyWith(
                                decoration: TextDecoration.lineThrough,
                                decorationColor: z.onFrondMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ZadFactChip(label: o.quantityAvailable == 0 ? l10n.soldOut : l10n.mealsLeftShort(o.quantityAvailable)),
                    ZadFactChip(label: l10n.categoryLabel(o.categoryEnum)),
                  ],
                ),
                if (o.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Card(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text(o.description, style: ZadType.body(size: 15, height: 22 / 15, color: z.card)),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: ZadActionTile(icon: ZadIcons.directions, label: l10n.directions, onTap: onDirections)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ZadActionTile(
                        icon: ZadIcons.call,
                        label: l10n.call,
                        onTap: phone == null ? null : () => onCall(phone),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SafetyCard(offer: o),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo area: a placeholder (category name) until meal photos are added,
/// fading into the page at the bottom.
class _Photo extends StatelessWidget {
  const _Photo({required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Figma: 145°, stops 14% → 86%.
                  begin: Alignment(-0.57, -1),
                  end: Alignment(0.57, 1),
                  colors: [ZadColors.mealPhotoTop, ZadColors.mealPhotoBottom],
                  stops: [0.143, 0.857],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 150 + MediaQuery.paddingOf(context).top - 44,
            child: Column(
              children: [
                const ZadIcon(ZadIcons.image28, size: 28),
                const SizedBox(height: 6),
                Text(label, style: ZadType.body(size: 12, color: z.onFrondMuted)),
              ],
            ),
          ),
          // Figma "Fade into page": the last 170 px fade to the page colour.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 170,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [z.nightSheet.withValues(alpha: 0), z.nightSheet],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Allergens & safety": allergen chips and the food-safety disclaimer (§8.2).
class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ZadIcon(ZadIcons.shield18, size: 18),
              const SizedBox(width: 8),
              Text(l10n.allergensSafety, style: ZadType.body(size: 15, weight: FontWeight.w600, color: z.card)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final a in offer.allergens) ZadFactChip(label: l10n.allergenLabel(a))],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.safetyNote(muscatClock(offer.preparedAt)),
            style: ZadType.body(size: 13, height: 19 / 13, color: z.onFrondMuted),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: z.nightRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: z.nightHairline),
      ),
      child: child,
    );
  }
}

/// Figma "Reserve bar": price and a white pill, or the reservation once made.
class _ReserveBar extends StatelessWidget {
  const _ReserveBar({
    required this.offer,
    required this.reservation,
    required this.now,
    required this.onReserve,
    required this.onShowCode,
  });

  final NearbyOffer offer;
  final UserReservation? reservation;
  final DateTime now;
  final VoidCallback onReserve;
  final VoidCallback onShowCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final o = offer.offer;
    final r = reservation;

    final String title;
    final String subtitle;
    final String action;
    final VoidCallback? onTap;
    var titleIsPrice = false;
    if (r != null) {
      title = l10n.reserved;
      subtitle = l10n.reservedHeldUntil(r.quantity, muscatClock(r.holdExpiresAt));
      action = l10n.showPickupCode;
      onTap = onShowCode;
    } else if (!o.isLive(now) || o.status == OfferStatus.cancelled) {
      title = l10n.pickupEnded;
      subtitle = l10n.pickupEndedHint;
      action = l10n.reserve;
      onTap = null;
    } else if (o.quantityAvailable == 0) {
      title = l10n.soldOut;
      subtitle = l10n.soldOutHint;
      action = l10n.reserve;
      onTap = null;
    } else {
      title = l10n.priceLabel(o.priceBaisa);
      subtitle = o.priceBaisa == 0 ? l10n.nothingToPay : l10n.payAtPickup;
      action = l10n.reserve;
      onTap = onReserve;
      titleIsPrice = true;
    }

    return Container(
      height: 68,
      padding: const EdgeInsetsDirectional.fromSTEB(22, 6, 6, 6),
      decoration: BoxDecoration(
        color: z.nightRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: z.nightHairline),
        boxShadow: const [BoxShadow(color: ZadColors.barShadow, offset: Offset(0, 8), blurRadius: 24)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleIsPrice
                      ? ZadType.mono(size: 18, color: z.card)
                      : ZadType.body(size: 16, weight: FontWeight.w600, color: r != null ? z.sap : z.card),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZadType.body(size: 12, color: z.onFrondMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Figma: at least 150 px wide, growing with the label.
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150),
            child: ZadButton(label: action, onPressed: onTap, fullWidth: false),
          ),
        ],
      ),
    );
  }
}

/// Figma "Toast · Reserved": saffron ticket tile, "Reserved. 1 meal is yours."
/// and the code to show at the counter.
class _ReservedToast extends StatelessWidget {
  const _ReservedToast({super.key, required this.reservation, required this.onTap});

  final UserReservation reservation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Semantics(
      liveRegion: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: z.nightRaised,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: z.nightHairline),
            boxShadow: const [BoxShadow(color: ZadColors.cardShadow, offset: Offset(0, 8), blurRadius: 24)],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: z.saffron, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: ZadIcon(ZadIcons.ticketToast, size: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reservedToastTitle(reservation.quantity),
                      style: ZadType.body(size: 15, weight: FontWeight.w500, color: z.card),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.reservedToastBody(
                        formatPickupCode(reservation.pickupCode),
                        muscatClock(reservation.holdExpiresAt),
                      ),
                      style: ZadType.body(size: 13, color: z.onFrondMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma "Close": chevron-down in a 38 px scrim circle (the screen slides down).
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.zad.nightScrim,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox.square(dimension: 38, child: Center(child: ZadIcon(ZadIcons.chevronDown24, size: 18))),
        ),
      ),
    );
  }
}

/// Loading and error state before the offer arrives.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.error, required this.onRetry});

  final bool error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    if (!error) return Center(child: CircularProgressIndicator(color: z.sap));
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.mealLoadError, textAlign: TextAlign.center, style: ZadType.body(size: 15, color: z.card)),
            const SizedBox(height: 16),
            ZadButton(label: l10n.tryAgain, style: ZadButtonStyle.secondary, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
