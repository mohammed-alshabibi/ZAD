import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/format/muscat_time.dart';
import 'package:zad/features/restaurant/application/insights.dart';
import 'package:zad/features/restaurant/application/restaurant_today.dart';
import 'package:zad/features/restaurant/data/daily_logs_repository.dart';
import 'package:zad/features/restaurant/data/fake_forecast.dart';
import 'package:zad/features/restaurant/domain/daily_log.dart';
import 'package:zad/features/restaurant/domain/forecast.dart';
import 'package:zad/features/restaurant/domain/restaurant.dart';
import 'package:zad/features/restaurant/insights/forecast_chart.dart';

Restaurant _restaurant(String id, {int? meals, int? pct}) => Restaurant.fromJson({
      'id': id,
      'owner_id': 'u_$id',
      'name': 'Test kitchen',
      'cuisine': 'bakery',
      'description': '',
      'phone': '+968 9000 0000',
      'address_text': 'Muscat',
      'location': {
        'type': 'Point',
        'coordinates': [58.39, 23.58],
      },
      'status': 'approved',
      'created_at': '2026-10-01T10:00:00Z',
      'typical_daily_meals': meals,
      'typical_surplus_pct': pct,
    });

Forecast _forecast(DateTime day, int predicted, {int? low, int? high}) => Forecast.fromJson({
      'target_date': isoDate(day),
      'predicted': predicted,
      'low': low ?? predicted - 2,
      'high': high ?? predicted + 2,
      'confidence': 'medium',
      'model': 'm1',
      'explanations': [],
    });

DailyLog _log(DateTime day, int prepared, int surplus) => DailyLog.fromJson({
      'id': 'log_${isoDate(day)}',
      'date': isoDate(day),
      'meals_prepared': prepared,
      'meals_surplus': surplus,
      'source': 'manual',
    });

