import 'dart:io';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/repos/mock_blueprint_repo.dart';
import 'package:cse_cet_reviewer/features/mock_exam/application/mock_session_controller.dart';
import 'package:cse_cet_reviewer/features/mock_exam/data/blueprint_section.dart';
import 'package:cse_cet_reviewer/features/mock_exam/data/mock_sampler.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_session_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentDatabase db;
  late MockBlueprintRepo repo;

  setUpAll(() {
    final dbFile = File('assets/seed/content.db');
    db = ContentDatabase(NativeDatabase(dbFile));
    repo = MockBlueprintRepo(db);
  });

  tearDownAll(() => db.close());

  test('Sit the UPCAT paper', () async {
    // 1. Get UPCAT Blueprint
    final blueprints = await repo.byExam('exam_upcat');
    final bp = blueprints.single;
    final sections = BlueprintSection.parseList(bp.sectionsJson);

    // 2. Assert paper is 250 questions across 4 parts
    expect(sections, hasLength(4));
    final totalItems = sections.fold<int>(0, (sum, s) => sum + s.questionCount);
    expect(totalItems, 250);

    // 3. Assert no Reasoning topics
    final reasoningTopics = await (db.select(db.contentTopics)
          ..where((t) => t.subjectId.equals('subj_upcat_reasoning')))
        .get();
    final reasoningTopicIds = reasoningTopics.map((t) => t.id).toSet();
    expect(reasoningTopicIds, isNotEmpty);

    for (final section in sections) {
      for (final topicId in section.topicIds) {
        expect(reasoningTopicIds.contains(topicId), isFalse);
      }
    }

    // 4. Sample the paper
    final poolsByTopic = <String, List<String>>{};
    for (final section in sections) {
      for (final topicId in section.topicIds) {
        final qRows = await (db.select(db.contentQuestions)
              ..where((q) => q.topicId.equals(topicId)))
            .get();
        poolsByTopic[topicId] = qRows.map((r) => r.id).toList();
      }
    }

    final sampler = MockSampler();
    final sample = sampler.sample(
      sections: sections,
      poolsByTopic: poolsByTopic,
      recentlySampledQuestionIds: {},
      seed: 123,
    );

    // 5. Build parts for the controller
    final parts = <MockSessionPart>[];
    final allQuestionIds = <String>[];
    var currentIndex = 0;
    for (final s in sample.sections) {
      final sectionDef = sections.firstWhere((x) => x.id == s.sectionId);
      parts.add(
        MockSessionPart(
          name: sectionDef.name,
          startIndex: currentIndex,
          count: s.questionIds.length,
          minutes: sectionDef.sectionalMinutes,
        ),
      );
      allQuestionIds.addAll(s.questionIds);
      currentIndex += s.questionIds.length;
    }

    // The blueprint asking for 250 is not the same as a paper of 250: a thin
    // pool would sample short and every assertion below would still pass.
    expect(allQuestionIds, hasLength(250));

    // 6. Drive it
    final controller = MockSessionController.initial(
      attemptId: 'test_upcat',
      durationSeconds: bp.durationMinutes * 60,
      questionIds: allQuestionIds,
      parts: parts,
    );

    // Answer through the first part
    final firstPart = parts[0];
    // Language Proficiency runs 70 minutes on its own clock.
    expect(firstPart.minutes, 70);

    for (var i = 0; i < firstPart.count; i++) {
      controller
        ..answerCurrent(0)
        ..goNext();
    }

    // At the end of the first part, and it must not run on into the second.
    expect(controller.canGoNext, isFalse);

    // Let the first part's clock expire (tick to 70 mins)
    controller.tickTo(70 * 60);

    // Confirm the paper moves on (now in part 1)
    expect(controller.currentPartIndex, 1);

    // Finished part cannot be re-entered
    controller.goTo(0);
    expect(
      (controller.state as MockSessionInProgress).currentIndex,
      firstPart.count,
      reason: 'a finished part cannot be re-entered',
    );
  });
}
