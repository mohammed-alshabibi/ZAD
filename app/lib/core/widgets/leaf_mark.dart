import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';

import '../theme/zad_colors.dart';

/// The ZAD leaf (Figma "Leaf mark", 124×124 at 1×): sap fill, card outline, frond midrib.
///
/// The outline and midrib "draw on" (path trim), so their geometry is read from the
/// SVG assets and stroked here; the fill is shown as the SVG itself.
/// All progress values run 0 → 1; the defaults show the finished mark.
class LeafMark extends StatelessWidget {
  const LeafMark({
    super.key,
    this.size = 124,
    this.fillOpacity = 1,
    this.fillScale = 1,
    this.outlineProgress = 1,
    this.midribProgress = 1,
  });

  final double size;
  final double fillOpacity;
  final double fillScale;
  final double outlineProgress;
  final double midribProgress;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return SizedBox.square(
      dimension: size,
      child: FittedBox(
        child: SizedBox.square(
          dimension: 124,
          child: Stack(
            children: [
              Opacity(
                opacity: fillOpacity.clamp(0, 1),
                child: Transform.scale(
                  scale: fillScale,
                  child: SvgPicture.asset('assets/splash/leaf_fill.svg', width: 124, height: 124),
                ),
              ),
              FutureBuilder<_LeafPaths>(
                future: _LeafPaths.load(),
                builder: (context, snap) {
                  final paths = snap.data;
                  if (paths == null) return const SizedBox.shrink();
                  return CustomPaint(
                    size: const Size.square(124),
                    painter: _LeafStrokePainter(
                      paths: paths,
                      outlineColor: z.card,
                      midribColor: z.frond,
                      outlineProgress: outlineProgress,
                      midribProgress: midribProgress,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stroke paths parsed once from the SVG assets, already offset into the 124 box
/// (offsets = the vector's position in Figma minus its stroke bleed).
class _LeafPaths {
  _LeafPaths(this.outline, this.outlineWidth, this.midrib, this.midribWidth);

  final Path outline;
  final double outlineWidth;
  final Path midrib;
  final double midribWidth;

  static Future<_LeafPaths>? _cache;
  static Future<_LeafPaths> load() => _cache ??= _read();

  static Future<_LeafPaths> _read() async {
    final outlineSvg = await rootBundle.loadString('assets/splash/leaf_outline.svg');
    final midribSvg = await rootBundle.loadString('assets/splash/leaf_midrib.svg');
    return _LeafPaths(
      _path(outlineSvg).shift(const Offset(6.006, 21.506)),
      _strokeWidth(outlineSvg),
      _path(midribSvg).shift(const Offset(11.431, 28.869)),
      _strokeWidth(midribSvg),
    );
  }

  static Path _path(String svg) => parseSvgPathData(RegExp(r' d="([^"]+)"').firstMatch(svg)!.group(1)!);

  static double _strokeWidth(String svg) =>
      double.parse(RegExp(r'stroke-width="([\d.]+)"').firstMatch(svg)!.group(1)!);
}

class _LeafStrokePainter extends CustomPainter {
  _LeafStrokePainter({
    required this.paths,
    required this.outlineColor,
    required this.midribColor,
    required this.outlineProgress,
    required this.midribProgress,
  });

  final _LeafPaths paths;
  final Color outlineColor;
  final Color midribColor;
  final double outlineProgress;
  final double midribProgress;

  @override
  void paint(Canvas canvas, Size size) {
    _drawTrimmed(canvas, paths.outline, outlineProgress, Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = paths.outlineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
    _drawTrimmed(canvas, paths.midrib, midribProgress, Paint()
      ..color = midribColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = paths.midribWidth
      ..strokeCap = StrokeCap.round);
  }

  void _drawTrimmed(Canvas canvas, Path path, double progress, Paint paint) {
    if (progress <= 0) return;
    if (progress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    final total = path.computeMetrics().fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * progress;
    final trimmed = Path();
    for (final PathMetric m in path.computeMetrics()) {
      if (remaining <= 0) break;
      trimmed.addPath(m.extractPath(0, remaining.clamp(0, m.length)), Offset.zero);
      remaining -= m.length;
    }
    canvas.drawPath(trimmed, paint);
  }

  @override
  bool shouldRepaint(_LeafStrokePainter old) =>
      old.outlineProgress != outlineProgress ||
      old.midribProgress != midribProgress ||
      old.outlineColor != outlineColor ||
      old.midribColor != midribColor;
}
