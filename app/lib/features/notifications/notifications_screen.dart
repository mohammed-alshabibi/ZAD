import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/time/clock.dart';
import '../../core/widgets/zad_icon.dart';
import '../auth/application/session.dart';
import '../auth/domain/app_user.dart';
import '../user/pickups/pickup_text.dart';
import 'application/notifications.dart';
import 'domain/app_notification.dart';

/// Inbox (Zesty 71–73 pattern; no Figma frame): newest first, unread rows
/// bold with a sap dot. Tapping a "new meals nearby" alert opens the meal.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, AppNotification n) async {
    await ref.read(notificationsProvider.notifier).markRead(n);
    final isUser = ref.read(sessionProvider)?.role == UserRole.user;
    if (context.mounted && isUser && n.type == AppNotification.typeNewOffer && n.offerId != null) {
      context.push(Routes.mealDetails(n.offerId!));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final now = ref.now;
    final async = ref.watch(notificationsProvider);
    final items = async.value ?? const <AppNotification>[];
    final unread = ref.watch(unreadNotificationsProvider);
    final role = ref.watch(sessionProvider.select((u) => u?.role));

    final List<Widget> body;
    if (async.isLoading && !async.hasValue) {
      body = [
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Center(child: CircularProgressIndicator(color: z.sap)),
        ),
      ];
    } else if (async.hasError && !async.hasValue) {
      body = [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(l10n.notificationsLoadError, style: ZadType.body(size: 14, color: z.danger)),
        ),
      ];
    } else if (items.isEmpty) {
      body = [
        _Empty(body: role == UserRole.restaurant ? l10n.notificationsEmptyRestaurant : l10n.notificationsEmptyUser),
      ];
    } else {
      body = [for (final n in items) _Row(n: n, when: l10n.notificationAge(n.createdAt, now), onTap: () => _open(context, ref, n))];
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.nightSheet,
        body: RefreshIndicator(
          color: z.frond,
          backgroundColor: z.sap,
          onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 6, 20, 32),
            children: [
              Row(
                children: [
                  _BackButton(
                    label: l10n.back,
                    onTap: () => context.canPop() ? context.pop() : context.go(homeForRole(role ?? UserRole.user)),
                  ),
                  const Spacer(),
                  if (unread > 0)
                    TextButton(
                      onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
                      style: TextButton.styleFrom(foregroundColor: z.sap, minimumSize: const Size(48, 40)),
                      child: Text(l10n.notificationsMarkAllRead, style: ZadType.body(size: 14, color: z.sap)),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(l10n.notifications, style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card)),
              const SizedBox(height: 6),
              Text(
                unread == 0 ? l10n.notificationsAllRead : l10n.notificationsUnread(unread),
                style: ZadType.body(size: 14, color: z.onFrondMuted),
              ),
              const SizedBox(height: 12),
              ...body,
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.n, required this.when, required this.onTap});

  final AppNotification n;
  final String when;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final unread = !n.isRead;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: z.nightHairline))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: z.onFrondSubtle, shape: BoxShape.circle),
                child: ZadIcon(
                  n.type == AppNotification.typeNewOffer ? ZadIcons.leaf : ZadIcons.storeSmall,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: ZadType.body(size: 15, weight: unread ? FontWeight.w600 : FontWeight.w500, color: z.card),
                    ),
                    const SizedBox(height: 3),
                    Text(n.body, style: ZadType.body(size: 13, height: 18 / 13, color: z.onFrondMuted)),
                    const SizedBox(height: 6),
                    Text(when, style: ZadType.mono(size: 11, weight: FontWeight.w400, color: z.onFrondMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: unread ? z.sap : Colors.transparent, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const ZadIcon(ZadIcons.leafLarge, size: 48),
          const SizedBox(height: 16),
          Text(l10n.notificationsEmptyTitle, style: ZadType.display(size: 22, color: z.card)),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: z.nightRaised,
        shape: CircleBorder(side: BorderSide(color: z.nightHairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox.square(dimension: 40, child: Center(child: ZadIcon(ZadIcons.chevronLeft, size: 20))),
        ),
      ),
    );
  }
}

extension NotificationText on AppLocalizations {
  /// "Just now", "12 min ago", "3 h ago", then "Yesterday", "Tue" or "18 Oct".
  String notificationAge(DateTime at, DateTime now) {
    final minutes = now.difference(at).inMinutes;
    if (minutes < 1) return notificationJustNow;
    if (minutes < 60) return notificationMinutesAgo(minutes);
    if (minutes < 12 * 60) return notificationHoursAgo(minutes ~/ 60);
    return pickupDay(at, now);
  }
}
