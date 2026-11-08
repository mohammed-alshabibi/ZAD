import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/distance.dart';
import '../../../core/format/money.dart';
import '../../../core/format/muscat_time.dart';
import '../../auth/application/session.dart';
import '../../restaurant/data/fake_today_store.dart';
import '../../restaurant/data/restaurant_today_repositories.dart';
import '../../user/data/user_offers_repository.dart';
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
/// Demo: fatema@example.com has three "new meals nearby" alerts from tonight
/// (2 unread) and one from two days ago, written the way `notify_nearby`
/// will write them (§6). khubz@example.com has its approval note.
/// Everyone else starts with an empty inbox.
class FakeNotificationsStore {
  FakeNotificationsStore._(this.byUser);

  factory FakeNotificationsStore.seeded(FakeTodayStore offers, DateTime now) {
    String ago(Duration d) => now.toUtc().subtract(d).toIso8601String();
    // Fatema's saved location (Al Khuwair), as in FakeAuthRepository.
    const fatemaLat = 23.583, fatemaLng = 58.396;

    Map<String, dynamic> newOffer(String id, String offerId, Duration age, {bool read = false}) {
      final o = offers.offerById(offerId)!;
      final coords = (o['location'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
      final meters =
          distanceMeters(fatemaLat, fatemaLng, (coords[1] as num).toDouble(), (coords[0] as num).toDouble()).round();
      final price = o['price_baisa'] as int;
      final until = muscatClock(DateTime.parse(o['pickup_end'] as String));
      return {
        'id': id,
        'user_id': 'u_fatema',
        'type': AppNotification.typeNewOffer,
        'offer_id': offerId,
        // §6: "🍃 {Restaurant} posted surplus 1.2 km away: {title}, {price|Free}, pickup until {time}".
        'title': '🍃 ${o['restaurant_name']} posted surplus',
        'body': '${formatKm(meters)} away: ${o['title']}, ${price == 0 ? 'Free' : formatOmr(price)}, '
            'pickup until $until',
        'read_at': read ? ago(age - const Duration(minutes: 2)) : null,
        'created_at': ago(age),
      };
    }

    return FakeNotificationsStore._({
      'u_fatema': [
        newOffer('n_1', 'o_mandi', const Duration(minutes: 12)),
        newOffer('n_2', 'o_bowls', const Duration(minutes: 41)),
        newOffer('n_3', 'o_zaatar', const Duration(minutes: 95), read: true),
        newOffer('n_4', 'o_past_pastry', const Duration(days: 2, minutes: 70), read: true),
      ],
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
  (ref) => FakeNotificationsStore.seeded(ref.watch(fakeTodayStoreProvider), DateTime.now()),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => FakeNotificationsRepository(ref.watch(fakeNotificationsStoreProvider), () => ref.read(sessionProvider)?.id),
);
