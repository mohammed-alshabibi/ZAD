import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/money.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_checkbox.dart';
import '../../../core/widgets/zad_form_row.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../user/home/offer_text.dart';
import '../application/restaurant_today.dart';
import '../data/restaurant_today_repositories.dart';
import '../domain/offer_draft.dart';
import 'surplus_sheets.dart';

/// Figma "Add new surplus" (30:458): optional photo, meal name and note,
/// Category · Quantity · Price · Pickup window · Prepared at · Allergens,
/// the required food-safety check (§8.2), and a pinned "Post surplus".
///
/// A forecast never fills this in (§7.1): the owner always sets the quantity.
class AddSurplusScreen extends ConsumerStatefulWidget {
  const AddSurplusScreen({super.key});

  @override
  ConsumerState<AddSurplusScreen> createState() => _AddSurplusScreenState();
}

class _AddSurplusScreenState extends ConsumerState<AddSurplusScreen> {
  late var _draft = OfferDraft.start(DateTime.now());
  final _title = TextEditingController();
  final _note = TextEditingController();

  /// Errors are shown only after the first "Post surplus" tap.
  var _attempted = false;
  var _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  OfferDraft get _current => _draft.copyWith(title: _title.text, description: _note.text);

  Future<void> _post() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final draft = _current;
    if (draft.validate(DateTime.now()).isNotEmpty) {
      setState(() => _attempted = true);
      messenger.showSnackBar(SnackBar(content: Text(l10n.fixHighlighted)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(restaurantTodayProvider.notifier).post(draft);
      if (!mounted) return;
      context.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.posted)));
    } on OfferException catch (e) {
      _fail(e.code == OfferException.notApproved ? l10n.errorNotApproved : l10n.errorPostFailed);
    } catch (_) {
      _fail(l10n.errorPostFailed);
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _set(OfferDraft d) => setState(() => _draft = d);

  /// Before a sheet or time picker opens, so the keyboard doesn't come back
  /// over the form when it closes.
  void _closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = math.max(16.0, MediaQuery.viewPaddingOf(context).bottom);
    final errors = _attempted ? _current.validate(DateTime.now()) : const <OfferDraftError>{};
    final d = _draft;

    final String pickupValue;
    if (errors.contains(OfferDraftError.pickupOrder)) {
      pickupValue = l10n.pickupWindowOrder;
    } else if (errors.contains(OfferDraftError.pickupOver)) {
      pickupValue = l10n.pickupWindowOver;
    } else if (errors.contains(OfferDraftError.pickupTooLate)) {
      pickupValue = l10n.pickupWindowTooLate;
    } else {
      pickupValue = l10n.pickupWindowValue(muscatClock(d.pickupStart!), muscatClock(d.pickupEnd!));
    }

    final price = d.priceBaisa;
    final was = d.originalPriceBaisa;
    final priceValue = price == null
        ? l10n.setPrice
        : was == null
            ? l10n.priceLabel(price)
            : l10n.priceWithWas(l10n.priceLabel(price), formatOmrAmount(was));

    final prepared = d.preparedAt;
    final preparedValue = prepared == null
        ? l10n.preparedAtMissing
        : errors.contains(OfferDraftError.preparedAt)
            ? l10n.preparedAtInvalid
            : l10n.preparedAtValue(muscatClock(prepared));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.nightSheet,
        body: Stack(
          children: [
            ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsetsDirectional.fromSTEB(20, top + 66, 20, 130 + bottom),
              children: [
                _PhotoTile(onTap: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l10n.photosComingSoon)))),
                const SizedBox(height: 18),
                TextField(
                  controller: _title,
                  maxLength: OfferDraft.maxTitle,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  cursorColor: z.sap,
                  style: ZadType.display(size: 26, letterSpacing: -0.26, color: z.card),
                  decoration: InputDecoration.collapsed(
                    hintText: l10n.mealNameHint,
                    hintStyle: ZadType.display(size: 26, letterSpacing: -0.26, color: z.onFrondMuted),
                  ).copyWith(counterText: ''),
                ),
                if (errors.contains(OfferDraftError.title)) ...[
                  const SizedBox(height: 4),
                  Text(l10n.errorMealName, style: ZadType.body(size: 13, color: z.danger)),
                ],
                const SizedBox(height: 6),
                TextField(
                  controller: _note,
                  maxLength: OfferDraft.maxDescription,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: z.sap,
                  style: ZadType.body(size: 15, height: 21 / 15, color: z.card),
                  decoration: InputDecoration.collapsed(
                    hintText: l10n.mealNoteHint,
                    hintStyle: ZadType.body(size: 15, height: 21 / 15, color: z.onFrondMuted),
                  ).copyWith(counterText: ''),
                ),
                const SizedBox(height: 18),
                DecoratedBox(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: z.nightHairline))),
                  child: Column(
                    children: [
                      ZadFormRow(
                        icon: ZadIcons.tag,
                        title: l10n.rowCategory,
                        value: d.category == null ? l10n.chooseCategory : l10n.categoryLabel(d.category),
                        error: errors.contains(OfferDraftError.category),
                        onTap: () async {
                          _closeKeyboard();
                          final c = await showCategorySheet(context, d.category);
                          if (c != null) _set(_draft.copyWith(category: c));
                        },
                      ),
                      ZadFormRow(
                        icon: ZadIcons.package,
                        title: l10n.rowQuantity,
                        value: l10n.quantityValue(d.quantity),
                        onTap: () async {
                          _closeKeyboard();
                          final q = await showQuantitySheet(context, d.quantity);
                          if (q != null) _set(_draft.copyWith(quantity: q));
                        },
                      ),
                      ZadFormRow(
                        icon: ZadIcons.banknote,
                        title: l10n.rowPrice,
                        value: priceValue,
                        error: errors.contains(OfferDraftError.price) || errors.contains(OfferDraftError.wasPrice),
                        onTap: () async {
                          _closeKeyboard();
                          final p = await showPriceSheet(context, price: d.priceBaisa, was: d.originalPriceBaisa);
                          if (p != null) {
                            _set(_draft.copyWith(priceBaisa: () => p.price, originalPriceBaisa: () => p.was));
                          }
                        },
                      ),
                      ZadFormRow(
                        icon: ZadIcons.clock,
                        title: l10n.rowPickupWindow,
                        value: pickupValue,
                        error: errors.contains(OfferDraftError.pickupOrder) ||
                            errors.contains(OfferDraftError.pickupOver) ||
                            errors.contains(OfferDraftError.pickupTooLate),
                        onTap: () async {
                          _closeKeyboard();
                          final w = await showPickupWindowSheet(context, start: d.pickupStart!, end: d.pickupEnd!);
                          if (w != null) _set(_draft.copyWith(pickupStart: w.start, pickupEnd: w.end));
                        },
                      ),
                      ZadFormRow(
                        icon: ZadIcons.chefHat,
                        title: l10n.rowPreparedAt,
                        value: preparedValue,
                        error: errors.contains(OfferDraftError.preparedAt),
                        onTap: () async {
                          _closeKeyboard();
                          final t = await pickMuscatTime(context, d.preparedAt ?? DateTime.now());
                          if (t != null) _set(_draft.copyWith(preparedAt: t));
                        },
                      ),
                      ZadFormRow(
                        icon: ZadIcons.alert,
                        title: l10n.rowAllergens,
                        value: d.allergens.isEmpty
                            ? l10n.allergensMissing
                            : d.allergens.map(l10n.allergenLabel).join(', '),
                        error: errors.contains(OfferDraftError.allergens),
                        onTap: () async {
                          _closeKeyboard();
                          final a = await showAllergenSheet(context, d.allergens);
                          if (a != null) _set(_draft.copyWith(allergens: a));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SafetyCheck(
                  checked: d.safetyAttested,
                  error: errors.contains(OfferDraftError.safety),
                  onChanged: (v) {
                    _closeKeyboard();
                    _set(_draft.copyWith(safetyAttested: v));
                  },
                  onWhatCant: () => showCantPostSheet(context),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const ZadIcon(ZadIcons.bell, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.notifyNote, style: ZadType.body(size: 13, color: z.onFrondMuted))),
                  ],
                ),
              ],
            ),
            // Figma: title bar over the content.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                color: z.nightSheet,
                padding: EdgeInsetsDirectional.fromSTEB(16, top + 10, 16, 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Semantics(
                        button: true,
                        label: l10n.close,
                        child: Material(
                          color: z.nightRaised,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: _busy ? null : () => context.pop(),
                            child: const SizedBox.square(
                              dimension: 40,
                              child: Center(child: ZadIcon(ZadIcons.x, size: 20)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(l10n.newSurplusTitle, style: ZadType.body(size: 16, weight: FontWeight.w600, color: z.card)),
                  ],
                ),
              ),
            ),
            // Figma "Bottom fade" behind the pinned button.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 130,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [z.nightSheet.withValues(alpha: 0), z.nightSheet.withValues(alpha: 0.97), z.nightSheet],
                      stops: const [0, 0.35, 1],
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: bottom,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                  boxShadow: [BoxShadow(color: ZadColors.buttonShadow, offset: Offset(0, 6), blurRadius: 20)],
                ),
                child: ZadButton(label: l10n.postSurplus, loading: _busy, onPressed: _post),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma "Add photo": dashed 92 px tile and caption. Photos come later.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Row(
      children: [
        Semantics(
          button: true,
          label: l10n.addPhoto,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: CustomPaint(
              painter: _DashedBorder(color: z.nightHairline),
              child: const SizedBox.square(dimension: 92, child: Center(child: ZadIcon(ZadIcons.imagePlus, size: 24))),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.addPhoto, style: ZadType.body(size: 14, weight: FontWeight.w500, color: z.card)),
              const SizedBox(height: 2),
              Text(l10n.addPhotoHint, style: ZadType.body(size: 12, height: 16 / 12, color: z.onFrondMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 1.5 px dashed rounded border (Figma "Add photo").
class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)).deflate(0.75);
    for (final metric in (Path()..addRRect(rect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 5, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}

/// Figma "Safety check": the required §8.2 statement with a checkbox; sap
/// outline when checked, danger outline when missing after a Post tap.
class _SafetyCheck extends StatelessWidget {
  const _SafetyCheck({required this.checked, required this.error, required this.onChanged, required this.onWhatCant});

  final bool checked;
  final bool error;
  final ValueChanged<bool> onChanged;
  final VoidCallback onWhatCant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Semantics(
      checked: checked,
      child: Material(
        color: z.nightRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: error ? z.danger : checked ? z.sap : z.nightHairline, width: error ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(!checked),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZadCheckbox(value: checked),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.safetyCheckText, style: ZadType.body(size: 14, height: 20 / 14, color: z.card)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: onWhatCant,
                        child: Text(
                          l10n.whatCantBePosted,
                          style: ZadType.body(size: 13, weight: FontWeight.w500, color: z.sap).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: z.sap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
