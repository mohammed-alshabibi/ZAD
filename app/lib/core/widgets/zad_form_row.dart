import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Figma component "Form row" (28:464): icon, title, one-line value and an
/// optional chevron, with a hairline underneath. The whole row is the tap target.
class ZadFormRow extends StatelessWidget {
  const ZadFormRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.chevron = true,
    this.error = false,
    this.iconColor,
    this.onTap,
  });

  /// Re-tints the icon (a `context.zad` token), e.g. sap for a done state.
  final Color? iconColor;

  /// Shows [value] in the danger colour (a required field still missing).
  final bool error;

  final ZadIcons icon;
  final String title;
  final String? value;
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: z.nightHairline))),
          child: Row(
            children: [
              ZadIcon(icon, size: 20, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ZadType.body(size: 15, weight: FontWeight.w500, color: z.card)),
                    if (value != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        value!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ZadType.body(size: 13, color: error ? z.danger : z.onFrondMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (chevron) ...[
                const SizedBox(width: 14),
                const ZadIcon(ZadIcons.chevronRight, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
