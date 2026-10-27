import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_pickup_row.dart';
import '../../../core/widgets/zad_tabs.dart';
import '../../user/pickups/pickup_text.dart';
import '../application/restaurant_offers.dart';
import '../application/restaurant_today.dart';
import '../home/live_offer_card.dart';
import '../home/offer_sheets.dart';

/// Restaurant "Offers" tab (no Figma frame; built from the Pickups layout):
/// Live offers with Edit quantity / End early, and Past offers with how
/// many meals were picked up.
class RestaurantOffersScreen extends ConsumerStatefulWidget {
  const RestaurantOffersScreen({super.key});

  @override
  ConsumerState<RestaurantOffersScreen> createState() => _RestaurantOffersScreenState();
}

class _RestaurantOffersScreenState extends ConsumerState<RestaurantOffersScreen> {
  /// 0 = Live, 1 = Past.
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final now = ref.now;
    final async = ref.watch(restaurantOffersViewProvider);
    final view = async.value;

    final List<Widget> body;
    if (view == null) {
      body = [
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Center(
            child: async.hasError
                ? Text(l10n.errorLoadOffers, textAlign: TextAlign.center, style: ZadType.body(size: 14, color: z.danger))
                : CircularProgressIndicator(color: z.sap),
          ),
        ),
      ];
    } else if (_tab == 0) {
      body = [
        if (view.live.isEmpty)
          NothingLive(onPost: () => context.push(Routes.restaurantNewOffer))
        else
          for (final offer in view.live) ...[
            LiveOfferCard(
              offer: offer,
              now: now,
              onEditQuantity: () => showEditQuantitySheet(context, offer),
              onEndEarly: () => showEndEarlySheet(context, offer),
            ),
            const SizedBox(height: 12),
          ],
      ];
    } else {
      body = [
        if (view.past.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.offersPastEmpty, style: ZadType.body(size: 15, height: 22 / 15, color: z.onFrondMuted)),
          )
        else
          for (final p in view.past) _PastOfferRow(past: p, now: now),
      ];
    }

    return RefreshIndicator(
      color: z.frond,
      backgroundColor: z.sap,
      onRefresh: () => ref.read(restaurantTodayProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
        children: [
          Text(l10n.tabOffers, style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card)),
          const SizedBox(height: 6),
          Row(
            children: [
              const ZadIcon(ZadIcons.leaf, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.offersCollectedWeek(view?.collectedThisWeek ?? 0),
                  style: ZadType.body(size: 14, color: z.sap),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ZadUnderlineTabs(
            selected: _tab,
            labels: [
              (view?.live.length ?? 0) == 0 ? l10n.offersTabLive : l10n.offersTabLiveCount(view!.live.length),
              l10n.offersTabPast,
            ],
            onSelect: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 20),
          ...body,
        ],
      ),
    );
  }
}

class _PastOfferRow extends StatelessWidget {
  const _PastOfferRow({required this.past, required this.now});

  final PastOffer past;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = past.offer;
    final outcome = pastOfferOutcome(o);
    return ZadPickupRow(
      meal: o.title,
      detail: l10n.offerPastDetail(l10n.pickupDay(o.pickupEnd, now), past.collectedMeals, o.quantityTotal),
      status: outcome == PastOfferOutcome.allTaken ? ZadPickupStatus.collected : ZadPickupStatus.missed,
      statusLabel: switch (outcome) {
        PastOfferOutcome.allTaken => l10n.offerStatusAllTaken,
        PastOfferOutcome.ended => l10n.offerStatusEnded,
        PastOfferOutcome.endedEarly => l10n.offerStatusEndedEarly,
        PastOfferOutcome.removed => l10n.offerStatusRemoved,
      },
    );
  }
}
