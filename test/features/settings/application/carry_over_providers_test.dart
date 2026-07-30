import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<void> seedQuestion({
    required String id,
    required List<String> examIds,
  }) async {
    await seedContentQuestionWithChoices(
      contentDb,
      questionId: id,
      topicId: 't1',
      examIds: examIds,
      choices: const [],
      stem: 'Stem',
      explanation: 'Exp',
    );
  }

  var attemptCounter = 0;

  Future<void> seedAttempt({
    required String questionId,
    required String examId,
  }) async {
    attemptCounter++;
    final attemptId = 'att_${attemptCounter}_$questionId';
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: attemptId,
            examId: examId,
            startedAt: DateTime.now(),
            itemsJson: jsonEncode([
              {
                'questionId': questionId,
                'selectedChoiceId': 'c1',
                'isCorrect': true,
                'responseMs': 1000,
              }
            ]),
          ),
        );
  }

  test('counts distinct answered questions that also list the new exam',
      () async {
    // Two questions on DOST, one of which is also on UPCAT.
    await seedQuestion(id: 'q1', examIds: ['DOST', 'UPCAT']);
    await seedQuestion(id: 'q2', examIds: ['DOST']);
    await seedAttempt(questionId: 'q1', examId: 'DOST');
    await seedAttempt(questionId: 'q2', examId: 'DOST');

    final count = await container.read(carryableCountProvider('UPCAT').future);

    expect(count, 1);
  });

  test('answering the same question twice counts once', () async {
    await seedQuestion(id: 'q1', examIds: ['DOST', 'UPCAT']);
    await seedAttempt(questionId: 'q1', examId: 'DOST');
    await seedAttempt(questionId: 'q1', examId: 'DOST');

    final count = await container.read(carryableCountProvider('UPCAT').future);

    expect(count, 1);
  });

  test('a student with no attempts carries nothing over', () async {
    final count = await container.read(carryableCountProvider('UPCAT').future);

    expect(count, 0);
  });
}
