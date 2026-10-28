import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/l10n/generated/app_localizations.dart';
import 'package:zad/features/auth/data/fake_auth_repository.dart';
import 'package:zad/features/auth/domain/app_user.dart';
import 'package:zad/features/notifications/data/notifications_repository.dart';
import 'package:zad/features/notifications/domain/app_notification.dart';
import 'package:zad/features/notifications/notifications_screen.dart';
import 'package:zad/features/restaurant/data/fake_today_store.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('Notifications inbox (fake)', () {
    late FakeNotificationsStore store;
    String? signedIn;
    late FakeNotificationsRepository repo;

    setUp(() {
      final now = DateTime.now();
      store = FakeNotificationsStore.seeded(FakeTodayStore.seeded(now), now);
      signedIn = 'u_fatema';
      repo = FakeNotificationsRepository(store, () => signedIn, latency: Duration.zero);
    });

    test('Fatema: four "new meals nearby" alerts, newest first, two unread', () async {
      final inbox = await repo.mine();
      expect(inbox.map((n) => n.offerId), ['o_mandi', 'o_bowls', 'o_zaatar', 'o_past_pastry']);
      expect(inbox.every((n) => n.type == AppNotification.typeNewOffer), isTrue);
      expect(inbox.where((n) => !n.isRead).length, 2);
    });

    test('messages follow the §6 wording, with Free for a free offer', () async {
      final inbox = await repo.mine();
      expect(inbox[0].title, '🍃 Wadi Grill House posted surplus');
      expect(inbox[0].body, matches(RegExp(r'^\d\.\d km away: Chicken mandi, half portions, 1\.500 OMR, pickup until \d\d:\d\d$')));
      expect(inbox[1].body, contains('Falafel salad bowls, Free, pickup until'));
    });

    test('marking one as read keeps the others unread', () async {
      final first = (await repo.mine()).first;
      final read = await repo.markRead(first.id);
      expect(read.isRead, isTrue);
      expect((await repo.mine()).where((n) => !n.isRead).length, 1);
    });

    test('nobody can read or mark another account’s notifications', () async {
      signedIn = 'u_khubz';
      expect((await repo.mine()).single.type, AppNotification.typeRestaurantStatus);
      await expectLater(repo.markRead('n_1'), throwsStateError);
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
      final renamed = await auth.updateMe(fullName: '  Fatema Al-Said ');
      expect((renamed.fullName, renamed.notifyEnabled, renamed.role), ('Fatema Al-Said', false, UserRole.user));
      expect((await auth.me()).fullName, 'Fatema Al-Said');
    });
  });
}
