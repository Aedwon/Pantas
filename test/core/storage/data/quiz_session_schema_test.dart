import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app database creates quiz session tables at current schema version',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, greaterThanOrEqualTo(7));
    expect(await _tableNames(db), contains('quiz_sessions'));
    expect(await _tableNames(db), contains('daily_new_card_intro'));
  });

  test('quiz_sessions stores ordered questionIdsJson and currentIndex',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: 'session_1',
            userId: 'user_1',
            examId: 'exam',
            origin: 'today_topic',
            questionIdsJson: '["q1","q2"]',
            startedAt: DateTime.utc(2026, 5, 18),
          ),
        );

    final row = await db.select(db.quizSessions).getSingle();
    expect(row.questionIdsJson, equals('["q1","q2"]'));
    expect(row.currentIndex, equals(0));
  });

  test('daily_new_card_intro primary key is user exam day', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final day = DateTime.utc(2026, 5, 18);

    await db.into(db.dailyNewCardIntro).insert(
          DailyNewCardIntroCompanion.insert(
            userId: 'user',
            examId: 'exam',
            day: day,
          ),
        );

    expect(
      () => db.into(db.dailyNewCardIntro).insert(
            DailyNewCardIntroCompanion.insert(
              userId: 'user',
              examId: 'exam',
              day: day,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('content database schema does not include quiz session tables',
      () async {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await _tableNames(db), isNot(contains('quiz_sessions')));
    expect(await _tableNames(db), isNot(contains('daily_new_card_intro')));
  });
}

Future<List<String>> _tableNames(GeneratedDatabase database) async {
  final rows = await database
      .customSelect(
        "select name from sqlite_master where type = 'table' "
        "and name not like 'sqlite_%' order by name",
      )
      .get();
  return rows.map((row) => row.read<String>('name')).toList();
}
