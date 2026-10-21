import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_checkbox.dart';
import '../../../core/widgets/zad_chip.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_stepper.dart';
import '../../auth/widgets/auth_layout.dart';
import '../application/my_restaurant.dart';
import '../application/onboarding_draft.dart';
import '../domain/restaurant.dart';
import 'onboarding_text.dart';

/// Figma "Onboarding — Your typical day" (38:1033), setup step 3 of 3.
/// The two answers feed the forecast's cold start (CLAUDE.md §7.3).
class TypicalDayScreen extends ConsumerStatefulWidget {
  const TypicalDayScreen({super.key});

  @override
  ConsumerState<TypicalDayScreen> createState() => _TypicalDayScreenState();
}

class _TypicalDayScreenState extends ConsumerState<TypicalDayScreen> {
  late final RestaurantDraft _start = ref.read(onboardingDraftProvider);
  late int _meals = _start.typicalDailyMeals;
  late SurplusBand? _band = _start.surplusBand;
  // Editing an existing restaurant: the terms were accepted the first time.
  late final bool _editing = ref.read(myRestaurantProvider).value != null;
  late bool _acceptedTerms = _editing;
  var _submitted = false;
  var _busy = false;

  void _step(int delta) =>
      setState(() => _meals = (_meals + delta).clamp(DailyMeals.min, DailyMeals.max));

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_band == null || !_acceptedTerms) return;

    final draftNotifier = ref.read(onboardingDraftProvider.notifier)
      ..setTypicalDay(dailyMeals: _meals, band: _band!);
    setState(() => _busy = true);
    try {
      final saved = await ref.read(myRestaurantProvider.notifier).submit(ref.read(onboardingDraftProvider));
      draftNotifier.start();
      if (mounted) context.go(routeForRestaurant(saved));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final errorStyle = ZadType.body(size: 12, height: 16 / 12, color: z.danger);

    return AuthLayout(
      glow: false,
      onBack: () => context.pop(),
      stepLabel: l10n.onboardingStep(3, 3),
      actions: [
        ZadButton(
          label: _editing ? l10n.saveChanges : l10n.submitForReview,
          loading: _busy,
          onPressed: _submit,
        ),
      ],
      children: [
        AuthTitle(l10n.typicalDayTitle, size: 28),
        const SizedBox(height: 8),
        AuthBody(l10n.typicalDayBody),
        const SizedBox(height: 22),
        _QuestionCard(
          question: l10n.mealsPerDayQuestion,
          child: ZadStepper(
            value: _meals,
            unit: l10n.mealsUnit,
            decreaseLabel: l10n.fewerMeals,
            increaseLabel: l10n.moreMeals,
            onDecrease: _meals > DailyMeals.min ? () => _step(-DailyMeals.step) : null,
            onIncrease: _meals < DailyMeals.max ? () => _step(DailyMeals.step) : null,
          ),
        ),
        const SizedBox(height: 12),
        _QuestionCard(
          question: l10n.leftOverQuestion,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final b in SurplusBand.values)
                    ZadChip(
                      label: l10n.surplusBandLabel(b),
                      active: b == _band,
                      onTap: () => setState(() => _band = b),
                    ),
                ],
              ),
              if (_submitted && _band == null) ...[
                const SizedBox(height: 10),
                Text(l10n.errorSurplusRequired, style: errorStyle),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ForecastPreview(meals: _meals, band: _band),
        const SizedBox(height: 20),
        _RestaurantTermsRow(
          accepted: _acceptedTerms,
          onChanged: (v) => setState(() => _acceptedTerms = v),
        ),
        if (_submitted && !_acceptedTerms) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 36),
            child: Text(l10n.errorRestaurantTermsRequired, style: errorStyle),
          ),
        ],
      ],
    );
  }
}

/// Night-raised card with a question on top (Figma "Meals per day", "Left over").
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.child});

  final String question;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: z.nightRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: z.nightHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: ZadType.body(size: 15, weight: FontWeight.w500, height: 20 / 15, color: z.card)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Frond card: "First forecast: ~6–12 meals a day".
class _ForecastPreview extends StatelessWidget {
  const _ForecastPreview({required this.meals, required this.band});

  final int meals;
  final SurplusBand? band;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final String title;
    final String note;
    if (band == null) {
      title = l10n.firstForecastEmptyTitle;
      note = l10n.firstForecastEmptyNote;
    } else {
      final (low, high) = firstForecastRange(meals, band!);
      title = l10n.firstForecast(low, high);
      note = l10n.firstForecastNote;
    }
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: z.frond,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: z.stem),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ZadIcon(ZadIcons.sparkles, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: ZadType.body(size: 15, weight: FontWeight.w600, height: 20 / 15, color: z.card)),
                  const SizedBox(height: 2),
                  Text(note, style: ZadType.body(size: 13, height: 18 / 13, color: z.onFrondMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Required checkbox: "I accept the Restaurant Terms. We are responsible for…" (§8.2).
class _RestaurantTermsRow extends StatefulWidget {
  const _RestaurantTermsRow({required this.accepted, required this.onChanged});

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  State<_RestaurantTermsRow> createState() => _RestaurantTermsRowState();
}

class _RestaurantTermsRowState extends State<_RestaurantTermsRow> {
  late final _termsTap = TapGestureRecognizer()..onTap = () => context.push(Routes.terms);

  @override
  void dispose() {
    _termsTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final link = ZadType.body(size: 14, weight: FontWeight.w500, height: 20 / 14, color: z.sap)
        .copyWith(decoration: TextDecoration.underline, decorationColor: z.sap);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onChanged(!widget.accepted),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(checked: widget.accepted, child: ZadCheckbox(value: widget.accepted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted),
                children: [
                  TextSpan(text: l10n.restaurantTermsPrefix),
                  TextSpan(text: l10n.restaurantTerms, style: link, recognizer: _termsTap),
                  TextSpan(text: l10n.restaurantTermsSuffix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
