import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/launch/external_links.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/zad_button.dart';
import '../../core/widgets/zad_form_row.dart';
import '../../core/widgets/zad_icon.dart';
import '../../core/widgets/zad_pickup_row.dart';
import '../../core/widgets/zad_sheet.dart';
import '../../core/widgets/zad_tabs.dart';
import '../restaurant/domain/restaurant.dart';
import '../restaurant/onboarding/onboarding_text.dart';
import 'admin_widgets.dart';
import 'application/admin_providers.dart';
import 'domain/admin_models.dart';

/// Figma "Admin: Restaurant approvals" (43:867): Pending · Approved ·
/// Suspended. Pending shows the oldest request as a review card with
/// Reject / Approve and the rest below; the other tabs list restaurants,
/// and a tap opens the same card in a sheet (Suspend / Reinstate).
class AdminRestaurantsScreen extends ConsumerStatefulWidget {
  const AdminRestaurantsScreen({super.key});

  @override
  ConsumerState<AdminRestaurantsScreen> createState() => _AdminRestaurantsScreenState();
}

class _AdminRestaurantsScreenState extends ConsumerState<AdminRestaurantsScreen> {
  static const _tabs = [RestaurantStatus.pending, RestaurantStatus.approved, RestaurantStatus.suspended];
  var _tab = 0;

  /// The pending request shown in the card; the oldest when null.
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final lists = [for (final s in _tabs) ref.watch(adminRestaurantsProvider(s))];
    int count(int i) => lists[i].value?.length ?? 0;
    final pending = lists[0].value ?? const <AdminRestaurant>[];
    final current = lists[_tab];

    final List<Widget> body;
    if (current.isLoading && !current.hasValue) {
      body = [const AdminLoading()];
    } else if (current.hasError && !current.hasValue) {
      body = [AdminMessage(text: l10n.adminLoadError)];
    } else if (_tab == 0) {
      final selected = pending.where((r) => r.id == _selectedId).firstOrNull ?? pending.firstOrNull;
      final others = [for (final r in pending) if (r != selected) r];
      body = [
        if (selected == null)
          AdminMessage(text: l10n.nonePending)
        else
          _ReviewCard(
            key: ValueKey(selected.id),
            restaurant: selected,
            onDone: () => setState(() => _selectedId = null),
          ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(l10n.alsoWaiting(others.length),
                    style: ZadType.body(size: 16, weight: FontWeight.w600, color: z.card)),
              ),
              Text(l10n.oldestFirst, style: ZadType.body(size: 14, color: z.onFrondMuted)),
            ],
          ),
          const SizedBox(height: 8),
          for (final r in others) _ApprovalRow(restaurant: r, onTap: () => setState(() => _selectedId = r.id)),
        ],
      ];
    } else {
      final list = current.value ?? const <AdminRestaurant>[];
      body = [
        if (list.isEmpty)
          AdminMessage(text: _tab == 1 ? l10n.noneApproved : l10n.noneSuspended)
        else
          for (final r in list) _ApprovalRow(restaurant: r, onTap: () => _openSheet(r)),
      ];
    }

    return RefreshIndicator(
      color: z.frond,
      backgroundColor: z.sap,
      onRefresh: () => ref.refresh(adminRestaurantsProvider(_tabs[_tab]).future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
        children: [
          AdminHeader(
            title: l10n.adminRestaurantsTitle,
            summary: count(0) == 0 ? l10n.pendingSummaryNone : l10n.pendingSummary(count(0)),
          ),
          const SizedBox(height: 20),
          ZadUnderlineTabs(
            selected: _tab,
            labels: [l10n.tabPendingCount(count(0)), l10n.tabApprovedCount(count(1)), l10n.tabSuspendedCount(count(2))],
            onSelect: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 20),
          ...body,
        ],
      ),
    );
  }

  void _openSheet(AdminRestaurant r) => showZadSheet<void>(
        context,
        builder: (context) => Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12 + MediaQuery.viewPaddingOf(context).bottom),
          child: _ReviewCard(restaurant: r, onDone: () => Navigator.pop(context)),
        ),
      );
}

/// Figma "Review card": logo placeholder, status kicker, name, cuisine ·
/// area, owner, pickup point, typical day, terms, and the decision.
class _ReviewCard extends ConsumerStatefulWidget {
  const _ReviewCard({super.key, required this.restaurant, required this.onDone});

  final AdminRestaurant restaurant;

  /// After a decision (e.g. close the sheet, or show the next request).
  final VoidCallback onDone;

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  var _busy = false;

