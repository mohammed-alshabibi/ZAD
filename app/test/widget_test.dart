import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/motion/zad_curves.dart';
import 'package:zad/core/theme/zad_colors.dart';

void main() {
  test('ZadColors match the Figma "ZAD tokens" collection', () {
    const z = ZadColors.brand;
    expect(z.frond, const Color(0xFF123D2C));
    expect(z.sap, const Color(0xFFCFE6C0));
    expect(z.saffron, const Color(0xFFE59A2B));
    expect(z.nightSheet, const Color(0xFF141A16));
    expect(z.onFrondMuted.a, closeTo(0.8, 0.01));
    expect(z.nightHairline.a, closeTo(0.12, 0.01));
  });

  test('SampledCurve starts at 0, ends near 1 and overshoots like a spring', () {
    const c = ZadCurves.leafSpring;
    expect(c.transform(0), 0);
    expect(c.transform(1), closeTo(1, 0.01));
    expect(c.transform(0.25), greaterThan(1)); // overshoot
  });
}
