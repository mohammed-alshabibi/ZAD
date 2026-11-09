import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/widgets/zad_tabs.dart';
import 'admin_widgets.dart';

/// Admin "Restaurants" tab: the Pending, Approved and Suspended tabs are left
/// empty for now. The approval screen (review card, approval rows) is in git
/// tag `ui-v1`.
class AdminRestaurantsScreen extends StatefulWidget {
  const AdminRestaurantsScreen({super.key});

  @override
  State<AdminRestaurantsScreen> createState() => _AdminRestaurantsScreenState();
}

class _AdminRestaurantsScreenState extends State<AdminRestaurantsScreen> {
  /// 0 = Pending, 1 = Approved, 2 = Suspended.
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
      children: [
        AdminHeader(title: l10n.adminRestaurantsTitle),
        const SizedBox(height: 20),
        ZadUnderlineTabs(
          selected: _tab,
          labels: [l10n.tabPending, l10n.tabApproved, l10n.tabSuspended],
          onSelect: (i) => setState(() => _tab = i),
        ),
      ],
    );
  }
}
