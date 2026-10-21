import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_chip.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_text_field.dart';
import '../../auth/widgets/auth_layout.dart';
import '../application/onboarding_draft.dart';
import '../domain/restaurant.dart';
import 'onboarding_text.dart';

/// Figma "Onboarding — Restaurant details" (38:768), setup step 1 of 3.
class RestaurantDetailsScreen extends ConsumerStatefulWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  ConsumerState<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends ConsumerState<RestaurantDetailsScreen> {
  late final RestaurantDraft _start = ref.read(onboardingDraftProvider);
  late final _name = TextEditingController(text: _start.name);
  // Most numbers are local, so the country code is filled in.
  late final _phone = TextEditingController(text: _start.phone.isEmpty ? '+968 ' : _start.phone);
  late final _description = TextEditingController(text: _start.description);
  late Cuisine? _cuisine = _start.cuisine;
  late bool _showAllCuisines = _cuisine != null && !Cuisine.main.contains(_cuisine);
  var _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    final invalid = RestaurantValidators.name(_name.text) != null ||
        RestaurantValidators.cuisine(_cuisine) != null ||
        RestaurantValidators.phone(_phone.text) != null ||
        RestaurantValidators.description(_description.text) != null;
    if (invalid) return;

    ref.read(onboardingDraftProvider.notifier).setDetails(
          name: _name.text.trim(),
          cuisine: _cuisine!,
          phone: normalizeOmanPhone(_phone.text),
          description: _description.text.trim(),
        );
    context.push(Routes.restaurantOnboardingLocation);
  }

  void _refresh(String _) {
    if (_submitted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    String? check(RestaurantFieldError? e) => _submitted ? l10n.restaurantFieldError(e) : null;
    final cuisineError = check(RestaurantValidators.cuisine(_cuisine));
    final cuisines = _showAllCuisines ? Cuisine.values : Cuisine.main;

    return AuthLayout(
      glow: false,
      // Right after signup there is nothing to go back to; when editing there is.
      onBack: context.canPop() ? context.pop : null,
      stepLabel: l10n.onboardingStep(1, 3),
      actions: [ZadButton(label: l10n.continueLabel, onPressed: _continue)],
      children: [
        AuthTitle(l10n.detailsTitle, size: 28),
        const SizedBox(height: 8),
        AuthBody(l10n.detailsBody),
        const SizedBox(height: 22),
        _LogoRow(
          title: l10n.addLogo,
          hint: l10n.addLogoHint,
          // Photos are optional and first in the cut order (CLAUDE.md §10).
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.logoComingSoon))),
        ),
        const SizedBox(height: 20),
        ZadTextField(
          label: l10n.fieldRestaurantName,
          controller: _name,
          leadingIcon: ZadIcons.storeSmall,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          errorText: check(RestaurantValidators.name(_name.text)),
          onChanged: _refresh,
        ),
        const SizedBox(height: 16),
        Text(l10n.fieldCuisine, style: ZadType.body(size: 13, weight: FontWeight.w500, color: z.onFrondMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in cuisines)
              ZadChip(
                label: l10n.cuisineLabel(c),
                active: c == _cuisine,
                onTap: () => setState(() => _cuisine = c),
              ),
            if (!_showAllCuisines)
              ZadChip(label: l10n.cuisineMore, onTap: () => setState(() => _showAllCuisines = true)),
          ],
        ),
        if (cuisineError != null) ...[
          const SizedBox(height: 8),
          Text(cuisineError, style: ZadType.body(size: 12, height: 16 / 12, color: z.danger)),
        ],
        const SizedBox(height: 16),
        ZadTextField(
          label: l10n.fieldPhone,
          controller: _phone,
          leadingIcon: ZadIcons.phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          helperText: l10n.phoneHelper,
          errorText: check(RestaurantValidators.phone(_phone.text)),
          onChanged: _refresh,
        ),
        const SizedBox(height: 16),
        ZadTextField(
          label: l10n.fieldDescription,
          controller: _description,
          leadingIcon: ZadIcons.chefHat,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          errorText: check(RestaurantValidators.description(_description.text)),
          onChanged: _refresh,
          onSubmitted: (_) => _continue(),
        ),
      ],
    );
  }
}

/// Dashed 72 px "Add logo" tile with its caption (optional, not wired yet).
class _LogoRow extends StatelessWidget {
  const _LogoRow({required this.title, required this.hint, required this.onTap});

  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            CustomPaint(
              painter: _DashedBorderPainter(color: z.nightHairline),
              child: const SizedBox.square(
                dimension: 72,
                child: Center(child: ZadIcon(ZadIcons.imagePlus, size: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ZadType.body(size: 14, weight: FontWeight.w500, color: z.card)),
                  const SizedBox(height: 2),
                  Text(hint, style: ZadType.body(size: 12, height: 16 / 12, color: z.onFrondMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1.5 px dashed rounded border (radius 18), as on the Figma logo tile.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.5;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18 - stroke / 2)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    const dash = 4.5;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
