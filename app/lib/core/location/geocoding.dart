import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/mapbox_config.dart';

/// A street address for a map point, e.g. "Way 4212" in "Muscat".
class PlaceAddress {
  const PlaceAddress({required this.line, this.city});

  /// Street-level text, saved as the restaurant's `address_text`.
  final String line;
  final String? city;
}

/// Turns a map point into a readable address (reverse geocoding).
abstract interface class Geocoder {
  /// Null when nothing useful is found or the lookup fails.
  Future<PlaceAddress?> addressAt({required double lat, required double lng});
}

/// Mapbox Geocoding v6 (`/search/geocode/v6/reverse`), free up to 100k
/// lookups a month. Muscat data usually has the street but no neighbourhood,
/// so the restaurant can edit the line afterwards.
class MapboxGeocoder implements Geocoder {
  MapboxGeocoder({Dio? dio, this.token = mapboxAccessToken})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 8)));

  final Dio _dio;
  final String token;

  @override
  Future<PlaceAddress?> addressAt({required double lat, required double lng}) async {
    if (token.isEmpty) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.mapbox.com/search/geocode/v6/reverse',
        queryParameters: {
          'longitude': lng,
          'latitude': lat,
          'limit': 1,
          'language': 'en',
          'access_token': token,
        },
      );
      final features = response.data?['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;
      final props = (features.first as Map<String, dynamic>)['properties'] as Map<String, dynamic>;
      return parseMapboxProperties(props);
    } on DioException {
      return null;
    }
  }
}

/// "Al Khuwair, Way 3013" from a Mapbox feature: neighbourhood (or locality)
/// first, then the street or address name. The city goes in [PlaceAddress.city].
PlaceAddress? parseMapboxProperties(Map<String, dynamic> props) {
  final context = (props['context'] as Map<String, dynamic>?) ?? const {};
  String? nameOf(String key) => (context[key] as Map<String, dynamic>?)?['name'] as String?;

  final area = nameOf('neighborhood') ?? nameOf('locality');
  final street = props['name'] as String?;
  final parts = [?area, if (street != null && street != area) street];
  if (parts.isEmpty) return null;
  return PlaceAddress(line: parts.join(', '), city: nameOf('place'));
}

final geocoderProvider = Provider<Geocoder>((ref) => MapboxGeocoder());
