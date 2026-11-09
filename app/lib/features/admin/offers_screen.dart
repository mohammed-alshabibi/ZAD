import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import 'admin_widgets.dart';

/// Admin "Offers" tab: left empty for now. The list of live offers with
/// Remove is in git tag `ui-v1`.
class AdminOffersScreen extends StatelessWidget {
  const AdminOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
      children: [AdminHeader(title: l10n.adminOffersTitle)],
    );
  }
}
