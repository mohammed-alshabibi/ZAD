import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

import '../../../core/config/mapbox_config.dart';
import '../../../core/format/distance.dart';
import '../../../core/format/muscat_time.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/location/location_service.dart';
import '../../../core/location/map_fit.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/pickup_window_bar.dart';
import '../../../core/widgets/zad_chip.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_map_pin.dart';
import '../../../core/widgets/zad_offer_photo_card.dart';
import '../../auth/application/session.dart';
import '../../restaurant/domain/offer.dart';
import '../application/home_offers.dart';
import '../domain/nearby_offer.dart';
import 'offer_text.dart';

/// Figma "Home — Map-first" (8:48). The map is the home screen: leaf pins
/// (one per restaurant, with meals left), the selected restaurant's offers as
/// floating photo cards, and a sheet with the meal count, filters and search
/// that drags up into a list sorted by pickup end.
class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  /// Mapbox zoom: about 3 km across a phone screen, enough for the
  /// neighbourhood around the user.
  static const _zoom = 13.0;

  /// Gap between the sheet and the card row; the Mapbox logo sits in it.
  static const _cardsGap = 32.0;

  final _cards = ScrollController();
  final _sheet = DraggableScrollableController();
  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  /// The restaurant whose pin is selected. Null + [_cleared] = the user
  /// closed the cards by tapping the map.
  String? _selectedId;
  var _cleared = false;
  var _locating = false;

  /// Sheet height when collapsed (grabber to search field), measured.
  double _sheetMin = 186;

  MapboxMap? _map;
  CameraViewportState? _viewport;

  /// Pin and "you" positions on screen, from Mapbox (logical pixels).
  Map<String, Offset> _pinPx = const {};
  Offset? _youPx;
  var _projecting = false;
  var _projectAgain = false;
  String _projectedKey = '';

  /// Where pins may sit without hiding under the top bar, the cards or the
  /// locate button (screen coordinates), and whether the camera was fitted
  /// to the current location's pins yet.
  Rect? _pinBox;
  Size? _viewSize;
  var _fitted = false;

  /// What the pin layer needs, kept from the last build for re-projection.
  List<MapPlace> _places = const [];
  HomeCenter? _center;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      // Typing a search opens the list so the results are visible.
      if (_searchFocus.hasFocus) _expandSheet();
    });
  }

  @override
  void dispose() {
    _cards.dispose();
    _sheet.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- map

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await Future.wait([
      map.compass.updateSettings(CompassSettings(enabled: false)),
      // The Figma scale bar is left out: on real maps it ran through the pins.
      map.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
      map.gestures.updateSettings(GesturesSettings(rotateEnabled: false, pitchEnabled: false)),
      _placeOrnaments(),
    ]);
    map.addInteraction(TapInteraction.onMap((_) => _clearSelection()));
    await _reproject();
    await _fitCamera();
  }

  /// Once per location: zooms and pans so the user and every pin fit in the
  /// strip between the top bar and the card row ([_pinBox]), whatever the
  /// phone's height. Zoom stays between the whole city and street level.
  Future<void> _fitCamera() async {
    final map = _map;
    final camera = _fittedCamera();
    if (map == null || camera == null || _fitted) return;
    _fitted = true;
    try {
      await map.easeTo(
        CameraOptions(
          center: Point(coordinates: Position(camera.lng, camera.lat)),
          zoom: camera.zoom,
          padding: MbxEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        ),
        MapAnimationOptions(duration: 600),
      );
    } catch (_) {
      // Keep the current camera if the map went away meanwhile.
    }
  }

  /// The camera that fits the user and the pins into [_pinBox], or null
  /// before the first layout or when there is nothing to show.
  MapCamera? _fittedCamera() {
    final center = _center;
    final box = _pinBox;
    final view = _viewSize;
    if (center == null || box == null || view == null || _places.isEmpty) return null;
    if (box.height < 60 || box.width < 120) return (lat: center.lat, lng: center.lng, zoom: _zoom);
    return fitCamera([(center.lat, center.lng), for (final p in _places) (p.lat, p.lng)], box, view);
  }

  /// The Mapbox logo and attribution must stay visible, so they sit just
  /// above the collapsed sheet, under the card row.
  Future<void> _placeOrnaments() async {
    final map = _map;
    if (map == null) return;
    final margin = _sheetMin + 6;
    await map.logo.updateSettings(LogoSettings(marginBottom: margin));
    await map.attribution.updateSettings(AttributionSettings(marginBottom: margin));
  }

  /// Asks Mapbox where each pin is on screen. Camera events come faster than
  /// answers, so at most one request runs and the latest camera wins.
  Future<void> _reproject() async {
    final map = _map;
    final center = _center;
    if (map == null || center == null) return;
    if (_projecting) {
      _projectAgain = true;
      return;
    }
    _projecting = true;
    try {
      do {
        _projectAgain = false;
        final places = _places;
        final points = [
          Point(coordinates: Position(center.lng, center.lat)),
          for (final p in places) Point(coordinates: Position(p.lng, p.lat)),
        ];
        final px = await map.pixelsForCoordinates(points);
        if (!mounted) return;
        setState(() {
          _youPx = Offset(px[0].x, px[0].y);
          _pinPx = {for (final (i, p) in places.indexed) p.restaurantId: Offset(px[i + 1].x, px[i + 1].y)};
        });
      } while (_projectAgain && mounted);
    } catch (_) {
      // The map can go away mid-request (tab switch); the next camera event retries.
    } finally {
      _projecting = false;
    }
  }

  // ---------------------------------------------------------- selection

  void _selectPlace(String restaurantId, List<NearbyOffer> cards) {
    setState(() {
      _selectedId = restaurantId;
      _cleared = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollCardsTo(restaurantId, cards));
  }

  void _clearSelection() {
    if (!mounted) return;
    setState(() {
      _selectedId = null;
      _cleared = true;
    });
  }

  double _cardWidth(double screenWidth) => math.min(340, screenWidth - 16 - 46);

  void _scrollCardsTo(String restaurantId, List<NearbyOffer> cards) {
    if (!_cards.hasClients) return;
    final index = cards.indexWhere((o) => o.restaurantId == restaurantId);
    if (index < 0) return;
    final extent = _cardWidth(MediaQuery.sizeOf(context).width) + 10;
    final target = (index * extent).clamp(0.0, _cards.position.maxScrollExtent);
    if ((target - _cards.offset).abs() > 1) {
      _cards.animateTo(target, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  /// A card snapped into place: its restaurant becomes the selected pin.
  void _onCardsSettled(List<NearbyOffer> cards, double extent) {
    if (!_cards.hasClients || cards.isEmpty) return;
    final index = (_cards.offset / extent).round().clamp(0, cards.length - 1);
    final id = cards[index].restaurantId;
    if (id != _selectedId) setState(() => _selectedId = id);
  }

  // -------------------------------------------------------------- sheet

  void _expandSheet() {
    if (_sheet.isAttached) {
      _sheet.animateTo(1, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    }
  }

  // ----------------------------------------------------------- location

  Future<void> _locateMe() async {
    final l10n = AppLocalizations.of(context);
    final location = ref.read(locationServiceProvider);
    setState(() => _locating = true);
    try {
      final result = await location.requestCurrent();
      if (!mounted) return;
      switch (result) {
        case LocationFound(:final lat, :final lng):
          // The camera fits again once the offers around the new location arrive.
          _fitted = false;
          await ref.read(sessionProvider.notifier).updateLocation(lat: lat, lng: lng);
        case LocationDenied():
          _tell(l10n.locationDenied);
        case LocationBlocked():
          _tell(l10n.locationBlocked, action: l10n.openSettings, onAction: location.openAppSettings);
        case LocationServiceOff():
          _tell(l10n.locationServiceOff, action: l10n.openSettings, onAction: location.openLocationSettings);
      }
    } catch (_) {
      if (mounted) _tell(l10n.locationFailed);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _tell(String message, {String? action, VoidCallback? onAction}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: action == null ? null : SnackBarAction(label: action, onPressed: onAction!),
    ));
  }

  // -------------------------------------------------------------- build

  double _topBarBottom(BuildContext context) => MediaQuery.paddingOf(context).top + 10 + 42;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final now = ref.now;
    final center = ref.watch(homeCenterProvider);
    final offersAsync = ref.watch(nearbyOffersProvider);
    final filters = ref.watch(homeFiltersProvider);

    final visible = applyHomeFilters(offersAsync.value ?? const [], filters, now);
    final places = groupByRestaurant(visible);
    final selectedId = places.any((p) => p.restaurantId == _selectedId)
        ? _selectedId
        : (_cleared ? null : places.firstOrNull?.restaurantId);

    // Re-project pins when the set of places or the user's location changes.
    _places = places;
    _center = center;
    final key = '${center.lat},${center.lng}|${places.map((p) => p.restaurantId).join(',')}';
    if (key != _projectedKey) {
      _projectedKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) => _reproject());
    }
    if (!_fitted && offersAsync.hasValue && !offersAsync.isLoading && places.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitCamera());
    }

    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        final height = box.maxHeight;
        final topBar = _topBarBottom(context);
        final cardsBottom = _sheetMin + _cardsGap;
        // Figma: the card row is about 318 px tall.
        final cardsTop = height - cardsBottom - 318;
        _viewport ??= CameraViewportState(center: Point(coordinates: Position(center.lng, center.lat)), zoom: _zoom);
        _viewSize = Size(width, height);
        // Pins need ~40 px above for the badge and ~30 px below for the
        // selected pin's name; the end side keeps clear of the locate button.
        _pinBox = Rect.fromLTRB(32, topBar + 40, width - 80, cardsTop - 30);
        final extent = _cardWidth(width) + 10;
        // Without Mapbox the pins are placed with the same fit, computed here.
        final fallbackCamera = _fittedCamera() ?? (lat: center.lat, lng: center.lng, zoom: _zoom);

        return Stack(
          children: [
            Positioned.fill(child: _mapLayer(z)),
            Positioned.fill(
              child: _PinLayer(
                places: places,
                selectedId: selectedId,
                positions: mapboxAvailable ? _pinPx : {
                  for (final p in places) p.restaurantId: projectToView(p.lat, p.lng, fallbackCamera, _viewSize!),
                },
                you: !center.isUserLocation
                    ? null
                    : (mapboxAvailable ? _youPx : projectToView(center.lat, center.lng, fallbackCamera, _viewSize!)),
                pinLabel: (p) => l10n.mapPinLabel(p.name, p.mealsLeft),
                onTap: (id) => _selectPlace(id, visible),
              ),
            ),
            PositionedDirectional(
              start: 16,
              end: 16,
              top: MediaQuery.paddingOf(context).top + 10,
              child: Row(
                children: [
                  Flexible(
                    child: _AreaPill(
                      label: ref.watch(homeAreaNameProvider).value ??
                          (center.isUserLocation ? l10n.homeAreaNearYou : l10n.homeAreaUnset),
                      onTap: () => context.push(Routes.setArea),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Spacer(),
                  _RoundMapButton(
                    label: l10n.notifications,
                    icon: ZadIcons.bell18,
                    onTap: () => context.push(Routes.notifications),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: cardsBottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16),
                      child: _RoundMapButton(
                        label: l10n.showMyLocation,
                        icon: ZadIcons.locate,
                        busy: _locating,
                        onTap: _locateMe,
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.bottomCenter,
                    child: selectedId == null || visible.isEmpty
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _cardRow(l10n, visible, width, extent, now),
                          ),
                  ),
                ],
              ),
            ),
            _sheetLayer(l10n, z, height, topBar, offersAsync, filters, visible, now),
          ],
        );
      },
    );
  }

  Widget _mapLayer(ZadColors z) {
    if (!mapboxAvailable) {
      // Web preview and tests: the Figma map stand-in, with pins placed by
      // the same Web Mercator maths Mapbox uses (map_fit.dart).
      return GestureDetector(
        onTap: _clearSelection,
        child: ColoredBox(
          color: z.nightSheet,
          child: SvgPicture.asset('assets/home/map_standin.svg', fit: BoxFit.cover, alignment: Alignment.topCenter),
        ),
      );
    }
    return MapWidget(
      key: const ValueKey('homeMap'),
      styleUri: MapboxStyles.DARK,
      viewport: _viewport,
      onMapCreated: _onMapCreated,
      onCameraChangeListener: (_) => _reproject(),
    );
  }

  Widget _cardRow(AppLocalizations l10n, List<NearbyOffer> cards, double width, double extent, DateTime now) {
    final cardWidth = _cardWidth(width);
    return NotificationListener<ScrollEndNotification>(
      onNotification: (_) {
        _onCardsSettled(cards, extent);
        return false;
      },
      child: SingleChildScrollView(
        controller: _cards,
        scrollDirection: Axis.horizontal,
        physics: _SnapPhysics(itemExtent: extent),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        // Room for the card shadow, which would otherwise be clipped.
        clipBehavior: Clip.none,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (i, o) in cards.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              SizedBox(
                width: cardWidth,
                child: ZadOfferPhotoCard(
                  restaurant: o.restaurantName,
                  details: l10n.cardDetails(o),
                  statusLabel: l10n.pickupStatus(o.offer, now),
                  untilLabel: l10n.pickupUntil(muscatClock(o.offer.pickupEnd)),
                  windowStartLabel: muscatClock(o.offer.pickupStart),
                  windowEndLabel: muscatClock(o.offer.pickupEnd),
                  pickupStart: o.offer.pickupStart,
                  pickupEnd: o.offer.pickupEnd,
                  now: now,
                  priceLabel: l10n.priceLabel(o.offer.priceBaisa),
                  wasPriceLabel: l10n.wasPriceLabel(o.offer),
                  mealsLeftLabel: l10n.mealsLeftShort(o.offer.quantityAvailable),
                  placeholderLabel: l10n.categoryLabel(o.offer.categoryEnum),
                  tagText: l10n.closingTag(o.offer, now),
                  onTap: () => context.push(Routes.mealDetails(o.id)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sheetLayer(
    AppLocalizations l10n,
    ZadColors z,
    double height,
    double topBar,
    AsyncValue<List<NearbyOffer>> offersAsync,
    HomeFilters filters,
    List<NearbyOffer> visible,
    DateTime now,
  ) {
    final minSize = (_sheetMin / height).clamp(0.1, 0.9);
    final maxSize = math.max(minSize, (height - topBar - 8) / height);
    final list = byPickupEnd(visible);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return DraggableScrollableSheet(
      controller: _sheet,
      initialChildSize: minSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      builder: (context, scroll) => DecoratedBox(
        decoration: BoxDecoration(
          color: z.nightSheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [BoxShadow(color: ZadColors.pinShadow, offset: Offset(0, -6), blurRadius: 12)],
        ),
        child: CustomScrollView(
          controller: scroll,
          slivers: [
            SliverToBoxAdapter(
              child: _MeasureHeight(
                onHeight: (h) {
                  if ((h - _sheetMin).abs() > 0.5) {
                    setState(() => _sheetMin = h);
                    unawaited(_placeOrnaments());
                  }
                },
                child: _SheetHeader(
                  title: _SheetTitle(offersAsync: offersAsync, visible: visible, filtered: !filters.isEmpty),
                  filters: filters,
                  search: _search,
                  searchFocus: _searchFocus,
                ),
              ),
            ),
            if (offersAsync.hasError && offersAsync.value == null)
              SliverToBoxAdapter(
                child: _SheetMessage(
                  title: l10n.homeLoadError,
                  action: l10n.tryAgain,
                  onAction: () => ref.invalidate(nearbyOffersProvider),
                ),
              )
            else if (offersAsync.value != null && list.isEmpty)
              SliverToBoxAdapter(
                child: filters.isEmpty
                    ? _SheetMessage(title: l10n.homeNoMealsTitle, body: l10n.homeNoMealsBody)
                    : _SheetMessage(title: l10n.homeNoMatchesTitle, body: l10n.homeNoMatchesBody),
              )
            else if (list.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
                  child: Text(l10n.closingFirst, style: ZadType.body(size: 14, weight: FontWeight.w600, color: z.card)),
                ),
              ),
              SliverList.builder(
                itemCount: list.length,
                itemBuilder: (context, i) => _OfferRow(
                  offer: list[i],
                  now: now,
                  onTap: () => context.push(Routes.mealDetails(list[i].id)),
                ),
              ),
            ],
            SliverToBoxAdapter(child: SizedBox(height: 24 + keyboard)),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- map layer

/// Leaf pins and the "you" dot over the map. Only the pins take taps; the
/// empty space lets gestures through to the map underneath.
class _PinLayer extends StatelessWidget {
  const _PinLayer({
    required this.places,
    required this.selectedId,
    required this.positions,
    required this.you,
    required this.pinLabel,
    required this.onTap,
  });

  final List<MapPlace> places;
  final String? selectedId;
  final Map<String, Offset> positions;
  final Offset? you;
  final String Function(MapPlace) pinLabel;
  final ValueChanged<String> onTap;

  /// Widest a selected pin's name may be before it is cut with "…".
  static const _labelMax = 150.0;

  /// How far to slide the name so a pin near an edge keeps it on screen.
  static double _labelShift(double x, double width) {
    const half = _labelMax / 2;
    const edge = 8.0;
    if (x - half < edge) return edge - (x - half);
    if (x + half > width - edge) return (width - edge) - (x + half);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final width = MediaQuery.sizeOf(context).width;
    // The selected pin is drawn last so it sits on top.
    final ordered = [
      for (final p in places)
        if (p.restaurantId != selectedId) p,
      for (final p in places)
        if (p.restaurantId == selectedId) p,
    ];
    return Stack(
      children: [
        if (you != null)
          Positioned(
            left: you!.dx - 20,
            top: you!.dy - 20,
            child: const IgnorePointer(child: _YouMarker()),
          ),
        for (final p in ordered)
          if (positions[p.restaurantId] case final pos?)
            if (p.restaurantId == selectedId)
              // The disc centre is the restaurant's location.
              Positioned(
                left: pos.dx,
                top: pos.dy - ZadSelectedMapPin.disc / 2,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: Semantics(
                    button: true,
                    selected: true,
                    label: pinLabel(p),
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(p.restaurantId),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: _labelMax),
                        child: ZadSelectedMapPin(
                          label: p.name,
                          meals: p.mealsLeft,
                          labelShift: _labelShift(pos.dx, width),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              // ZadMapPin pads 10 px on its end and 8 px on top for the badge;
              // its 32 px disc centre goes on the location.
              Positioned(
                left: pos.dx - (rtl ? 26 : 16),
                top: pos.dy - 24,
                child: Semantics(
                  button: true,
                  label: pinLabel(p),
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(p.restaurantId),
                    child: ZadMapPin(meals: p.mealsLeft),
                  ),
                ),
              ),
      ],
    );
  }
}

/// Figma "You · accuracy" (40 px halo) with the "You" dot (14 px) on top.
class _YouMarker extends StatelessWidget {
  const _YouMarker();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset('assets/home/you_accuracy.svg', width: 40, height: 40),
          SvgPicture.asset('assets/home/you.svg', width: 14, height: 14),
        ],
      ),
    );
  }
}

/// Figma "Pickup area": raised pill with the area name; opens "Set my area".
class _AreaPill extends StatelessWidget {
  const _AreaPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          boxShadow: [BoxShadow(color: ZadColors.buttonShadow, offset: Offset(0, 4), blurRadius: 14)],
        ),
        child: Material(
          color: z.nightRaised,
          shape: StadiumBorder(side: BorderSide(color: z.nightHairline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 12, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ZadIcon(ZadIcons.pinSmall, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZadType.body(size: 14, weight: FontWeight.w500, color: z.card),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ZadIcon(ZadIcons.chevronDown, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma "Notifications" / "Locate me": 42 px raised circle over the map.
class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({required this.label, required this.icon, required this.onTap, this.busy = false});

  final String label;
  final ZadIcons icon;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      label: label,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: ZadColors.buttonShadow, offset: Offset(0, 4), blurRadius: 14)],
        ),
        child: Material(
          color: z.nightRaised,
          shape: CircleBorder(side: BorderSide(color: z.nightHairline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: busy ? null : onTap,
            child: SizedBox.square(
              dimension: 42,
              child: Center(
                child: busy
                    ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: z.card))
                    : ZadIcon(icon, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Snaps a horizontal row to whole items of [itemExtent], like a PageView
/// whose pages are narrower than the screen (so the next card peeks in).
class _SnapPhysics extends ScrollPhysics {
  const _SnapPhysics({required this.itemExtent, super.parent});

  final double itemExtent;

  @override
  _SnapPhysics applyTo(ScrollPhysics? ancestor) => _SnapPhysics(itemExtent: itemExtent, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    var item = position.pixels / itemExtent;
    if (velocity < -tolerance.velocity) {
      item -= 0.5;
    } else if (velocity > tolerance.velocity) {
      item += 0.5;
    }
    final target = (item.roundToDouble() * itemExtent).clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < tolerance.distance) return null;
    return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
  }

  @override
  bool get allowImplicitScrolling => false;
}

// ----------------------------------------------------------------- sheet

/// Grabber, meal count, filter chips and search (the collapsed sheet).
class _SheetHeader extends ConsumerWidget {
  const _SheetHeader({required this.title, required this.filters, required this.search, required this.searchFocus});

  final Widget title;
  final HomeFilters filters;
  final TextEditingController search;
  final FocusNode searchFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final f = ref.read(homeFiltersProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(color: z.nightHairline, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 14),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: title),
          const SizedBox(height: 14),
          // Chips run to the screen edges (Figma clips the last one).
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ZadChip(label: l10n.filterClosingSoon, active: filters.closingSoon, onTap: f.toggleClosingSoon),
                const SizedBox(width: 8),
                ZadChip(label: l10n.free, active: filters.free, onTap: f.toggleFree),
                const SizedBox(width: 8),
                ZadChip(label: l10n.filterUnderOneOmr, active: filters.underOneOmr, onTap: f.toggleUnderOneOmr),
                for (final c in const [OfferCategory.bakery, OfferCategory.riceMandi]) ...[
                  const SizedBox(width: 8),
                  ZadChip(
                    label: l10n.categoryLabel(c),
                    active: filters.category == c,
                    onTap: () => f.toggleCategory(c),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchField(controller: search, focusNode: searchFocus, onChanged: f.setQuery),
          ),
        ],
      ),
    );
  }
}

/// "23 meals left near you tonight", with the count in sap.
class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.offersAsync, required this.visible, required this.filtered});

  final AsyncValue<List<NearbyOffer>> offersAsync;
  final List<NearbyOffer> visible;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final style = ZadType.display(size: 24, height: 28 / 24, letterSpacing: -0.36, color: z.card);
    if (offersAsync.value == null) {
      return Text(offersAsync.hasError ? l10n.homeLoadError : l10n.homeLoading, style: style);
    }
    final count = mealsLeft(visible);
    if (count == 0) return Text(filtered ? l10n.homeNoMatchesTitle : l10n.homeNoMealsTitle, style: style);
    final meals = l10n.homeMealsCount(count);
    final text = l10n.homeMealsTitle(meals);
    final at = text.indexOf(meals);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, at)),
          TextSpan(text: meals, style: style.copyWith(color: z.sap)),
          TextSpan(text: text.substring(at + meals.length)),
        ],
      ),
    );
  }
}

