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
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      maxLength: 40,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: context.type.body.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        letterSpacing: -.228,
      ),
      decoration: InputDecoration(
        hintText: label,
        constraints:
            context.wideWeb ? const BoxConstraints.tightFor(height: 56) : null,
        isDense: context.wideWeb,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        counterText: '',
        filled: true,
        fillColor: context.colors.surface,
        hintStyle: context.type.body.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: context.colors.tertiaryLabel,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.wideWeb ? 18 : 16,
          vertical: context.wideWeb ? 16 : 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colors.accent, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colors.accent, width: 1.5),
        ),
      ),
    );
    if (!context.wideWeb) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label.toUpperCase(), style: context.webTokens.eb),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