  Future<void> _decide(RestaurantStatus status) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = widget.restaurant.restaurant.name;
    if (status == RestaurantStatus.rejected || status == RestaurantStatus.suspended) {
      final reject = status == RestaurantStatus.rejected;
      final ok = await confirmAdminAction(
        context,
        title: reject ? l10n.rejectTitle(name) : l10n.suspendTitle(name),
        body: reject ? l10n.rejectBody : l10n.suspendBody,
        action: reject ? l10n.adminReject : l10n.adminSuspend,
      );
      if (!ok || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(adminActionsProvider).setStatus(widget.restaurant, status);
      messenger.showSnackBar(SnackBar(
        content: Text(switch (status) {
          RestaurantStatus.approved => widget.restaurant.restaurant.status == RestaurantStatus.suspended
              ? l10n.reinstatedToast(name)
              : l10n.approvedToast(name),
          RestaurantStatus.rejected => l10n.rejectedToast(name),
          RestaurantStatus.suspended => l10n.suspendedToast(name),
          RestaurantStatus.pending => name,
        }),
      ));
      widget.onDone();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorAdminAction)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final a = widget.restaurant;
    final r = a.restaurant;
    final now = DateTime.now();
    final kicker = switch (r.status) {
      RestaurantStatus.pending => l10n.reviewKickerNew(l10n.age(r.createdAt, now).toUpperCase()),
      RestaurantStatus.suspended => l10n.reviewKickerSuspended,
      _ => l10n.reviewKickerApproved,
    };

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
              const ZadMealThumb(size: 60, radius: 16, leafSize: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kicker, style: ZadType.mono(size: 11, color: z.sap, letterSpacing: 1.1)),
                    const SizedBox(height: 3),
                    Text(r.name, style: ZadType.display(size: 20, letterSpacing: -0.2, color: z.card)),
                    const SizedBox(height: 3),
                    Text(
                      l10n.cuisineArea(l10n.cuisineLabel(r.cuisine), r.area),
                      style: ZadType.body(size: 13, color: z.onFrondMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ZadFormRow(
            icon: ZadIcons.user,
            title: l10n.rowOwner,
            value: l10n.ownerValue(a.ownerName, r.phone),
            chevron: false,
          ),
          ZadFormRow(
            icon: ZadIcons.mapPin,
            title: l10n.rowPickupPoint,
            value: r.addressText,
            onTap: () => openMapAt(context, lat: r.lat, lng: r.lng),
          ),
          ZadFormRow(icon: ZadIcons.chefHat, title: l10n.rowTypicalDay, value: l10n.typicalDay(r), chevron: false),
          const SizedBox(height: 14),
          Row(
            children: [
              ZadIcon(ZadIcons.check, size: 16, color: z.sap),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.termsAccepted(l10n.when(r.createdAt, now)),
                    style: ZadType.body(size: 13, color: z.sap)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (r.status == RestaurantStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: ZadButton(
                    label: l10n.adminReject,
                    style: ZadButtonStyle.secondary,
                    labelColor: z.danger,
                    onPressed: _busy ? null : () => _decide(RestaurantStatus.rejected),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ZadButton(
                    label: l10n.adminApprove,
                    loading: _busy,
                    onPressed: () => _decide(RestaurantStatus.approved),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(l10n.ownerNotified, style: ZadType.body(size: 12, color: z.onFrondMuted)),
            ),
          ] else if (r.status == RestaurantStatus.approved)
            ZadButton(
              label: l10n.adminSuspend,
              style: ZadButtonStyle.secondary,
              labelColor: z.danger,
              loading: _busy,
              onPressed: () => _decide(RestaurantStatus.suspended),
            )
          else
            ZadButton(label: l10n.adminReinstate, loading: _busy, onPressed: () => _decide(RestaurantStatus.approved)),
        ],
      ),
    );
  }
}

/// Figma component "Approval row" (43:857): initial, name, cuisine · area,
/// how long it has waited (pending only), chevron.
class _ApprovalRow extends StatelessWidget {
  const _ApprovalRow({required this.restaurant, required this.onTap});

  final AdminRestaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final r = restaurant.restaurant;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: z.nightRaised,
                  shape: BoxShape.circle,
                  border: Border.all(color: z.nightHairline),
                ),
                child: Text(
                  r.name.characters.first.toUpperCase(),
                  style: ZadType.display(size: 18, color: z.sap),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ZadType.body(size: 16, weight: FontWeight.w500, color: z.card)),
                    const SizedBox(height: 3),
                    Text(
                      l10n.cuisineArea(l10n.cuisineLabel(r.cuisine), r.area),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZadType.body(size: 13, color: z.onFrondMuted),
                    ),
                  ],
                ),
              ),
              if (r.status == RestaurantStatus.pending) ...[
                const SizedBox(width: 14),
                Text(l10n.age(r.createdAt, DateTime.now()),
                    style: ZadType.mono(size: 12, weight: FontWeight.w400, color: z.onFrondMuted)),
              ],
              const SizedBox(width: 14),
              const ZadIcon(ZadIcons.chevronRight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
