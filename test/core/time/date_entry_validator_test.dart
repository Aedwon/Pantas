import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/date_entry_validator.dart';

void main() {
  final first = DateTime(2026, 11, 10);

  DateEntryResult parse(String text, {DateTime? last}) =>
      DateEntryValidator.parse(text, firstAllowed: first, lastAllowed: last);

  group('parse', () {
    test('a real date on or after the first allowed day is valid', () {
      final result = parse('11/28/2026');
      expect(result.isValid, isTrue);
      expect(result.date, DateTime(2026, 11, 28));
      expect(result.issue, isNull);
    });

    test('the first allowed day itself is valid', () {
      expect(parse('11/10/2026').date, DateTime(2026, 11, 10));
    });

    test('one-digit month and day are accepted', () {
      expect(parse('12/5/2026').date, DateTime(2026, 12, 5));
    });

    test('Feb 29 is valid in a leap year', () {
      expect(parse('02/29/2028').date, DateTime(2028, 2, 29));
    });

    test('Feb 29 is not a real date in a non-leap year', () {
      final result = parse('02/29/2027');
      expect(result.isValid, isFalse);
      expect(result.issue, DateEntryIssue.notReal);
    });

    test('13/40/2026 is not a real date', () {
      expect(parse('13/40/2026').issue, DateEntryIssue.notReal);
      expect(parse('00/10/2026').issue, DateEntryIssue.notReal);
      expect(parse('11/31/2026').issue, DateEntryIssue.notReal);
    });

    test('a day before the first allowed day is too early', () {
      final result = parse('11/09/2026');
      expect(result.isValid, isFalse);
      expect(result.issue, DateEntryIssue.tooEarly);
      expect(result.date, isNull);
      expect(parse('11/28/2025').issue, DateEntryIssue.tooEarly);
    });

    test('a day after the last allowed day is too late', () {
      expect(
        parse('01/01/2028', last: DateTime(2027, 12, 31)).issue,
        DateEntryIssue.tooLate,
      );
      expect(
        parse('12/31/2027', last: DateTime(2027, 12, 31)).isValid,
        isTrue,
      );
    });

    test('partial input is incomplete, not an error of the date itself', () {
      for (final text in [
        '1',
        '11',
        '11/',
        '11/2',
        '11/28',
        '11/28/',
        '11/28/20',
        '11/28/202',
      ]) {
        expect(parse(text).issue, DateEntryIssue.incomplete, reason: text);
      }
    });

    test('empty input is empty', () {
      expect(parse('').issue, DateEntryIssue.empty);
      expect(parse('   ').issue, DateEntryIssue.empty);
    });

    test('letters and other characters are not a real date', () {
      expect(parse('ab/cd/efgh').issue, DateEntryIssue.notReal);
      expect(parse('11-28-2026').issue, DateEntryIssue.notReal);
    });

    test('the time of day on the first allowed day is ignored', () {
      final result = DateEntryValidator.parse(
        '11/10/2026',
        firstAllowed: DateTime(2026, 11, 10, 15, 30),
      );
      expect(result.isValid, isTrue);
    });
  });

  group('isAllowed', () {
    test('matches the grid rule: not before the first allowed day', () {
      expect(
        DateEntryValidator.isAllowed(
          DateTime(2026, 11, 9),
          firstAllowed: first,
        ),
        isFalse,
      );
      expect(
        DateEntryValidator.isAllowed(
          DateTime(2026, 11, 10),
          firstAllowed: first,
        ),
        isTrue,
      );
      expect(
        DateEntryValidator.isAllowed(
          DateTime(2030),
          firstAllowed: first,
        ),
        isTrue,
      );
      expect(
        DateEntryValidator.isAllowed(
          DateTime(2028),
          firstAllowed: first,
          lastAllowed: DateTime(2027, 12, 31),
        ),
        isFalse,
      );
    });
  });

  group('format', () {
    test('writes MM/DD/YYYY with leading zeros', () {
      expect(DateEntryValidator.format(DateTime(2026, 3, 5)), '03/05/2026');
    });
  });

  group('mask', () {
    test('inserts slashes while digits are typed', () {
      expect(DateEntryValidator.mask('1'), '1');
      expect(DateEntryValidator.mask('11'), '11');
      expect(DateEntryValidator.mask('112'), '11/2');
      expect(DateEntryValidator.mask('1128'), '11/28');
      expect(DateEntryValidator.mask('11282'), '11/28/2');
      expect(DateEntryValidator.mask('11282026'), '11/28/2026');
    });

    test('drops letters and stops at eight digits', () {
      expect(DateEntryValidator.mask('11a28b2026999'), '11/28/2026');
    });

    test('a pasted date with separators keeps one-digit parts', () {
      expect(DateEntryValidator.mask('1/5/2026'), '01/05/2026');
      expect(DateEntryValidator.mask('11/28/2026'), '11/28/2026');
      expect(DateEntryValidator.mask('1/'), '01');
    });
  });
}
