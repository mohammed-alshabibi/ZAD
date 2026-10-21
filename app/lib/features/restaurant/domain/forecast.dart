/// How sure the forecast is (CLAUDE.md §7.3).
enum ForecastConfidence {
  low,
  medium,
  high;

  static ForecastConfidence fromJson(String value) => values.byName(value);
}

/// One day of the 7-day surplus forecast (`GET /forecasts`, §4 `forecasts`).
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

  /// The Muscat calendar day this forecast is for (date only).
  final DateTime targetDate;
  final int predicted;
  final int low;
  final int high;
  final ForecastConfidence confidence;

  /// `cold_start` (onboarding answers, "rough estimate") or `m1` (seasonal average).
  final String model;
  final List<String> explanations;

  bool get isRoughEstimate => model == 'cold_start';

  factory Forecast.fromJson(Map<String, dynamic> json) => Forecast(
        targetDate: DateTime.parse(json['target_date'] as String),
        predicted: json['predicted'] as int,
        low: json['low'] as int,
        high: json['high'] as int,
        confidence: ForecastConfidence.fromJson(json['confidence'] as String),
        model: json['model'] as String,
        explanations: [for (final e in (json['explanations'] as List<dynamic>? ?? const [])) e as String],
      );
}
