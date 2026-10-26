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
