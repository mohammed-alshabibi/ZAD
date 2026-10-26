import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../domain/forecast.dart';

/// Y axis for the 7-day chart: a top line on a multiple of 5 that clears the
/// highest range (at least 10), split into 4 steps (Figma: 0–20 by 5).
({double maxY, double interval}) forecastChartScale(Iterable<Forecast> days) {
  final top = days.fold(0, (m, f) => math.max(m, math.max(f.high, f.predicted)));
  if (top <= 20) return (maxY: math.max(10, (top / 5).ceil() * 5).toDouble(), interval: 5);
  final step = ((top / 4) / 5).ceil() * 5;
  return (maxY: step * 4.0, interval: step.toDouble());
}

/// Figma "Next 7 days" chart (32:628): one bar per day for the expected
/// surplus over a P10–P90 band, tomorrow in sap and later days in rib, the
/// value above every bar, faint grid, and Fri–Sat shaded. Tapping a bar
/// shows a tooltip with the day, the expected number and the range.
class ForecastChart extends StatefulWidget {
  const ForecastChart({super.key, required this.days});

  /// Tomorrow first.
  final List<Forecast> days;

  @override
  State<ForecastChart> createState() => _ForecastChartState();
}

class _ForecastChartState extends State<ForecastChart> {
  // Figma geometry: 26 px for the y labels, 26 px of headroom for the value
  // labels, 26 px for the day labels.
  static const _axisWidth = 26.0;
  static const _headroom = 26.0;
  static const _dayLabels = 26.0;
  static const _height = 210.0;

  int? _selected;

