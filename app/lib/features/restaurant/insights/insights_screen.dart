import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_fact_chip.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_tabs.dart';
import '../application/insights.dart';
import '../domain/forecast.dart';
import 'forecast_chart.dart';

/// Figma "Insights: AI forecast" (32:601), the restaurant's Insights tab
/// (CLAUDE.md §7.6): tomorrow's surplus with its range and confidence, the
/// 7-day chart, why, a suggestion, how accurate it has been, and a nudge to
/// log yesterday. A forecast is advice only: it never posts meals.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final async = ref.watch(insightsViewProvider);
    final insights = async.value;

    return RefreshIndicator(
      color: z.frond,
      backgroundColor: z.sap,
      onRefresh: () => ref.read(insightsProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 16, 20, 28),
        children: [
          Text(l10n.tabInsights, style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card)),
          const SizedBox(height: 16),
          ZadUnderlineTabs(
            selected: _tab,
            labels: [l10n.insightsTabForecast, l10n.insightsTabImpact],
            onSelect: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 16),
          if (_tab == 1)
            _Note(text: l10n.insightsImpactSoon)
          else if (insights == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: async.hasError
                    ? Text(l10n.errorLoadInsights,
                        textAlign: TextAlign.center, style: ZadType.body(size: 14, color: z.danger))
                    : CircularProgressIndicator(color: z.sap),
              ),
            )
          else
            ..._forecast(context, l10n, insights),
        ],
      ),
    );
  }

  List<Widget> _forecast(BuildContext context, AppLocalizations l10n, Insights insights) {
    final tomorrow = insights.tomorrow;
    const gap = SizedBox(height: 16);
    return [
      if (tomorrow == null)
        _Note(text: l10n.insightsNoForecast)
      else ...[
        _TomorrowCard(forecast: tomorrow),
        gap,
        _NextDaysCard(days: insights.next7),
        if (_reasons(l10n, tomorrow).isNotEmpty) ...[
          gap,
          _Reasons(labels: _reasons(l10n, tomorrow)),
        ],
        gap,
        _SuggestionCard(forecast: tomorrow, onPost: () => context.push(Routes.restaurantNewOffer)),
        gap,
        _AccuracyLine(error: insights.recentError),
      ],
      gap,
      _LogYesterdayCard(insights: insights, onTap: () => context.push(Routes.restaurantDailyLog)),
    ];
  }

  /// Chip text for each reason the app knows; unknown codes are skipped.
  static List<String> _reasons(AppLocalizations l10n, Forecast f) => [
        for (final r in f.explanations)
          ?switch (r.code) {
            ForecastReason.weekdayHigher when r.weekday != null && r.pct != null =>
              l10n.reasonWeekdayHigher(_weekdayKey(r.weekday!), r.pct!),
            ForecastReason.weekdayLower when r.weekday != null && r.pct != null =>
              l10n.reasonWeekdayLower(_weekdayKey(r.weekday!), r.pct!),
            ForecastReason.daysLogged when r.days != null => l10n.reasonDaysLogged(r.days!),
            ForecastReason.weekdayAverage when r.weeks != null => l10n.reasonWeekdayAverage(r.weeks!),
            ForecastReason.ramadan => l10n.reasonRamadan,
            ForecastReason.holiday => l10n.reasonHoliday,
            ForecastReason.coldStart => l10n.reasonColdStart,
            _ => null,
          },
      ];

  static String _weekdayKey(int weekday) =>
      const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][(weekday - 1).clamp(0, 6)];
}

/// Night-raised card used across the tab.
BoxDecoration _card(ZadColors z) => BoxDecoration(
      color: z.nightRaised,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: z.nightHairline),
    );

class _TomorrowCard extends StatelessWidget {
  const _TomorrowCard({required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final f = forecast;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _card(z),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.insightsTomorrowKicker(DateFormat('EEEE').format(f.targetDate).toUpperCase()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZadType.mono(size: 11, letterSpacing: 1.1, color: z.sap),
                ),
              ),
              const SizedBox(width: 8),
              ConfidencePill(forecast: f),
            ],
          ),
          const SizedBox(height: 6),
          MergeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('~${f.predicted}', style: ZadType.mono(size: 56, letterSpacing: -1.68, color: z.card)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(l10n.insightsExpected(f.predicted),
                      style: ZadType.body(size: 15, color: z.onFrondMuted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(l10n.insightsLikelyRange(f.low, f.high), style: ZadType.body(size: 14, color: z.card)),
        ],
      ),
    );
  }
}

