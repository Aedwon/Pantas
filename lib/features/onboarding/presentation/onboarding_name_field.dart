import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

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
  Widget build(BuildContext context) {
    final field = TextField(
      // ds-raw: needs textCapitalization and focus node
      controller: controller,
      focusNode: focusNode,
      maxLength: maxLength,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      textAlignVertical: TextAlignVertical.center,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: PantasType.webRowTitleSettings
          .copyWith(color: context.colors.textPrimary),
      cursorColor: context.colors.accent,
      decoration: InputDecoration(
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        counterText: '',
        // A TextField ignores a SizedBox height, so the 48 well is a minimum.
        constraints: context.wideWeb
            ? null
            : const BoxConstraints(minHeight: PantasSize.field),
        filled: true,
        fillColor: context.colors.surfaceCard,
        hoverColor: context.colors.surfaceCard,
        hintStyle: PantasType.webRowTitleSettings
            .copyWith(color: context.colors.textSecondary),
        contentPadding: EdgeInsets.symmetric(
          horizontal: PantasSpace.s14,
          vertical: context.wideWeb ? PantasSpace.s12 : PantasSpace.s0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PantasRadius.md),
          borderSide: BorderSide(color: context.colors.borderControl),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PantasRadius.md),
          borderSide: BorderSide(
            color: context.colors.accent,
            width: PantasBorder.ringSelected,
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PantasFieldLabel(label),
        const SizedBox(height: PantasSpace.s6),
        field,
      ],
    );
  }
}
