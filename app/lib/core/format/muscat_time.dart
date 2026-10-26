import 'package:intl/intl.dart';

/// Times are stored in UTC and shown in Muscat time (CLAUDE.md §1.1).
/// Oman is UTC+4 all year (no daylight saving), so a fixed offset is exact.
const muscatOffset = Duration(hours: 4);

/// The same instant as a Muscat wall-clock time (returned as a UTC DateTime
/// whose fields read as Muscat time).
DateTime toMuscat(DateTime instant) => instant.toUtc().add(muscatOffset);

/// "14:12" in Muscat time.
String muscatClock(DateTime instant) => DateFormat('HH:mm').format(toMuscat(instant));

/// Which Muscat calendar day [instant] falls on, relative to [now].
enum MuscatDay { today, yesterday, earlier }

MuscatDay muscatDayOf(DateTime instant, {required DateTime now}) {
  final a = toMuscat(instant);
  final b = toMuscat(now);
  final days = DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
  return switch (days) {
    0 => MuscatDay.today,
    1 => MuscatDay.yesterday,
    _ => MuscatDay.earlier,
  };
}

/// "18 Oct, 14:12" in Muscat time, for dates before yesterday.
String muscatDateTime(DateTime instant) => DateFormat('d MMM, HH:mm').format(toMuscat(instant));

/// Whole Muscat calendar days from [instant] to [now] (0 = same day).
int muscatDaysAgo(DateTime instant, {required DateTime now}) {
  final a = toMuscat(instant);
  final b = toMuscat(now);
  return DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}

/// "Tue" in Muscat time.
String muscatWeekday(DateTime instant) => DateFormat('EEE').format(toMuscat(instant));

/// "18 Oct" in Muscat time.
String muscatDate(DateTime instant) => DateFormat('d MMM').format(toMuscat(instant));

/// The instant that reads [hour]:[minute] in Muscat on the Muscat day of [now].
DateTime muscatTodayAt(int hour, int minute, {required DateTime now}) {
  final day = toMuscat(now);
  return DateTime.utc(day.year, day.month, day.day, hour, minute).subtract(muscatOffset);
}

/// Today's Muscat calendar date, date only (UTC midnight, like [parseIsoDate]).
DateTime muscatToday(DateTime now) {
  final m = toMuscat(now);
  return DateTime.utc(m.year, m.month, m.day);
}

/// A §4 date field ("2026-10-25") as a date-only UTC DateTime.
DateTime parseIsoDate(String value) {
  final d = DateTime.parse(value);
  return DateTime.utc(d.year, d.month, d.day);
}

/// "2026-10-25" for a date-only DateTime (API paths and JSON).
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

bool isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Fri–Sat, the Omani weekend (CLAUDE.md §1.1).
bool isWeekendDate(DateTime date) => date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
