import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/money.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_sheet.dart';
import '../application/restaurant_today.dart';
import '../data/restaurant_today_repositories.dart';
import '../domain/restaurant_reservation.dart';

/// Opens Figma "Restaurant home — Confirm pickup" (31:535). Returns the
/// collected reservation, or null if the sheet was closed.
Future<RestaurantReservation?> showConfirmPickupSheet(BuildContext context, {RestaurantReservation? expected}) =>
    showZadSheet<RestaurantReservation>(context, builder: (_) => ConfirmPickupSheet(expected: expected));

/// Staff type the customer's 6-digit code. Once it's complete the app checks
/// who it belongs to (`POST /pickups/check`) and shows the match, and only
/// then can they confirm (`POST /pickups/confirm`).
class ConfirmPickupSheet extends ConsumerStatefulWidget {
  const ConfirmPickupSheet({super.key, this.expected});

  /// Set when opened from a row's "Confirm": only used for the prompt.
  final RestaurantReservation? expected;

  static const codeLength = 6;

  @override
  ConsumerState<ConfirmPickupSheet> createState() => _ConfirmPickupSheetState();
}

class _ConfirmPickupSheetState extends ConsumerState<ConfirmPickupSheet> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  RestaurantReservation? _match;
  String? _error;
  var _checking = false;
  var _confirming = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _changed(String value) {
    setState(() {
      _match = null;
      _error = null;
    });
    if (value.length == ConfirmPickupSheet.codeLength) _check(value);
  }

  Future<void> _check(String code) async {
    setState(() => _checking = true);
    try {
      final match = await ref.read(restaurantTodayProvider.notifier).checkCode(code);
      if (mounted && _code.text == code) setState(() => _match = match);
    } on PickupException catch (e) {
      if (mounted && _code.text == code) setState(() => _error = _errorText(e));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  String _errorText(PickupException e) {
    final l10n = AppLocalizations.of(context);
    return switch (e.code) {
      PickupException.alreadyCollected => l10n.codeAlreadyCollected,
      PickupException.expired => l10n.codeExpired,
      PickupException.locked => l10n.codeLocked(muscatClock(e.retryAfter ?? DateTime.now())),
      _ => l10n.codeNotFound,
    };
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    try {
      final collected = await ref.read(restaurantTodayProvider.notifier).confirmPickup(_code.text);
      if (mounted) Navigator.pop(context, collected);
    } on PickupException catch (e) {
      if (mounted) {
        setState(() {
          _match = null;
          _error = _errorText(e);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final expected = widget.expected;

    return ZadSheet(
      title: l10n.confirmPickup,
      subtitle: expected == null ? l10n.confirmPickupBody : l10n.confirmPickupBodyFor(expected.userFirstName),
      children: [
        _CodeBoxes(
          controller: _code,
          focusNode: _focus,
          error: _error != null,
          label: l10n.pickupCodeLabel,
          onChanged: _changed,
        ),
        const SizedBox(height: 18),
        if (_match != null)
          _MatchCard(reservation: _match!)
        else if (_error != null)
          Text(_error!, style: ZadType.body(size: 14, height: 20 / 14, color: z.danger))
        else if (_checking)
          Center(child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: z.sap))),
        const SizedBox(height: 18),
        ZadButton(
          label: l10n.confirmPickup,
          loading: _confirming,
          onPressed: _match == null ? null : _confirm,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            l10n.codeLockNote,
            textAlign: TextAlign.center,
            style: ZadType.body(size: 11, color: z.onFrondMuted),
          ),
        ),
      ],
    );
  }
}

/// Six DM Mono boxes over one hidden number field (so paste and the
/// keyboard's backspace work as usual).
class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool error;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final code = value.text;
        return Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < ConfirmPickupSheet.codeLength; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: z.nightSheet,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          width: 1.5,
                          color: error
                              ? z.danger
                              : i < code.length || (focusNode.hasFocus && i == code.length)
                                  ? z.sap
                                  : z.nightHairline,
                        ),
                      ),
                      child: Text(i < code.length ? code[i] : '', style: ZadType.mono(size: 26, color: z.card)),
                    ),
                  ),
                ],
              ],
            ),
            // Invisible input covering the boxes: tapping anywhere focuses it.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(ConfirmPickupSheet.codeLength),
                  ],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  decoration: InputDecoration.collapsed(hintText: label),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Figma "Match": sap check + "Code matches · Fatema" + what to hand over.
class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.reservation});

  final RestaurantReservation reservation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final r = reservation;
    final detail = r.amountBaisa == 0
        ? l10n.codeMatchDetailFree(r.quantity, r.offerTitle)
        : l10n.codeMatchDetail(r.quantity, r.offerTitle, formatOmr(r.amountBaisa));
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: z.onFrondSubtle, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: z.sap, shape: BoxShape.circle),
              child: const ZadIcon(ZadIcons.checkLarge, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.codeMatches(r.userFirstName),
                      style: ZadType.body(size: 15, weight: FontWeight.w600, color: z.sap)),
                  const SizedBox(height: 2),
                  Text(detail, style: ZadType.body(size: 13, color: z.card)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
