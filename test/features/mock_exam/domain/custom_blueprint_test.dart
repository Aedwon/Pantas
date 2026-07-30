import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';

void main() {
  const topicsBySubject = {
    'math': ['algebra', 'geometry', 'trig'],
    'sci': ['chem', 'physics', 'bio'],
  };

  test('no breakdown means the totals stand', () {
    const blueprint = CustomBlueprint(
      examId: 'exam_custom_1',
      totalQuestions: 120,
      totalMinutes: 120,
    );

    expect(blueprint.hasBreakdown, isFalse);
    expect(blueprint.effectiveQuestions, 120);
    expect(blueprint.effectiveMinutes, 120);
  });

  test('a breakdown overrides the totals', () {
    const blueprint = CustomBlueprint(
      examId: 'exam_custom_1',
      totalQuestions: 120,
      totalMinutes: 120,
      sections: [
        CustomBlueprintSectionDraft(
          subjectId: 'math',
          name: 'Mathematics',
          questions: 60,
          minutes: 50,
        ),
        CustomBlueprintSectionDraft(
          subjectId: 'sci',
          name: 'Science',
          questions: 40,
          minutes: 40,
        ),
      ],
    );

    // The parts are the more specific claim, so they win.
    expect(blueprint.effectiveQuestions, 100);
    expect(blueprint.effectiveMinutes, 90);
  });

  test('one continuous paper emits one section over every topic', () {
    const blueprint = CustomBlueprint(
      examId: 'exam_custom_1',
      totalQuestions: 120,
      totalMinutes: 120,
    );

    final sections = BlueprintSection.parseList(
      blueprint.toSectionsJson(topicsBySubject),
    );

    expect(sections, hasLength(1));
    expect(sections.single.topicIds, hasLength(6));
    expect(sections.single.questionCount, 120);
  });

  test('a breakdown emits one section per part', () {
    const blueprint = CustomBlueprint(
      examId: 'exam_custom_1',
      totalQuestions: 100,
      totalMinutes: 90,
      sections: [
        CustomBlueprintSectionDraft(
          subjectId: 'math',
          name: 'Mathematics',
          questions: 60,
          minutes: 50,
        ),
        CustomBlueprintSectionDraft(
          subjectId: 'sci',
          name: 'Science',
          questions: 40,
          minutes: 40,
        ),
      ],
    );

    final sections = BlueprintSection.parseList(
      blueprint.toSectionsJson(topicsBySubject),
    );

    expect(sections.map((s) => s.name), ['Mathematics', 'Science']);
    expect(sections.first.topicIds, ['algebra', 'geometry', 'trig']);
    expect(sections.first.questionCount, 60);
    expect(sections.last.suggestedMinutes, 40);
  });

  test('a part with no subject draws on the whole track', () {
    const blueprint = CustomBlueprint(
      examId: 'exam_custom_1',
      totalQuestions: 30,
      totalMinutes: 30,
      sections: [
        CustomBlueprintSectionDraft(
          name: 'General',
          questions: 30,
          minutes: 30,
        ),
      ],
    );

    final sections = BlueprintSection.parseList(
      blueprint.toSectionsJson(topicsBySubject),
    );

    expect(sections.single.topicIds, hasLength(6));
  });

  test('the emitted json carries no weights at all', () {
    const blueprint = CustomBlueprint(
      examId: 'exam_custom_1',
      totalQuestions: 120,
      totalMinutes: 120,
    );

    final emitted =
        jsonDecode(blueprint.toSectionsJson(topicsBySubject)) as List;

    // Omitted rather than written as equal ones. The shipped parser fills
    // them in evenly on its own, so the parsed section always carries a
    // weight per topic and it is the emitted json that must stay silent.
    expect((emitted.single as Map).containsKey('topicWeights'), isFalse);

    final sections = BlueprintSection.parseList(
      blueprint.toSectionsJson(topicsBySubject),
    );
    expect(sections.single.topicWeights.values.toSet(), {1.0});
  });
}
