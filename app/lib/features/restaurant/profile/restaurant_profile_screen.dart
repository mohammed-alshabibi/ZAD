import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_form_row.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_profile.dart';
import '../../auth/application/session.dart';
import '../../auth/widgets/log_out_button.dart';
import '../../notifications/application/notifications.dart';
import '../application/my_restaurant.dart';
import '../application/onboarding_draft.dart';
import '../domain/restaurant.dart';
import '../onboarding/onboarding_text.dart';

/// Restaurant "Profile" tab, the restaurant's settings (§9). No Figma frame;
/// built from the Form row component. "Edit restaurant details" reuses the
/// three onboarding steps, filled in with the saved answers.
class RestaurantProfileScreen extends ConsumerWidget {
  const RestaurantProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final user = ref.watch(sessionProvider);
    final restaurant = ref.watch(myRestaurantProvider).value;
    final unread = ref.watch(unreadNotificationsProvider);

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(20, MediaQuery.paddingOf(context).top + 18, 20, 32),
      children: [
        Text(l10n.tabProfile, style: ZadType.display(size: 34, letterSpacing: -0.51, color: z.card)),
        const SizedBox(height: 18),
        if (restaurant != null) ...[
          ZadProfileHeader(
            name: restaurant.name,
            detail: l10n.cuisineArea(l10n.cuisineLabel(restaurant.cuisine), restaurant.area),
            badge: restaurant.status == RestaurantStatus.approved
                ? Row(
                    children: [
                      const ZadIcon(ZadIcons.checkSmall, size: 14),
                      const SizedBox(width: 5),
                      Text(l10n.profileVerified, style: ZadType.body(size: 13, color: z.sap)),
                    ],
                  )
                : null,
          ),
          ZadSectionLabel(l10n.profileSectionRestaurant),
          ZadFormRow(
            icon: ZadIcons.storeSmall,
            title: l10n.profileEditRestaurant,
            value: l10n.profileEditRestaurantValue,
            onTap: () {
              ref.read(onboardingDraftProvider.notifier).start(restaurant);
              context.push(Routes.restaurantOnboarding);
            },
          ),
          ZadFormRow(icon: ZadIcons.phone, title: l10n.profilePhone, value: restaurant.phone, chevron: false),
          ZadFormRow(
            icon: ZadIcons.mapPin,
            title: l10n.profilePickupPoint,
            value: restaurant.addressText,
            chevron: false,
          ),
          if (restaurant.typicalDailyMeals != null && restaurant.typicalSurplusPct != null)
            ZadFormRow(
              icon: ZadIcons.chefHat,
              title: l10n.profileTypicalDay,
              value: l10n.profileTypicalDayValue(
                restaurant.typicalDailyMeals!,
                l10n.surplusBandLabel(SurplusBand.fromPct(restaurant.typicalSurplusPct!)),
              ),
              chevron: false,
            ),
        ],
        ZadSectionLabel(l10n.profileSectionAccount),
        if (user != null) ...[
          ZadFormRow(icon: ZadIcons.userSmall, title: l10n.profileOwner, value: user.fullName, chevron: false),
          ZadFormRow(icon: ZadIcons.mail, title: l10n.fieldEmail, value: user.email, chevron: false),
        ],
        ZadFormRow(
          icon: ZadIcons.bell,
          title: l10n.notifications,
          value: unread == 0 ? l10n.notificationsAllRead : l10n.notificationsUnread(unread),
          onTap: () => context.push(Routes.notifications),
        ),
        const SizedBox(height: 28),
        const LogOutButton(),
      ],
    );
  }
}
