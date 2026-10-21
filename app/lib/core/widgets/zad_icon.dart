import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma `icon/*` set. Each SVG in `assets/icons/` is the icon's vector group as
/// Figma exports it, so it is placed inside the icon frame at the group's offset:
/// [box] is the frame size the asset was exported at, the rest is the group's
/// rect in that frame (including the stroke bleed).
enum ZadIcons {
  chevronLeft('chevron_left', 24, 0, 0, 24, 24),
  user('user', 24, 3.125, 2.125, 17.75, 19.75),
  userSmall('user_small', 20, 2.458, 1.625, 15.083, 16.75),
  store('store', 24, 1.125, 1.125, 21.75, 21.75),
  leaf('leaf', 28, 1.458, 1.458, 23.917, 23.917),
  leafPin('leaf_pin', 16, 0.333, 0.333, 14.667, 14.667),
  check('check', 16, 1.792, 3.125, 12.417, 9.083),
  mail('mail', 20, 0, 0, 20, 20),
  lock('lock', 20, 0, 0, 20, 20),
  eye('eye', 20, 0, 0, 20, 20),
  clock('clock', 20, 0.792, 0.792, 18.417, 18.417),
  shield('shield', 20, 2.458, 0.792, 15.083, 18.42),
  bell('bell', 20, 1.625, 0.792, 16.75, 18.417);

  const ZadIcons(this.file, this.box, this.left, this.top, this.width, this.height);

  final String file;
  final double box;
  final double left;
  final double top;
  final double width;
  final double height;

  String get asset => 'assets/icons/$file.svg';
}

/// One icon at [size] (defaults to the Figma frame size). Colours come from the
/// asset, which is already bound to the right token in Figma; pass [color]
/// (a `context.zad` token) only to re-tint it.
class ZadIcon extends StatelessWidget {
  const ZadIcon(this.icon, {super.key, this.size, this.color});

  final ZadIcons icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Direction arrows point the other way in a right-to-left layout (Arabic later).
    final mirror = icon == ZadIcons.chevronLeft && Directionality.of(context) == TextDirection.rtl;
    return SizedBox.square(
      dimension: size ?? icon.box,
      child: FittedBox(
        child: Transform.flip(
          flipX: mirror,
          child: SizedBox.square(
            dimension: icon.box,
            child: Stack(
              children: [
                Positioned(
                  left: icon.left,
                  top: icon.top,
                  width: icon.width,
                  height: icon.height,
                  child: SvgPicture.asset(
                    icon.asset,
                    fit: BoxFit.fill,
                    colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
