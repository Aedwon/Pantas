import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late QuizSessionRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = QuizSessionRepository(db);
  });
  tearDown(() => db.close());

  Future<void> completed(String id, int minutes) {
    final startedAt = DateTime.utc(2026, 8, 1, 10);
    return db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: id,
            userId: 'local',
            examId: 'exam_cse_pro',
            origin: 'today_topic',
            questionIdsJson: '[]',
            startedAt: startedAt,
            completedAt: Value(startedAt.add(Duration(minutes: minutes))),
          ),
        );
  }

  test('returns null below the minimum number of sessions', () async {
    for (var i = 0; i < 6; i++) {
      await completed('s_$i', 10);
    }

    expect(
      await repo.averageCompletedMinutes(
        userId: 'local',
        examId: 'exam_cse_pro',
      ),
      isNull,
    );
  });

  test('averages once the minimum is reached', () async {
    for (var i = 0; i < 6; i++) {
      await completed('s_$i', 10);
    }
    await completed('s_6', 17);

    expect(
      await repo.averageCompletedMinutes(
        userId: 'local',
        examId: 'exam_cse_pro',
      ),
      11,
    );
  });

  test('ignores sessions that were never completed', () async {
    for (var i = 0; i < 7; i++) {
      await completed('s_$i', 10);
    }
    await db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: 's_open',
            userId: 'local',
            examId: 'exam_cse_pro',
            origin: 'today_topic',
            questionIdsJson: '[]',
            startedAt: DateTime.utc(2026, 8, 1, 10),
          ),
        );

    expect(
      await repo.averageCompletedMinutes(
        userId: 'local',
        examId: 'exam_cse_pro',
      ),
      10,
    );
  });
}
