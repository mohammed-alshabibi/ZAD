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
  bell('bell', 20, 1.625, 0.792, 16.75, 18.417),
  storeSmall('store_small', 20, 0.792, 0.792, 18.417, 18.417),
  phone('phone', 20, 0.792, 0.792, 18.417, 18.417),
  chefHat('chef_hat', 20, 1.623, 1.621, 16.756, 16.753),
  imagePlus('image_plus', 24, 2.125, 1.125, 20.75, 20.75),
  mapPin('map_pin', 24, 0, 0, 24, 24),
  chevronRight('chevron_right', 18, 5.875, 3.625, 6.25, 10.75),
  locate('locate', 18, 1.375, 0.625, 16, 16),
  leafPinSelected('leaf_pin_selected', 22, 0.833, 0.833, 19.417, 19.417),
  leafLarge('leaf_large', 48, 3.125, 3.125, 39.75, 39.75),
  plus('plus', 24, 4.125, 4.125, 15.75, 15.75),
  minus('minus', 24, 4.125, 11.125, 15.75, 1.75),
  sparkles('sparkles', 22, 0.958, 0.958, 20.084, 20.084),
  checkSmall('check_small', 14, 1.458, 2.625, 11.083, 8.167),
  checkLarge('check_large', 20, 2.083, 3.75, 15.833, 11.667),
  scan('scan', 20, 1.625, 1.625, 16.75, 16.75),
  tabHome('tab_home', 22, 1.875, 0.959, 18.25, 19.166),
  tabGrid('tab_grid', 22, 1.875, 1.875, 18.25, 18.25),
  tabChart('tab_chart', 22, 1.875, 1.875, 18.25, 18.25),
  tabUser('tab_user', 22, 2.792, 1.875, 16.417, 18.25),
  tabPlus('tab_plus', 24, 4.125, 4.125, 15.75, 15.75),
  tabTicket('tab_ticket', 22, 0.958, 3.708, 20.083, 14.583),
  image('image', 22, 1.875, 1.875, 18.25, 18.25),
  pinSmall('pin_small', 16, 1.792, 0.458, 12.417, 15.083),
  chevronDown('chevron_down', 14, 2.5, 4.25, 9, 5.5),
  bell18('bell_18', 18, 1.375, 0.625, 15.25, 16.75),
  search('search', 18, 1.375, 1.375, 15.25, 15.25);

  const ZadIcons(this.file, this.box, this.left, this.top, this.width, this.height);

  final String file;
  final double box;
  final double left;
  final double top;
  final double width;
  final double height;

  String get asset => 'assets/icons/$file.svg';
}

/// Loads every icon once at startup. Without this, an icon whose file
/// finishes loading after its card is first drawn can stay blank until the
/// next repaint (seen on the web build), and icons pop in on slow phones.
Future<void> precacheZadIcons() async {
  await Future.wait([
    for (final icon in ZadIcons.values)
      () {
        final loader = SvgAssetLoader(icon.asset);
        return svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
      }(),
  ]);
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
    final mirror = (icon == ZadIcons.chevronLeft || icon == ZadIcons.chevronRight) &&
        Directionality.of(context) == TextDirection.rtl;
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
