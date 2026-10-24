/// Distances are shown in km with one decimal, as in Figma: 640 m → "0.6 km",
/// 1180 m → "1.2 km". Under 100 m still reads "0.1 km".
String formatKm(int meters) {
  final tenths = (meters / 100).round().clamp(1, 1 << 30);
  return '${tenths ~/ 10}.${tenths % 10} km';
}
