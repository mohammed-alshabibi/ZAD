import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/zad_colors.dart';
import '../../../core/theme/zad_type.dart';
import '../../../core/widgets/zad_icon.dart';

/// Frame shared by the auth screens (Figma row 4): optional rib glow at the top,
/// a back button with an optional step label, scrolling content and actions
/// pinned to the bottom (they ride above the keyboard).
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.children,
    required this.actions,
    this.onBack,
    this.stepLabel,
    this.glow = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.physics,
  });

  final List<Widget> children;
  final List<Widget> actions;

  /// Null hides the back button. The header row shows if there is a back
  /// button or a [stepLabel].
  final VoidCallback? onBack;
  final String? stepLabel;
  final bool glow;
  final CrossAxisAlignment crossAxisAlignment;

  /// e.g. [AlwaysScrollableScrollPhysics] so pull-to-refresh works on short content.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final hasHeader = onBack != null || stepLabel != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: z.nightSheet,
        body: Stack(
          children: [
            if (glow) const _Glow(),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (hasHeader) _header(context, z),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: physics,
                      padding: EdgeInsetsDirectional.fromSTEB(20, hasHeader ? 24 : 38, 20, 20),
                      child: Column(crossAxisAlignment: crossAxisAlignment, children: children),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        16, 12, 16, keyboardOpen ? 16 : math.max(32, bottomInset + 16)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: actions),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ZadColors z) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 0),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (onBack != null)
              Align(alignment: AlignmentDirectional.centerStart, child: _backButton(context, z)),
            if (stepLabel != null)
              Text(stepLabel!, style: ZadType.body(size: 14, weight: FontWeight.w500, color: z.onFrondMuted)),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context, ZadColors z) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).back,
      child: Material(
        color: z.nightRaised,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onBack,
          child: const SizedBox.square(
            dimension: 40,
            child: Center(child: ZadIcon(ZadIcons.chevronLeft, size: 20)),
          ),
        ),
      ),
    );
  }
}

/// Figma "Glow": a 460×420 rib ellipse, 200 px above the top edge, blurred 75 px.
/// (flutter_svg cannot render the SVG's blur filter, so it is drawn here.)
class _Glow extends StatelessWidget {
  const _Glow();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Positioned(
      left: w / 2 - 230 + 1, // Figma: x −30 in a 402 frame, i.e. centred +1 px
      top: -200,
      width: 460,
      height: 420,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 75, sigmaY: 75, tileMode: TileMode.decal),
          child: CustomPaint(painter: _EllipsePainter(context.zad.rib)),
        ),
      ),
    );
  }
}

class _EllipsePainter extends CustomPainter {
  _EllipsePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawOval(Offset.zero & size, Paint()..color = color);

  @override
  bool shouldRepaint(_EllipsePainter old) => old.color != color;
}

/// "Prompt **Link**" line, e.g. "Already have an account? **Log in**".
/// The whole line is the tap target.
class AuthLinkText extends StatelessWidget {
  const AuthLinkText({
    super.key,
    required this.prompt,
    required this.link,
    required this.onTap,
    this.separator = ' ',
    this.textAlign = TextAlign.center,
  });

  final String prompt;
  final String link;
  final String separator;
  final VoidCallback onTap;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text.rich(
            TextSpan(
              style: ZadType.body(size: 14, color: z.onFrondMuted),
              children: [
                TextSpan(text: '$prompt$separator'),
                TextSpan(text: link, style: ZadType.body(size: 14, weight: FontWeight.w600, color: z.sap)),
              ],
            ),
            textAlign: textAlign,
          ),
        ),
      ),
    );
  }
}

/// 56 px frond tile with the sap leaf (Figma "Leaf mark" on Account type / Login).
class AuthLeafTile extends StatelessWidget {
  const AuthLeafTile({super.key});

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: z.frond,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: z.sap),
      ),
      child: const ZadIcon(ZadIcons.leaf, size: 28),
    );
  }
}

/// Screen title (Bricolage Grotesque SemiBold).
class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key, this.size = 30, this.textAlign});

  final String text;
  final double size;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: ZadType.display(size: size, height: (size + 6) / size, color: context.zad.card),
    );
  }
}

/// Muted intro paragraph under a title.
class AuthBody extends StatelessWidget {
  const AuthBody(this.text, {super.key, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: ZadType.body(size: 15, height: 22 / 15, color: context.zad.onFrondMuted),
    );
  }
}
