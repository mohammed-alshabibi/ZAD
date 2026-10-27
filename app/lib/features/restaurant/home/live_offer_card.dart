import 'package:flutter/material.dart';

import '../../../core/format/money.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/pickup_window_bar.dart';
import '../../../core/widgets/zad_button.dart';
import '../domain/offer.dart';

/// Night-raised card used on the Today and Offers tabs.
BoxDecoration _card(ZadColors z, {double radius = 24}) => BoxDecoration(
      color: z.nightRaised,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: z.nightHairline),
    );

/// "28 min" / "1 h 12 min" until [end].
String timeLeftLabel(AppLocalizations l10n, DateTime end, DateTime now) {
  final minutes = end.difference(now).inMinutes.clamp(0, 24 * 60);
  return minutes < 60 ? l10n.minutesLeft(minutes) : l10n.hoursMinutesLeft(minutes ~/ 60, minutes % 60);
}

class LiveOfferCard extends StatelessWidget {
  const LiveOfferCard({
    super.key,
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

class NothingLive extends StatelessWidget {
  const NothingLive({super.key, required this.onPost});

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

