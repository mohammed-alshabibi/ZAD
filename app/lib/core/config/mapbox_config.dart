import 'package:flutter/foundation.dart';

/// Mapbox public token (`pk.…`), passed at build time so it never sits in git:
/// `flutter run --dart-define-from-file=config/mapbox.json`
/// (copy `config/mapbox.example.json` to `config/mapbox.json` first).
const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

/// The Mapbox map runs on Android/iOS only, and only with a token.
/// Elsewhere (web preview, tests, missing token) screens show a fallback.
bool get mapboxAvailable =>
    mapboxAccessToken.isNotEmpty &&
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

/// Al Khuwair, Muscat: where maps open when there is no better location.
const muscatLat = 23.588;
const muscatLng = 58.391;
