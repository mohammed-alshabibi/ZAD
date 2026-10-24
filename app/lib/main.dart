import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app.dart';
import 'core/config/mapbox_config.dart';
import 'core/widgets/zad_icon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Public token from config/mapbox.json (passed with --dart-define-from-file).
  if (mapboxAvailable) MapboxOptions.setAccessToken(mapboxAccessToken);
  await precacheZadIcons();
  runApp(const ProviderScope(child: ZadApp()));
}
