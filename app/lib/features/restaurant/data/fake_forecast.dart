import '../../../core/format/muscat_time.dart';
import '../domain/daily_log.dart';
import '../domain/forecast.dart';
import '../domain/restaurant.dart';
import 'daily_logs_repository.dart';
import 'restaurant_today_repositories.dart';

/// Khubz & Co. Bakery's demo pattern, shared by its fake forecast and fake
/// logs so the two agree: the expected surplus and likely range per weekday,
/// as on Figma "Insights" (32:601). Fridays and Saturdays are the peak.
abstract final class KhubzDemo {
  static const restaurantId = 'r_khubz';

  /// ISO weekday (Mon = 1) → (expected, low, high).
  static const pattern = {
    DateTime.monday: (5, 3, 8),
    DateTime.tuesday: (6, 4, 9),
    DateTime.wednesday: (7, 4, 10),
    DateTime.thursday: (9, 6, 13),
    DateTime.friday: (12, 8, 16),
    DateTime.saturday: (14, 10, 19),
    DateTime.sunday: (6, 3, 9),
  };

  /// Logs on the 23 days before yesterday (yesterday is left for the demo).
  static const loggedDays = 23;

  /// How far each logged day was from the pattern, from 2 days ago back.
  /// The last 2 weeks are off by about 3 meals a day on average.
  static const _noise = [3, -2, 4, -3, 2, -4, 1, 3, -2, 5, -3, 2, -1, 4, -2, 3, -3, 1, -2, 2, -1, 3, -2];

  static double get _mean => pattern.values.fold(0, (sum, p) => sum + p.$1) / pattern.length;

  /// "Fridays are usually 40% higher": the weekday's difference from the
  /// weekly mean, to the nearest 10%, when it is at least 15%.
  static ForecastReason? weekdayReason(int weekday) {
    final pct = (pattern[weekday]!.$1 / _mean - 1) * 100;
    if (pct.abs() < 15) return null;
    final rounded = (pct.abs() / 10).round() * 10;
    return ForecastReason(pct > 0 ? ForecastReason.weekdayHigher : ForecastReason.weekdayLower,
        weekday: weekday, pct: rounded);
  }

  static List<Map<String, dynamic>> seededLogs(DateTime now) {
    final today = muscatToday(now);
    return [
      for (var daysAgo = 2; daysAgo < 2 + loggedDays; daysAgo++)
        () {
          final date = today.subtract(Duration(days: daysAgo));
          final surplus = pattern[date.weekday]!.$1 + _noise[daysAgo - 2];
          final prepared = 56 + (daysAgo * 5) % 11 + (isWeekendDate(date) ? 6 : 0);
          final stamp = date.add(const Duration(hours: 20)).toIso8601String();
          return {
            'id': 'log_khubz_${isoDate(date)}',
            'restaurant_id': restaurantId,
            'date': isoDate(date),
            'meals_prepared': prepared,
            'meals_surplus': surplus,
            // Demo data: never reported as real accuracy (§13).
            'source': 'synthetic',
            'created_at': stamp,
            'updated_at': stamp,
          };
        }(),
    ];
  }
}

/// Answers like `run_forecast` would (§7.3, §7.5): the last 14 days (kept so
/// the app can compare them with the logs) and the next 7. Khubz has 23 days
/// of logs and gets the seasonal model; a new restaurant gets the cold-start
/// estimate from its onboarding answers, for the coming days only.
class FakeForecastRepository implements ForecastRepository {
  FakeForecastRepository(this.restaurant, {this.latency = const Duration(milliseconds: 300), this.now});

  final Future<Restaurant?> Function() restaurant;
  final Duration latency;

  /// Fixed "now" for tests; the real clock otherwise.
  final DateTime? now;

  /// Generic weekday pattern for the cold start, Monday first.
  static const _weekday = [0.9, 0.95, 1.0, 1.1, 1.35, 1.2, 0.9];

