import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/preferences_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preferences mapper converts account prefs to root preferences object',
      () {
    final doc = const PreferencesMapper().toFirestore([
      const AccountPrefRow(key: 'reminder_time', value: '07:30'),
      const AccountPrefRow(key: 'strict_mock_mode', value: 'true'),
    ]);

    expect(doc, {
      'preferences': {
        'reminder_time': '07:30',
        'strict_mock_mode': 'true',
      },
    });
  });

  test('preferences mapper converts root preferences object to account prefs',
      () {
    final rows = const PreferencesMapper().fromFirestore({
      'preferences': {
        'reminder_time': '07:30',
        'strict_mock_mode': 'true',
      },
    });

    expect(rows.map((row) => row.key), ['reminder_time', 'strict_mock_mode']);
    expect(rows.map((row) => row.value), ['07:30', 'true']);
  });

  test('preferences mapper does not include device prefs keys', () {
    final doc = const PreferencesMapper().toFirestore(
      [const AccountPrefRow(key: 'reminder_time', value: '07:30')],
      devicePrefs: [
        const DevicePrefRow(key: 'selected_exam_id', value: 'cse'),
        const DevicePrefRow(key: 'passed_age_gate', value: 'true'),
      ],
    );

    final preferences = doc['preferences']! as Map<String, Object?>;
    expect(preferences, isNot(contains('selected_exam_id')));
    expect(preferences, isNot(contains('passed_age_gate')));
  });

  test('preferences mapper includes quiz preference keys from account_prefs',
      () {
    final doc = const PreferencesMapper().toFirestore([
      const AccountPrefRow(key: 'quiz_session_length', value: '20'),
      const AccountPrefRow(key: 'quiz_today_interleaved', value: 'true'),
      const AccountPrefRow(key: 'quiz_new_card_cap', value: '5'),
    ]);

    expect(doc, {
      'preferences': {
        'quiz_session_length': '20',
        'quiz_today_interleaved': 'true',
        'quiz_new_card_cap': '5',
      },
    });
  });
}
