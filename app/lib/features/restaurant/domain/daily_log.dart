import '../../../core/format/muscat_time.dart';

/// Where a log came from (§4). Seeded and generated data is always
/// `synthetic` and never reported as real accuracy (§13).
enum DailyLogSource {
  manual,
  synthetic;

  static DailyLogSource fromJson(String value) => values.byName(value);
}

/// One day's numbers (§4 `daily_logs`): the label the forecast learns from.
class DailyLog {
  const DailyLog({
    required this.id,
    required this.date,
    required this.mealsPrepared,
    required this.mealsSurplus,
    required this.source,
  });

  final String id;

  /// The Muscat calendar day (date only, UTC midnight).
  final DateTime date;
  final int mealsPrepared;
  final int mealsSurplus;
  final DailyLogSource source;

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
        id: json['id'] as String,
        date: parseIsoDate(json['date'] as String),
        mealsPrepared: json['meals_prepared'] as int,
        mealsSurplus: json['meals_surplus'] as int,
        source: DailyLogSource.fromJson(json['source'] as String),
      );
}

enum DailyLogError { negative, tooMany, surplusOverPrepared, notPast }

/// The §4 rules for `PUT /daily-logs/{date}`, shared by the form and the fake
/// server: whole numbers from 0 to [maxMeals], left over ≤ prepared, and only
/// days that have ended (before today in Muscat).
abstract final class DailyLogRules {
  static const maxMeals = 999;

  static Set<DailyLogError> validate({
    required DateTime date,
    required int prepared,
    required int surplus,
    required DateTime now,
  }) =>
      {
        if (prepared < 0 || surplus < 0) DailyLogError.negative,
        if (prepared > maxMeals) DailyLogError.tooMany,
        if (surplus > prepared) DailyLogError.surplusOverPrepared,
        if (!date.isBefore(muscatToday(now))) DailyLogError.notPast,
      };

  /// Share left over, as a whole percent ("9 of 64 left · 14%").
  static int surplusPct(int prepared, int surplus) => prepared == 0 ? 0 : (surplus * 100 / prepared).round();
}
