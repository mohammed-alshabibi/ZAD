import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_tabs.dart';
import '../application/insights.dart';

/// Restaurant "Insights" tab: the Forecast and Impact tabs are left empty
/// for now. The forecast cards (tomorrow, 7-day chart, reasons, suggestion,
/// accuracy, Log yesterday) are in git tag `ui-v1`.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;

    return RefreshIndicator(
      color: z.frond,
      backgroundColor: z.sap,
      onRefresh: () => ref.read(insightsProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 16, 20, 28),
        children: [
          Text(l10n.tabInsights, style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card)),
          const SizedBox(height: 16),
          ZadUnderlineTabs(
            selected: _tab,
            labels: [l10n.insightsTabForecast, l10n.insightsTabImpact],
            onSelect: (i) => setState(() => _tab = i),
          ),
        ],
      ),
    );
  }
}
