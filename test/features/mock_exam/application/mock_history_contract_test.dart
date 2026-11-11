import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('finished mocks update the history feed after the first read', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = MockAttemptRepo(db);
    final feed = repo.watchHistory(mockAttemptLocalUserId, limit: null);
    expect(await feed.first, isEmpty);
    final next = feed.firstWhere((rows) => rows.isNotEmpty);
    await _insert(repo, 'new', at: 1);
    expect((await next).single.id, 'new');
  });
  test('scoring hydrates active questions and excludes withdrawn rows',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    final repo = MockAttemptRepo(db);
    await repo.insertStart(
      MockAttemptStart(
        id: 'score',
        userId: mockAttemptLocalUserId,
        examId: 'exam_upcat',
        blueprintId: 'bp',
        blueprintName: 'UPCAT',
        durationMinutes: 165,
        strictMode: false,
        startedAt: DateTime.utc(2026),
        sampledQuestionsJson: '[{"sectionId":"s1","name":"Part 1", '
            '"questionIds":["active","withdrawn","missing"]}]',
      ),
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'active',
      topicId: 'topic',
      examId: 'exam_upcat',
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'withdrawn',
      topicId: 'topic',
      examId: 'exam_upcat',
      isActive: false,
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);
    final questions =
        await container.read(mockScoringQuestionsProvider('score').future);
    expect(questions.keys, ['active']);
  });
  test('recent ids use only two latest finished mocks of this exam and profile',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = MockAttemptRepo(db);
    await _insert(repo, 'older', at: 1);
    await _insert(repo, 'second', at: 2);
    await _insert(repo, 'latest', at: 3, status: MockAttemptStatus.forfeited);
    await _insert(repo, 'discard', at: 4, status: MockAttemptStatus.discarded);
    await _insert(repo, 'active', at: 5, status: MockAttemptStatus.inProgress);
    await _insert(repo, 'otherExam', at: 6, exam: 'exam_cse_pro');
    await _insert(repo, 'otherProfile', at: 7, user: 'other');
    expect(
      await repo.recentQuestionIds(mockAttemptLocalUserId, 'exam_upcat'),
      {'second', 'latest'},
    );
    expect(
      await repo.recentQuestionIds(mockAttemptLocalUserId, 'new_exam'),
      isEmpty,
    );
  });

  test(
      'Your mocks receives every finished record newest first '
      'with per-exam scoring', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = MockAttemptRepo(db);
    for (var day = 1; day <= 11; day++) {
      await _insert(
        repo,
        'mock_$day',
        at: day,
        exam: day.isEven ? 'exam_cse_pro' : 'exam_upcat',
      );
    }
    await _insert(repo, 'discard', at: 12, status: MockAttemptStatus.discarded);
    await _insert(repo, 'active', at: 13, status: MockAttemptStatus.inProgress);
    await _insert(repo, 'other', at: 14, user: 'other');
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    final entries = await container.read(mockHistoryProvider.future);
    expect(entries, hasLength(11));
    expect(entries.first.attempt.id, 'mock_11');
    expect(entries.last.attempt.id, 'mock_1');
    expect(entries.first.results.percent, 37.5);
    expect(entries[1].results.percent, 50);
    expect(entries.first.results.sections.single.wrong, 1);
    expect(entries.first.results.sections.single.blank, 0);
  });
}

Future<void> _insert(
  MockAttemptRepo repo,
  String id, {
  required int at,
  String exam = 'exam_upcat',
  String user = mockAttemptLocalUserId,
  MockAttemptStatus status = MockAttemptStatus.completed,
}) async {
  final date = DateTime.utc(2026, 10, at);
  await repo.insertStart(
    MockAttemptStart(
      id: id,
      userId: user,
      examId: exam,
      blueprintId: 'bp',
      blueprintName: exam,
      durationMinutes: 90,
      strictMode: false,
      startedAt: date,
      sampledQuestionsJson: jsonEncode([
        {
          'sectionId': 's1',
          'name': 'Part 1',
          'questionIds': [id],
        },
      ]),
    ),
  );
  if (status == MockAttemptStatus.inProgress) return;
  if (status == MockAttemptStatus.discarded) {
    await repo.discard(id, date);
    return;
  }
  await SubmitMock(repo: repo)(
    attemptId: id,
    status: status,
    submittedAt: date,
    results: const MockResults(
      scoreRaw: 1,
      scoreTotal: 2,
      percent: 50,
      sections: [
        SectionResult(
          sectionId: 's1',
          name: 'Part 1',
          correct: 1,
          wrong: 1,
          blank: 0,
          total: 2,
          retiredCount: 0,
          timeSeconds: 60,
        ),
      ],
      topWeak: [],
      totalTimeSeconds: 60,
      wasStrict: false,
    ),
  );
}
