import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// One item in a bottom tab bar (user, restaurant and admin shells): 22 px
/// icon over an 11 px label, sap when active. [dot] adds the saffron
/// "something waiting" dot (Figma 8:229).
class ZadTabItem extends StatelessWidget {
  const ZadTabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.width = 64,
    this.dot = false,
  });

  final ZadIcons icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final double width;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final color = active ? z.sap : z.onFrondMuted;
    return Semantics(
      button: true,
      selected: active,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ZadIcon(icon, size: 22, color: color),
                  if (dot)
                    // 8 px saffron dot with a 2 px ring in the bar colour.
                    PositionedDirectional(
                      start: 19,
                      top: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: z.saffron,
                          shape: BoxShape.circle,
                          border: Border.all(color: z.nightSheet, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZadType.body(size: 11, weight: active ? FontWeight.w600 : FontWeight.w400, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Underline tabs (Figma "Tabs" on Pickups and Admin restaurants): equal
/// widths, a 3 px card-coloured indicator under the selected one, and a
/// hairline under the row.
class ZadUnderlineTabs extends StatelessWidget {
  const ZadUnderlineTabs({super.key, required this.selected, required this.labels, required this.onSelect});

  final int selected;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: z.nightHairline))),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            style: ZadType.body(
                              size: 16,
                              weight: i == selected ? FontWeight.w600 : FontWeight.w500,
                              color: i == selected ? z.card : z.onFrondMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          decoration: BoxDecoration(
                            color: i == selected ? z.card : z.card.withValues(alpha: 0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
