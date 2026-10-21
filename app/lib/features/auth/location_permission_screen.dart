import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/location/location_service.dart';
import '../../core/router/routes.dart';
import '../../core/theme/zad_colors.dart';
import '../../core/theme/zad_type.dart';
import '../../core/widgets/zad_button.dart';
import '../../core/widgets/zad_icon.dart';
import '../../core/widgets/zad_map_pin.dart';
import 'application/session.dart';
import 'widgets/auth_layout.dart';

/// Figma "Auth — Location permission" (36:786): explains why before the OS
/// dialog appears (CLAUDE.md §6). If the user says no, they set their area by
/// dropping a pin instead.
class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends ConsumerState<LocationPermissionScreen> {
  var _busy = false;

  Future<void> _turnOn() async {
    final location = ref.read(locationServiceProvider);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final result = await location.requestCurrent();
      if (!mounted) return;
      switch (result) {
        case LocationFound(:final lat, :final lng):
          await ref.read(sessionProvider.notifier).updateLocation(lat: lat, lng: lng);
          if (mounted) context.go(Routes.userHome);
        case LocationDenied():
          _tell(l10n.locationDenied);
        case LocationBlocked():
          _tell(l10n.locationBlocked, action: l10n.openSettings, onAction: location.openAppSettings);
        case LocationServiceOff():
          _tell(l10n.locationServiceOff, action: l10n.openSettings, onAction: location.openLocationSettings);
      }
    } catch (_) {
      if (mounted) _tell(l10n.locationFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _tell(String message, {String? action, VoidCallback? onAction}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: action == null ? null : SnackBarAction(label: action, onPressed: onAction!),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthLayout(
      crossAxisAlignment: CrossAxisAlignment.center,
      actions: [
        ZadButton(label: l10n.locationTurnOn, loading: _busy, onPressed: _turnOn),
        const SizedBox(height: 6),
        ZadButton(
          label: l10n.locationSetArea,
          style: ZadButtonStyle.ghost,
          onPressed: _busy ? null : () => context.push(Routes.setArea),
        ),
      ],
      children: [
        _RadiusIllustration(radiusLabel: l10n.locationRadiusLabel),
        const SizedBox(height: 26),
        AuthTitle(l10n.locationTitle, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        AuthBody(l10n.locationBody, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        _PrivacyCard(rows: [
          (ZadIcons.clock, l10n.locationWhileUsing),
          (ZadIcons.shield, l10n.locationRounded),
          (ZadIcons.bell, l10n.locationAlerts),
        ]),
      ],
    );
  }
}

/// Three rib rings around a "you" dot, three leaf pins and a "3 km" label.
/// Positions are the Figma "Illustration" frame (362×230). Decorative only.
class _RadiusIllustration extends StatelessWidget {
  const _RadiusIllustration({required this.radiusLabel});

  final String radiusLabel;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    Widget svg(String name, double left, double top, double size) => Positioned(
          left: left,
          top: top,
          width: size,
          height: size,
          child: SvgPicture.asset('assets/auth/$name.svg', width: size, height: size),
        );

    // Shrinks on phones narrower than the 402 px Figma frame.
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 362,
          height: 230,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              svg('ring_outer', 67, 1, 228),
              svg('ring_middle', 106, 40, 150),
              svg('ring_inner', 143, 77, 76),
              svg('you_halo', 161, 95, 40),
              // 18 px dot; the SVG adds 3 px of stroke on each side.
              svg('you', 169, 103, 24),
              const Positioned(left: 43, top: 16, child: ZadMapPin(meals: 4)),
              const Positioned(left: 241, top: 42, child: ZadMapPin(meals: 2)),
              const Positioned(left: 193, top: 148, child: ZadMapPin(meals: 6)),
              Positioned(
                left: 0,
                right: 0,
                top: 216.5,
                child: Center(
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: z.nightRaised,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: z.nightHairline),
                    ),
                    child: Text(radiusLabel, style: ZadType.body(size: 12, weight: FontWeight.w500, color: z.sap)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma "Privacy card": icon + one-line promise per row.
class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.rows});

  final List<(ZadIcons, String)> rows;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: z.nightRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: z.nightHairline),
      ),
      child: Column(
        children: [
          for (final (i, (icon, text)) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              children: [
                ZadIcon(icon, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: ZadType.body(size: 14, height: 20 / 14, color: z.card))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
