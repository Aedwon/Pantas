import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/time/date_entry_validator.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

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
///
/// The phone exam-date picker sets [showHelp] to false, [liveErrors] to true
/// and gives the field an [action] (the calendar button): the field then has
/// no help line, says what is wrong as soon as a complete date is typed, and
/// says nothing about an incomplete one. It tells [onUnresolvedChanged] while
/// the text is not a valid date, so the screen can hold its Continue button.
class TypedDateField extends StatefulWidget {
  const TypedDateField({
    required this.value,
    required this.firstAllowed,
    required this.onChanged,
    this.lastAllowed,
    this.label = 'Type the date',
    this.focusNode,
    this.action,
    this.showHelp = true,
    this.liveErrors = false,
    this.onFieldPointer,
    this.onUnresolvedChanged,
    this.resetToken = 0,
    super.key,
  });

  /// The picker's chosen day, or null when it has none.
  final DateTime? value;
  final DateTime firstAllowed;

  /// Set when the grid shows a bounded range.
  final DateTime? lastAllowed;
  final ValueChanged<DateTime> onChanged;
  final String label;

  /// The picker's own focus node, so it can focus and unfocus the field.
  final FocusNode? focusNode;

  /// The trailing action of the field, such as a calendar button.
  final Widget? action;

  /// Whether the help line shows the first day the learner can pick.
  final bool showHelp;

  /// Show an error the moment a complete date is not valid, and say nothing
  /// about an incomplete one. The wording names the first allowed day.
  final bool liveErrors;

  /// A pointer went down on the field, but not on its [action].
  final VoidCallback? onFieldPointer;

  /// True while text is typed that is not a valid date.
  final ValueChanged<bool>? onUnresolvedChanged;

  /// A new value empties or refills the field, even if [value] is unchanged.
  final int resetToken;

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
    final raw = newValue.text;
    // A single-character edit inside the text must not rewrite the part being
    // edited; a paste, or a slash typed at the end, finishes the parts.
    final single = (raw.length - oldValue.text.length).abs() <= 1;
    final pad = !single || raw.endsWith('/');
    final masked = DateEntryValidator.mask(raw, pad: pad);
    final offset = newValue.selection.baseOffset;
    final atEnd = offset < 0 || offset >= raw.length;
    var caret = masked.length;
    if (!atEnd && !pad) {
      // Keep the caret after the same number of digits.
      final before = raw.substring(0, offset).replaceAll(RegExp('[^0-9]'), '');
      var seen = 0;
      caret = 0;
      while (caret < masked.length && seen < before.length) {
        if (masked[caret] != '/') seen++;
        caret++;
      }
    }
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: caret),
    );
  }
}

class _TypedDateFieldState extends State<TypedDateField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value == null ? '' : DateEntryValidator.format(widget.value!),
  );
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  bool _lastUnresolved = false;
  bool _actionDown = false;

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
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
    final before = oldWidget.value;
    final after = widget.value;
    final reset = oldWidget.resetToken != widget.resetToken;
    final changed = (before == null) != (after == null) ||
        (before != null &&
            after != null &&
            DateUtils.dateOnly(before) != DateUtils.dateOnly(after));
    if (!changed && !reset) return;
    final typed = _parse().date;
    if (!reset && after != null && typed != null) {
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
    // The parent is building now; tell it after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notifyUnresolved();
    });
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ownFocus?.dispose();
    _controller.dispose();
    super.dispose();
  }

  DateEntryResult _parse() => DateEntryValidator.parse(
        _controller.text,
        firstAllowed: widget.firstAllowed,
        lastAllowed: widget.lastAllowed,
      );

  void _notifyUnresolved() {
    final unresolved = _controller.text.isNotEmpty && _parse().date == null;
    if (unresolved == _lastUnresolved) return;
    _lastUnresolved = unresolved;
    widget.onUnresolvedChanged?.call(unresolved);
  }

  void _onFocus() {
    if (_focus.hasFocus) return;
    final result = _parse();
    final bad = !result.isValid &&
        result.issue != DateEntryIssue.empty &&
        !(widget.liveErrors && result.issue == DateEntryIssue.incomplete);
    if (bad != _showError) setState(() => _showError = bad);
  }

  void _onText(String text) {
    _notifyUnresolved();
    if (widget.liveErrors) setState(() {});
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
    final issue = _parse().issue;
    if (widget.liveErrors) return _liveErrorText(issue);
    if (!_showError) return null;
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

  /// The phone wording: the error shows once a complete date is wrong, or
  /// when the field blurs with a complete wrong date. An incomplete date
  /// shows nothing.
  String? _liveErrorText(DateEntryIssue? issue) => switch (issue) {
        DateEntryIssue.notReal => 'Enter a real date, like '
            '${DateEntryValidator.format(widget.firstAllowed)}.',
        DateEntryIssue.tooEarly => 'Pick a date from '
            '${DateFormat('MMMM d, y', 'en_US').format(widget.firstAllowed)}.',
        DateEntryIssue.tooLate =>
          'Pick a date by ${PantasDates.full(widget.lastAllowed!)}.',
        DateEntryIssue.incomplete || DateEntryIssue.empty || null => null,
      };

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final field = PantasField(
      label: widget.label,
      controller: _controller,
      focusNode: _focus,
      hint: 'MM/DD/YYYY',
      helpText: widget.showHelp
          ? 'Type or paste the date. The first day you can pick is '
              '${PantasDates.full(widget.firstAllowed)}.'
          : null,
      errorText: _errorText(),
      keyboardType: TextInputType.number,
      inputFormatters: TypedDateField.formatters,
      onChanged: _onText,
      action: action == null
          ? null
          // The Field pulls its action 8 px into the padding; this undoes it
          // so the whole 44 px box stays inside the field's outline, with
          // the glyph near the padding edge.
          : Transform.translate(
              offset: const Offset(-PantasSpace.s8, 0),
              child: Listener(
                onPointerDown: (_) => _actionDown = true,
                child: action,
              ),
            ),
    );
    if (widget.onFieldPointer == null) return field;
    // The action's listener runs first and marks the press as its own.
    return Listener(
      onPointerDown: (_) {
        if (_actionDown) {
          _actionDown = false;
          return;
        }
        widget.onFieldPointer!();
      },
      child: field,
    );
  }
}
