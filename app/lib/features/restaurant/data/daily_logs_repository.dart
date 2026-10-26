import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/my_restaurant.dart';
import '../domain/daily_log.dart';
import 'fake_forecast.dart';

/// The restaurant's daily numbers (CLAUDE.md §5.1, §7.2).
abstract interface class DailyLogsRepository {
  /// `GET /daily-logs`: the signed-in restaurant's logs, newest first.
  Future<List<DailyLog>> myLogs();

  /// `PUT /daily-logs/{date}`: creates or replaces that day's log.
  /// Throws [DailyLogException].
  Future<DailyLog> save(DateTime date, {required int mealsPrepared, required int mealsSurplus});
}

class DailyLogException implements Exception {
  const DailyLogException(this.code);

  final String code;

  static const invalid = 'invalid_log';
  static const noRestaurant = 'no_restaurant';

  @override
  String toString() => 'DailyLogException($code)';
}

/// In-memory logs for P1, seeded with Khubz's 23 days. P2 swaps in the API.
final fakeDailyLogStoreProvider = Provider<FakeDailyLogStore>((ref) => FakeDailyLogStore.seeded(DateTime.now()));

final dailyLogsRepositoryProvider = Provider<DailyLogsRepository>(
  (ref) => FakeDailyLogsRepository(
    ref.watch(fakeDailyLogStoreProvider),
    () async => (await ref.read(myRestaurantProvider.future))?.id,
  ),
);
