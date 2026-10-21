import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app.dart';
import 'core/config/mapbox_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Public token from config/mapbox.json (passed with --dart-define-from-file).
  if (mapboxAvailable) MapboxOptions.setAccessToken(mapboxAccessToken);
  runApp(const ProviderScope(child: ZadApp()));
}
