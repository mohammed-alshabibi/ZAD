import 'package:flutter/material.dart';

import '../../core/format/muscat_time.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/zad_button.dart';
import '../../core/widgets/zad_icon.dart';
import '../../core/widgets/zad_sheet.dart';
import '../restaurant/domain/restaurant.dart';

/// ARB labels for the admin screens.
extension AdminText on AppLocalizations {
  /// How long something has waited: "40 min", "7 h", "3 d".
  String age(DateTime since, DateTime now) {
    final minutes = now.difference(since).inMinutes.clamp(0, 1 << 30);
    if (minutes < 60) return ageMinutes(minutes);
    if (minutes < 48 * 60) return ageHours(minutes ~/ 60);
    return ageDays(minutes ~/ (24 * 60));
  }

  /// "today 14:12", "yesterday 09:30", or "18 Oct, 14:12".
  String when(DateTime at, DateTime now) {
    final time = muscatClock(at);
    return switch (muscatDaysAgo(at, now: now)) {
      0 => todayAt(time),
      1 => yesterdayAt(time),
      _ => muscatDateTime(at),
    };
  }

  /// "60 meals · usually 10–20% left", from the onboarding answers.
  String typicalDay(Restaurant r) {
    final meals = r.typicalDailyMeals;
    final pct = r.typicalSurplusPct;
    if (meals == null || pct == null) return typicalDayNone;
    final band = SurplusBand.fromPct(pct);
    return typicalDayValue(meals, band.lowPct, band.highPct);
  }
}

/// "ZAD ADMIN" kicker, big title and a sap summary line with a clock.
class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key, required this.title, required this.summary});

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adminKicker, style: ZadType.mono(size: 11, color: z.sap, letterSpacing: 1.1)),
        const SizedBox(height: 6),
        Text(title, style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card)),
        const SizedBox(height: 6),
        Row(
          children: [
            const ZadIcon(ZadIcons.clock, size: 16),
            const SizedBox(width: 6),
            Expanded(child: Text(summary, style: ZadType.body(size: 14, color: z.sap))),
          ],
        ),
      ],
    );
  }
}

/// "Are you sure?" sheet for actions that hit someone else (reject, suspend,
/// remove). Returns true when confirmed.
Future<bool> confirmAdminAction(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final l10n = AppLocalizations.of(context);
  final z = context.zad;
  final ok = await showZadSheet<bool>(
    context,
    builder: (context) => ZadSheet(
      title: title,
      subtitle: body,
      children: [
        Row(
          children: [
            Expanded(
              child: ZadButton(
                label: l10n.keepIt,
                style: ZadButtonStyle.secondary,
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ZadButton(
                label: action,
                style: ZadButtonStyle.secondary,
                labelColor: z.danger,
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Loading, error and empty states inside an admin list.
class AdminMessage extends StatelessWidget {
  const AdminMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(text, style: ZadType.body(size: 15, height: 22 / 15, color: context.zad.onFrondMuted)),
      );
}

class AdminLoading extends StatelessWidget {
  const AdminLoading({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator(color: context.zad.sap)),
      );
}
