import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Meal thumbnail placeholder (Figma "Thumbnail"): the warm photo gradient
/// with a faint leaf, until meal photos exist.
class ZadMealThumb extends StatelessWidget {
  const ZadMealThumb({super.key, this.size = 56, this.radius = 14, this.leafSize = 20});

  final double size;
  final double radius;
  final double leafSize;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            // Figma: 143°, stops 14% → 86%.
            begin: Alignment(-0.6, -0.8),
            end: Alignment(0.6, 0.8),
            colors: [ZadColors.mealPhotoTop, ZadColors.mealPhotoBottom],
            stops: [0.143, 0.857],
          ),
        ),
        child: Center(child: Opacity(opacity: 0.8, child: ZadIcon(ZadIcons.leaf, size: leafSize))),
      ),
    );
  }
}

enum ZadPickupStatus { collected, missed }

/// Figma component "Pickup row" (Collected / Missed): thumbnail, meal, one
/// line of detail, and a status pill. Missed is also used for cancelled.
class ZadPickupRow extends StatelessWidget {
  const ZadPickupRow({
    super.key,
    required this.meal,
    required this.detail,
    required this.status,
    required this.statusLabel,
  });

  final String meal;
  final String detail;
  final ZadPickupStatus status;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final collected = status == ZadPickupStatus.collected;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const ZadMealThumb(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal, style: ZadType.body(size: 16, weight: FontWeight.w500, color: z.card)),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.body(size: 13, color: z.onFrondMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: collected ? z.onFrondSubtle : null,
                borderRadius: BorderRadius.circular(999),
                border: collected ? null : Border.all(color: z.nightHairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (collected) ...[
                    const ZadIcon(ZadIcons.checkSmall, size: 14),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    statusLabel,
                    style: ZadType.body(size: 12, weight: FontWeight.w500, color: collected ? z.sap : z.onFrondMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
