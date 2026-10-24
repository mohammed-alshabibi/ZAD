import 'dart:math' as math;
import 'dart:ui';

/// A map camera: the point at the middle of the map view, and the zoom.
typedef MapCamera = ({double lat, double lng, double zoom});

/// Web Mercator, as Mapbox draws it: at zoom z the world is 512 × 2^z
/// logical pixels wide. x and y are 0–1 across the world.
double mercatorX(double lng) => (lng + 180) / 360;

double mercatorY(double lat) {
  final s = math.sin(lat * math.pi / 180);
  return 0.5 - math.log((1 + s) / (1 - s)) / (4 * math.pi);
}

double _lngOf(double x) => x * 360 - 180;
double _latOf(double y) => math.atan(_sinh(math.pi * (1 - 2 * y))) * 180 / math.pi;
double _sinh(double v) => (math.exp(v) - math.exp(-v)) / 2;

double worldSize(double zoom) => 512 * math.pow(2, zoom).toDouble();

/// Where [lat]/[lng] is drawn on a map view of [view] size showing [camera].
Offset projectToView(double lat, double lng, MapCamera camera, Size view) {
  final world = worldSize(camera.zoom);
  return Offset(
    view.width / 2 + (mercatorX(lng) - mercatorX(camera.lng)) * world,
    view.height / 2 + (mercatorY(lat) - mercatorY(camera.lat)) * world,
  );
}

/// The camera that fits every point inside [box] (in view coordinates),
/// as close as [maxZoom] allows and never further out than [minZoom].
/// One point (or points on top of each other) uses [maxZoom].
MapCamera fitCamera(
  List<(double lat, double lng)> points,
  Rect box,
  Size view, {
  double minZoom = 11.5,
  double maxZoom = 15,
}) {
  assert(points.isNotEmpty);
  final xs = [for (final p in points) mercatorX(p.$2)];
  final ys = [for (final p in points) mercatorY(p.$1)];
  final minX = xs.reduce(math.min), maxX = xs.reduce(math.max);
  final minY = ys.reduce(math.min), maxY = ys.reduce(math.max);

  // Largest zoom where the points' span still fits the box.
  double zoomFor(double span, double pixels) =>
      span <= 0 ? maxZoom : math.log(pixels / (span * 512)) / math.ln2;
  final zoom = math.min(zoomFor(maxX - minX, box.width), zoomFor(maxY - minY, box.height)).clamp(minZoom, maxZoom);

  // Put the middle of the points on the middle of the box, then work out
  // which point lands in the middle of the whole view.
  final world = worldSize(zoom);
  final cx = (minX + maxX) / 2 - (box.center.dx - view.width / 2) / world;
  final cy = (minY + maxY) / 2 - (box.center.dy - view.height / 2) / world;
  return (lat: _latOf(cy), lng: _lngOf(cx), zoom: zoom);
}
