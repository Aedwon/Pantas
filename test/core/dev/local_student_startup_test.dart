import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/local_sample_students.dart';
import 'package:pantas/core/dev/local_student_startup.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
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

    final loaded = await loadLocalStudentFromUrl(
      container,
      url: Uri.parse('http://localhost:7357/?localStudent=steady'),
    );

    // Nothing loaded, so startup does not rebind payments either.
    expect(loaded, isFalse);
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

  test('the link names a Home state, and only a known one', () {
    String? read(String link) => localStateFromUrl(Uri.parse(link));

    expect(read('http://localhost:7357/?localState=dayDone'), 'dayDone');
    expect(
      read('http://localhost:7357/?localStudent=new&localState=noDate'),
      'noDate',
    );
    expect(read('http://localhost:7357/?localState=nobody'), isNull);
    expect(read('http://localhost:7357/'), isNull);
  });

  test('a Home state needs no student in the link', () async {
    // These tests run without LOCAL_EMULATOR_HOST, so nothing loads.
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

    expect(
      await loadLocalStudentFromUrl(
        container,
        url: Uri.parse('http://localhost:7357/?localState=dayDone'),
      ),
      isFalse,
    );
  });

  test('a part-read lesson, no date and no placement test reach the device',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await loadSampleStudentProfile(
      db,
      SampleStudentProfile.fromJson(const {
        'examDate': null,
        'examPrecision': null,
        'studyDays': '1,2,3,4,5,7',
        'assessmentDone': false,
        'resumeLessonId': 'lesson-a',
        'streak': 0,
        'longest': 0,
        'lastActiveDate': null,
      }),
      today: DateTime(2026, 10, 31),
    );

    final prefs = {
      for (final row in await db.select(db.accountPrefs).get())
        row.key: row.value,
    };
    expect(prefs[SettingsPrefKeys.examDate], '');
    expect(prefs[SettingsPrefKeys.examDatePrecision], '');
    expect(prefs[SettingsPrefKeys.studyDays], '1,2,3,4,5,7');
    expect(await db.select(db.assessmentResultsLocal).get(), isEmpty);
    final positions = ReaderPositionRepository(
      AppPreferencesRepository(db),
      database: db,
    );
    expect(await positions.readFraction(sampleExamId, 'lesson-a'), 0.5);
  });

  test('a month-only exam date keeps its month precision', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await loadSampleStudentProfile(
      db,
      SampleStudentProfile.fromJson(const {
        'examDate': '2026-11-01',
        'examPrecision': 'month',
        'streak': 1,
        'longest': 1,
        'lastActiveDate': '2026-10-30',
      }),
      today: DateTime(2026, 10, 31),
    );

    final prefs = {
      for (final row in await db.select(db.accountPrefs).get())
        row.key: row.value,
    };
    expect(prefs[SettingsPrefKeys.examDate], '2026-11-01');
    expect(prefs[SettingsPrefKeys.examDatePrecision], 'month');
  });
}
