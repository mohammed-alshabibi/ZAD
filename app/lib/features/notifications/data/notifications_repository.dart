import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session.dart';
import '../domain/app_notification.dart';

/// The signed-in account's inbox (CLAUDE.md §5.1). P2 adds an
/// `ApiNotificationsRepository`; push messages (FCM) come with it.
abstract interface class NotificationsRepository {
  /// `GET /notifications`, newest first.
  Future<List<AppNotification>> mine();

  /// `POST /notifications/{id}/read`.
  Future<AppNotification> markRead(String id);
}

/// In-memory inbox for P1, keyed by user id, in the §4 JSON shape.
///
/// Demo: khubz@example.com has its approval note. Customers start with an
/// empty inbox for now (later it will only hold reservation confirmations).
class FakeNotificationsStore {
  FakeNotificationsStore._(this.byUser);

  factory FakeNotificationsStore.seeded() {
    return FakeNotificationsStore._({
      'u_khubz': [
        {
          'id': 'n_khubz_ok',
          'user_id': 'u_khubz',
          'type': AppNotification.typeRestaurantStatus,
          'offer_id': null,
          'title': 'Khubz & Co. Bakery is approved',
          'body': 'You can post surplus meals now. People within 3 km get an alert when you do.',
          'read_at': '2026-09-03T08:00:00Z',
          'created_at': '2026-09-03T07:40:00Z',
        },
      ],
    });
  }

  /// user_id → notifications.
  final Map<String, List<Map<String, dynamic>>> byUser;
}

class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository(this.store, this.userId, {this.latency = const Duration(milliseconds: 300)});

  final FakeNotificationsStore store;
  final String? Function() userId;
  final Duration latency;

  List<Map<String, dynamic>> get _mine => store.byUser[userId()] ?? const [];

  @override
  Future<List<AppNotification>> mine() async {
    await Future<void>.delayed(latency);
    return [for (final n in _mine) AppNotification.fromJson(n)]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<AppNotification> markRead(String id) async {
    await Future<void>.delayed(latency ~/ 2);
    // Only the owner's own rows are found (§5.1: querysets filtered by user).
    final n = _mine.where((n) => n['id'] == id).firstOrNull;
    if (n == null) throw StateError('not_found');
    n['read_at'] ??= DateTime.now().toUtc().toIso8601String();
    return AppNotification.fromJson(n);
  }
}

final fakeNotificationsStoreProvider = Provider<FakeNotificationsStore>(
  (ref) => FakeNotificationsStore.seeded(),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => FakeNotificationsRepository(ref.watch(fakeNotificationsStoreProvider), () => ref.read(sessionProvider)?.id),
);
