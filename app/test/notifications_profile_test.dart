import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/l10n/generated/app_localizations.dart';
import 'package:zad/features/auth/data/fake_auth_repository.dart';
import 'package:zad/features/auth/domain/app_user.dart';
import 'package:zad/features/notifications/data/notifications_repository.dart';
import 'package:zad/features/notifications/domain/app_notification.dart';
import 'package:zad/features/notifications/notifications_screen.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('Notifications inbox (fake)', () {
    late FakeNotificationsStore store;
    String? signedIn;
    late FakeNotificationsRepository repo;

    setUp(() {
      store = FakeNotificationsStore.seeded();
      signedIn = 'u_fatma';
      repo = FakeNotificationsRepository(store, () => signedIn, latency: Duration.zero);
    });

    test('Fatma: the customer inbox is empty for now', () async {
      expect(await repo.mine(), isEmpty);
    });

    test('nobody can read or mark another account’s notifications', () async {
      await expectLater(repo.markRead('n_khubz_ok'), throwsStateError);
      signedIn = 'u_khubz';
      expect((await repo.mine()).single.type, AppNotification.typeRestaurantStatus);
      expect((await repo.markRead('n_khubz_ok')).isRead, isTrue);
      signedIn = 'u_karak';
      expect(await repo.mine(), isEmpty);
    });

    test('age labels: minutes, hours, then the day', () {
      final now = DateTime.utc(2026, 10, 27, 17, 0);
      expect(l10n.notificationAge(now.subtract(const Duration(seconds: 20)), now), 'Just now');
      expect(l10n.notificationAge(now.subtract(const Duration(minutes: 12)), now), '12 min ago');
      expect(l10n.notificationAge(now.subtract(const Duration(hours: 3, minutes: 5)), now), '3 h ago');
      expect(l10n.notificationAge(now.subtract(const Duration(days: 1)), now), 'Yesterday');
    });
  });

  group('PATCH /me (fake)', () {
    test('changes the name and the alerts switch, never the role', () async {
      final auth = FakeAuthRepository(latency: Duration.zero);
      await auth.login(email: 'fatema@example.com', password: FakeAuthRepository.demoPassword);

      final off = await auth.updateMe(notifyEnabled: false);
      expect(off.notifyEnabled, isFalse);
      final renamed = await auth.updateMe(fullName: '  Fatma Al-Said ');
      expect((renamed.fullName, renamed.notifyEnabled, renamed.role), ('Fatma Al-Said', false, UserRole.user));
      expect((await auth.me()).fullName, 'Fatma Al-Said');
    });
  });
}
