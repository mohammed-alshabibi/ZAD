import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/zad_form_row.dart';
import '../../core/widgets/zad_icon.dart';
import '../../core/widgets/zad_profile.dart';
import '../auth/application/session.dart';
import '../auth/widgets/log_out_button.dart';

/// Admin "Profile" tab: who is signed in, and Log out. Admin accounts are
/// made on the server (`createsuperuser`, §8.1), so there is nothing to edit.
class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final user = ref.watch(sessionProvider);

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
      children: [
        Text(l10n.tabProfile, style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card)),
        const SizedBox(height: 18),
        if (user != null) ...[
          ZadProfileHeader(kicker: l10n.adminKicker, name: user.fullName, detail: user.email),
          ZadSectionLabel(l10n.profileSectionAccount),
          ZadFormRow(icon: ZadIcons.mail, title: l10n.fieldEmail, value: user.email, chevron: false),
          ZadFormRow(icon: ZadIcons.shield, title: l10n.profileRole, value: l10n.profileRoleAdmin, chevron: false),
        ],
        const SizedBox(height: 12),
        Text(l10n.profileAdminNote, style: ZadType.body(size: 13, height: 18 / 13, color: z.onFrondMuted)),
        const SizedBox(height: 28),
        const LogOutButton(),
      ],
    );
  }
}
