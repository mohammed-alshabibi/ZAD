import '../../../core/format/muscat_time.dart';
import 'offer.dart';

/// Allergen codes as the API sends them (CLAUDE.md §8.2: required, or "none").
abstract final class Allergens {
  static const none = 'none';
  static const all = ['gluten', 'milk', 'eggs', 'nuts', 'peanuts', 'sesame', 'soy', 'fish', 'shellfish'];
}

/// What can be wrong with a new offer. The server checks the same rules.
enum OfferDraftError {
  title,
  category,
  quantity,
  price,
  wasPrice,

  /// Pickup ends before it starts.
  pickupOrder,

  /// Pickup has already ended.
  pickupOver,

  /// Pickup ends more than 12 hours from now (§4).
  pickupTooLate,
  preparedAt,
  allergens,
  safety,
}

/// The "Add new surplus" form (Figma 30:458), sent as `POST /offers`.
/// Times are UTC instants; the screen shows them in Muscat time.
class OfferDraft {
  const OfferDraft({
    this.title = '',
    this.description = '',
    this.category,
    this.quantity = 5,
    this.priceBaisa,
    this.originalPriceBaisa,
    this.pickupStart,
    this.pickupEnd,
    this.preparedAt,
    this.allergens = const [],
    this.safetyAttested = false,
  });

  final String title;
  final String description;
  final OfferCategory? category;
  final int quantity;

  /// 0 = free. Null until the owner sets it.
  final int? priceBaisa;

  /// The normal price, shown crossed out. Optional.
  final int? originalPriceBaisa;
  final DateTime? pickupStart;
  final DateTime? pickupEnd;
  final DateTime? preparedAt;

  /// Allergen codes, or just `["none"]`.
  final List<String> allergens;
  final bool safetyAttested;

  static const maxTitle = 60;
  static const maxDescription = 200;

  /// Highest price the form accepts: 50 OMR.
  static const maxPriceBaisa = 50000;

  /// Pickup must end within this long from now (§4).
  static const maxAhead = Duration(hours: 12);

  /// A starting point for tonight: pickup from the next quarter hour, for an
  /// hour. Price, category, allergens and "prepared at" are left for the owner.
  factory OfferDraft.start(DateTime now) {
    final muscat = toMuscat(now);
    final quarter = (muscat.minute ~/ 15 + 1) * 15;
    final start = muscatTodayAt(muscat.hour, 0, now: now).add(Duration(minutes: quarter));
    return OfferDraft(pickupStart: start, pickupEnd: start.add(const Duration(hours: 1)));
  }

  OfferDraft copyWith({
    String? title,
    String? description,
    OfferCategory? category,
    int? quantity,
    int? Function()? priceBaisa,
    int? Function()? originalPriceBaisa,
    DateTime? pickupStart,
    DateTime? pickupEnd,
    DateTime? preparedAt,
    List<String>? allergens,
    bool? safetyAttested,
  }) =>
      OfferDraft(
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        priceBaisa: priceBaisa == null ? this.priceBaisa : priceBaisa(),
        originalPriceBaisa: originalPriceBaisa == null ? this.originalPriceBaisa : originalPriceBaisa(),
        pickupStart: pickupStart ?? this.pickupStart,
        pickupEnd: pickupEnd ?? this.pickupEnd,
        preparedAt: preparedAt ?? this.preparedAt,
        allergens: allergens ?? this.allergens,
        safetyAttested: safetyAttested ?? this.safetyAttested,
      );

  /// Every rule from CLAUDE.md §4 and §8.2. Empty = ready to post.
  Set<OfferDraftError> validate(DateTime now) {
    final errors = <OfferDraftError>{};
    final name = title.trim();
    if (name.isEmpty || name.length > maxTitle) errors.add(OfferDraftError.title);
    if (category == null) errors.add(OfferDraftError.category);
    if (quantity < OfferQuantity.min || quantity > OfferQuantity.max) errors.add(OfferDraftError.quantity);

    final price = priceBaisa;
    if (price == null || price < 0 || price > maxPriceBaisa) errors.add(OfferDraftError.price);
    final was = originalPriceBaisa;
    if (was != null && (price == null || was <= price || was > maxPriceBaisa)) errors.add(OfferDraftError.wasPrice);

    final start = pickupStart;
    final end = pickupEnd;
    if (start == null || end == null || !end.isAfter(start)) {
      errors.add(OfferDraftError.pickupOrder);
    } else if (!end.isAfter(now)) {
      errors.add(OfferDraftError.pickupOver);
    } else if (end.isAfter(now.add(maxAhead))) {
      errors.add(OfferDraftError.pickupTooLate);
    }

    // Prepared today: not in the future, and within the last 12 hours.
    final prepared = preparedAt;
    if (prepared == null || prepared.isAfter(now) || now.difference(prepared) > maxAhead) {
      errors.add(OfferDraftError.preparedAt);
    }

    final allergensOk = allergens.isNotEmpty &&
        (allergens.length == 1 && allergens.first == Allergens.none ||
            allergens.every(Allergens.all.contains));
    if (!allergensOk) errors.add(OfferDraftError.allergens);
    if (!safetyAttested) errors.add(OfferDraftError.safety);
    return errors;
  }

  /// The `POST /offers` body. Status and counters are set by the server.
  Map<String, dynamic> toJson() => {
        'title': title.trim(),
        'description': description.trim(),
        'category': category?.json,
        'allergens': allergens,
        'original_price_baisa': originalPriceBaisa,
        'price_baisa': priceBaisa,
        'quantity_total': quantity,
        'prepared_at': preparedAt?.toUtc().toIso8601String(),
        'pickup_start': pickupStart?.toUtc().toIso8601String(),
        'pickup_end': pickupEnd?.toUtc().toIso8601String(),
        'safety_attested': safetyAttested,
      };
}
