import 'package:flutter/material.dart';

import '../theme/zad_colors.dart';
import '../theme/zad_type.dart';
import 'zad_icon.dart';

/// Figma component "Text field" (35:695): label above a raised rounded input,
/// optional helper below. Focused = sap outline, Error = danger outline + danger
/// helper ([errorText] replaces [helperText]).
class ZadTextField extends StatefulWidget {
  const ZadTextField({
    super.key,
    required this.label,
    required this.controller,
    this.leadingIcon,
    this.helperText,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.showPasswordLabel,
    this.hidePasswordLabel,
  });

  final String label;
  final TextEditingController controller;
  final ZadIcons? leadingIcon;
  final String? helperText;
  final String? errorText;

  /// Password field: hides the text and adds the eye toggle as the trailing icon.
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Screen-reader labels for the eye toggle (password fields only).
  final String? showPasswordLabel;
  final String? hidePasswordLabel;

  @override
  State<ZadTextField> createState() => _ZadTextFieldState();
}

class _ZadTextFieldState extends State<ZadTextField> {
  final _focus = FocusNode();
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = context.zad;
    final error = widget.errorText;
    final helper = error ?? widget.helperText;
    final border = error != null
        ? Border.all(color: z.danger, width: 1.5)
        : _focus.hasFocus
            ? Border.all(color: z.sap, width: 1.5)
            : Border.all(color: z.nightHairline);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: ZadType.body(size: 13, weight: FontWeight.w500, color: z.onFrondMuted)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _focus.requestFocus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 54,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: z.nightRaised,
              borderRadius: BorderRadius.circular(16),
              border: border,
            ),
            child: Row(
              children: [
                if (widget.leadingIcon != null) ...[
                  ZadIcon(widget.leadingIcon!, size: 20),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    obscureText: _hidden,
                    obscuringCharacter: '•',
                    enableSuggestions: !widget.obscure,
                    autocorrect: !widget.obscure,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    autofillHints: widget.autofillHints,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    cursorColor: z.sap,
                    style: ZadType.body(size: 16, color: z.card),
                    decoration: const InputDecoration.collapsed(hintText: null),
                  ),
                ),
                if (widget.obscure) ...[
                  const SizedBox(width: 12),
                  Semantics(
                    button: true,
                    label: _hidden ? widget.showPasswordLabel : widget.hidePasswordLabel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _hidden = !_hidden),
                      // 20 px icon with a 44 px touch target.
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ZadIcon(ZadIcons.eye, size: 20, color: _hidden ? null : z.sap),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 8),
          Text(
            helper,
            style: ZadType.body(size: 12, height: 16 / 12, color: error != null ? z.danger : z.onFrondMuted),
          ),
        ],
      ],
    );
  }
}
