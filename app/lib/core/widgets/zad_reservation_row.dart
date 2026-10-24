import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Figma component "Reservation row" (Waiting / Collected): initial avatar,
/// name + detail, and a white Confirm pill (waiting) or a Collected chip.
class ZadReservationRow extends StatelessWidget {
  const ZadReservationRow({
    super.key,
    required this.initial,
    required this.name,
    required this.detail,
    required this.collected,
    required this.confirmLabel,
    required this.collectedLabel,
    this.onConfirm,
  });

  final String initial;
  final String name;
  final String detail;
  final bool collected;
  final String confirmLabel;
  final String collectedLabel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: collected ? z.nightRaised : z.onFrondSubtle,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: ZadType.body(size: 16, weight: FontWeight.w600, color: collected ? z.onFrondMuted : z.sap),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.body(size: 15, weight: FontWeight.w500, color: z.card)),
                const SizedBox(height: 2),
                Text(detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.body(size: 13, color: z.onFrondMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (collected)
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: z.onFrondSubtle, borderRadius: BorderRadius.circular(999)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ZadIcon(ZadIcons.checkSmall, size: 14),
                  const SizedBox(width: 4),
                  Text(collectedLabel, style: ZadType.body(size: 12, weight: FontWeight.w500, color: z.sap)),
                ],
              ),
            )
          else
            Material(
              color: z.card,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onConfirm,
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 9),
                  child: Text(confirmLabel,
                      style: ZadType.body(size: 13, weight: FontWeight.w600, color: z.frond)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
