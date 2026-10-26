import '../../../core/format/muscat_time.dart';

/// How sure the forecast is (CLAUDE.md §7.3).
enum ForecastConfidence {
  low,
  medium,
  high;

  static ForecastConfidence fromJson(String value) => values.byName(value);

  /// Filled dots on the confidence pill (1–3), so the level never relies on colour alone.
  int get dots => index + 1;
}

/// One "Why this forecast" chip (§7.6). The server sends a code plus numbers,
/// not English text, so the app can word it (and translate it later).
class ForecastReason {
  const ForecastReason(this.code, {this.weekday, this.pct, this.days, this.weeks});

  /// Known codes. Unknown codes are skipped by the app.
  static const weekdayHigher = 'weekday_higher'; // weekday + pct
  static const weekdayLower = 'weekday_lower'; // weekday + pct
  static const daysLogged = 'days_logged'; // days
  static const weekdayAverage = 'weekday_average'; // weeks
  static const ramadan = 'ramadan';
  static const holiday = 'holiday';
  static const coldStart = 'cold_start';

  final String code;

  /// ISO weekday, Monday = 1 … Sunday = 7.
  final int? weekday;
  final int? pct;
  final int? days;
  final int? weeks;

  factory ForecastReason.fromJson(Map<String, dynamic> json) => ForecastReason(
        json['code'] as String,
        weekday: json['weekday'] as int?,
        pct: json['pct'] as int?,
        days: json['days'] as int?,
        weeks: json['weeks'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        if (weekday != null) 'weekday': weekday,
        if (pct != null) 'pct': pct,
        if (days != null) 'days': days,
        if (weeks != null) 'weeks': weeks,
      };
}

/// One day of the surplus forecast (`GET /forecasts`, §4 `forecasts`).
class Forecast {
  const Forecast({
    required this.targetDate,
    required this.predicted,
    required this.low,
    required this.high,
    required this.confidence,
    required this.model,
    required this.explanations,
  });

  /// The Muscat calendar day this forecast is for (date only, UTC midnight).
  final DateTime targetDate;
  final int predicted;

  /// The likely range: 10th–90th percentile of past errors (§7.3).
  final int low;
  final int high;
  final ForecastConfidence confidence;

  /// `cold_start` (onboarding answers, "rough estimate") or `m1` (seasonal average).
  final String model;
  final List<ForecastReason> explanations;

  bool get isRoughEstimate => model == 'cold_start';
  bool get isWeekend => isWeekendDate(targetDate);

  factory Forecast.fromJson(Map<String, dynamic> json) => Forecast(
        targetDate: parseIsoDate(json['target_date'] as String),
        predicted: json['predicted'] as int,
        low: json['low'] as int,
        high: json['high'] as int,
        confidence: ForecastConfidence.fromJson(json['confidence'] as String),
        model: json['model'] as String,
        explanations: [
          for (final e in (json['explanations'] as List<dynamic>? ?? const []))
            ForecastReason.fromJson(e as Map<String, dynamic>),
        ],
      );
}
