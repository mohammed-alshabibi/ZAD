import 'package:flutter/material.dart';

import '../../../core/format/money.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_chip.dart';
import '../../../core/widgets/zad_form_row.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_sheet.dart';
import '../../../core/widgets/zad_stepper.dart';
import '../../../core/widgets/zad_text_field.dart';
import '../../user/home/offer_text.dart';
import '../domain/offer.dart';
import '../domain/offer_draft.dart';

/// The small sheets behind each "Add new surplus" row. Each returns the new
/// value, or null when the owner closes it without choosing.

Future<OfferCategory?> showCategorySheet(BuildContext context, OfferCategory? current) {
  final l10n = AppLocalizations.of(context);
  return showZadSheet<OfferCategory>(
    context,
    builder: (context) => ZadSheet(
      title: l10n.categorySheetTitle,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in OfferCategory.values)
              ZadChip(label: l10n.categoryLabel(c), active: c == current, onTap: () => Navigator.pop(context, c)),
          ],
        ),
      ],
    ),
  );
}

Future<int?> showQuantitySheet(BuildContext context, int current) =>
    showZadSheet<int>(context, builder: (_) => _QuantitySheet(initial: current));

class _QuantitySheet extends StatefulWidget {
  const _QuantitySheet({required this.initial});

  final int initial;

  @override
  State<_QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends State<_QuantitySheet> {
  late var _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ZadSheet(
      title: l10n.quantitySheetTitle,
      subtitle: l10n.quantitySheetHint,
      children: [
        Center(
          child: ZadStepper(
            value: _value,
            unit: l10n.mealsUnit,
            decreaseLabel: l10n.decreaseQuantity,
            increaseLabel: l10n.increaseQuantity,
            onDecrease: _value <= OfferQuantity.min ? null : () => setState(() => _value--),
            onIncrease: _value >= OfferQuantity.max ? null : () => setState(() => _value++),
          ),
        ),
        const SizedBox(height: 24),
        ZadButton(label: l10n.done, onPressed: () => Navigator.pop(context, _value)),
      ],
    );
  }
}

typedef PriceChoice = ({int price, int? was});

Future<PriceChoice?> showPriceSheet(BuildContext context, {int? price, int? was}) =>
    showZadSheet<PriceChoice>(context, builder: (_) => _PriceSheet(price: price, was: was));

class _PriceSheet extends StatefulWidget {
  const _PriceSheet({required this.price, required this.was});

  final int? price;
  final int? was;

  @override
  State<_PriceSheet> createState() => _PriceSheetState();
}

class _PriceSheetState extends State<_PriceSheet> {
  late final _price = TextEditingController(
    text: widget.price == null || widget.price == 0 ? '' : formatOmrAmount(widget.price!),
  );
  late final _was = TextEditingController(text: widget.was == null ? '' : formatOmrAmount(widget.was!));
  late var _free = widget.price == 0;
  String? _priceError;
  String? _wasError;

  @override
  void dispose() {
    _price.dispose();
    _was.dispose();
    super.dispose();
  }

  void _done() {
    final l10n = AppLocalizations.of(context);
    final price = _free ? 0 : parseOmr(_price.text);
    final wasText = _was.text.trim();
    final was = wasText.isEmpty ? null : parseOmr(wasText);
    setState(() {
      _priceError = price == null || price > OfferDraft.maxPriceBaisa ? l10n.errorPriceFormat : null;
      _wasError = wasText.isEmpty
          ? null
          : was == null
              ? l10n.errorPriceFormat
              : price != null && was <= price
                  ? l10n.errorWasPrice
                  : null;
    });
    if (_priceError == null && _wasError == null) Navigator.pop(context, (price: price!, was: was));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const keyboard = TextInputType.numberWithOptions(decimal: true);
    return ZadSheet(
      title: l10n.priceSheetTitle,
      subtitle: l10n.priceSheetHint,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ZadChip(
            label: l10n.makeItFree,
            active: _free,
            onTap: () => setState(() {
              _free = !_free;
              _priceError = null;
            }),
          ),
        ),
        const SizedBox(height: 16),
        if (!_free) ...[
          ZadTextField(
            label: l10n.priceField,
            controller: _price,
            leadingIcon: ZadIcons.banknote,
            keyboardType: keyboard,
            textInputAction: TextInputAction.next,
            errorText: _priceError,
          ),
          const SizedBox(height: 16),
        ],
        ZadTextField(
          label: l10n.wasPriceField,
          controller: _was,
          keyboardType: keyboard,
          textInputAction: TextInputAction.done,
          helperText: l10n.wasPriceHelper,
          errorText: _wasError,
          onSubmitted: (_) => _done(),
        ),
        const SizedBox(height: 24),
        ZadButton(label: l10n.done, onPressed: _done),
      ],
    );
  }
}

