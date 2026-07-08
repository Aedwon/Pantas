import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Returns the new name. An empty result clears it, because empty and absent
/// are the same state.
Future<String?> showNameSheet({
  required BuildContext context,
  required String? current,
}) {
  return showInkSheet<String>(
    context: context,
    builder: (sheetContext) {
      return _NameSheetBody(current: current);
    },
  );
}

class _NameSheetBody extends StatefulWidget {
  const _NameSheetBody({required this.current});

  final String? current;

  @override
  State<_NameSheetBody> createState() => _NameSheetBodyState();
}

class _NameSheetBodyState extends State<_NameSheetBody> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.current ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What should we call you?',
          style: styles.headlineSmall.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          autofocus: true,
          style: styles.bodyLarge.copyWith(color: colors.ink),
          decoration: InputDecoration(
            hintText: 'A nickname is fine.',
            hintStyle: styles.bodyMedium.copyWith(color: colors.inkMuted),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.rule),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.rule),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.ink),
            ),
            filled: false,
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        BoardButton(
          label: 'Save',
          onPressed: () {
            Navigator.of(context).pop(_controller.text.trim());
          },
        ),
      ],
    );
  }
}
