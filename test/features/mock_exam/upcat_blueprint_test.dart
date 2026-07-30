import 'dart:io';

import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/content/repos/mock_blueprint_repo.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentDatabase db;
  late MockBlueprintRepo repo;

  setUpAll(() {
    final dbFile = File('assets/seed/content.db');
    expect(
      dbFile.existsSync(),
      isTrue,
      reason: 'assets/seed/content.db must exist',
    );
    db = ContentDatabase(NativeDatabase(dbFile));
    repo = MockBlueprintRepo(db);
  });

  tearDownAll(() => db.close());

  test('UPCAT blueprint figures and sections match spec', () async {
    final blueprints = await repo.byExam('exam_upcat');
    expect(blueprints, hasLength(1));

    final bp = blueprints.single;
    expect(bp.id, 'mock_blueprint_upcat');
    expect(bp.examId, 'exam_upcat');
    expect(bp.name, 'UPCAT Practice Paper');
    expect(bp.durationMinutes, 230);
    expect(bp.sectionalTiming, SectionalTiming.sectional);
    expect(bp.totalPublishedItems, 250);
    expect(bp.source, BlueprintSource.reported);
    // Attribution and date, not the sentence. The note is prose and will be
    // reworded; what must survive is who supplied the figures and when, since
    // "reported" is meaningless without them.
    expect(bp.sourceNote, contains('Aedwon'));
    expect(bp.sourceNote, contains('11 August 2026'));
    // And that the weights are not passed off as published.
    expect(bp.sourceNote, contains('weights'));

    final sections = BlueprintSection.parseList(bp.sectionsJson);
    expect(sections, hasLength(4));

    final totalItems = sections.fold<int>(0, (sum, s) => sum + s.questionCount);
    final totalMinutes =
        sections.fold<int>(0, (sum, s) => sum + s.suggestedMinutes);
    expect(totalItems, 250);
    expect(totalMinutes, 230);

    // Section 1: Language Proficiency
    final s1 = sections[0];
    expect(s1.id, 'sec_upcat_language_proficiency');
    expect(s1.name, 'Language Proficiency');
    expect(s1.questionCount, 80);
    expect(s1.suggestedMinutes, 70);
    expect(s1.sectionalMinutes, 70);
    final w1 = s1.topicWeights.values.fold<double>(0, (sum, w) => sum + w);
    expect(w1, closeTo(1.0, 1e-6));

    // Section 2: Reading Comprehension
    final s2 = sections[1];
    expect(s2.id, 'sec_upcat_reading_comprehension');
    expect(s2.name, 'Reading Comprehension');
    expect(s2.questionCount, 50);
    expect(s2.suggestedMinutes, 35);
    expect(s2.sectionalMinutes, 35);
    final w2 = s2.topicWeights.values.fold<double>(0, (sum, w) => sum + w);
    expect(w2, closeTo(1.0, 1e-6));

    // Section 3: Mathematics
    final s3 = sections[2];
    expect(s3.id, 'sec_upcat_mathematics');
    expect(s3.name, 'Mathematics');
    expect(s3.questionCount, 60);
    expect(s3.suggestedMinutes, 75);
    expect(s3.sectionalMinutes, 75);
    final w3 = s3.topicWeights.values.fold<double>(0, (sum, w) => sum + w);
    expect(w3, closeTo(1.0, 1e-6));

    // Section 4: Science
    final s4 = sections[3];
    expect(s4.id, 'sec_upcat_science');
    expect(s4.name, 'Science');
    expect(s4.questionCount, 60);
    expect(s4.suggestedMinutes, 50);
    expect(s4.sectionalMinutes, 50);
    final w4 = s4.topicWeights.values.fold<double>(0, (sum, w) => sum + w);
    expect(w4, closeTo(1.0, 1e-6));
  });

  test('no section contains a Reasoning topic', () async {
    final reasoningTopics = await (db.select(db.contentTopics)
          ..where((t) => t.subjectId.equals('subj_upcat_reasoning')))
        .get();
    final reasoningTopicIds = reasoningTopics.map((t) => t.id).toSet();
    expect(reasoningTopicIds, isNotEmpty);

    final blueprints = await repo.byExam('exam_upcat');
    final sections = BlueprintSection.parseList(
      blueprints.single.sectionsJson,
    );

    for (final section in sections) {
      for (final topicId in section.topicIds) {
        expect(
          reasoningTopicIds.contains(topicId),
          isFalse,
          reason: 'Section ${section.name} contains Reasoning topic $topicId',
        );
      }
    }
  });

  test('corpus can fill each section and reports shortfalls', () async {
    final blueprints = await repo.byExam('exam_upcat');
    final sections = BlueprintSection.parseList(
      blueprints.single.sectionsJson,
    );

    final shortfalls = <String, int>{};

    for (final section in sections) {
      final query = db.select(db.contentQuestions).join([
        innerJoin(
          db.contentQuestionExams,
          db.contentQuestionExams.questionId.equalsExp(db.contentQuestions.id),
        ),
      ])
        ..where(
          db.contentQuestions.topicId.isIn(section.topicIds) &
              db.contentQuestionExams.examId.equals('exam_upcat'),
        );

      final questionRows = await query.get();
      final availableCount = questionRows
          .map((row) => row.readTable(db.contentQuestions).id)
          .toSet()
          .length;

      final shortfall = section.questionCount > availableCount
          ? section.questionCount - availableCount
          : 0;

      shortfalls[section.name] = shortfall;
    }

    stdout.writeln('Corpus Section Shortfalls: $shortfalls');

    for (final entry in shortfalls.entries) {
      expect(
        entry.value,
        0,
        reason: 'Corpus shortfall for section "${entry.key}": '
            '${entry.value} items short',
      );
    }
  });
}