void main() {
  // A Thursday evening in Muscat (tomorrow = Friday, as on Figma 32:601).
  final now = DateTime.utc(2026, 10, 29, 15);
  final today = muscatToday(now);
  final yesterday = today.subtract(const Duration(days: 1));

  group('Forecast JSON (§4)', () {
    test('dates are Muscat calendar days and reasons are codes with numbers', () {
      final f = Forecast.fromJson({
        'target_date': '2026-10-30',
        'predicted': 12,
        'low': 8,
        'high': 16,
        'confidence': 'medium',
        'model': 'm1',
        'explanations': [
          {'code': 'weekday_higher', 'weekday': 5, 'pct': 40},
          {'code': 'days_logged', 'days': 23},
          {'code': 'something_new'},
        ],
      });
      expect(f.targetDate, DateTime.utc(2026, 10, 30));
      expect(f.isWeekend, isTrue);
      expect(f.confidence.dots, 2);
      expect(f.explanations.map((r) => r.code), ['weekday_higher', 'days_logged', 'something_new']);
      expect((f.explanations.first.weekday, f.explanations.first.pct), (5, 40));
    });

    test('Fri and Sat are the weekend', () {
      expect(isWeekendDate(DateTime.utc(2026, 10, 30)), isTrue); // Fri
      expect(isWeekendDate(DateTime.utc(2026, 10, 31)), isTrue); // Sat
      expect(isWeekendDate(DateTime.utc(2026, 11, 1)), isFalse); // Sun
    });
  });

  group('Fake forecast (run_forecast)', () {
    test('Khubz gets the last 14 days, today and the next 7 from the seasonal model', () async {
      final repo = FakeForecastRepository(() async => _restaurant('r_khubz'), latency: Duration.zero, now: now);
      final all = await repo.myForecasts();
      expect(all, hasLength(22));
      expect(all.first.targetDate, today.subtract(const Duration(days: 14)));
      expect(all.every((f) => f.model == 'm1' && f.confidence == ForecastConfidence.medium), isTrue);

      final friday = all.firstWhere((f) => isSameDate(f.targetDate, today.add(const Duration(days: 1))));
      expect((friday.predicted, friday.low, friday.high), (12, 8, 16));
      final weekday = friday.explanations.first;
      expect((weekday.code, weekday.weekday, weekday.pct), (ForecastReason.weekdayHigher, 5, 40));
      expect(friday.explanations.map((r) => r.code),
          [ForecastReason.weekdayHigher, ForecastReason.daysLogged, ForecastReason.weekdayAverage]);
    });

    test('an ordinary weekday gets no weekday chip; a quiet one says lower', () {
      expect(KhubzDemo.weekdayReason(DateTime.thursday), isNull);
      final monday = KhubzDemo.weekdayReason(DateTime.monday)!;
      expect((monday.code, monday.pct), (ForecastReason.weekdayLower, 40));
    });

    test('a new restaurant gets a rough estimate for the coming days only', () async {
      final repo = FakeForecastRepository(() async => _restaurant('r_new', meals: 40, pct: 10),
          latency: Duration.zero, now: now);
      final all = await repo.myForecasts();
      expect(all, hasLength(7));
      expect(all.every((f) => f.targetDate.isAfter(today)), isTrue);
      expect(all.every((f) => f.isRoughEstimate && f.confidence == ForecastConfidence.low), isTrue);
      expect(all.first.explanations.single.code, ForecastReason.coldStart);
    });

    test('Today still finds tomorrow among the past days', () async {
      final repo = FakeForecastRepository(() async => _restaurant('r_khubz'), latency: Duration.zero, now: now);
      final view = buildRestaurantToday(
          offers: const [], reservations: const [], forecasts: await repo.myForecasts(), now: now);
      expect(view.tomorrow?.predicted, 12);
    });
  });

  group('Insights view', () {
    test('Khubz demo: 7 days from tomorrow, yesterday not logged, off by about 3 a day', () async {
      final forecasts =
          await FakeForecastRepository(() async => _restaurant('r_khubz'), latency: Duration.zero, now: now)
              .myForecasts();
      final store = FakeDailyLogStore.seeded(now);
      final logs = [for (final l in store.logs) DailyLog.fromJson(l)];
      final insights = buildInsights(forecasts: forecasts, logs: logs, now: now);

      expect(insights.next7, hasLength(7));
      expect(insights.tomorrow!.targetDate, today.add(const Duration(days: 1)));
      expect(insights.next7.last.targetDate, today.add(const Duration(days: 7)));
      expect(insights.yesterdayLog, isNull);
      expect(insights.daysLogged, 23);
      expect(insights.recentError!.round(), 3);
      expect(logs.every((l) => l.source == DailyLogSource.synthetic), isTrue);
    });

    test('accuracy compares the last 14 days only, and needs 3 days', () {
      final f = [for (var i = 1; i <= 20; i++) _forecast(today.subtract(Duration(days: i)), 10)];
      // Two days in the window: not enough.
      expect(
        forecastError(forecasts: f, logs: [_log(yesterday, 50, 12), _log(today.subtract(const Duration(days: 2)), 50, 8)], now: now),
        isNull,
      );
      final logs = [
        _log(yesterday, 50, 12), // off by 2
        _log(today.subtract(const Duration(days: 2)), 50, 6), // off by 4
        _log(today.subtract(const Duration(days: 14)), 50, 10), // off by 0
        _log(today.subtract(const Duration(days: 15)), 50, 30), // outside the 2 weeks
      ];
      expect(forecastError(forecasts: f, logs: logs, now: now), 2.0);
    });

    test('a day without a stored forecast is not compared', () {
      final f = [_forecast(yesterday, 10)];
      final logs = [for (var i = 1; i <= 5; i++) _log(today.subtract(Duration(days: i)), 50, 9)];
      expect(forecastError(forecasts: f, logs: logs, now: now), isNull);
    });

    test('suggestion: about the low end fewer portions, unless that is under 2', () {
      expect(suggestedCut(_forecast(today, 12, low: 8, high: 16)), 8);
      expect(suggestedCut(_forecast(today, 2, low: 1, high: 4)), isNull);
    });
  });

  group('Daily log rules (§4)', () {
    test('left over can’t be more than prepared', () {
      expect(DailyLogRules.validate(date: yesterday, prepared: 64, surplus: 9, now: now), isEmpty);
      expect(DailyLogRules.validate(date: yesterday, prepared: 64, surplus: 64, now: now), isEmpty);
      expect(DailyLogRules.validate(date: yesterday, prepared: 8, surplus: 9, now: now),
          {DailyLogError.surplusOverPrepared});
    });

    test('only days that have ended, whole numbers 0–999', () {
      expect(DailyLogRules.validate(date: today, prepared: 10, surplus: 1, now: now), {DailyLogError.notPast});
      expect(DailyLogRules.validate(date: yesterday, prepared: 0, surplus: 0, now: now), isEmpty);
      expect(DailyLogRules.validate(date: yesterday, prepared: 1000, surplus: 1, now: now), {DailyLogError.tooMany});
      expect(DailyLogRules.validate(date: yesterday, prepared: 5, surplus: -1, now: now), {DailyLogError.negative});
    });

    test('share left over, as on Figma: 9 of 64 → 14%', () {
      expect(DailyLogRules.surplusPct(64, 9), 14);
      expect(DailyLogRules.surplusPct(0, 0), 0);
    });

    test('the form starts from that day’s log, else last week’s, else the last log, else onboarding', () {
      final logs = [
        _log(today.subtract(const Duration(days: 3)), 60, 7),
        _log(today.subtract(const Duration(days: 5)), 50, 4),
        _log(today.subtract(const Duration(days: 8)), 66, 12), // a week before yesterday
      ];
      expect(dailyLogStart(date: today.subtract(const Duration(days: 3)), logs: logs), (prepared: 60, surplus: 7));
      expect(dailyLogStart(date: yesterday, logs: logs), (prepared: 66, surplus: 12));
      expect(dailyLogStart(date: today.subtract(const Duration(days: 2)), logs: logs), (prepared: 60, surplus: 7));
      expect(dailyLogStart(date: today.subtract(const Duration(days: 4)), logs: logs), (prepared: 50, surplus: 4));
      expect(dailyLogStart(date: yesterday, logs: const [], typicalDailyMeals: 60, typicalSurplusPct: 15),
          (prepared: 60, surplus: 9));
    });
  });

  group('Fake daily logs (GET/PUT /daily-logs)', () {
    late FakeDailyLogStore store;
    late FakeDailyLogsRepository khubz;
    final realYesterday = muscatToday(DateTime.now()).subtract(const Duration(days: 1));

    setUp(() {
      store = FakeDailyLogStore.seeded(DateTime.now());
      khubz = FakeDailyLogsRepository(store, () async => 'r_khubz', latency: Duration.zero);
    });

    test('lists the restaurant’s own logs, newest first', () async {
      final logs = await khubz.myLogs();
      expect(logs, hasLength(23));
      expect(logs.first.date, realYesterday.subtract(const Duration(days: 1)));
      final other = FakeDailyLogsRepository(store, () async => 'r_karak', latency: Duration.zero);
      expect(await other.myLogs(), isEmpty);
    });

    test('saving yesterday adds a manual log; saving again replaces it', () async {
      final first = await khubz.save(realYesterday, mealsPrepared: 64, mealsSurplus: 9);
      expect((first.mealsPrepared, first.mealsSurplus, first.source), (64, 9, DailyLogSource.manual));
      await khubz.save(realYesterday, mealsPrepared: 64, mealsSurplus: 11);
      final logs = await khubz.myLogs();
      expect(logs, hasLength(24));
      expect(logs.first.mealsSurplus, 11);
    });

    test('a seeded day can be fixed and becomes manual', () async {
      final day = realYesterday.subtract(const Duration(days: 3));
      await khubz.save(day, mealsPrepared: 70, mealsSurplus: 5);
      final fixed = (await khubz.myLogs()).firstWhere((l) => isSameDate(l.date, day));
      expect((fixed.mealsPrepared, fixed.source), (70, DailyLogSource.manual));
      expect(await khubz.myLogs(), hasLength(23));
    });

    test('refuses left over above prepared, today, and no restaurant', () async {
      expect(() => khubz.save(realYesterday, mealsPrepared: 5, mealsSurplus: 6), throwsA(isA<DailyLogException>()));
      expect(() => khubz.save(muscatToday(DateTime.now()), mealsPrepared: 5, mealsSurplus: 1),
          throwsA(isA<DailyLogException>()));
      final nobody = FakeDailyLogsRepository(store, () async => null, latency: Duration.zero);
      expect(() => nobody.save(realYesterday, mealsPrepared: 5, mealsSurplus: 1), throwsA(isA<DailyLogException>()));
    });
  });

  group('Chart scale', () {
    test('Figma: highest range 19 → 0–20 by 5', () {
      final days = [_forecast(today, 14, low: 10, high: 19), _forecast(today, 5, low: 3, high: 8)];
      expect(forecastChartScale(days), (maxY: 20.0, interval: 5.0));
    });

    test('at least 0–10; big kitchens get 4 round steps', () {
      expect(forecastChartScale([_forecast(today, 3, low: 1, high: 6)]), (maxY: 10.0, interval: 5.0));
      expect(forecastChartScale([_forecast(today, 25, low: 18, high: 33)]), (maxY: 40.0, interval: 10.0));
    });
  });
}
