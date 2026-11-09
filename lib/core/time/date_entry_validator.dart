import 'package:flutter/foundation.dart';

/// Why a typed date was not accepted.
enum DateEntryIssue {
  /// Nothing was typed.
  empty,

  /// The text stops before a full month, day and four-digit year.
  incomplete,

  /// The text is not a real calendar date, such as 13/40/2026 or 02/29/2027.
  notReal,

  /// The date is before the first allowed day.
  tooEarly,

  /// The date is after the last allowed day.
  tooLate,
}

/// The outcome of [DateEntryValidator.parse]: a [date] when valid, else the
/// [issue].
@immutable
class DateEntryResult {
  const DateEntryResult.valid(DateTime this.date) : issue = null;
  const DateEntryResult.invalid(DateEntryIssue this.issue) : date = null;

  final DateTime? date;
  final DateEntryIssue? issue;

  bool get isValid => date != null;
}

/// The one rule for a chosen date (design system DatePicker, R3-A13): a date
/// is valid only if it is a real calendar date and not before the first
/// allowed day. The typed field and both calendar grids ask this class, so
/// they cannot disagree. `lastAllowed` is optional, for a grid that shows a
/// bounded range.
abstract final class DateEntryValidator {
  static final RegExp _full = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
  static final RegExp _shape = RegExp(r'^[0-9/]*$');

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Whether [day] may be chosen, whatever the time of day it carries.
  static bool isAllowed(
    DateTime day, {
    required DateTime firstAllowed,
    DateTime? lastAllowed,
  }) {
    final d = _day(day);
    if (d.isBefore(_day(firstAllowed))) return false;
    if (lastAllowed != null && d.isAfter(_day(lastAllowed))) return false;
    return true;
  }

  /// Reads `MM/DD/YYYY` (one-digit month and day are accepted).
  static DateEntryResult parse(
    String text, {
    required DateTime firstAllowed,
    DateTime? lastAllowed,
  }) {
    final value = text.trim();
    if (value.isEmpty) {
      return const DateEntryResult.invalid(DateEntryIssue.empty);
    }
    if (!_shape.hasMatch(value)) {
      return const DateEntryResult.invalid(DateEntryIssue.notReal);
    }
    final match = _full.firstMatch(value);
    if (match == null) {
      return const DateEntryResult.invalid(DateEntryIssue.incomplete);
    }
    final month = int.parse(match.group(1)!);
    final day = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    final real = date.year == year && date.month == month && date.day == day;
    if (!real) return const DateEntryResult.invalid(DateEntryIssue.notReal);
    if (_day(date).isBefore(_day(firstAllowed))) {
      return const DateEntryResult.invalid(DateEntryIssue.tooEarly);
    }
    if (lastAllowed != null && _day(date).isAfter(_day(lastAllowed))) {
      return const DateEntryResult.invalid(DateEntryIssue.tooLate);
    }
    return DateEntryResult.valid(date);
  }

  /// `MM/DD/YYYY`.
  static String format(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.month)}/${two(date.day)}/'
        '${date.year.toString().padLeft(4, '0')}';
  }

  /// Shapes typed or pasted text into `MM/DD/YYYY` as it is entered: digits
  /// only, a slash after the month and the day, at most eight digits. A pasted
  /// "1/5/2026" keeps its parts and becomes "01/05/2026". With `pad` false a
  /// one-digit part is left alone, for an edit inside the text.
  static String mask(String raw, {bool pad = true}) {
    var digits = raw.replaceAll(RegExp('[^0-9]'), '');
    if (pad && raw.contains('/')) {
      final parts = raw.split('/').map(
            (p) => p.replaceAll(RegExp('[^0-9]'), ''),
          );
      final list = parts.toList();
      // A part followed by a slash is finished: one digit gets its zero.
      final padded = <String>[];
      for (var i = 0; i < list.length; i++) {
        final finished = i < list.length - 1 && i < 2;
        padded.add(finished && list[i].length == 1 ? '0${list[i]}' : list[i]);
      }
      digits = padded.join();
    }
    if (digits.length > 8) digits = digits.substring(0, 8);
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) out.write('/');
      out.write(digits[i]);
    }
    return out.toString();
  }
}
