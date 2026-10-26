import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/launch/external_links.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/pickup_window_bar.dart';
import '../../../core/widgets/zad_action_tile.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_sheet.dart';
import '../application/reservations.dart';
import '../domain/user_reservation.dart';
import 'pickup_text.dart';

/// Figma "Pickups — Pickup code" (27:319): the code to show at the counter,
/// the hold countdown, Directions / Call, and Cancel reservation. Says so in
/// a snackbar when the user cancels.
Future<void> showPickupCodeSheet(BuildContext context, UserReservation reservation) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final cancelled = await showZadSheet<bool>(context, builder: (_) => _PickupCodeSheet(initial: reservation));
  if (cancelled == true) messenger.showSnackBar(SnackBar(content: Text(l10n.reservationCancelled)));
}

class _PickupCodeSheet extends ConsumerStatefulWidget {
  const _PickupCodeSheet({required this.initial});

  final UserReservation initial;

  @override
  ConsumerState<_PickupCodeSheet> createState() => _PickupCodeSheetState();
}

class _PickupCodeSheetState extends ConsumerState<_PickupCodeSheet> {
  var _confirming = false;
  var _busy = false;
  String? _error;

  Future<void> _cancel(UserReservation r) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(myReservationsProvider.notifier).cancel(r);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.errorCancelFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final now = ref.now;
    // Follow the reservation while the sheet is open (e.g. after a refresh).
    final r = (ref.watch(myReservationsProvider).value ?? const <UserReservation>[])
            .where((x) => x.id == widget.initial.id)
            .firstOrNull ??
        widget.initial;
    final active = r.isActive(now);
    final phone = r.restaurantPhone;

    return ZadSheet(
      title: l10n.pickupCodeTitle,
      subtitle: l10n.pickupCodeSubtitle(r.offerTitle, r.quantity, r.restaurantName),
      children: [
        _CodePanel(code: r.pickupCode, dimmed: !active),
        const SizedBox(height: 16),
        if (active) ...[
          Row(
            children: [
              ZadIcon(ZadIcons.clock, size: 16, color: z.saffron),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.amountBaisa == 0
                      ? l10n.heldUntilFree(muscatClock(r.holdExpiresAt))
                      : l10n.heldUntilPay(muscatClock(r.holdExpiresAt)),
                  style: ZadType.body(size: 14, color: z.card),
                ),
              ),
              const SizedBox(width: 8),
              Text(l10n.timeLeft(r.holdExpiresAt, now, left: false), style: ZadType.mono(size: 13, color: z.saffron)),
            ],
          ),
          const SizedBox(height: 8),
          PickupWindowBar(start: r.holdStartsAt, end: r.holdExpiresAt, now: now),
        ] else
          Text(
            l10n.holdEnded(muscatClock(r.holdExpiresAt)),
            style: ZadType.body(size: 14, height: 20 / 14, color: z.danger),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ZadActionTile(
                icon: ZadIcons.directions,
                label: l10n.directions,
                onTap: () => openDirections(context, lat: r.lat, lng: r.lng),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ZadActionTile(
                icon: ZadIcons.call,
                label: l10n.callRestaurant,
                onTap: phone == null ? null : () => callPhone(context, phone),
              ),
            ),
          ],
        ),
        if (active) ...[
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _confirming ? _confirmBox(l10n, r) : _cancelLink(l10n),
          ),
        ],
      ],
    );
  }

  Widget _cancelLink(AppLocalizations l10n) => ZadButton(
        label: l10n.cancelReservation,
        style: ZadButtonStyle.ghost,
        height: 44,
        labelColor: context.zad.danger,
        onPressed: () => setState(() => _confirming = true),
      );

  /// Cancelling can't be undone, so it asks once more in place.
  Widget _confirmBox(AppLocalizations l10n, UserReservation r) {
    final z = context.zad;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: z.nightSheet,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: z.nightHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cancelConfirmTitle, style: ZadType.body(size: 15, weight: FontWeight.w600, color: z.card)),
          const SizedBox(height: 4),
          Text(l10n.cancelConfirmBody, style: ZadType.body(size: 13, height: 18 / 13, color: z.onFrondMuted)),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: ZadType.body(size: 13, color: z.danger)),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ZadButton(
                  label: l10n.keepIt,
                  style: ZadButtonStyle.secondary,
                  height: 46,
                  labelSize: 15,
                  onPressed: _busy ? null : () => setState(() => _confirming = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ZadButton(
                  label: l10n.yesCancel,
                  style: ZadButtonStyle.secondary,
                  height: 46,
                  labelSize: 15,
                  labelColor: z.danger,
                  loading: _busy,
                  onPressed: () => _cancel(r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Figma "Code panel": light card, QR (decorative stand-in until a real QR
/// is generated), the code in DM Mono and a caption.
class _CodePanel extends StatelessWidget {
  const _CodePanel({required this.code, required this.dimmed});

  final String code;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Semantics(
      // Read digit by digit: "Pickup code 4 8 2 9 1 3".
      label: l10n.pickupCodeSemantics(code.split('').join(' ')),
      excludeSemantics: true,
      child: Opacity(
        opacity: dimmed ? 0.45 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 22, bottom: 20),
          decoration: BoxDecoration(color: z.card, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              SvgPicture.asset('assets/pickups/qr_standin.svg', width: 150, height: 150),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatPickupCode(code),
                  style: ZadType.mono(size: 44, color: z.ink, letterSpacing: 2.64),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.pickupCodeCaption, style: ZadType.body(size: 12, color: z.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
