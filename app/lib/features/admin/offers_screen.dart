import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/muscat_time.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/zad_button.dart';
import '../../core/widgets/zad_pickup_row.dart';
import '../user/home/offer_text.dart';
import 'admin_widgets.dart';
import 'application/admin_providers.dart';
import 'domain/admin_models.dart';

/// Admin "Offers" (no Figma frame; built from the existing parts): every
/// live offer, closing soonest first, each with Remove (§1.2).
class AdminOffersScreen extends ConsumerWidget {
  const AdminOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final async = ref.watch(adminOffersProvider);
    final offers = async.value;
    final meals = (offers ?? const <AdminOffer>[]).fold(0, (sum, o) => sum + o.offer.quantityAvailable);

    return RefreshIndicator(
      color: z.frond,
      backgroundColor: z.sap,
      onRefresh: () => ref.refresh(adminOffersProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
        children: [
          AdminHeader(
            title: l10n.adminOffersTitle,
            summary: offers == null || offers.isEmpty
                ? l10n.adminOffersNone
                : l10n.adminOffersSummary(offers.length, meals),
          ),
          const SizedBox(height: 12),
          if (offers != null)
            // Keyed, so a row's spinner doesn't move to the next offer after a removal.
            for (final o in offers) _OfferRow(key: ValueKey(o.id), offer: o)
          else if (async.hasError)
            AdminMessage(text: l10n.adminLoadError)
          else
            const AdminLoading(),
        ],
      ),
    );
  }
}

class _OfferRow extends ConsumerStatefulWidget {
  const _OfferRow({super.key, required this.offer});

  final AdminOffer offer;

  @override
  ConsumerState<_OfferRow> createState() => _OfferRowState();
}

class _OfferRowState extends ConsumerState<_OfferRow> {
  var _busy = false;

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final o = widget.offer;
    final ok = await confirmAdminAction(
      context,
      title: l10n.removeTitle,
      body: l10n.removeBody(o.offer.title, o.restaurantName),
      action: l10n.adminRemove,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(adminActionsProvider).removeOffer(o);
      messenger.showSnackBar(SnackBar(content: Text(l10n.removedToast)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorAdminAction)));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final o = widget.offer.offer;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: z.nightHairline))),
      child: Row(
        children: [
          const ZadMealThumb(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.body(size: 16, weight: FontWeight.w500, color: z.card)),
                const SizedBox(height: 3),
                Text(
                  '${widget.offer.restaurantName} · ${l10n.categoryLabel(o.categoryEnum)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZadType.body(size: 13, color: z.onFrondMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.adminOfferLine(o.quantityAvailable, o.quantityTotal, muscatClock(o.pickupEnd)),
                  style: ZadType.mono(size: 12, weight: FontWeight.w400, color: z.card),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ZadButton(
            label: l10n.adminRemove,
            style: ZadButtonStyle.secondary,
            labelColor: z.danger,
            height: 40,
            labelSize: 14,
            sidePadding: 14,
            fullWidth: false,
            loading: _busy,
            onPressed: _remove,
          ),
        ],
      ),
    );
  }
}
