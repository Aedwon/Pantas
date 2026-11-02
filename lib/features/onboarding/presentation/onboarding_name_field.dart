import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The Name and custom-exam input drawn by O_Name and O_Custom.
class OnboardingNameField extends StatelessWidget {
  const OnboardingNameField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.done,
    this.maxLength = 40,
    this.autofillHints,
    this.restingBorder = false,
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final int maxLength;
  final Iterable<String>? autofillHints;

  /// Board O_Name draws its one field in the accent color. With several
  /// fields on a step that reads as all of them focused, so those steps rest
  /// in the neutral outline and show the accent only on focus.
  final bool restingBorder;
  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      textAlignVertical: TextAlignVertical.center,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: context.type.body.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        letterSpacing: -.228,
      ),
      decoration: InputDecoration(
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        counterText: '',
        // A TextField ignores a SizedBox height; the board field is 52 px.
        constraints:
            context.wideWeb ? null : const BoxConstraints.tightFor(height: 52),
        filled: true,
        fillColor: context.colors.surface,
        hoverColor: context.wideWeb ? context.colors.surface : null,
        hintStyle: context.type.body.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: context.colors.tertiaryLabel,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.wideWeb ? 18 : 16,
          vertical: context.wideWeb ? 19 : 0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: restingBorder
                ? context.colors.controlOutline
                : context.colors.accent,
            width: context.wideWeb ? 2 : 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: context.colors.accent,
            width: context.wideWeb ? 2 : 1.5,
          ),
        ),
      ),
    );
    if (!context.wideWeb) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(label.toUpperCase(), style: context.webTokens.eb),
        ),
        // Board gap is 8; the label's taller line box takes 2 of it here.
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
