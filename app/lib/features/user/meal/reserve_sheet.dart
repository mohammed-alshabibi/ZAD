import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_sheet.dart';
import '../../../core/widgets/zad_stepper.dart';
import '../application/reservations.dart';
import '../data/user_offers_repository.dart';
import '../data/user_reservations_repository.dart';
import '../domain/nearby_offer.dart';
import '../domain/user_reservation.dart';
import '../home/offer_text.dart';

/// Figma "Meal details — Reserve sheet" (24:170). Returns the new
/// reservation, or null if the user closed the sheet.
Future<UserReservation?> showReserveSheet(BuildContext context, NearbyOffer offer) =>
    showZadSheet<UserReservation>(context, builder: (_) => _ReserveSheet(offer: offer));

class _ReserveSheet extends ConsumerStatefulWidget {
  const _ReserveSheet({required this.offer});

  final NearbyOffer offer;

  @override
  ConsumerState<_ReserveSheet> createState() => _ReserveSheetState();
}

class _ReserveSheetState extends ConsumerState<_ReserveSheet> {
  var _quantity = 1;
  var _busy = false;
  String? _error;

  Future<void> _reserve() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final reservation = await ref.read(myReservationsProvider.notifier).reserve(widget.offer.id, _quantity);
      if (mounted) Navigator.pop(context, reservation);
    } on ReserveException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (e.code) {
          ReserveException.soldOut => l10n.errorSoldOut,
          ReserveException.notEnoughLeft => l10n.errorNotEnoughLeft,
          ReserveException.alreadyReserved => l10n.errorAlreadyReserved,
          ReserveException.notLive => l10n.errorOfferNotLive,
          _ => l10n.errorReserveFailed,
        };
      });
      // Someone else may have taken meals meanwhile: show the new count.
      ref.invalidate(offerDetailsProvider(widget.offer.id));
    } on OfferNotFound {
      _fail(l10n.errorOfferNotLive);
    } catch (_) {
      _fail(l10n.errorReserveFailed);
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final now = ref.now;
    // Follow the live count while the sheet is open.
    final offer = ref.watch(offerDetailsProvider(widget.offer.id)).value ?? widget.offer;
    final o = offer.offer;
    final max = maxReservable(o.quantityAvailable);
    final quantity = _quantity.clamp(1, max < 1 ? 1 : max);

    // hold_expires_at = min(max(now, pickup_start) + 30 min, pickup_end), as the server works it out.
    final from = now.isAfter(o.pickupStart) ? now : o.pickupStart;
    final hold = from.add(FakeUserReservationsRepository.hold);
    final holdUntil = hold.isAfter(o.pickupEnd) ? o.pickupEnd : hold;
    final free = o.priceBaisa == 0;

    return ZadSheet(
      title: l10n.reserveSheetTitle,
      subtitle: l10n.reserveSheetSubtitle(o.title, offer.restaurantName),
      children: [
        _Box(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.howMany, style: ZadType.body(size: 15, weight: FontWeight.w500, color: z.card)),
                    const SizedBox(height: 2),
                    Text(
                      l10n.howManyHint(o.quantityAvailable),
                      style: ZadType.body(size: 12, color: z.onFrondMuted),
                    ),
                  ],
                ),
              ),
              ZadStepper.compact(
                value: quantity,
                decreaseLabel: l10n.decreaseQuantity,
                increaseLabel: l10n.increaseQuantity,
                onDecrease: _busy || quantity <= 1 ? null : () => setState(() => _quantity = quantity - 1),
                onIncrease: _busy || quantity >= max ? null : () => setState(() => _quantity = quantity + 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _Box(
          child: Column(
            children: [
              _SummaryRow(
                icon: ZadIcons.clock,
                title: l10n.holdUntilTitle(muscatClock(holdUntil)),
                body: l10n.holdUntilBody,
                divider: true,
              ),
              _SummaryRow(
                icon: ZadIcons.wallet,
                title: free ? l10n.freeCounterTitle : l10n.payCounterTitle(l10n.priceLabel(o.priceBaisa * quantity)),
                body: free ? l10n.freeCounterBody : l10n.payCounterBody,
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: ZadType.body(size: 13, height: 18 / 13, color: z.danger)),
        ],
        const SizedBox(height: 18),
        ZadButton(
          label: l10n.reserveMeals(quantity),
          loading: _busy,
          onPressed: max < 1 ? null : _reserve,
        ),
        const SizedBox(height: 8),
        ZadButton(
          label: l10n.notNow,
          style: ZadButtonStyle.ghost,
          height: 40,
          onPressed: _busy ? null : () => Navigator.pop(context),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.reserveSafetyNote,
          textAlign: TextAlign.center,
          style: ZadType.body(size: 11, height: 15 / 11, color: z.onFrondMuted),
        ),
      ],
    );
  }
}

/// Night-sheet panel with a hairline, as in Figma's Quantity and Summary.
class _Box extends StatelessWidget {
  const _Box({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: z.nightSheet,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: z.nightHairline),
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.title, required this.body, this.divider = false});

  final ZadIcons icon;
  final String title;
  final String body;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: divider ? Border(bottom: BorderSide(color: z.nightHairline)) : null,
      ),
      child: Row(
        children: [
          ZadIcon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ZadType.body(size: 14, weight: FontWeight.w500, color: z.card)),
                const SizedBox(height: 2),
                Text(body, style: ZadType.body(size: 12, height: 17 / 12, color: z.onFrondMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
