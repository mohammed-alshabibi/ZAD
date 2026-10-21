import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session.dart';
import '../domain/restaurant.dart';

/// Answers collected across the three onboarding screens, kept until
/// "Submit for review". Cleared when a different account signs in.
class OnboardingDraftNotifier extends Notifier<RestaurantDraft> {
  @override
  RestaurantDraft build() {
    ref.watch(sessionProvider.select((u) => u?.id));
    return const RestaurantDraft();
  }

  /// Starts fresh, or from the saved restaurant when editing it.
  void start([Restaurant? existing]) =>
      state = existing == null ? const RestaurantDraft() : RestaurantDraft.fromRestaurant(existing);

  void setDetails({
    required String name,
    required Cuisine cuisine,
    required String phone,
    required String description,
  }) =>
      state = state.withDetails(name: name, cuisine: cuisine, phone: phone, description: description);

  void setLocation({required double lat, required double lng, required String addressText}) =>
      state = state.withLocation(lat: lat, lng: lng, addressText: addressText);

  void setTypicalDay({required int dailyMeals, required SurplusBand band}) =>
      state = state.withTypicalDay(dailyMeals: dailyMeals, band: band);
}

final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftNotifier, RestaurantDraft>(OnboardingDraftNotifier.new);