  @override
  void didUpdateWidget(ForecastChart old) {
    super.didUpdateWidget(old);
    if (_selected != null && _selected! >= widget.days.length) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final days = widget.days;
    final scale = forecastChartScale(days);
    final summary = [
      for (final f in days)
        l10n.insightsChartDay(DateFormat('EEEE').format(f.targetDate), f.predicted, f.low, f.high),
    ].join(' ');

    return Semantics(
      label: '${l10n.insightsNext7Title}. $summary',
      child: ExcludeSemantics(
        // fl_chart always draws left to right, so the weekend shading behind
        // it is placed left to right too.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            height: _height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // spaceAround with equal group widths puts day i at the centre
                // of slot i, so the shading lines up with the bars.
                final slot = (constraints.maxWidth - _axisWidth) / days.length;
                return Stack(
                  children: [
                    for (final (start, end) in _weekendRuns(days))
                      Positioned(
                        left: _axisWidth + slot * start + 2,
                        width: slot * (end - start + 1) - 4,
                        top: _headroom,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: z.onFrondSubtle.withValues(alpha: z.onFrondSubtle.a * 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    BarChart(
                      _data(context, l10n, z, scale, slot),
                      duration: const Duration(milliseconds: 250),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Consecutive Fri–Sat days as (first, last) indexes.
  static List<(int, int)> _weekendRuns(List<Forecast> days) {
    final runs = <(int, int)>[];
    for (var i = 0; i < days.length; i++) {
      if (!days[i].isWeekend) continue;
      if (runs.isNotEmpty && runs.last.$2 == i - 1) {
        runs.last = (runs.last.$1, i);
      } else {
        runs.add((i, i));
      }
    }
    return runs;
  }

  BarChartData _data(
    BuildContext context,
    AppLocalizations l10n,
    ZadColors z,
    ({double maxY, double interval}) scale,
    double slot,
  ) {
    final days = widget.days;
    final selected = _selected;
    final muted = ZadType.mono(size: 10, weight: FontWeight.w400, color: z.onFrondMuted);

    return BarChartData(
      minY: 0,
      maxY: scale.maxY,
      alignment: BarChartAlignment.spaceAround,
      // fl_chart leaves out grid lines on the chart's edges; Figma has the 0
      // and top lines, so they are drawn as the border.
      borderData: FlBorderData(
        border: Border(
          top: BorderSide(color: z.nightHairline),
          bottom: BorderSide(color: z.nightHairline),
        ),
      ),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: scale.interval,
        getDrawingHorizontalLine: (_) => FlLine(color: z.nightHairline, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _headroom,
            getTitlesWidget: (_, _) => const SizedBox.shrink(),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _axisWidth,
            interval: scale.interval,
            getTitlesWidget: (value, _) => Align(
              alignment: Alignment.centerLeft,
              child: Text('${value.round()}', style: muted),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _dayLabels,
            getTitlesWidget: (value, _) {
              final i = value.round();
              if (i < 0 || i >= days.length) return const SizedBox.shrink();
              final tomorrow = i == 0;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  DateFormat('EEE').format(days[i].targetDate),
                  style: ZadType.body(
                    size: 11,
                    weight: tomorrow ? FontWeight.w600 : FontWeight.w400,
                    color: tomorrow ? z.card : z.onFrondMuted,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (final (i, f) in days.indexed)
          BarChartGroupData(
            x: i,
            groupVertically: true,
            // The value label sits on the band (rod 0), the selected day's
            // tooltip on the bar (rod 1). While one is selected, only its
            // tooltip shows.
            showingTooltipIndicators: switch (selected) {
              null => const [0],
              final s when s == i => const [1],
              _ => const [],
            },
            barRods: [
              BarChartRodData(
                fromY: f.low.toDouble(),
                toY: f.high.toDouble(),
                width: 30,
                color: selected == i ? z.onFrondSubtle : z.nightHairline,
                borderRadius: BorderRadius.circular(8),
              ),
              BarChartRodData(
                toY: f.predicted.toDouble(),
                width: 18,
                color: i == 0 ? z.sap : z.rib,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
      ],
      barTouchData: BarTouchData(
        handleBuiltInTouches: false,
        touchCallback: (event, _) {
          if (event is! FlTapUpEvent) return;
          // fl_chart reports positions inside the plot (after the y labels).
          final i = (event.localPosition.dx / slot).floor();
          setState(() => _selected = (i < 0 || i >= days.length || i == _selected) ? null : i);
        },
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          tooltipMargin: 2,
          tooltipBorderRadius: BorderRadius.circular(10),
          maxContentWidth: 200,
          fitInsideHorizontally: true,
          // Labels may rise into the headroom above the plot (fitting them
          // inside pushed the tallest one down onto its band).
          fitInsideVertically: false,
          direction: TooltipDirection.top,
          getTooltipColor: (group) => group.x == selected ? z.card : Colors.transparent,
          getTooltipItem: (group, _, _, _) {
            final f = days[group.x];
            if (group.x != selected) {
              return BarTooltipItem('${f.predicted}', ZadType.mono(size: 11, color: z.card));
            }
            return BarTooltipItem(
              '${DateFormat('EEE d MMM').format(f.targetDate)}\n',
              ZadType.body(size: 12, weight: FontWeight.w600, color: z.frond),
              children: [
                TextSpan(
                  text: l10n.insightsTooltipExpected(f.predicted),
                  style: ZadType.mono(size: 12, color: z.frond),
                ),
                TextSpan(
                  text: ' · ${l10n.insightsTooltipRange(f.low, f.high)}',
                  style: ZadType.body(size: 12, color: z.frond),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "View as list": the same 7 days as rows, for screen readers and anyone
/// who prefers numbers (chart rules, CLAUDE.md §14.3).
class ForecastTable extends StatelessWidget {
  const ForecastTable({super.key, required this.days});

  final List<Forecast> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final head = ZadType.body(size: 12, color: z.onFrondMuted);

    Widget row(Widget day, Widget expected, Widget range, {bool line = true}) => Container(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
          decoration: line ? BoxDecoration(border: Border(top: BorderSide(color: z.nightHairline))) : null,
          child: Row(
            children: [
              Expanded(flex: 5, child: day),
              Expanded(flex: 3, child: expected),
              Expanded(flex: 3, child: Align(alignment: AlignmentDirectional.centerEnd, child: range)),
            ],
          ),
        );

    return Column(
      children: [
        row(
          Text(l10n.insightsListDay, style: head),
          Text(l10n.insightsListExpected, style: head),
          Text(l10n.insightsListRange, style: head),
          line: false,
        ),
        for (final (i, f) in days.indexed)
          MergeSemantics(
            child: row(
              Row(
                children: [
                  Text(
                    DateFormat('EEE d MMM').format(f.targetDate),
                    style: ZadType.body(size: 14, weight: i == 0 ? FontWeight.w600 : FontWeight.w400, color: z.card),
                  ),
                  if (f.isWeekend) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(l10n.insightsListWeekend,
                          overflow: TextOverflow.ellipsis, style: ZadType.body(size: 12, color: z.onFrondMuted)),
                    ),
                  ],
                ],
              ),
              Text('~${f.predicted}', style: ZadType.mono(size: 14, color: i == 0 ? z.sap : z.card)),
              Text('${f.low}–${f.high}', style: ZadType.mono(size: 14, weight: FontWeight.w400, color: z.card)),
            ),
          ),
      ],
    );
  }
}
