import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_form_row.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_sheet.dart';
import '../../../core/widgets/zad_stepper.dart';
import '../../auth/widgets/auth_layout.dart';
import '../application/insights.dart';
import '../application/my_restaurant.dart';
import '../domain/daily_log.dart';
import '../domain/forecast.dart';

/// Figma "Daily log" (46:931), opened from Insights' "Log yesterday": meals
/// prepared and left over at closing (left over ≤ prepared), how far the
/// forecast was off, and "Earlier days" to fix a missed or wrong day.
/// Save log → `PUT /daily-logs/{date}`.
class DailyLogScreen extends ConsumerStatefulWidget {
  const DailyLogScreen({super.key});

  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  /// Null until the logs have loaded; then yesterday, or a day picked in
  /// "Earlier days".
  DateTime? _date;
  var _prepared = 0;
  var _surplus = 0;
  var _saving = false;

  /// Fills the form for [date] (see [dailyLogStart]).
  void _start(DateTime date, InsightsData data) {
    final r = ref.read(myRestaurantProvider).value;
    final start = dailyLogStart(
      date: date,
      logs: data.logs,
      typicalDailyMeals: r?.typicalDailyMeals,
      typicalSurplusPct: r?.typicalSurplusPct,
    );
    _date = date;
    _prepared = math.min(start.prepared, DailyLogRules.maxMeals);
    _surplus = math.min(start.surplus, _prepared);
  }

  Future<void> _pickEarlierDay(InsightsData data, DateTime today) async {
    final picked = await showZadSheet<DateTime>(
      context,
      builder: (_) => _EarlierDaysSheet(today: today, logs: data.logs, current: _date!),
    );
    if (picked == null || !mounted) return;
    setState(() => _start(picked, data));
    // Bring the title ("Log Saturday") back into view so the change is clear.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final title = _titleKey.currentContext;
      if (title != null && title.mounted) {
        Scrollable.ensureVisible(title, duration: const Duration(milliseconds: 250));
      }
    });
  }

  final _titleKey = GlobalKey();

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final date = _date!;
    setState(() => _saving = true);
    try {
      await ref.read(insightsProvider.notifier).saveLog(date, prepared: _prepared, surplus: _surplus);
      messenger.showSnackBar(SnackBar(content: Text(l10n.dailyLogSaved(DateFormat('EEEE').format(date)))));
      if (mounted) context.pop();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.dailyLogSaveError)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final today = muscatToday(ref.now);
    final yesterday = today.subtract(const Duration(days: 1));
    final data = ref.watch(insightsProvider).value;
    if (data != null && _date == null) _start(yesterday, data);
    final date = _date;

    final errors = date == null
        ? const <DailyLogError>{}
        : DailyLogRules.validate(date: date, prepared: _prepared, surplus: _surplus, now: ref.now);

    return AuthLayout(
      glow: false,
      onBack: () => context.pop(),
      stepLabel: l10n.dailyLogHeader,
      actions: [
        ZadButton(
          label: l10n.dailyLogSave,
          loading: _saving,
          onPressed: date == null || errors.isNotEmpty ? null : _save,
        ),
      ],
      children: date == null || data == null
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator(color: z.sap)),
              ),
            ]
          : _form(l10n, z, data, date, isSameDate(date, yesterday), today),
    );
  }

  List<Widget> _form(
    AppLocalizations l10n,
    ZadColors z,
    InsightsData data,
    DateTime date,
    bool isYesterday,
    DateTime today,
  ) {
    final weekday = DateFormat('EEEE').format(date);
    final atLimit = _surplus >= _prepared;
    final predicted = data.forecasts.where((f) => isSameDate(f.targetDate, date)).firstOrNull;

    return [
      Text(
        key: _titleKey,
        isYesterday ? l10n.dailyLogTitleYesterday : l10n.dailyLogTitleDay(weekday),
        style: ZadType.display(size: 28, height: 34 / 28, color: z.card),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.dailyLogIntro(DateFormat('EEEE d MMM').format(date)),
        style: ZadType.body(size: 15, height: 22 / 15, color: z.onFrondMuted),
      ),
      const SizedBox(height: 18),
      _StepperCard(
        title: isYesterday ? l10n.dailyLogPreparedYesterday : l10n.dailyLogPreparedOn(weekday),
        stepper: ZadStepper(
          value: _prepared,
          unit: l10n.mealsUnit,
          decreaseLabel: l10n.dailyLogFewerPrepared,
          increaseLabel: l10n.dailyLogMorePrepared,
          // Can't go below what was left over (lower that first).
          onDecrease: _prepared > _surplus ? () => setState(() => _prepared--) : null,
          onIncrease: _prepared < DailyLogRules.maxMeals ? () => setState(() => _prepared++) : null,
        ),
      ),
      const SizedBox(height: 10),
      _StepperCard(
        title: l10n.dailyLogLeftOver,
        stepper: ZadStepper(
          value: _surplus,
          unit: l10n.mealsUnit,
          decreaseLabel: l10n.dailyLogFewerLeft,
          increaseLabel: l10n.dailyLogMoreLeft,
          onDecrease: _surplus > 0 ? () => setState(() => _surplus--) : null,
          onIncrease: atLimit ? null : () => setState(() => _surplus++),
        ),
        footer: [
          Text(l10n.dailyLogLeftOverHelp, style: ZadType.body(size: 13, height: 18 / 13, color: z.onFrondMuted)),
          const SizedBox(height: 14),
          Semantics(
            liveRegion: true,
            child: Text(
              atLimit && _prepared > 0
                  ? l10n.dailyLogLeftOverMax
                  : l10n.dailyLogShare(_surplus, _prepared, DailyLogRules.surplusPct(_prepared, _surplus)),
              style: atLimit && _prepared > 0
                  ? ZadType.body(size: 13, color: z.card)
                  : ZadType.mono(size: 13, color: z.sap),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _ForecastCheck(
        predicted: predicted,
        surplus: _surplus,
        daysLogged: data.logs.length,
        dayWord: isYesterday ? l10n.dailyLogYesterdayWord : weekday,
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: z.nightRaised, borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: ZadFormRow(
          icon: ZadIcons.clock,
          title: l10n.dailyLogEarlier,
          value: l10n.dailyLogEarlierNote,
          onTap: () => _pickEarlierDay(data, today),
        ),
      ),
    ];
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({required this.title, required this.stepper, this.footer = const []});

  final String title;
  final Widget stepper;
  final List<Widget> footer;

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
          Text(title, style: ZadType.body(size: 15, height: 20 / 15, weight: FontWeight.w500, color: z.card)),
          const SizedBox(height: 14),
          stepper,
          if (footer.isNotEmpty) ...[const SizedBox(height: 14), ...footer],
        ],
      ),
    );
  }
}

