import 'package:meta/meta.dart';

/// How much of the exam date the student actually knew.
enum ExamDatePrecision { day, month }

/// A date the student asserted, carrying how precisely they asserted it.
///
/// [day] is null at month precision on purpose. A day count derived from a
/// month would be a figure this app assumed, and a flag beside the date only
/// works until the first reader forgets to check it.
@immutable
class ExamDate {
  const ExamDate._(this._date, this.precision);

  factory ExamDate.onDay(DateTime date) {
    return ExamDate._(
      DateTime(date.year, date.month, date.day),
      ExamDatePrecision.day,
    );
  }

  factory ExamDate.inMonth({required int year, required int month}) {
    return ExamDate._(DateTime(year, month), ExamDatePrecision.month);
  }

  final DateTime _date;
  final ExamDatePrecision precision;

  int get year => _date.year;
  int get month => _date.month;

  /// The exact day, or null when only the month is known.
  DateTime? get day => precision == ExamDatePrecision.day ? _date : null;

  /// Always available. The first of the month at month precision, and the
  /// first of the containing month at day precision.
  DateTime get monthStart => DateTime(_date.year, _date.month);

  /// Whole days from [today] to the exam, or null when only the month is
  /// known. Never negative-safe: a past date returns a negative number and
  /// the caller decides what that means.
  int? daysUntil(DateTime today) {
    if (precision != ExamDatePrecision.day) return null;
    final from = DateTime(today.year, today.month, today.day);
    return _date.difference(from).inDays;
  }

  /// Always `YYYY-MM-DD`. At month precision the day is the 1st, which is why
  /// the precision must be stored alongside it.
  String get storageValue {
    return '${_date.year.toString().padLeft(4, '0')}-'
        '${_date.month.toString().padLeft(2, '0')}-'
        '${_date.day.toString().padLeft(2, '0')}';
  }

  static ExamDate? fromStorage(String? date, String? precision) {
    if (date == null || precision == null) return null;

    final parts = date.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;

    return switch (precision) {
      'day' => ExamDate.onDay(DateTime(year, month, day)),
      'month' => ExamDate.inMonth(year: year, month: month),
      _ => null,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ExamDate &&
        other._date == _date &&
        other.precision == precision;
  }

  @override
  int get hashCode => Object.hash(_date, precision);

  @override
  String toString() => '$storageValue (${precision.name})';
}
