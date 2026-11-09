import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/time/date_entry_validator.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';

/// The typed entry of the DatePicker (design system DatePicker): a Field, 48
/// high, with a numeric keyboard, the placeholder "MM/DD/YYYY" and a help
/// line that says the first day the learner can pick.
///
/// It shares one validator with the grids ([DateEntryValidator]): a date is
/// valid only if it is a real calendar date and not before [firstAllowed].
/// Typing or pasting a full valid date calls [onChanged]. An entry that is not
/// valid reports nothing, so the picker keeps its last valid selection, and
/// shows its error under the field when the field loses focus. The error
/// clears as soon as a valid date is typed. Pasted text may carry slashes or
/// not: "1/5/2027" and "01052027" both read as 01/05/2027.
///
/// [value] is the picker's chosen day. When it changes to something the text
/// does not show, the field shows it, and a null value empties the field.
class TypedDateField extends StatefulWidget {
  const TypedDateField({
    required this.value,
    required this.firstAllowed,
    required this.onChanged,
    this.lastAllowed,
    this.label = 'Type the date',
    super.key,
  });

  /// The picker's chosen day, or null when it has none.
  final DateTime? value;
  final DateTime firstAllowed;

  /// Set when the grid shows a bounded range.
  final DateTime? lastAllowed;
  final ValueChanged<DateTime> onChanged;
  final String label;

  /// The input mask: digits, with the slashes put in as they are typed.
  static final List<TextInputFormatter> formatters = [_DateMaskFormatter()];

  @override
  State<TypedDateField> createState() => _TypedDateFieldState();
}

class _DateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final masked = DateEntryValidator.mask(newValue.text);
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}

class _TypedDateFieldState extends State<TypedDateField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value == null ? '' : DateEntryValidator.format(widget.value!),
  );
  final FocusNode _focus = FocusNode();

  /// Set when the field first loses focus with an invalid entry, and kept
  /// until a valid date is typed or the picker changes the value.
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(TypedDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = oldWidget.value;
    final after = widget.value;
    final changed = (before == null) != (after == null) ||
        (before != null &&
            after != null &&
            DateUtils.dateOnly(before) != DateUtils.dateOnly(after));
    if (!changed) return;
    final typed = _parse().date;
    if (after != null && typed != null) {
      if (DateUtils.dateOnly(typed) == DateUtils.dateOnly(after)) return;
    }
    // The picker moved on: show its value and drop any error.
    _controller.value = TextEditingValue(
      text: after == null ? '' : DateEntryValidator.format(after),
      selection: TextSelection.collapsed(
        offset: after == null ? 0 : DateEntryValidator.format(after).length,
      ),
    );
    _showError = false;
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  DateEntryResult _parse() => DateEntryValidator.parse(
        _controller.text,
        firstAllowed: widget.firstAllowed,
        lastAllowed: widget.lastAllowed,
      );

  void _onFocus() {
    if (_focus.hasFocus) return;
    final result = _parse();
    final bad = !result.isValid && result.issue != DateEntryIssue.empty;
    if (bad != _showError) setState(() => _showError = bad);
  }

  void _onText(String text) {
    final result = _parse();
    final date = result.date;
    if (date != null) {
      if (_showError) setState(() => _showError = false);
      final current = widget.value;
      if (current == null ||
          DateUtils.dateOnly(current) != DateUtils.dateOnly(date)) {
        widget.onChanged(date);
      }
    } else if (_showError && result.issue == DateEntryIssue.empty) {
      setState(() => _showError = false);
    } else if (_showError) {
      // The message follows what is typed now.
      setState(() {});
    }
  }

  String? _errorText() {
    if (!_showError) return null;
    final issue = _parse().issue;
    return switch (issue) {
      DateEntryIssue.incomplete => 'Type the full date, like 11/28/2026.',
      DateEntryIssue.notReal => 'Enter a real date, like 11/28/2026.',
      DateEntryIssue.tooEarly =>
        'Pick ${PantasDates.full(widget.firstAllowed)} or a later date.',
      DateEntryIssue.tooLate =>
        'Pick a date by ${PantasDates.full(widget.lastAllowed!)}.',
      DateEntryIssue.empty || null => null,
    };
  }

  @override
  Widget build(BuildContext context) => PantasField(
        label: widget.label,
        controller: _controller,
        focusNode: _focus,
        hint: 'MM/DD/YYYY',
        helpText: 'Type or paste the date. The first day you can pick is '
            '${PantasDates.full(widget.firstAllowed)}.',
        errorText: _errorText(),
        keyboardType: TextInputType.number,
        inputFormatters: TypedDateField.formatters,
        onChanged: _onText,
      );
}
