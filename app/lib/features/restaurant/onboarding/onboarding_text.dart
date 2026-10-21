import '../../../core/l10n/generated/app_localizations.dart';
import '../domain/restaurant.dart';

/// ARB labels for the restaurant enums and form errors.
extension RestaurantText on AppLocalizations {
  String cuisineLabel(Cuisine c) => switch (c) {
        Cuisine.bakery => cuisineBakery,
        Cuisine.omani => cuisineOmani,
        Cuisine.arabic => cuisineArabic,
        Cuisine.indian => cuisineIndian,
        Cuisine.cafe => cuisineCafe,
        Cuisine.fastFood => cuisineFastFood,
        Cuisine.healthy => cuisineHealthy,
        Cuisine.grill => cuisineGrill,
        Cuisine.seafood => cuisineSeafood,
        Cuisine.asian => cuisineAsian,
        Cuisine.international => cuisineInternational,
        Cuisine.other => cuisineOther,
      };

  String surplusBandLabel(SurplusBand b) => switch (b) {
        SurplusBand.under5 => surplusUnder5,
        SurplusBand.from5To10 => surplus5to10,
        SurplusBand.from10To20 => surplus10to20,
        SurplusBand.over20 => surplusOver20,
      };

  String? restaurantFieldError(RestaurantFieldError? e) => switch (e) {
        null => null,
        RestaurantFieldError.nameRequired => errorRestaurantNameRequired,
        RestaurantFieldError.nameTooLong => errorRestaurantNameTooLong,
        RestaurantFieldError.cuisineRequired => errorCuisineRequired,
        RestaurantFieldError.phoneRequired => errorPhoneRequired,
        RestaurantFieldError.phoneInvalid => errorPhoneInvalid,
        RestaurantFieldError.descriptionTooLong => errorDescriptionTooLong,
        RestaurantFieldError.addressRequired => errorAddressRequired,
      };
}
