import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';

/// The Name and custom-exam input drawn by O_Name and O_Custom.
class OnboardingNameField extends StatelessWidget {
  const OnboardingNameField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hint,
    this.onSubmitted,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.done,
    this.maxLength = 40,
    this.autofillHints,
    this.focusNode,
    super.key,
  });
  final TextEditingController controller;
  final String label;

  /// The placeholder: an example of what to type. The label is always drawn
  /// above the field (Field README: never use the placeholder as the label),
  /// so a placeholder that repeats it says nothing and is left out.
  final String? hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final int maxLength;
  final Iterable<String>? autofillHints;

  /// Lets the step keep this field focused. The field is drawn in the accent
  /// color at rest, as the active input, so it must be the one holding focus.
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => PantasField(
        label: label,
        controller: controller,
        focusNode: focusNode,
        hint: hint,
        maxLength: maxLength,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
}
