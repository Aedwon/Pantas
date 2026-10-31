import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/local_sample_students.dart';
import 'package:pantas/core/dev/local_student_startup.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('the link names a student by its panel id', () {
    SampleStudent? read(String link) => localStudentFromUrl(Uri.parse(link));

    expect(
      read('http://localhost:7357/?localStudent=new'),
      SampleStudent.newStudent,
    );
    expect(
      read('http://localhost:7357/?localStudent=examWeek'),
      SampleStudent.examWeek,
    );
    expect(
      read('http://localhost:7357/?localStudent=steady&x=1'),
      SampleStudent.steady,
    );
    expect(read('http://localhost:7357/?localStudent=nobody'), isNull);
    expect(read('http://localhost:7357/'), isNull);
  });

  test('a normal build does nothing, even with the link', () async {
    // These tests run without LOCAL_EMULATOR_HOST, as every normal build does.
    expect(localEmulators, isFalse);
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(() async {
      await db.close();
      await content.close();
    });
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
      ],
    );
    addTearDown(container.dispose);

    await loadLocalStudentFromUrl(
      container,
      url: Uri.parse('http://localhost:7357/?localStudent=steady'),
    );

    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    expect(await db.select(db.devicePrefs).get(), isEmpty);
    expect(await db.select(db.streakLocal).get(), isEmpty);
  });

  test('on web the device keeps only onboarding and the streak', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    // Leftovers from an earlier student must go.
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(current: const Value(3)),
        );

    await loadSampleStudentProfile(
      db,
      SampleStudentProfile.fromJson(const {
        'examDate': '2026-11-28',
        'streak': 18,
        'longest': 18,
        'lastActiveDate': '2026-10-30',
      }),
      today: DateTime(2026, 10, 31),
    );

    final streak = await db.select(db.streakLocal).getSingle();
    expect((streak.current, streak.longest), (18, 18));
    expect(streak.lastActiveDate, DateTime(2026, 10, 30));
    final prefs = {
      for (final row in await db.select(db.accountPrefs).get())
        row.key: row.value,
    };
    expect(prefs[SettingsPrefKeys.examDate], '2026-11-28');
    expect(prefs[SettingsPrefKeys.name], 'Aerol');
    final device = {
      for (final row in await db.select(db.devicePrefs).get())
        row.key: row.value,
    };
    expect(device['onboarding_complete'], 'true');
    // The settings sent to the server say the placement test is done.
    expect(
      (await db.select(db.assessmentResultsLocal).get()).single.examId,
      sampleExamId,
    );
    // The server holds these records. Writing them here would upload them.
    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    expect(await db.select(db.quizSessions).get(), isEmpty);
    expect(await db.select(db.reviewLogs).get(), isEmpty);
    expect(await db.select(db.reviewStateLocal).get(), isEmpty);
    expect(await db.select(db.lessonProgressLocal).get(), isEmpty);
    expect(await db.select(db.mockAttempts).get(), isEmpty);
    expect(await db.select(db.pendingSync).get(), isEmpty);
  });

  test('a Behind streak that ended reads back as zero', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await loadSampleStudentProfile(
      db,
      SampleStudentProfile.fromJson(const {
        'examDate': '2026-12-15',
        'streak': 0,
        'longest': 6,
        'lastActiveDate': '2026-10-25',
      }),
      today: DateTime(2026, 10, 31),
    );
    final streak = await db.select(db.streakLocal).getSingle();
    expect((streak.current, streak.longest), (0, 6));
  });
}
