import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/miss_causes_provider.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        activeExamFocusProvider.overrideWith((ref) async {
          return ActiveExamFocus.selected(
            buildExam(
              id: 'cse',
              code: 'CSE',
              name: 'Civil Service Exam',
              shortName: 'CSE',
            ),
          );
        }),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> seedAttempt({
    required String id,
    required List<AttemptItem> items,
    String origin = 'today_topic',
    DateTime? startedAt,
  }) async {
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: id,
            examId: 'cse',
            startedAt: startedAt ?? DateTime.now(),
            itemsJson: jsonEncode(items.map((i) => i.toJson()).toList()),
            origin: Value(origin),
            completedAt: Value(startedAt ?? DateTime.now()),
          ),
        );
  }

  test('a prior correct attempt is had it right before', () async {
    final now = DateTime.now();
    final itemsCorrect = <AttemptItem>[];
    final itemsMissed = <AttemptItem>[];

    for (var i = 1; i <= 6; i++) {
      final qId = 'q_prior_$i';
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'cse',
        topicId: 'topic1',
        topicName: 'Topic 1',
        questionIds: [qId],
      );
      itemsCorrect.add(
        AttemptItem(
          questionId: qId,
          questionVersion: 1,
          chosenChoiceId: 'c_a',
          correctChoiceId: 'c_a',
          responseMs: 5000,
        ),
      );
      itemsMissed.add(
        AttemptItem(
          questionId: qId,
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 5000,
        ),
      );
    }

    await seedAttempt(
      id: 'att_1',
      items: itemsCorrect,
      startedAt: now.subtract(const Duration(hours: 2)),
    );
    await seedAttempt(
      id: 'att_2',
      items: itemsMissed,
      startedAt: now.subtract(const Duration(hours: 1)),
    );

    final causes = await container.read(missCausesProvider.future);
    expect(causes!.hadItRightBefore, 6);
  });

  test('no prior attempt and no scheduler state is never seen it', () async {
    final now = DateTime.now();
    final itemsMissed = <AttemptItem>[];

    for (var i = 1; i <= 3; i++) {
      final qId = 'q_never_$i';
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'cse',
        topicId: 'topic1',
        topicName: 'Topic 1',
        questionIds: [qId],
      );
      itemsMissed.add(
        AttemptItem(
          questionId: qId,
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 5000,
        ),
      );
    }

    await seedAttempt(
      id: 'att_never',
      items: itemsMissed,
      startedAt: now,
    );

    final causes = await container.read(missCausesProvider.future);
    expect(causes!.neverSeenIt, 3);
  });

  test('far below the student own average is answered too fast', () async {
    final now = DateTime.now();

    final baselineItems = <AttemptItem>[];
    for (var i = 1; i <= 5; i++) {
      final qId = 'q_base_$i';
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'cse',
        topicId: 'topic1',
        topicName: 'Topic 1',
        questionIds: [qId],
      );
      baselineItems.add(
        AttemptItem(
          questionId: qId,
          questionVersion: 1,
          chosenChoiceId: 'c_b', // missed initially so seen but not correct
          correctChoiceId: 'c_a',
          responseMs: 9000,
        ),
      );
    }
    await seedAttempt(
      id: 'att_base',
      items: baselineItems,
      startedAt: now.subtract(const Duration(hours: 2)),
    );

    final fastMissItems = <AttemptItem>[];
    for (var i = 1; i <= 2; i++) {
      final qId = 'q_base_$i';
      fastMissItems.add(
        AttemptItem(
          questionId: qId,
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 2000,
        ),
      );
    }
    await seedAttempt(
      id: 'att_fast',
      items: fastMissItems,
      startedAt: now.subtract(const Duration(hours: 1)),
    );

    final causes = await container.read(missCausesProvider.future);
    expect(causes!.answeredTooFast, 2);
  });

  test('a fast reader is not accused of rushing', () async {
    final now = DateTime.now();

    final baselineItems = <AttemptItem>[];
    for (var i = 1; i <= 5; i++) {
      final qId = 'q_base_fast_$i';
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'cse',
        topicId: 'topic1',
        topicName: 'Topic 1',
        questionIds: [qId],
      );
      baselineItems.add(
        AttemptItem(
          questionId: qId,
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 3000,
        ),
      );
    }
    await seedAttempt(
      id: 'att_base_fast',
      items: baselineItems,
      startedAt: now.subtract(const Duration(hours: 2)),
    );

    await seedAttempt(
      id: 'att_slow_miss',
      items: [
        const AttemptItem(
          questionId: 'q_base_fast_1',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 2000,
        ),
      ],
      startedAt: now.subtract(const Duration(hours: 1)),
    );

    final causes = await container.read(missCausesProvider.future);
    expect(causes!.answeredTooFast, 0);
  });

  test('a miss falls into exactly one cause', () async {
    final now = DateTime.now();
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'cse',
      topicId: 'topic1',
      topicName: 'Topic 1',
      questionIds: ['q_once_correct'],
    );

    await seedAttempt(
      id: 'att_correct',
      items: [
        const AttemptItem(
          questionId: 'q_once_correct',
          questionVersion: 1,
          chosenChoiceId: 'c_a',
          correctChoiceId: 'c_a',
          responseMs: 9000,
        ),
      ],
      startedAt: now.subtract(const Duration(hours: 2)),
    );

    await seedAttempt(
      id: 'att_rushed_miss',
      items: [
        const AttemptItem(
          questionId: 'q_once_correct',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 500,
        ),
      ],
      startedAt: now.subtract(const Duration(hours: 1)),
    );

    final causes = await container.read(missCausesProvider.future);
    expect(causes!.hadItRightBefore, 1);
    expect(causes.answeredTooFast, 0);
  });

  test('an untimed miss is never answered too fast', () async {
    final now = DateTime.now();
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'cse',
      topicId: 'topic1',
      topicName: 'Topic 1',
      questionIds: ['q_untimed'],
    );

    await seedAttempt(
      id: 'att_untimed',
      origin: 'assessment',
      items: [
        const AttemptItem(
          questionId: 'q_untimed',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 0,
        ),
      ],
      startedAt: now,
    );

    final causes = await container.read(missCausesProvider.future);
    expect(causes!.answeredTooFast, 0);
    expect(causes.neverSeenIt, 1);
  });

  test('an unclassified miss is counted nowhere', () async {
    final now = DateTime.now();
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'cse',
      topicId: 'topic1',
      topicName: 'Topic 1',
      questionIds: ['q_unclassified'],
    );

    await seedAttempt(
      id: 'att_seen',
      items: [
        const AttemptItem(
          questionId: 'q_unclassified',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 9000,
        ),
      ],
      startedAt: now.subtract(const Duration(hours: 2)),
    );

    await seedAttempt(
      id: 'att_second_miss',
      items: [
        const AttemptItem(
          questionId: 'q_unclassified',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 9000,
        ),
      ],
      startedAt: now.subtract(const Duration(hours: 1)),
    );

    final causes = await container.read(missCausesProvider.future);
    expect(
      causes!.total,
      causes.hadItRightBefore + causes.neverSeenIt + causes.answeredTooFast,
      reason: 'the total is the sum of the three, never padded',
    );
  });

  test('with no misses at all the provider returns null', () async {
    final now = DateTime.now();
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'cse',
      topicId: 'topic1',
      topicName: 'Topic 1',
      questionIds: ['q_correct'],
    );

    await seedAttempt(
      id: 'att_all_correct',
      items: [
        const AttemptItem(
          questionId: 'q_correct',
          questionVersion: 1,
          chosenChoiceId: 'c_a',
          correctChoiceId: 'c_a',
          responseMs: 5000,
        ),
      ],
      startedAt: now,
    );

    expect(await container.read(missCausesProvider.future), isNull);
  });

  test('self-noted misreads are zero until the debrief writes tags', () async {
    final now = DateTime.now();
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'cse',
      topicId: 'topic1',
      topicName: 'Topic 1',
      questionIds: ['q_tag_test'],
    );

    await seedAttempt(
      id: 'att_untagged',
      items: [
        const AttemptItem(
          questionId: 'q_tag_test',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 5000,
        ),
      ],
      startedAt: now,
    );

    final causes = await container.read(missCausesProvider.future);
    expect(causes!.selfNotedMisreads, 0);
  });

  test('a tagged misread is counted once the debrief writes it', () async {
    final now = DateTime.now();
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'cse',
      topicId: 'topic1',
      topicName: 'Topic 1',
      questionIds: ['q_tagged'],
    );

    await seedAttempt(
      id: 'att_tagged',
      items: [
        const AttemptItem(
          questionId: 'q_tagged',
          questionVersion: 1,
          chosenChoiceId: 'c_b',
          correctChoiceId: 'c_a',
          responseMs: 5000,
          mistakeTag: MistakeTag.misread,
        ),
      ],
      startedAt: now,
    );

    final causes = await container.read(missCausesProvider.future);
    expect(causes!.selfNotedMisreads, 1);
  });
}
