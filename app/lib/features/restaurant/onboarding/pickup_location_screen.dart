import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/config/mapbox_config.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/location/geocoding.dart';
import '../../../core/location/location_service.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_form_row.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../../core/widgets/zad_map_pin.dart';
import '../../../core/widgets/zad_text_field.dart';
import '../application/onboarding_draft.dart';
import '../domain/restaurant.dart';

/// Figma "Onboarding — Pickup location" (38:873), setup step 2 of 3.
/// The pin stays in the middle and the owner moves the Mapbox map under it;
/// when the map stops, the address is looked up for the pin.
class PickupLocationScreen extends ConsumerStatefulWidget {
  const PickupLocationScreen({super.key});

  @override
  ConsumerState<PickupLocationScreen> createState() => _PickupLocationScreenState();
}

class _PickupLocationScreenState extends ConsumerState<PickupLocationScreen> {
  /// How far the map runs under the sheet's rounded top corners.
  static const _underSheet = 28.0;

  late final RestaurantDraft _draft = ref.read(onboardingDraftProvider);
  late double _lat = _draft.lat ?? muscatLat;
  late double _lng = _draft.lng ?? muscatLng;
  late String _address = _draft.addressText;
  String? _city;

  /// True once the owner typed the address: the pin no longer overwrites it.
  late bool _addressEdited = _draft.addressText.isNotEmpty;
  var _lookingUp = false;
  var _locating = false;
  var _submitted = false;
  var _lookupSeq = 0;

  MapboxMap? _map;
  double _sheetHeight = 260;

  @override
  void initState() {
    super.initState();
    if (!_addressEdited) unawaited(_lookUpAddress());
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await Future.wait([
      map.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
      map.compass.updateSettings(CompassSettings(enabled: false)),
      // A flat, north-up map is easier for placing an entrance.
      map.gestures.updateSettings(GesturesSettings(rotateEnabled: false, pitchEnabled: false)),
      _placeOrnaments(),
    ]);
  }

  /// The Mapbox logo and attribution must stay visible, so they sit just
  /// above the sheet instead of under it.
  Future<void> _placeOrnaments() async {
    final map = _map;
    if (map == null) return;
    const margin = _underSheet + 8;
    await map.logo.updateSettings(LogoSettings(marginBottom: margin));
    await map.attribution.updateSettings(AttributionSettings(marginBottom: margin));
  }

  /// Map stopped moving: read the centre (the pin) and look up its address.
  Future<void> _onMapIdle(MapIdleEventData _) async {
    final map = _map;
    if (map == null) return;
    final center = (await map.getCameraState()).center.coordinates;
    final moved = (center.lat.toDouble() - _lat).abs() > 1e-6 || (center.lng.toDouble() - _lng).abs() > 1e-6;
    if (!moved || !mounted) return;
    setState(() {
      _lat = center.lat.toDouble();
      _lng = center.lng.toDouble();
    });
    if (!_addressEdited) await _lookUpAddress();
  }

  Future<void> _lookUpAddress() async {
    final seq = ++_lookupSeq;
    setState(() => _lookingUp = true);
    final place = await ref.read(geocoderProvider).addressAt(lat: _lat, lng: _lng);
    // Only the latest lookup wins if the map moved again meanwhile.
    if (!mounted || seq != _lookupSeq) return;
    setState(() {
      _lookingUp = false;
      if (place != null && !_addressEdited) {
        _address = place.line;
        _city = place.city;
      }
    });
  }

  Future<void> _locateMe() async {
    final l10n = AppLocalizations.of(context);
    final location = ref.read(locationServiceProvider);
    setState(() => _locating = true);
    try {
      final result = await location.requestCurrent();
      if (!mounted) return;
      switch (result) {
        case LocationFound(:final lat, :final lng):
          await _map?.flyTo(
            CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 17),
            MapAnimationOptions(duration: 900),
          );
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

  Future<void> _editAddress() async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.zad.nightSheet,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddressSheet(initial: _address),
    );
    if (text == null || !mounted) return;
    setState(() {
      _address = text.trim();
      _addressEdited = _address.isNotEmpty;
    });
  }

