import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';

/// Temporary stand-in for screens that are not built yet.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Scaffold(
      appBar: AppBar(backgroundColor: z.nightSheet),
      body: Center(
        child: Text(
          AppLocalizations.of(context).comingSoon(name),
          style: ZadType.body(size: 15, color: z.onFrondMuted),
        ),
      ),
    );
  }
}
