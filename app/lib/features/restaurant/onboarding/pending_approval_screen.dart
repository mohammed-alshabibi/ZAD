import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../auth/application/session.dart';
import '../../auth/widgets/auth_layout.dart';
import '../application/my_restaurant.dart';
import '../application/onboarding_draft.dart';
import '../domain/restaurant.dart';

/// Figma "Onboarding — Pending approval" (38:1100). Restaurant accounts wait
/// here until an admin approves them; pull down to check again.
class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final restaurant = await ref.read(myRestaurantProvider.notifier).reload();
    if (!context.mounted) return;
    final next = routeForRestaurant(restaurant);
    if (next != Routes.restaurantPending) context.go(next);
  }

  void _edit(BuildContext context, WidgetRef ref, Restaurant restaurant) {
    ref.read(onboardingDraftProvider.notifier).start(restaurant);
    context.push(Routes.restaurantOnboarding);
  }

  Future<void> _logOut(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionProvider.notifier).logout();
    if (context.mounted) context.go(Routes.splash);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final restaurantAsync = ref.watch(myRestaurantProvider);
    final restaurant = restaurantAsync.value;
    final user = ref.watch(sessionProvider);

    final status = restaurant?.status ?? RestaurantStatus.pending;
    final (title, body) = switch (status) {
      RestaurantStatus.rejected => (l10n.rejectedTitle, l10n.rejectedBody),
      RestaurantStatus.suspended => (l10n.suspendedTitle, l10n.suspendedBody),
      _ => (l10n.pendingTitle, l10n.pendingBody),
    };
    final reviewDetail = switch (status) {
      RestaurantStatus.rejected => l10n.pendingNotApproved,
      RestaurantStatus.suspended => l10n.pendingPaused,
      _ => l10n.pendingInProgress,
    };

    return RefreshIndicator(
      color: z.frond,
      backgroundColor: z.sap,
      onRefresh: () => _refresh(context, ref),
      child: AuthLayout(
        crossAxisAlignment: CrossAxisAlignment.center,
        physics: const AlwaysScrollableScrollPhysics(),
        actions: [
          ZadButton(
            label: l10n.editRestaurantDetails,
            style: ZadButtonStyle.secondary,
            onPressed: restaurant == null ? null : () => _edit(context, ref, restaurant),
          ),
          const SizedBox(height: 6),
          ZadButton(label: l10n.logOut, style: ZadButtonStyle.ghost, onPressed: () => _logOut(context, ref)),
        ],
        children: [
          // Figma: the illustration starts 120 px from the top of the frame.
          const SizedBox(height: 20),
          const _Illustration(),
          const SizedBox(height: 24),
          AuthTitle(title, size: 28, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          AuthBody(body, textAlign: TextAlign.center),
          const SizedBox(height: 26),
          if (restaurantAsync.hasError && restaurant == null)
            Text(l10n.errorLoadRestaurant,
                textAlign: TextAlign.center, style: ZadType.body(size: 14, color: z.danger))
          else
            _StatusCard(steps: [
              _Step(
                _StepState.done,
                l10n.pendingStepAccount,
                user?.createdAt == null ? null : _when(l10n, user!.createdAt!),
              ),
              _Step(
                _StepState.done,
                l10n.pendingStepDetails,
                restaurant == null ? null : '${restaurant.name} · ${restaurant.area}',
              ),
              _Step(
                status == RestaurantStatus.pending ? _StepState.current : _StepState.blocked,
                l10n.pendingStepReview,
                reviewDetail,
              ),
              _Step(_StepState.todo, l10n.pendingStepFirstSurplus, l10n.pendingUnlocks),
            ]),
        ],
      ),
    );
  }

  /// "Today, 14:12" / "Yesterday, 09:30" / "18 Oct, 14:12" in Muscat time.
  static String _when(AppLocalizations l10n, DateTime at) => switch (muscatDayOf(at, now: DateTime.now())) {
        MuscatDay.today => l10n.todayAt(muscatClock(at)),
        MuscatDay.yesterday => l10n.yesterdayAt(muscatClock(at)),
        MuscatDay.earlier => muscatDateTime(at),
      };
}

/// 104 px frond leaf disc with a sap clock badge on its bottom-end corner.
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return ExcludeSemantics(
      child: SizedBox(
        width: 140,
        height: 120,
        child: Stack(
          children: [
            PositionedDirectional(
              start: 18,
              top: 8,
              child: Container(
                width: 104,
                height: 104,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: z.frond,
                  shape: BoxShape.circle,
                  border: Border.all(color: z.stem, width: 1.5),
                ),
                child: const ZadIcon(ZadIcons.leafLarge, size: 48),
              ),
            ),
            PositionedDirectional(
              start: 94,
              top: 76,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: z.sap,
                  shape: BoxShape.circle,
                  border: Border.all(color: z.nightSheet, width: 4),
                ),
                child: ZadIcon(ZadIcons.clock, size: 20, color: z.frond),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, current, blocked, todo }

class _Step {
  const _Step(this.state, this.title, this.detail);

  final _StepState state;
  final String title;
  final String? detail;
}

/// Figma "Status" card: four steps with an indicator each.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.steps});

  final List<_Step> steps;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: z.nightRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: z.nightHairline),
      ),
      child: Column(
        children: [
          for (final (i, step) in steps.indexed) ...[
            if (i > 0) const SizedBox(height: 16),
            _StepRow(step: step),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final todo = step.state == _StepState.todo;
    final detailColor = switch (step.state) {
      _StepState.current => z.sap,
      _StepState.blocked => z.danger,
      _ => z.onFrondMuted,
    };
    final indicator = switch (step.state) {
      _StepState.done => Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: z.sap, shape: BoxShape.circle),
          child: const ZadIcon(ZadIcons.check, size: 16),
        ),
      _StepState.current => SvgPicture.asset('assets/icons/radio_progress.svg', width: 26, height: 26),
      _StepState.blocked => Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: z.danger, width: 1.5)),
        ),
      _StepState.todo => Opacity(
          opacity: 0.6,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: z.onFrondMuted, width: 1.5)),
          ),
        ),
    };

    return MergeSemantics(
      child: Row(
        children: [
          indicator,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: ZadType.body(
                    size: 15,
                    height: 20 / 15,
                    weight: todo ? FontWeight.w400 : FontWeight.w500,
                    color: todo ? z.onFrondMuted : z.card,
                  ),
                ),
                if (step.detail != null) ...[
                  const SizedBox(height: 2),
                  Text(step.detail!, style: ZadType.body(size: 13, height: 18 / 13, color: detailColor)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
