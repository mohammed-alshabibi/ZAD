import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/motion/zad_curves.dart';
import '../../core/router/routes.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/leaf_mark.dart';
import '../../core/widgets/zad_button.dart';

/// Figma "Splash — Animated" (11:179): 4 s intro, then the welcome actions.
/// Timings are the Figma keyframes in milliseconds; the intro plays once,
/// the background glows keep drifting.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _totalMs = 4000.0;

  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
    } else if (!_intro.isAnimating && _intro.value == 0) {
      _intro.forward();
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _drift.dispose();
    super.dispose();
  }

  /// Progress of a keyframe segment [startMs, endMs] with [curve].
  double _seg(double startMs, double endMs, [Curve curve = Curves.linear]) {
    final t = ((_intro.value * _totalMs - startMs) / (endMs - startMs)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.frond,
        body: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

            return AnimatedBuilder(
              animation: Listenable.merge([_intro, _drift]),
              builder: (context, _) {
                // Brand lockup slides up from 134 px below its resting place.
                final lockupDy = 134 * (1 - _seg(1950, 2650, Curves.easeInOut));
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Aurora: four blurred glows + bottom shade, fades in over 1 s.
                    Positioned.fill(
                      child: Opacity(
                        opacity: _seg(0, 1000, Curves.easeOut),
                        child: ClipRect(
                          child: Stack(
                            children: [
                              _glow(w, h, cx: 370, cy: 130, r: 200, color: z.rib, opacity: 0.95, drift: const Offset(40, 36)),
                              _glow(w, h, cx: 40, cy: 300, r: 150, color: z.sap, opacity: 0.45, drift: const Offset(50, -40)),
                              _glow(w, h, cx: 350, cy: 610, r: 140, color: z.saffron, opacity: 0.55, drift: const Offset(-60, -56)),
                              _glow(w, h, cx: 60, cy: 730, r: 130, color: z.sap, opacity: 0.30, drift: const Offset(44, -30)),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 360,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        ZadColors.splashShade.withValues(alpha: 0),
                                        ZadColors.splashShade.withValues(alpha: 0.9),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Brand lockup, centred 134 px above the middle of the screen.
                    Positioned(
                      left: 0,
                      right: 0,
                      top: h / 2 - 134 + lockupDy,
                      child: FractionalTranslation(
                        translation: const Offset(0, -0.5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: -0.314 * (1 - _seg(600, 1450, ZadCurves.leafSpring)),
                              child: LeafMark(
                                fillOpacity: _seg(750, 1000, Curves.easeOut),
                                fillScale: 0.5 + 0.5 * _seg(750, 1350, ZadCurves.fillSpring),
                                outlineProgress: _seg(200, 950, Curves.easeInOut),
                                midribProgress: _seg(1000, 1400, Curves.easeOut),
                              ),
                            ),
                            const SizedBox(height: 2),
                            _wordmark(z),
                            const SizedBox(height: 2),
                            Opacity(
                              opacity: _seg(1550, 1950, Curves.easeOut),
                              child: Transform.translate(
                                offset: Offset(0, 14 * (1 - _seg(1550, 1950, Curves.easeOut))),
                                child: Text(
                                  'زاد', // brand name, shown in Arabic in every locale
                                  textDirection: TextDirection.rtl,
                                  style: ZadType.body(size: 30, weight: FontWeight.w600, color: z.sap),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tagline, 23 px below the middle; words rise in one by one.
                    Positioned(
                      left: 20,
                      right: 20,
                      top: h / 2 + 23,
                      child: _tagline(l10n.splashTagline, z),
                    ),

                    // Actions
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: math.max(34, bottomInset + 16),
                      child: Opacity(
                        opacity: _seg(3000, 3400, Curves.easeOut),
                        child: Transform.translate(
                          offset: Offset(0, 32 * (1 - _seg(3000, 3400, Curves.easeOut))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ZadButton(
                                label: l10n.getStarted,
                                onPressed: () => context.push(Routes.accountType),
                              ),
                              const SizedBox(height: 10),
                              ZadButton(
                                label: l10n.haveAccount,
                                style: ZadButtonStyle.ghost,
                                height: 40,
                                onPressed: () => context.push(Routes.login),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.splashLegal,
                                textAlign: TextAlign.center,
                                style: ZadType.body(size: 11, color: z.onFrondMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// One aurora glow. Position is given in the 402×874 Figma frame and scaled
  /// to the screen; it drifts by [drift] and grows to 1.15× and back every 4 s.
  Widget _glow(double w, double h,
      {required double cx,
      required double cy,
      required double r,
      required Color color,
      required double opacity,
      required Offset drift}) {
    final t = Curves.easeInOut.transform(1 - (2 * _drift.value - 1).abs());
    final scale = 1 + 0.15 * t;
    return Positioned(
      left: cx / 402 * w - r + drift.dx * t,
      top: cy / 874 * h - r + drift.dy * t,
      width: r * 2,
      height: r * 2,
      child: Transform.scale(
        scale: scale,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55, tileMode: TileMode.decal),
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: opacity)),
          ),
        ),
      ),
    );
  }

  /// "zad": letters rise 50 px, grow from 60 % and fade in, 175 ms apart from 1150 ms.
  Widget _wordmark(ZadColors z) {
    final style = ZadType.wordmark(size: 104, color: z.card);
    const word = 'zad';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < word.length; i++)
          Builder(builder: (_) {
            final start = 1150.0 + 175 * i;
            final p = _seg(start, start + 350, ZadCurves.letterPop);
            return Opacity(
              opacity: p.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 50 * (1 - p)),
                child: Transform.scale(scale: 0.6 + 0.4 * p, child: Text(word[i], style: style)),
              ),
            );
          }),
      ],
    );
  }

  /// Tagline: each word rises 16 px, un-blurs from 8 px and fades in, ~61 ms apart from 2600 ms.
  Widget _tagline(String text, ZadColors z) {
    final style = ZadType.body(size: 17, height: 25 / 17, color: z.onFrondMuted);
    var index = 0;
    final lines = text.split('\n');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final word in line.split(' '))
                Builder(builder: (_) {
                  final start = 2600.0 + 60.87 * index++;
                  final p = _seg(start, start + 152, ZadCurves.wordIn);
                  final blur = 8 * (1 - p);
                  Widget child = Text('$word ', style: style);
                  if (blur > 0.05) {
                    child = ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: child,
                    );
                  }
                  return Opacity(
                    opacity: p,
                    child: Transform.translate(offset: Offset(0, 16 * (1 - p)), child: child),
                  );
                }),
            ],
          ),
      ],
    );
  }
}
