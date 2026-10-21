import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Outcome of asking for the phone's location.
sealed class LocationResult {
  const LocationResult();
}

class LocationFound extends LocationResult {
  const LocationFound(this.lat, this.lng);

  final double lat;
  final double lng;
}

/// The user said no this time; asking again is allowed.
class LocationDenied extends LocationResult {
  const LocationDenied();
}

/// The user blocked it; only the system settings can turn it back on.
class LocationBlocked extends LocationResult {
  const LocationBlocked();
}

/// Location services (GPS) are switched off on the phone.
class LocationServiceOff extends LocationResult {
  const LocationServiceOff();
}

/// Foreground location only ("while using the app", CLAUDE.md §6).
class LocationService {
  const LocationService();

  /// Shows the OS permission dialog if needed, then reads one position.
  Future<LocationResult> requestCurrent() async {
    if (!await Geolocator.isLocationServiceEnabled()) return const LocationServiceOff();

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        return const LocationDenied();
      case LocationPermission.deniedForever:
        return const LocationBlocked();
      case LocationPermission.whileInUse:
      case LocationPermission.always:
      case LocationPermission.unableToDetermine:
        break;
    }

    // ~100 m is all we keep, so medium accuracy is enough and faster.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LocationFound(position.latitude, position.longitude);
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}

final locationServiceProvider = Provider<LocationService>((ref) => const LocationService());
