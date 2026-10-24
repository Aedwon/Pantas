import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
  Widget build(BuildContext context) => TextField(
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
          counterText: '',
          filled: true,
          fillColor: context.colors.surface,
          hintStyle: context.type.body.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            color: context.colors.tertiaryLabel,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
}
