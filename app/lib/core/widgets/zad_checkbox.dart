import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import 'zad_icon.dart';

/// 24 px rounded checkbox (Register terms, food-safety attestation).
/// Checked = sap fill + frond check; unchecked = muted outline.
class ZadCheckbox extends StatelessWidget {
  const ZadCheckbox({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value ? z.sap : null,
        borderRadius: BorderRadius.circular(7),
        border: value ? null : Border.all(color: z.onFrondMuted, width: 1.5),
      ),
      child: value ? const ZadIcon(ZadIcons.check, size: 16) : null,
    );
  }
}
