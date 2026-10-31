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
      textAlignVertical: context.wideWeb ? TextAlignVertical.center : null,
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
          vertical: context.wideWeb ? 19 : 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: context.colors.accent,
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
