import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'pickup_window_bar.dart';
import 'zad_icon.dart';

/// Figma component "Offer photo card" (7:70): the floating card shown over
/// the map when a pin is selected. Photo area (a placeholder until meal
/// photos exist), urgency tag, restaurant, meal line, pickup status,
/// pickup-window bar and fact chips. All text comes in already translated.
///
/// Ratings, save and share from the Figma card are left out: they are out of
/// scope (CLAUDE.md §1.3).
class ZadOfferPhotoCard extends StatelessWidget {
  const ZadOfferPhotoCard({
    super.key,
    required this.restaurant,
    required this.details,
    required this.statusLabel,
    required this.untilLabel,
    required this.windowStartLabel,
    required this.windowEndLabel,
    required this.pickupStart,
    required this.pickupEnd,
    required this.now,
    required this.priceLabel,
    required this.mealsLeftLabel,
    required this.placeholderLabel,
    this.wasPriceLabel,
    this.tagText,
    this.onTap,
  });

  final String restaurant;

  /// "Zaatar manakish box · 0.6 km · 8 min walk".
  final String details;

  /// "Pickup now" (sap) or "Pickup from 21:15".
  final String statusLabel;

  /// "until 21:40".
  final String untilLabel;
  final String windowStartLabel;
  final String windowEndLabel;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final DateTime now;
  final String priceLabel;
  final String? wasPriceLabel;
  final String mealsLeftLabel;

  /// Shown in the photo area while there is no photo (the meal category).
  final String placeholderLabel;

  /// Saffron "28 min left" tag; null when not closing soon.
  final String? tagText;
  final VoidCallback? onTap;

  static const double photoHeight = 148;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final started = !now.isBefore(pickupStart);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: ZadColors.cardShadow, offset: Offset(0, 10), blurRadius: 30)],
      ),
      child: Material(
        color: z.nightRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: z.nightHairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Photo(label: placeholderLabel, tagText: tagText),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZadType.display(size: 21, letterSpacing: -0.21, color: z.card),
                    ),
                    const SizedBox(height: 6),
                    // One line keeps every card in the row the same height.
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZadType.body(size: 13, color: z.onFrondMuted),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: statusLabel,
                          style: ZadType.body(size: 13, weight: FontWeight.w500, color: started ? z.sap : z.card),
                        ),
                        // Figma: 6 px gaps around the dot.
                        const WidgetSpan(child: SizedBox(width: 6)),
                        TextSpan(text: '·', style: ZadType.body(size: 13, color: z.onFrondMuted)),
                        const WidgetSpan(child: SizedBox(width: 6)),
                        TextSpan(text: untilLabel, style: ZadType.body(size: 13, color: z.card)),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(windowStartLabel, style: ZadType.mono(size: 10, weight: FontWeight.w400, color: z.onFrondMuted)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PickupWindowBar(start: pickupStart, end: pickupEnd, now: now, showNow: true),
                          ),
                          const SizedBox(width: 8),
                          Text(windowEndLabel, style: ZadType.mono(size: 10, weight: FontWeight.w400, color: z.onFrondMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 4),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _FactChip(children: [
                            Text(priceLabel, style: ZadType.mono(size: 12, color: z.card)),
                            if (wasPriceLabel != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                wasPriceLabel!,
                                style: ZadType.mono(size: 11, weight: FontWeight.w400, color: z.onFrondMuted)
                                    .copyWith(decoration: TextDecoration.lineThrough, decorationColor: z.onFrondMuted),
                              ),
                            ],
                          ]),
                          _FactChip(children: [Text(mealsLeftLabel, style: ZadType.mono(size: 12, color: z.card))]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.label, required this.tagText});

  final String label;
  final String? tagText;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      height: ZadOfferPhotoCard.photoHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // Figma: 161.8°, stops 14% → 86%.
          begin: Alignment(-0.33, -1),
          end: Alignment(0.33, 1),
          colors: [ZadColors.photoPlaceholderTop, ZadColors.photoPlaceholderBottom],
          stops: [0.143, 0.857],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ZadIcon(ZadIcons.image, size: 22),
                const SizedBox(height: 4),
                Text(label, style: ZadType.body(size: 11, color: z.onFrondMuted)),
              ],
            ),
          ),
          if (tagText != null)
            PositionedDirectional(
              start: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: z.saffron, borderRadius: BorderRadius.circular(8)),
                child: Text(tagText!, style: ZadType.mono(size: 11, color: z.ink)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Figma "Fact chip" on the dark card: hairline pill around mono text.
class _FactChip extends StatelessWidget {
  const _FactChip({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.zad.nightHairline),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
