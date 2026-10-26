import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format/muscat_time.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/zad_form_row.dart';
import '../../core/widgets/zad_icon.dart';
import '../../core/widgets/zad_stat_tile.dart';
import 'admin_widgets.dart';
import 'application/admin_providers.dart';
import 'domain/admin_models.dart';

/// Figma "Admin: Overview" (47:956): meals rescued (the end point of the
/// demo script), four counts, and what needs attention.
class AdminOverviewScreen extends ConsumerWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final async = ref.watch(adminOverviewProvider);
    final data = async.value;

    return RefreshIndicator(
      color: z.frond,
      backgroundColor: z.sap,
      onRefresh: () => ref.refresh(adminOverviewProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
        children: [
          AdminHeader(
            title: l10n.tabOverview,
            summary: l10n.adminUpdated(muscatClock(data?.loadedAt ?? DateTime.now())),
          ),
          const SizedBox(height: 20),
          if (data != null) ...[
            _MealsRescued(o: data.overview),
            const SizedBox(height: 20),
            _Stats(o: data.overview),
            const SizedBox(height: 20),
            Text(l10n.needsAttention, style: ZadType.body(size: 16, weight: FontWeight.w600, color: z.card)),
            const SizedBox(height: 20),
            _Attention(o: data.overview),
          ] else if (async.hasError)
            AdminMessage(text: l10n.adminLoadError)
          else
            const AdminLoading(),
        ],
      ),
    );
  }
}

/// Frond hero card: all-time meals, today, this week, collect rate, and the
/// food-saved estimate (labelled as one, §12).
class _MealsRescued extends StatelessWidget {
  const _MealsRescued({required this.o});

  final AdminOverview o;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final number = NumberFormat.decimalPattern('en');
    final pct = o.collectedPct;
    return MergeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: z.frond, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mealsRescuedKicker, style: ZadType.mono(size: 11, color: z.sap, letterSpacing: 1.1)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(number.format(o.mealsRescued), style: ZadType.display(size: 52, color: z.card)),
                const SizedBox(width: 12),
                Text(l10n.mealsTodayDelta(o.mealsToday), style: ZadType.mono(size: 14, color: z.sap)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              pct == null ? l10n.mealsWeek(o.mealsThisWeek) : l10n.mealsWeekRate(o.mealsThisWeek, pct),
              style: ZadType.body(size: 14, color: z.card),
            ),
            const SizedBox(height: 6),
            Text(l10n.kgSaved(o.kgSaved), style: ZadType.body(size: 12, color: z.onFrondMuted)),
          ],
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.o});

  final AdminOverview o;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget pair(Widget a, Widget b) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Expanded(child: a), const SizedBox(width: 10), Expanded(child: b)],
          ),
        );
    return Column(
      children: [
        pair(
          ZadStatTile(
            label: l10n.statRestaurants,
            value: '${o.restaurantsApproved}',
            detail: l10n.statRestaurantsDetail(o.restaurantsPending),
            onTap: () => context.go(Routes.adminRestaurants),
          ),
          ZadStatTile(
            label: l10n.statLiveOffers,
            value: '${o.liveOffers}',
            detail: l10n.statLiveOffersDetail(o.mealsLeft),
            onTap: () => context.go(Routes.adminOffers),
          ),
        ),
        const SizedBox(height: 10),
        pair(
          ZadStatTile(
            label: l10n.statPickupsToday,
            value: '${o.pickupsToday}',
            detail: l10n.statPickupsDetail(o.waitingNow),
          ),
          ZadStatTile(label: l10n.statUsers, value: '${o.users}', detail: l10n.statUsersDetail(o.usersReservedToday)),
        ),
      ],
    );
  }
}

/// "Needs attention": shortcuts to approvals and live offers.
class _Attention extends StatelessWidget {
  const _Attention({required this.o});

  final AdminOverview o;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final oldest = o.oldestPendingAt;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: z.nightRaised, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ZadFormRow(
            icon: ZadIcons.storeSmall,
            title: l10n.attentionApprovals,
            value: oldest == null
                ? l10n.attentionApprovalsNone
                : l10n.attentionApprovalsValue(o.restaurantsPending, l10n.age(oldest, DateTime.now())),
            onTap: () => context.go(Routes.adminRestaurants),
          ),
          ZadFormRow(
            icon: ZadIcons.tag,
            title: l10n.attentionOffers,
            value: l10n.attentionOffersValue(o.liveOffers),
            onTap: () => context.go(Routes.adminOffers),
          ),
        ],
      ),
    );
  }
}