/// A Muscat time picked on today's Muscat date (24-hour clock).
Future<DateTime?> pickMuscatTime(BuildContext context, DateTime initial) async {
  final m = toMuscat(initial);
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: m.hour, minute: m.minute),
    builder: (context, child) =>
        MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
  );
  if (picked == null) return null;
  return muscatTodayAt(picked.hour, picked.minute, now: DateTime.now());
}

typedef PickupChoice = ({DateTime start, DateTime end});

Future<PickupChoice?> showPickupWindowSheet(BuildContext context, {required DateTime start, required DateTime end}) =>
    showZadSheet<PickupChoice>(context, builder: (_) => _PickupSheet(start: start, end: end));

class _PickupSheet extends StatefulWidget {
  const _PickupSheet({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  State<_PickupSheet> createState() => _PickupSheetState();
}

class _PickupSheetState extends State<_PickupSheet> {
  late var _start = widget.start;
  late var _end = widget.end;

  /// An end time earlier than the start means after midnight.
  DateTime _afterStart(DateTime end) => end.isAfter(_start) ? end : end.add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ZadSheet(
      title: l10n.pickupSheetTitle,
      subtitle: l10n.pickupSheetHint,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: context.zad.nightHairline))),
          child: Column(
            children: [
              ZadFormRow(
                icon: ZadIcons.clock,
                title: l10n.pickupFromLabel,
                value: muscatClock(_start),
                onTap: () async {
                  final t = await pickMuscatTime(context, _start);
                  if (t == null) return;
                  final length = _end.difference(_start);
                  setState(() {
                    _start = t;
                    // Keep the same length when the start moves.
                    _end = t.add(length);
                  });
                },
              ),
              ZadFormRow(
                icon: ZadIcons.clock,
                title: l10n.pickupUntilLabel,
                value: muscatClock(_end),
                onTap: () async {
                  final t = await pickMuscatTime(context, _end);
                  if (t != null) setState(() => _end = _afterStart(t));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ZadButton(label: l10n.done, onPressed: () => Navigator.pop(context, (start: _start, end: _end))),
      ],
    );
  }
}

Future<List<String>?> showAllergenSheet(BuildContext context, List<String> current) =>
    showZadSheet<List<String>>(context, builder: (_) => _AllergenSheet(initial: current));

class _AllergenSheet extends StatefulWidget {
  const _AllergenSheet({required this.initial});

  final List<String> initial;

  @override
  State<_AllergenSheet> createState() => _AllergenSheetState();
}

class _AllergenSheetState extends State<_AllergenSheet> {
  late final _picked = {...widget.initial};

  void _toggle(String a) => setState(() {
        if (a == Allergens.none) {
          // "None" stands alone.
          final wasOn = _picked.contains(a);
          _picked.clear();
          if (!wasOn) _picked.add(a);
        } else {
          _picked.remove(Allergens.none);
          if (!_picked.remove(a)) _picked.add(a);
        }
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ZadSheet(
      title: l10n.allergenSheetTitle,
      subtitle: l10n.allergenSheetHint,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in [...Allergens.all, Allergens.none])
              ZadChip(label: l10n.allergenLabel(a), active: _picked.contains(a), onTap: () => _toggle(a)),
          ],
        ),
        const SizedBox(height: 24),
        ZadButton(
          label: l10n.done,
          onPressed: _picked.isEmpty
              ? null
              : () => Navigator.pop(context, [
                    // Keep the list order, not the tap order.
                    for (final a in [...Allergens.all, Allergens.none])
                      if (_picked.contains(a)) a,
                  ]),
        ),
      ],
    );
  }
}

/// §8.2 "What can't be posted?" list.
Future<void> showCantPostSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final z = context.zad;
  return showZadSheet<void>(
    context,
    builder: (context) => ZadSheet(
      title: l10n.cantPostTitle,
      children: [
        for (final item in [l10n.cantPostPlate, l10n.cantPostOpened, l10n.cantPostExpired, l10n.cantPostHomemade])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: ZadIcon(ZadIcons.x, size: 16, color: z.danger),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: ZadType.body(size: 15, height: 21 / 15, color: z.card))),
              ],
            ),
          ),
        const SizedBox(height: 12),
        ZadButton(label: l10n.gotIt, style: ZadButtonStyle.secondary, onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}
