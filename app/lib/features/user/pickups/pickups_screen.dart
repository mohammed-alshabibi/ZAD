import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/distance.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/launch/external_links.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/pickup_window_bar.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_pickup_row.dart';
import '../../restaurant/domain/restaurant_reservation.dart';
import '../application/home_offers.dart';
import '../application/reservations.dart';
import '../domain/user_reservation.dart';
import 'pickup_code_sheet.dart';
import 'pickup_text.dart';

/// Figma "Pickups" (26:256): meals rescued so far, Upcoming · History tabs,
/// a card per running hold with "Show pickup code", and recent pickups.
class PickupsScreen extends ConsumerStatefulWidget {
  const PickupsScreen({super.key});

  @override
  ConsumerState<PickupsScreen> createState() => _PickupsScreenState();
}

class _PickupsScreenState extends ConsumerState<PickupsScreen> {
  /// 0 = Upcoming, 1 = History.
  var _tab = 0;

  /// Rows under "Recent" on the Upcoming tab (Figma shows 3).
  static const _recentCount = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final now = ref.now;
    final async = ref.watch(myReservationsProvider);
    final all = async.value ?? const <UserReservation>[];
    final upcoming = upcomingPickups(all, now);
    final history = pickupHistory(all, now);
    final center = ref.watch(homeCenterProvider);

    final List<Widget> body;
    if (async.isLoading && !async.hasValue) {
      body = [
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Center(child: CircularProgressIndicator(color: z.sap)),
        ),
      ];
    } else if (async.hasError && !async.hasValue) {
      body = [_Message(text: l10n.pickupsLoadError)];
    } else if (_tab == 0) {
      body = [
        if (upcoming.isEmpty)
          _EmptyUpcoming(onFind: () => context.go(Routes.userHome))
        else
          for (final r in upcoming) ...[
            _ActiveCard(reservation: r, now: now, distanceM: distanceToPickup(center, r)),
            const SizedBox(height: 12),
          ],
        if (history.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(l10n.pickupsRecent, style: ZadType.body(size: 16, weight: FontWeight.w600, color: z.card)),
              ),
              TextButton(
                onPressed: () => setState(() => _tab = 1),
                style: TextButton.styleFrom(
                  foregroundColor: z.onFrondMuted,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 40),
                ),
                child: Text(l10n.seeAll, style: ZadType.body(size: 14, color: z.onFrondMuted)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final r in history.take(_recentCount)) _HistoryRow(reservation: r, now: now),
        ],
      ];
    } else {
      body = [
        if (history.isEmpty)
          _Message(text: l10n.historyEmpty)
        else
          for (final r in history) _HistoryRow(reservation: r, now: now),
      ];
    }

    return RefreshIndicator(
      color: z.frond,
      backgroundColor: z.sap,
      onRefresh: () => ref.read(myReservationsProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
        children: [
          Text(
            l10n.tabPickups,
            style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const ZadIcon(ZadIcons.leaf, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(l10n.impactLine(rescueStats(all)), style: ZadType.body(size: 14, color: z.sap))),
            ],
          ),
          const SizedBox(height: 20),
          _Tabs(
            selected: _tab,
            labels: [
              upcoming.isEmpty ? l10n.pickupsTabUpcoming : l10n.pickupsTabUpcomingCount(upcoming.length),
              l10n.pickupsTabHistory,
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

/// Underline tabs (Figma "Tabs"): equal halves, a 3 px card-coloured
/// indicator under the selected one, and a hairline under the row.
class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.labels, required this.onSelect});

  final int selected;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: z.nightHairline))),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      children: [
                        Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ZadType.body(
                            size: 16,
                            weight: i == selected ? FontWeight.w600 : FontWeight.w500,
                            color: i == selected ? z.card : z.onFrondMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          decoration: BoxDecoration(
                            color: i == selected ? z.card : z.card.withValues(alpha: 0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Figma "Active reservation": the meal, how much to pay, the hold countdown
/// and bar, and Show pickup code / Directions.
class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.reservation, required this.now, required this.distanceM});

  final UserReservation reservation;
  final DateTime now;
  final int distanceM;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final r = reservation;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: z.nightRaised,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: z.nightHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ZadMealThumb(size: 68, radius: 16, leafSize: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.pickupKicker(r), style: ZadType.mono(size: 11, color: z.sap, letterSpacing: 1.1)),
                    const SizedBox(height: 3),
                    Text(
                      r.offerTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ZadType.display(size: 20, letterSpacing: -0.2, color: z.card),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.pickupRestaurantDistance(r.restaurantName, formatKm(distanceM)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZadType.body(size: 13, color: z.onFrondMuted),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.pickupAmount(r),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZadType.mono(size: 12, weight: FontWeight.w400, color: z.card),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ZadIcon(ZadIcons.clock, size: 16, color: z.saffron),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.heldUntil(muscatClock(r.holdExpiresAt)), style: ZadType.body(size: 14, color: z.card)),
              ),
              const SizedBox(width: 8),
              Text(l10n.timeLeft(r.holdExpiresAt, now), style: ZadType.mono(size: 13, color: z.saffron)),
            ],
          ),
          const SizedBox(height: 8),
          PickupWindowBar(start: r.holdStartsAt, end: r.holdExpiresAt, now: now),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ZadButton(
                  label: l10n.showPickupCode,
                  icon: ZadIcons.tabTicket,
                  height: 50,
                  labelSize: 15,
                  sidePadding: 10,
                  onPressed: () => showPickupCodeSheet(context, r),
                ),
              ),
              const SizedBox(width: 10),
              ZadButton(
                label: l10n.directions,
                style: ZadButtonStyle.secondary,
                icon: ZadIcons.directions,
                iconSize: 16,
                height: 50,
                labelSize: 14,
                sidePadding: 17,
                fullWidth: false,
                onPressed: () => openDirections(context, lat: r.lat, lng: r.lng),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.reservation, required this.now});

  final UserReservation reservation;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = reservation;
    return ZadPickupRow(
      meal: r.offerTitle,
      detail: l10n.pickupHistoryDetail(r, now),
      status: r.status == ReservationStatus.collected ? ZadPickupStatus.collected : ZadPickupStatus.missed,
      statusLabel: l10n.pickupHistoryStatus(r, now),
    );
  }
}

/// No hold running: a short note and a way back to the map.
class _EmptyUpcoming extends StatelessWidget {
  const _EmptyUpcoming({required this.onFind});

  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: z.nightRaised,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: z.nightHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ZadIcon(ZadIcons.tabTicket, size: 24),
          const SizedBox(height: 12),
          Text(l10n.pickupsEmptyTitle, style: ZadType.display(size: 20, letterSpacing: -0.2, color: z.card)),
          const SizedBox(height: 4),
          Text(l10n.pickupsEmptyBody, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
          const SizedBox(height: 16),
          ZadButton(label: l10n.findMeals, height: 50, labelSize: 15, onPressed: onFind),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(text, style: ZadType.body(size: 15, height: 22 / 15, color: context.zad.onFrondMuted)),
      );
}
