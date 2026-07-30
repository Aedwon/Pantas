import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/features/settings/presentation/settings_value_formats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a day-precision date prints the day', () {
    expect(
      SettingsValueFormats.examDate(ExamDate.onDay(DateTime(2026, 10, 12))),
      '12 Oct 2026',
    );
  });

  test('a month-precision date prints the month and never a day', () {
    final printed = SettingsValueFormats.examDate(
      ExamDate.inMonth(year: 2026, month: 10),
    );

    expect(printed, 'October 2026');
    expect(printed.contains('2026'), isTrue);
    expect(printed.contains('01'), isFalse);
  });

  test('no exam date reads Not set', () {
    expect(SettingsValueFormats.examDate(null), 'Not set');
  });

  test('no format anywhere prints a day count', () {
    final printed = [
      SettingsValueFormats.examDate(ExamDate.onDay(DateTime(2026, 10, 12))),
      SettingsValueFormats.examDate(
        ExamDate.inMonth(year: 2026, month: 10),
      ),
      SettingsValueFormats.examDate(null),
    ];
    for (final value in printed) {
      expect(value.toLowerCase().contains('day'), isFalse);
      expect(value.toLowerCase().contains('to go'), isFalse);
    }
  });

  test('an absent name invites one', () {
    expect(SettingsValueFormats.name(null), 'Add your name');
    expect(SettingsValueFormats.name('Aedwon'), 'Aedwon');
  });

  test('the backup value is one word per state', () {
    expect(
      SettingsValueFormats.backup(isAnonymous: true, status: null),
      'Not backed up',
    );
    expect(
      SettingsValueFormats.backup(
        isAnonymous: false,
        status: const Syncing(pendingCount: 3),
      ),
      'Backing up',
    );
    expect(
      SettingsValueFormats.backup(
        isAnonymous: false,
        status: const SyncIdle(),
      ),
      'Saved',
    );
  });

  test('no format contains an em dash', () {
    final all = [
      SettingsValueFormats.name(null),
      SettingsValueFormats.examDate(null),
      SettingsValueFormats.onOff(value: true),
      SettingsValueFormats.backup(isAnonymous: true, status: null),
    ];
    for (final value in all) {
      expect(value.contains('—'), isFalse);
    }
  });
}
