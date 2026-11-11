import 'package:intl/intl.dart';

/// Calendar labels shared by the new design. Weeks begin on Sunday.
abstract final class PantasDates {
  static String full(DateTime date) => _format('MMM d, y', date);

  static String short(DateTime date, {DateTime? now}) =>
      date.year == (now ?? DateTime.now()).year
          ? _format('MMM d', date)
          : full(date);

  static String withWeekday(DateTime date) => _format('EEE, MMM d', date);

  static String heading(DateTime date) => _format('EEEE, MMMM d', date);

  static String monthOnly(DateTime date) => _format('MMMM y', date);

  static String weekRange(DateTime start) {
    final end = _day(start, 6);
    if (start.year != end.year) return '${full(start)} – ${full(end)}';
    final left = _format('MMM d', start);
    final right = _format(start.month == end.month ? 'd' : 'MMM d', end);
    return '$left – $right';
  }

  static String relativeDay(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    if (_sameDay(date, today)) return 'Today';
    if (_sameDay(date, _day(today, -1))) return 'Yesterday';
    return short(date, now: today);
  }

  static DateTime weekStart(DateTime date) => _day(date, -(date.weekday % 7));

  static String _format(String pattern, DateTime date) =>
      DateFormat(pattern, 'en_US').format(date);

  static bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  // Calendar arithmetic avoids daylight-saving changes in a 24-hour duration.
  static DateTime _day(DateTime date, int offset) => date.isUtc
      ? DateTime.utc(date.year, date.month, date.day + offset)
      : DateTime(date.year, date.month, date.day + offset);
}
