import 'package:flutter/animation.dart';

/// A curve defined by evenly spaced samples, like CSS `linear(...)`.
/// Used for the Figma spring easings, which are exported as sample lists.
class SampledCurve extends Curve {
  const SampledCurve(this.samples);

  final List<double> samples;

  @override
  double transformInternal(double t) {
    final pos = t * (samples.length - 1);
    final i = pos.floor().clamp(0, samples.length - 2);
    final f = pos - i;
    return samples[i] + (samples[i + 1] - samples[i]) * f;
  }
}

/// Easings exported from the Figma splash timeline (node 11:179).
abstract final class ZadCurves {
  /// Leaf mark rotation spring.
  static const SampledCurve leafSpring = SampledCurve([
    0, 0.0391, 0.14, 0.2792, 0.4368, 0.5961, 0.7449, 0.8748, 0.9809, 1.0613, //
    1.1167, 1.1492, 1.1623, 1.1599, 1.1463, 1.1252, 1.1001, 1.074, 1.049, 1.0267,
    1.0081, 0.9937, 0.9834, 0.977, 0.9739, 0.9736, 0.9753, 0.9784, 0.9824, 0.9866,
    0.9908, 0.9946, 0.9978, 1.0004, 1.0022, 1.0035, 1.0041, 1.0043, 1.0041, 1.0037,
    1.0031, 1.0024, 1.0017, 1.0011, 1.0005, 1.0001, 0.9997, 0.9995, 0.9993, 0.9993,
    0.9993,
  ]);

  /// Leaf fill scale spring.
  static const SampledCurve fillSpring = SampledCurve([
    0, 0.0328, 0.1177, 0.2359, 0.3715, 0.5117, 0.6464, 0.7686, 0.8739, 0.9601, //
    1.0267, 1.0745, 1.1054, 1.1218, 1.1263, 1.1218, 1.1108, 1.0958, 1.0786, 1.0609,
    1.0439, 1.0286, 1.0154, 1.0046, 0.9963, 0.9904, 0.9866, 0.9846, 0.984, 0.9847,
    0.9861, 0.988, 0.9902, 0.9924, 0.9945, 0.9965, 0.9981, 0.9995, 1.0005, 1.0012,
    1.0017, 1.002, 1.002, 1.0019, 1.0017, 1.0015, 1.0012, 1.0009, 1.0007, 1.0004,
    1.0002,
  ]);

  /// "zad" letters pop in with a slight overshoot.
  static const Cubic letterPop = Cubic(0.45, 1.45, 0.8, 1);

  /// Tagline words (CSS ease-out).
  static const Cubic wordIn = Cubic(0, 0, 0.58, 1);
}