/// Figma "Search": raised pill with a rib-to-saffron outline.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.focusNode, required this.onChanged});

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(colors: [z.rib, z.rib, z.saffron], stops: const [0, 0.55, 1]),
      ),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 6, 18, 6),
        decoration: BoxDecoration(color: z.nightRaised, borderRadius: BorderRadius.circular(999)),
        child: Row(
          children: [
            const ZadIcon(ZadIcons.search, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 40,
                child: Center(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => focusNode.unfocus(),
                    cursorColor: z.sap,
                    style: ZadType.body(size: 14, color: z.card),
                    decoration: InputDecoration.collapsed(
                      hintText: l10n.searchMealsHint,
                      hintStyle: ZadType.body(size: 14, color: z.onFrondMuted),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One offer in the expanded sheet's list.
class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.offer, required this.now, required this.onTap});

  final NearbyOffer offer;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final o = offer.offer;
    final tag = l10n.closingTag(o, now);
    final mono10 = ZadType.mono(size: 10, weight: FontWeight.w400, color: z.onFrondMuted);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: z.nightHairline))),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment(-0.33, -1),
                  end: Alignment(0.33, 1),
                  colors: [ZadColors.photoPlaceholderTop, ZadColors.photoPlaceholderBottom],
                ),
              ),
              child: const Center(child: ZadIcon(ZadIcons.image, size: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.body(size: 15, weight: FontWeight.w600, color: z.card),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.offerRowDetails(offer.restaurantName, formatKm(offer.distanceM)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZadType.body(size: 13, color: z.onFrondMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(muscatClock(o.pickupStart), style: mono10),
                      const SizedBox(width: 6),
                      Expanded(child: PickupWindowBar(start: o.pickupStart, end: o.pickupEnd, now: now)),
                      const SizedBox(width: 6),
                      Text(muscatClock(o.pickupEnd), style: mono10),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.priceLabel(o.priceBaisa), style: ZadType.mono(size: 13, color: z.card)),
                const SizedBox(height: 4),
                Text(l10n.mealsLeftShort(o.quantityAvailable), style: ZadType.mono(size: 11, weight: FontWeight.w400, color: z.onFrondMuted)),
                if (tag != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: z.saffron, borderRadius: BorderRadius.circular(6)),
                    child: Text(tag, style: ZadType.mono(size: 10, color: z.ink)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty and error states inside the sheet.
class _SheetMessage extends StatelessWidget {
  const _SheetMessage({required this.title, this.body, this.action, this.onAction});

  final String title;
  final String? body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ZadType.body(size: 15, weight: FontWeight.w600, color: z.card)),
          if (body != null) ...[
            const SizedBox(height: 4),
            Text(body!, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
          ],
          if (action != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: z.sap, padding: EdgeInsets.zero),
              child: Text(action!, style: ZadType.body(size: 14, weight: FontWeight.w600, color: z.sap)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reports its child's height after layout (the collapsed sheet height).
class _MeasureHeight extends StatefulWidget {
  const _MeasureHeight({required this.onHeight, required this.child});

  final ValueChanged<double> onHeight;
  final Widget child;

  @override
  State<_MeasureHeight> createState() => _MeasureHeightState();
}

class _MeasureHeightState extends State<_MeasureHeight> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      if (mounted && box != null && box.hasSize) widget.onHeight(box.size.height);
    });
    return widget.child;
  }
}
