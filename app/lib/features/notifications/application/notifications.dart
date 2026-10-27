import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

/// The signed-in account's inbox. Reloads when a different account signs in.
class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  NotificationsRepository get _repo => ref.read(notificationsRepositoryProvider);

  @override
  Future<List<AppNotification>> build() {
    final userId = ref.watch(sessionProvider.select((u) => u?.id));
    if (userId == null) return Future.value(const []);
    return _repo.mine();
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_repo.mine);

  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    final updated = await _repo.markRead(n.id);
    state = AsyncData([for (final x in state.value ?? const <AppNotification>[]) x.id == n.id ? updated : x]);
  }

  /// One `POST /notifications/{id}/read` per unread row (no bulk endpoint in §5).
  Future<void> markAllRead() async {
    final unread = (state.value ?? const <AppNotification>[]).where((n) => !n.isRead).toList();
    await Future.wait(unread.map((n) => _repo.markRead(n.id)));
    await refresh();
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(NotificationsNotifier.new);

/// Unread count for the dot on the bell buttons and the Profile row.
final unreadNotificationsProvider = Provider<int>(
  (ref) => (ref.watch(notificationsProvider).value ?? const []).where((n) => !n.isRead).length,
);
