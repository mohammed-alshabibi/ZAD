import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/config/mapbox_config.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/location/geocoding.dart';
import '../../../core/location/location_service.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/map_picker.dart';
import '../../../core/widgets/zad_button.dart';
import '../../../core/widgets/zad_form_row.dart';
import '../../../core/widgets/zad_icon.dart';
import '../../auth/application/session.dart';

/// "Set my area" (§6: if location is denied, the user drops a pin for their
/// area instead). Same pattern as the restaurant's Pickup location: the pin
/// stays in the middle and the map moves under it. Saved through
/// `PUT /me/location`, rounded to ~100 m.
class SetAreaScreen extends ConsumerStatefulWidget {
  const SetAreaScreen({super.key});

  @override
  ConsumerState<SetAreaScreen> createState() => _SetAreaScreenState();
}

class _SetAreaScreenState extends ConsumerState<SetAreaScreen> {
  /// How far the map runs under the sheet's rounded top corners.
  static const _underSheet = 28.0;

  late double _lat = ref.read(sessionProvider)?.lat ?? muscatLat;
  late double _lng = ref.read(sessionProvider)?.lng ?? muscatLng;
  String? _area;
  var _lookingUp = false;
  var _locating = false;
  var _saving = false;
  var _lookupSeq = 0;

  MapboxMap? _map;
  double _sheetHeight = 300;

  @override
  void initState() {
    super.initState();
    unawaited(_lookUpArea());
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await Future.wait([
      map.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
      map.compass.updateSettings(CompassSettings(enabled: false)),
      map.gestures.updateSettings(GesturesSettings(rotateEnabled: false, pitchEnabled: false)),
      // The Mapbox logo and attribution must stay visible above the sheet.
      map.logo.updateSettings(LogoSettings(marginBottom: _underSheet + 8)),
      map.attribution.updateSettings(AttributionSettings(marginBottom: _underSheet + 8)),
    ]);
  }

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
    await _lookUpArea();
  }

  /// "Al Khuwair, Muscat" for the pin (the same wording as the Home area pill).
  Future<void> _lookUpArea() async {
    final seq = ++_lookupSeq;
    setState(() => _lookingUp = true);
    final place = await ref.read(geocoderProvider).addressAt(lat: _lat, lng: _lng);
    if (!mounted || seq != _lookupSeq) return;
    setState(() {
      _lookingUp = false;
      final area = place?.area;
      final city = place?.city;
      _area = area == null ? city : (city == null || city == area ? area : '$area, $city');
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
            CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 14),
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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      // The session rounds to 3 decimals before sending (§6).
      await ref.read(sessionProvider.notifier).updateLocation(lat: _lat, lng: _lng);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.setAreaSaved)));
      context.go(Routes.userHome);
    } catch (_) {
      if (mounted) _tell(l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: math.max(0, _sheetHeight - _underSheet),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (mapboxAvailable)
                    MapWidget(
                      key: const ValueKey('setAreaMap'),
                      styleUri: MapboxStyles.DARK,
                      viewport: CameraViewportState(center: Point(coordinates: Position(_lng, _lat)), zoom: 13.5),
                      onMapCreated: _onMapCreated,
                      onMapIdleListener: _onMapIdle,
                    )
                  else
                    MapFallback(message: l10n.mapUnavailable),
                  MapCentrePin(hint: l10n.setAreaHint),
                  PositionedDirectional(
                    end: 16,
                    bottom: _underSheet + 30,
                    child: MapLocateButton(label: l10n.pickupLocateMe, busy: _locating, onTap: _locateMe),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              start: 16,
              top: topInset + 6,
              child: MapRoundButton(
                label: l10n.back,
                onTap: () => context.canPop() ? context.pop() : context.go(Routes.userHome),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: MeasureHeight(
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

  Widget _sheet(AppLocalizations l10n, ZadColors z) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
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
          Text(l10n.setAreaTitle, style: ZadType.display(size: 22, height: 28 / 22, color: z.card)),
          const SizedBox(height: 6),
          Text(l10n.setAreaBody, style: ZadType.body(size: 14, height: 20 / 14, color: z.onFrondMuted)),
          const SizedBox(height: 10),
          ZadFormRow(
            icon: ZadIcons.mapPin,
            title: _area ?? (_lookingUp ? l10n.setAreaFinding : l10n.setAreaPinned),
            value: l10n.setAreaPrivacy,
            chevron: false,
          ),
          const SizedBox(height: 18),
          ZadButton(label: l10n.setAreaSave, loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