/// Figma "Forecast check": how far the forecast for this day was from what
/// is being logged, updated as the numbers change.
class _ForecastCheck extends StatelessWidget {
  const _ForecastCheck({
    required this.predicted,
    required this.surplus,
    required this.daysLogged,
    required this.dayWord,
  });

  final Forecast? predicted;
  final int surplus;
  final int daysLogged;

  /// "yesterday" or the weekday.
  final String dayWord;

  /// Logs before the forecast switches from the cold start to the user's own
  /// numbers (§7.3).
  static const _learnsAfter = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final p = predicted;
    final learning = daysLogged >= _learnsAfter;
    final (title, body) = p == null
        ? (
            l10n.dailyLogNoGuessTitle(daysLogged),
            learning ? l10n.dailyLogNoGuessBody : l10n.dailyLogAfter14,
          )
        : (
            l10n.dailyLogGuessed(p.predicted, dayWord),
            '${l10n.dailyLogOffBy((surplus - p.predicted).abs())} '
                '${learning ? l10n.dailyLogLearning(daysLogged) : l10n.dailyLogWarmingUp(daysLogged)}',
          );
    return MergeSemantics(
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
                  Text(title, style: ZadType.body(size: 15, height: 20 / 15, weight: FontWeight.w600, color: z.card)),
                  const SizedBox(height: 2),
                  Text(body, style: ZadType.body(size: 13, height: 18 / 13, color: z.onFrondMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Earlier days": the last 14 days, logged or not; tap one to log or fix it.
class _EarlierDaysSheet extends StatelessWidget {
  const _EarlierDaysSheet({required this.today, required this.logs, required this.current});

  final DateTime today;
  final List<DailyLog> logs;
  final DateTime current;

  static const _days = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ZadSheet(
      title: l10n.dailyLogEarlier,
      subtitle: l10n.dailyLogEarlierSubtitle,
      children: [
        for (var i = 1; i <= _days; i++)
          () {
            final day = today.subtract(Duration(days: i));
            final log = logs.where((l) => isSameDate(l.date, day)).firstOrNull;
            return ZadFormRow(
              icon: log == null ? ZadIcons.clock : ZadIcons.checkLarge,
              iconColor: log == null ? null : context.zad.sap,
              title: DateFormat('EEEE d MMM').format(day),
              value: log == null ? l10n.dailyLogNotLogged : l10n.loggedNumbers(log.mealsPrepared, log.mealsSurplus),
              chevron: !isSameDate(day, current),
              onTap: () => Navigator.of(context).pop(day),
            );
          }(),
      ],
    );
  }
}