/// Figma "Confidence": up to three dots plus the level in words, so the
/// level never relies on colour alone. A cold start reads "Rough estimate".
class ConfidencePill extends StatelessWidget {
  const ConfidencePill({super.key, required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final label = forecast.isRoughEstimate
        ? l10n.confidencePillRough
        : switch (forecast.confidence) {
            ForecastConfidence.low => l10n.confidencePillLow,
            ForecastConfidence.medium => l10n.confidencePillMedium,
            ForecastConfidence.high => l10n.confidencePillHigh,
          };
    final filled = forecast.isRoughEstimate ? 1 : forecast.confidence.dots;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: z.nightHairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: i < filled ? z.sap : z.nightHairline),
            ),
          ],
          const SizedBox(width: 6),
          Text(label, style: ZadType.body(size: 12, color: z.card)),
        ],
      ),
    );
  }
}

class _NextDaysCard extends StatefulWidget {
  const _NextDaysCard({required this.days});

  final List<Forecast> days;

  @override
  State<_NextDaysCard> createState() => _NextDaysCardState();
}

class _NextDaysCardState extends State<_NextDaysCard> {
  var _asList = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _card(z),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(l10n.insightsNext7Title,
                    style: ZadType.body(size: 16, weight: FontWeight.w600, color: z.card)),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                child: InkWell(
                  onTap: () => setState(() => _asList = !_asList),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      _asList ? l10n.insightsViewAsChart : l10n.insightsViewAsList,
                      style: ZadType.body(size: 13, weight: FontWeight.w500, color: z.sap),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _asList ? l10n.insightsListNote : '${l10n.insightsNext7Note} · ${l10n.insightsChartHint}',
            style: ZadType.body(size: 12, color: z.onFrondMuted),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _asList
                ? ForecastTable(key: const ValueKey('list'), days: widget.days)
                : ForecastChart(key: const ValueKey('chart'), days: widget.days),
          ),
        ],
      ),
    );
  }
}

class _Reasons extends StatelessWidget {
  const _Reasons({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.insightsWhyTitle, style: ZadType.body(size: 16, weight: FontWeight.w600, color: z.card)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final l in labels) ZadFactChip(label: l)]),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.forecast, required this.onPost});

  final Forecast forecast;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final day = DateFormat('EEEE').format(forecast.targetDate);
    final cut = suggestedCut(forecast);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: z.onFrondSubtle, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ZadIcon(ZadIcons.sparkles, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cut == null ? l10n.insightsSuggestionLow(day) : l10n.insightsSuggestion(cut, day),
                  style: ZadType.body(size: 15, height: 21 / 15, color: z.card),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Opens Add surplus empty: the forecast never fills in a quantity.
          _SapOutlinePill(label: l10n.insightsPostNow, onTap: onPost),
          const SizedBox(height: 12),
          Text(l10n.insightsNeverPosts, style: ZadType.body(size: 12, color: z.onFrondMuted)),
        ],
      ),
    );
  }
}

/// Figma "Post surplus now": 44 px pill with a sap outline, plus icon and label.
class _SapOutlinePill extends StatelessWidget {
  const _SapOutlinePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: z.sap)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 44,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZadIcon(ZadIcons.plus, size: 18, color: z.sap),
                const SizedBox(width: 8),
                Text(label, style: ZadType.body(size: 14, weight: FontWeight.w500, color: z.sap)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccuracyLine extends StatelessWidget {
  const _AccuracyLine({required this.error});

  /// Average meals off per day, or null with too few days to compare.
  final double? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final e = error;
    if (e == null) {
      return Text(l10n.insightsAccuracyNotYet, style: ZadType.body(size: 14, color: z.onFrondMuted));
    }
    return Row(
      children: [
        ZadIcon(ZadIcons.check, size: 16, color: z.sap),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            e < 1 ? l10n.insightsAccuracyUnderOne : l10n.insightsAccuracy(e.round()),
            style: ZadType.body(size: 14, color: z.card),
          ),
        ),
      ],
    );
  }
}

class _LogYesterdayCard extends StatelessWidget {
  const _LogYesterdayCard({required this.insights, required this.onTap});

  final Insights insights;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final day = DateFormat('EEEE').format(insights.yesterday);
    final log = insights.yesterdayLog;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(z),
      child: Column(
        children: [
          MergeSemantics(
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: z.nightSheet, borderRadius: BorderRadius.circular(14)),
                  child: log == null
                      ? const ZadIcon(ZadIcons.package, size: 22)
                      : ZadIcon(ZadIcons.checkLarge, size: 22, color: z.sap),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log == null ? l10n.insightsLogYesterday(day) : l10n.insightsYesterdayLogged(day),
                        style: ZadType.body(size: 15, weight: FontWeight.w500, color: z.card),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        log == null
                            ? l10n.insightsLogYesterdayNote
                            : l10n.loggedNumbers(log.mealsPrepared, log.mealsSurplus),
                        style: ZadType.body(size: 13, color: z.onFrondMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ZadButton(
            label: log == null ? l10n.insightsLogNow : l10n.insightsEditLog,
            style: log == null ? ZadButtonStyle.primary : ZadButtonStyle.secondary,
            height: 46,
            labelSize: 15,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _card(z),
      child: Text(text, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
    );
  }
}
