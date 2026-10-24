import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_sheet.dart';
import '../../../core/widgets/zad_stepper.dart';
import '../application/restaurant_today.dart';
import '../data/restaurant_today_repositories.dart';
import '../domain/offer.dart';

Future<void> showEditQuantitySheet(BuildContext context, Offer offer) =>
    showZadSheet<void>(context, builder: (_) => _EditQuantitySheet(offer: offer));

Future<void> showEndEarlySheet(BuildContext context, Offer offer) =>
    showZadSheet<void>(context, builder: (_) => _EndEarlySheet(offer: offer));

/// "Edit quantity": the owner sets how many meals are left; meals already
/// reserved or collected can't be taken back.
class _EditQuantitySheet extends ConsumerStatefulWidget {
  const _EditQuantitySheet({required this.offer});

  final Offer offer;

  @override
  ConsumerState<_EditQuantitySheet> createState() => _EditQuantitySheetState();
}

class _EditQuantitySheetState extends ConsumerState<_EditQuantitySheet> {
  late int _left = widget.offer.quantityAvailable;
  var _busy = false;
  String? _error;

  // An offer needs at least 1 meal in total (§4: quantity 1–100).
  int get _min => widget.offer.taken == 0 ? OfferQuantity.min : 0;
  int get _max => OfferQuantity.max - widget.offer.taken;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(restaurantTodayProvider.notifier).setMealsLeft(widget.offer, _left);
      if (mounted) Navigator.pop(context);
    } on OfferException catch (e) {
      if (mounted) {
        setState(() => _error = e.code == OfferException.belowTaken ? l10n.errorQuantityBelowTaken : l10n.errorGeneric);
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return ZadSheet(
      title: l10n.editQuantityTitle,
      subtitle: l10n.editQuantityBody(widget.offer.taken),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: z.nightSheet,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: z.nightHairline),
          ),
          child: ZadStepper(
            value: _left,
            unit: l10n.mealsLeftUnit,
            decreaseLabel: l10n.fewerMeals,
            increaseLabel: l10n.moreMeals,
            onDecrease: _left > _min ? () => setState(() => _left--) : null,
            onIncrease: _left < _max ? () => setState(() => _left++) : null,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: ZadType.body(size: 13, color: z.danger)),
        ],
        const SizedBox(height: 18),
        ZadButton(
          label: l10n.save,
          loading: _busy,
          onPressed: _left == widget.offer.quantityAvailable ? null : _save,
        ),
      ],
    );
  }
}

/// "End early": stop new reservations; existing pickups stay valid.
class _EndEarlySheet extends ConsumerStatefulWidget {
  const _EndEarlySheet({required this.offer});

  final Offer offer;

  @override
  ConsumerState<_EndEarlySheet> createState() => _EndEarlySheetState();
}

class _EndEarlySheetState extends ConsumerState<_EndEarlySheet> {
  var _busy = false;

  Future<void> _end() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(restaurantTodayProvider.notifier).endEarly(widget.offer);
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(l10n.offerEnded)));
    } catch (_) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return ZadSheet(
      title: l10n.endEarlyTitle,
      subtitle: l10n.endEarlyBody,
      children: [
        ZadButton(
          label: l10n.endOffer,
          style: ZadButtonStyle.secondary,
          labelColor: z.danger,
          loading: _busy,
          onPressed: _end,
        ),
        const SizedBox(height: 6),
        ZadButton(
          label: l10n.keepLive,
          style: ZadButtonStyle.ghost,
          onPressed: _busy ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }
}
