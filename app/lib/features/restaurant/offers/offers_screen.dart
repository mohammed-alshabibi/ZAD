import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_tabs.dart';
import '../application/restaurant_offers.dart';
import '../application/restaurant_today.dart';

/// Restaurant "Offers" tab: the Live and Past tabs are left empty for now.
/// The lists (live offer cards, past offer rows) are in git tag `ui-v1`.
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
    final view = ref.watch(restaurantOffersViewProvider).value;

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
              l10n.offersTabLive,
              l10n.offersTabPast,
            ],
            onSelect: (i) => setState(() => _tab = i),
          ),
        ],
      ),
    );
  }
}
