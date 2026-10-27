import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/money.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_form_row.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_profile.dart';
import '../../../core/widgets/zad_sheet.dart';
import '../../../core/widgets/zad_text_field.dart';
import '../../auth/application/session.dart';
import '../../auth/domain/auth_validators.dart';
import '../../auth/widgets/log_out_button.dart';
import '../../notifications/application/notifications.dart';
import '../../restaurant/domain/restaurant_reservation.dart';
import '../application/home_offers.dart';
import '../application/reservations.dart';
import '../domain/user_reservation.dart';

/// User "Profile" tab (§9: name, history, notifications on/off, log out).
/// No Figma frame; built from the Form row and Stat tile components.
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  var _savingAlerts = false;

  Future<void> _setAlerts(bool on) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _savingAlerts = true);
    try {
      await ref.read(sessionProvider.notifier).updateMe(notifyEnabled: on);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _savingAlerts = false);
    }
  }

  void _openHistory() {
    ref.read(pickupsTabProvider.notifier).select(1);
    context.go(Routes.userPickups);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final user = ref.watch(sessionProvider);
    if (user == null) return const SizedBox.shrink();
    final reservations = ref.watch(myReservationsProvider).value ?? const <UserReservation>[];
    final stats = rescueStats(reservations);
    final pickups = reservations.where((r) => r.status == ReservationStatus.collected).length;
    final center = ref.watch(homeCenterProvider);
    final area = ref.watch(homeAreaNameProvider).value;
    final unread = ref.watch(unreadNotificationsProvider);

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
      children: [
        Text(l10n.tabProfile, style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card)),
        const SizedBox(height: 18),
        ZadProfileHeader(
          name: user.fullName,
          detail: user.createdAt == null
              ? user.email
              : l10n.memberSince(DateFormat('MMM y').format(user.createdAt!.toLocal())),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Stat(value: '${stats.meals}', label: l10n.profileStatMeals),
            const SizedBox(width: 10),
            _Stat(value: formatOmrAmount(stats.savedBaisa), label: l10n.profileStatSaved),
            const SizedBox(width: 10),
            _Stat(value: '$pickups', label: l10n.profileStatPickups),
          ],
        ),
        ZadSectionLabel(l10n.profileSectionAccount),
        ZadFormRow(
          icon: ZadIcons.userSmall,
          title: l10n.fieldFullName,
          value: user.fullName,
          onTap: () => showZadSheet<void>(context, builder: (_) => _EditNameSheet(initial: user.fullName)),
        ),
        ZadFormRow(icon: ZadIcons.mail, title: l10n.fieldEmail, value: user.email, chevron: false),
        ZadSectionLabel(l10n.profileSectionPickups),
        ZadFormRow(
          icon: ZadIcons.clock,
          title: l10n.profilePickupHistory,
          value: l10n.profilePickupHistoryValue(pickups),
          onTap: _openHistory,
        ),
        ZadFormRow(
          icon: ZadIcons.mapPin,
          title: l10n.profileMyArea,
          value: !center.isUserLocation ? l10n.profileAreaUnset : (area ?? l10n.homeAreaNearYou),
          onTap: () => context.push(Routes.setArea),
        ),
        ZadSectionLabel(l10n.profileSectionNotifications),
        ZadFormRow(
          icon: ZadIcons.leaf,
          title: l10n.profileAlerts,
          value: l10n.profileAlertsValue,
          onTap: _savingAlerts ? null : () => _setAlerts(!user.notifyEnabled),
          trailing: ZadSwitch(value: user.notifyEnabled, onChanged: _savingAlerts ? null : _setAlerts),
        ),
        ZadFormRow(
          icon: ZadIcons.bell,
          title: l10n.notifications,
          value: unread == 0 ? l10n.notificationsAllRead : l10n.notificationsUnread(unread),
          onTap: () => context.push(Routes.notifications),
        ),
        const SizedBox(height: 28),
        const LogOutButton(),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Expanded(
      child: MergeSemantics(
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: z.nightRaised,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: z.nightHairline),
          ),
          child: Column(
            children: [
              FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: ZadType.mono(size: 24, color: z.sap))),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZadType.body(size: 12, color: z.onFrondMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to change the name (`PATCH /me`).
class _EditNameSheet extends ConsumerStatefulWidget {
  const _EditNameSheet({required this.initial});

  final String initial;

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  late final _controller = TextEditingController(text: widget.initial);
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (AuthValidators.fullName(_controller.text) != null) {
      setState(() => _error = l10n.errorNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).updateMe(fullName: _controller.text);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ZadSheet(
      title: l10n.profileEditName,
      children: [
        ZadTextField(
          label: l10n.fieldFullName,
          controller: _controller,
          leadingIcon: ZadIcons.userSmall,
          errorText: _error,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 18),
        ZadButton(label: l10n.save, loading: _busy, onPressed: _save),
      ],
    );
  }
}