  void _confirm() {
    setState(() => _submitted = true);
    if (RestaurantValidators.address(_address) != null) return;
    ref.read(onboardingDraftProvider.notifier).setLocation(lat: _lat, lng: _lng, addressText: _address.trim());
    context.push(Routes.restaurantOnboardingTypicalDay);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.nightSheet,
        body: Stack(
          children: [
            // Map + centre pin, ending just under the sheet's rounded top.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: math.max(0, _sheetHeight - _underSheet),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _mapLayer(l10n),
                  _CentrePin(label: _draft.name, hint: l10n.pickupMoveHint),
                  PositionedDirectional(
                    end: 16,
                    bottom: _underSheet + 30,
                    child: _LocateButton(label: l10n.pickupLocateMe, busy: _locating, onTap: _locateMe),
                  ),
                ],
              ),
            ),
            // Back button and step pill over the map.
            PositionedDirectional(
              start: 16,
              end: 16,
              top: topInset + 6,
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _RoundButton(label: l10n.back, onTap: () => context.pop()),
                    ),
                    _StepPill(text: l10n.onboardingStep(2, 3)),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _MeasureHeight(
                onHeight: (h) {
                  if ((h - _sheetHeight).abs() > 0.5) setState(() => _sheetHeight = h);
                },
                child: _sheet(l10n, z),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapLayer(AppLocalizations l10n) {
    if (!mapboxAvailable) return _MapFallback(message: l10n.mapUnavailable);
    return MapWidget(
      key: const ValueKey('pickupMap'),
      styleUri: MapboxStyles.DARK,
      viewport: CameraViewportState(center: Point(coordinates: Position(_lng, _lat)), zoom: 16.5),
      onMapCreated: _onMapCreated,
      onMapIdleListener: _onMapIdle,
    );
  }

  Widget _sheet(AppLocalizations l10n, ZadColors z) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final hasAddress = _address.trim().isNotEmpty;
    final String title;
    final String detail;
    if (hasAddress) {
      title = _address;
      detail = _addressEdited || _city == null ? l10n.pickupEditHint : l10n.pickupFromPin(_city!);
    } else {
      title = _lookingUp ? l10n.pickupFindingAddress : l10n.pickupNoAddress;
      detail = l10n.pickupEditHint;
    }
    final error = _submitted && !hasAddress ? l10n.errorAddressRequired : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(16, 10, 16, math.max(32, bottomInset + 16)),
      decoration: BoxDecoration(
        color: z.nightSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: z.nightHairline)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: z.nightHairline, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 18),
          Text(l10n.pickupTitle, style: ZadType.display(size: 22, height: 28 / 22, color: z.card)),
          const SizedBox(height: 6),
          Text(l10n.pickupBody, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
          const SizedBox(height: 10),
          ZadFormRow(icon: ZadIcons.mapPin, title: title, value: detail, onTap: _editAddress),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error, style: ZadType.body(size: 12, height: 16 / 12, color: z.danger)),
          ],
          const SizedBox(height: 18),
          ZadButton(label: l10n.confirmLocation, onPressed: _confirm),
        ],
      ),
    );
  }
}

/// Fixed centre pin with its ground shadow and the "Move the map…" hint.
/// The point being chosen is the bottom of the pin's disc, at the exact
/// centre of the map.
class _CentrePin extends StatelessWidget {
  const _CentrePin({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    const disc = ZadSelectedMapPin.disc;
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) {
          final cx = box.maxWidth / 2;
          final cy = box.maxHeight / 2;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Figma: hint pill 54 px above the disc.
              Positioned(
                left: 16,
                right: 16,
                top: cy - disc - 54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: z.nightRaised,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: z.nightHairline),
                    ),
                    child: Text(hint, textAlign: TextAlign.center, style: ZadType.body(size: 13, color: z.card)),
                  ),
                ),
              ),
              Positioned(
                left: cx - 13,
                top: cy - 4,
                child: SvgPicture.asset('assets/onboarding/pin_shadow.svg', width: 26, height: 8),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: cy - disc,
                child: Center(child: ZadSelectedMapPin(label: label)),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shown instead of the map on the web preview, in tests, or without a token.
class _MapFallback extends StatelessWidget {
  const _MapFallback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return ColoredBox(
      color: z.nightRaised,
      child: Align(
        alignment: const Alignment(0, 0.55),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: ZadType.body(size: 12, height: 16 / 12, color: z.onFrondMuted),
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(color: z.nightRaised, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: ZadType.body(size: 13, weight: FontWeight.w500, color: z.card)),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.zad.nightRaised,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox.square(dimension: 40, child: Center(child: ZadIcon(ZadIcons.chevronLeft, size: 20))),
        ),
      ),
    );
  }
}

/// Figma "Locate me": 42 px raised circle with the locate arrow.
class _LocateButton extends StatelessWidget {
  const _LocateButton({required this.label, required this.busy, required this.onTap});

  final String label;
  final bool busy;
  final VoidCallback onTap;

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
                    ? SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: z.card),
                      )
                    : const ZadIcon(ZadIcons.locate, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to type or fix the pickup address.
class _AddressSheet extends StatefulWidget {
  const _AddressSheet({required this.initial});

  final String initial;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final z = context.zad;
    final bottom = math.max(MediaQuery.viewInsetsOf(context).bottom, MediaQuery.viewPaddingOf(context).bottom);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 18, 16, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.pickupAddressTitle, style: ZadType.display(size: 22, height: 28 / 22, color: z.card)),
          const SizedBox(height: 16),
          ZadTextField(
            label: l10n.pickupAddressField,
            controller: _controller,
            leadingIcon: ZadIcons.storeSmall,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            helperText: l10n.pickupAddressHelper,
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
          const SizedBox(height: 18),
          ZadButton(label: l10n.save, onPressed: () => Navigator.pop(context, _controller.text)),
        ],
      ),
    );
  }
}

/// Reports its child's height after layout (used to sit the map behind the sheet).
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
