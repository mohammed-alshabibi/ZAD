import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/muscat_time.dart';
import '../../../core/time/clock.dart';
import '../data/daily_logs_repository.dart';
import '../data/restaurant_today_repositories.dart';
import '../domain/daily_log.dart';
import '../domain/forecast.dart';
import 'my_restaurant.dart';

/// Everything on the Insights "Forecast" tab (Figma 32:601, CLAUDE.md §7.6).
class Insights {
  const Insights({
    required this.next7,
    required this.today,
    required this.recentError,
    required this.yesterdayLog,
    required this.daysLogged,
  });

  /// The coming days, tomorrow first (up to 7).
  final List<Forecast> next7;

  /// Today's Muscat date (date only).
  final DateTime today;

  /// Average meals the forecast was off by per day over the last 2 weeks,
  /// or null with fewer than [minDaysForAccuracy] days to compare.
  final double? recentError;

  final DailyLog? yesterdayLog;
  final int daysLogged;

  Forecast? get tomorrow => next7.firstOrNull;
  DateTime get yesterday => today.subtract(const Duration(days: 1));

  static const minDaysForAccuracy = 3;
}

Insights buildInsights({required List<Forecast> forecasts, required List<DailyLog> logs, required DateTime now}) {
  final today = muscatToday(now);
  final next7 = [for (final f in forecasts) if (f.targetDate.isAfter(today)) f]
    ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  final yesterday = today.subtract(const Duration(days: 1));
  return Insights(
    next7: next7.take(7).toList(),
    today: today,
    recentError: forecastError(forecasts: forecasts, logs: logs, now: now),
    yesterdayLog: logs.where((l) => isSameDate(l.date, yesterday)).firstOrNull,
    daysLogged: logs.length,
  );
}

/// Mean absolute error (meals a day) of the stored forecasts against the logs
/// over the last [days] days (§7.4). Null with too little to compare.
double? forecastError({
  required List<Forecast> forecasts,
  required List<DailyLog> logs,
  required DateTime now,
  int days = 14,
}) {
  final today = muscatToday(now);
  final from = today.subtract(Duration(days: days));
  final errors = [
    for (final log in logs)
      if (!log.date.isBefore(from) && log.date.isBefore(today))
        for (final f in forecasts)
          if (isSameDate(f.targetDate, log.date)) (f.predicted - log.mealsSurplus).abs(),
  ];
  if (errors.length < Insights.minDaysForAccuracy) return null;
  return errors.reduce((a, b) => a + b) / errors.length;
}

/// The suggestion card (§7.6): prepare about this many fewer portions. The
/// low end of the likely range, since that many are probably left over anyway.
/// Null when so little is expected that cutting isn't worth suggesting.
int? suggestedCut(Forecast f) => f.low >= 2 ? f.low : null;

/// What the Daily log form starts with for [date]: that day's log if there
/// is one, else the same weekday a week before (Fridays look like Fridays),
/// else the most recent earlier day, else the onboarding answers. Often the
/// owner only adjusts a number or two.
({int prepared, int surplus}) dailyLogStart({
  required DateTime date,
  required List<DailyLog> logs,
  int? typicalDailyMeals,
  int? typicalSurplusPct,
}) {
  final same = logs.where((l) => isSameDate(l.date, date)).firstOrNull;
  if (same != null) return (prepared: same.mealsPrepared, surplus: same.mealsSurplus);
  final weekAgo = date.subtract(const Duration(days: 7));
  final lastWeek = logs.where((l) => isSameDate(l.date, weekAgo)).firstOrNull;
  if (lastWeek != null) return (prepared: lastWeek.mealsPrepared, surplus: lastWeek.mealsSurplus);
  final earlier = [for (final l in logs) if (l.date.isBefore(date)) l]..sort((a, b) => b.date.compareTo(a.date));
  if (earlier.isNotEmpty) return (prepared: earlier.first.mealsPrepared, surplus: earlier.first.mealsSurplus);
  final prepared = typicalDailyMeals ?? 40;
  return (prepared: prepared, surplus: (prepared * (typicalSurplusPct ?? 10) / 100).round());
}

/// What `GET /forecasts` and `GET /daily-logs` returned.
typedef InsightsData = ({List<Forecast> forecasts, List<DailyLog> logs});

class InsightsNotifier extends AsyncNotifier<InsightsData> {
  @override
  Future<InsightsData> build() {
    // Reload when a different restaurant signs in.
    ref.watch(myRestaurantProvider.select((r) => r.value?.id));
    return _load();
  }

  Future<InsightsData> _load() async {
    final (forecasts, logs) = await (
      ref.read(forecastRepositoryProvider).myForecasts(),
      ref.read(dailyLogsRepositoryProvider).myLogs(),
    ).wait;
    return (forecasts: forecasts, logs: logs);
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_load);

  /// "Save log": `PUT /daily-logs/{date}`. Throws [DailyLogException].
  Future<DailyLog> saveLog(DateTime date, {required int prepared, required int surplus}) async {
    final log = await ref
        .read(dailyLogsRepositoryProvider)
        .save(date, mealsPrepared: prepared, mealsSurplus: surplus);
    await refresh();
    return log;
  }
}

final insightsProvider = AsyncNotifierProvider<InsightsNotifier, InsightsData>(InsightsNotifier.new);

/// The Insights view now; rebuilt on clock ticks so "tomorrow" moves at midnight.
final insightsViewProvider = Provider<AsyncValue<Insights>>((ref) {
  final now = ref.now;
  return ref
      .watch(insightsProvider)
      .whenData((d) => buildInsights(forecasts: d.forecasts, logs: d.logs, now: now));
});