  @override
  Future<List<Forecast>> myForecasts() async {
    await Future<void>.delayed(latency);
    final r = await restaurant();
    if (r == null) return const [];
    final today = muscatToday(now ?? DateTime.now());
    if (r.id == KhubzDemo.restaurantId) {
      return [for (var i = -14; i <= 7; i++) _khubz(today.add(Duration(days: i)))];
    }
    final base = (r.typicalDailyMeals ?? 40) * (r.typicalSurplusPct ?? 10) / 100;
    return [
      for (var i = 1; i <= 7; i++)
        () {
          final day = today.add(Duration(days: i));
          final predicted = (base * _weekday[day.weekday - 1]).round();
          final spread = (predicted * 0.5).round();
          return Forecast.fromJson({
            'target_date': isoDate(day),
            'predicted': predicted,
            'low': predicted - spread,
            'high': predicted + spread,
            'confidence': 'low',
            'model': 'cold_start',
            'explanations': [const ForecastReason(ForecastReason.coldStart).toJson()],
          });
        }(),
    ];
  }

  static Forecast _khubz(DateTime day) {
    final (predicted, low, high) = KhubzDemo.pattern[day.weekday]!;
    return Forecast.fromJson({
      'target_date': isoDate(day),
      'predicted': predicted,
      'low': low,
      'high': high,
      'confidence': 'medium',
      'model': 'm1',
      'explanations': [
        ?KhubzDemo.weekdayReason(day.weekday)?.toJson(),
        const ForecastReason(ForecastReason.daysLogged, days: KhubzDemo.loggedDays).toJson(),
        const ForecastReason(ForecastReason.weekdayAverage, weeks: 4).toJson(),
      ],
    });
  }
}

/// `daily_logs` rows by restaurant, in the §4 JSON shape.
class FakeDailyLogStore {
  FakeDailyLogStore._(this.logs);

  factory FakeDailyLogStore.seeded(DateTime now) => FakeDailyLogStore._([...KhubzDemo.seededLogs(now)]);

  final List<Map<String, dynamic>> logs;
}

class FakeDailyLogsRepository implements DailyLogsRepository {
  FakeDailyLogsRepository(this.store, this.restaurantId, {this.latency = const Duration(milliseconds: 300)});

  final FakeDailyLogStore store;
  final Future<String?> Function() restaurantId;
  final Duration latency;

  @override
  Future<List<DailyLog>> myLogs() async {
    await Future<void>.delayed(latency);
    final id = await restaurantId();
    final mine = [for (final l in store.logs) if (l['restaurant_id'] == id) l]
      ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return [for (final l in mine) DailyLog.fromJson(l)];
  }

  @override
  Future<DailyLog> save(DateTime date, {required int mealsPrepared, required int mealsSurplus}) async {
    await Future<void>.delayed(latency);
    final id = await restaurantId();
    if (id == null) throw const DailyLogException(DailyLogException.noRestaurant);
    final errors = DailyLogRules.validate(
        date: date, prepared: mealsPrepared, surplus: mealsSurplus, now: DateTime.now());
    if (errors.isNotEmpty) throw const DailyLogException(DailyLogException.invalid);

    final key = isoDate(date);
    final stamp = DateTime.now().toUtc().toIso8601String();
    // Unique (restaurant_id, date): a second save replaces the first.
    final existing = store.logs.where((l) => l['restaurant_id'] == id && l['date'] == key).firstOrNull;
    final log = existing ??
        {
          'id': 'log_${id}_$key',
          'restaurant_id': id,
          'date': key,
          'created_at': stamp,
        };
    log
      ..['meals_prepared'] = mealsPrepared
      ..['meals_surplus'] = mealsSurplus
      ..['source'] = 'manual'
      ..['updated_at'] = stamp;
    if (existing == null) store.logs.add(log);
    return DailyLog.fromJson(log);
  }
}
