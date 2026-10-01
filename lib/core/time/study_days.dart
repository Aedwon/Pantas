import 'package:meta/meta.dart';
import 'package:pantas/core/time/local_day.dart';

/// The weekdays a student studies on, as ISO weekdays (DateTime.monday 1
/// to DateTime.sunday 7). Never empty.
@immutable
final class StudyDays {
  factory StudyDays(Iterable<int> weekdays) {
    var mask = 0;
    for (final weekday in weekdays) {
      if (weekday < DateTime.monday || weekday > DateTime.sunday) {
        throw ArgumentError.value(weekday, 'weekdays', 'Must be in 1..7');
      }
      mask |= 1 << (weekday - 1);
    }
    if (mask == 0) {
      throw ArgumentError.value(weekdays, 'weekdays', 'Must not be empty');
    }
    return StudyDays._(mask);
  }

  const StudyDays._(this._mask);

  static const StudyDays all = StudyDays._(127);

  final int _mask;

  // The shared contract requires a static reader with a fallback to all days.
  // ignore: prefer_constructors_over_static_methods
  static StudyDays fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) return all;
    final weekdays = <int>[];
    for (final token in raw.split(',')) {
      final weekday = int.tryParse(token);
      if (weekday == null ||
          weekday < DateTime.monday ||
          weekday > DateTime.sunday) {
        return all;
      }
      weekdays.add(weekday);
    }
    return StudyDays(weekdays);
  }

  Set<int> get weekdays => Set<int>.unmodifiable({
        for (var weekday = DateTime.monday;
            weekday <= DateTime.sunday;
            weekday++)
          if (_contains(weekday)) weekday,
      });

  String get storageValue => weekdays.join(',');

  bool get isEveryDay => _mask == all._mask;

  bool isStudyDay(DateTime day) => _contains(day.weekday);

  /// Study days in [from, to), by local calendar day. 0 when to <= from.
  int countInRange(DateTime from, DateTime to) {
    final end = localDay(to);
    var count = 0;
    for (var day = localDay(from);
        day.isBefore(end);
        day = DateTime(day.year, day.month, day.day + 1)) {
      if (isStudyDay(day)) count++;
    }
    return count;
  }

  /// First study day strictly after [day] and strictly before [before]
  /// when given; null if none.
  DateTime? nextAfter(DateTime day, {DateTime? before}) {
    final end = before == null ? null : localDay(before);
    for (var offset = 1; offset <= 7; offset++) {
      final next = DateTime(day.year, day.month, day.day + offset);
      if (end != null && !next.isBefore(end)) return null;
      if (isStudyDay(next)) return next;
    }
    return null;
  }

  /// Study days strictly between [earlier] and [later] (both exclusive).
  int missedBetween(DateTime earlier, DateTime later) => countInRange(
        DateTime(earlier.year, earlier.month, earlier.day + 1),
        later,
      );

  bool _contains(int weekday) => _mask & (1 << (weekday - 1)) != 0;

  @override
  bool operator ==(Object other) => other is StudyDays && other._mask == _mask;

  @override
  int get hashCode => _mask.hashCode;
}
