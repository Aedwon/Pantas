import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

void main() {
  test('parses valid sections json in blueprint order', () {
    final sections = BlueprintSection.parseList(
      jsonEncode([
        {
          'id': 'verbal',
          'name': 'Verbal Ability',
          'questionCount': 30,
          'suggestedMinutes': 35,
          'topicIds': ['synonyms', 'reading'],
          'topicWeights': {'synonyms': 2, 'reading': 1},
        },
        {
          'id': 'math',
          'name': 'Numerical Ability',
          'questionCount': 20,
          'suggestedMinutes': 25,
          'topicIds': ['algebra'],
        },
      ]),
    );

    expect(sections.map((section) => section.id), ['verbal', 'math']);
    expect(sections.first.name, 'Verbal Ability');
    expect(sections.first.questionCount, 30);
    expect(sections.first.suggestedMinutes, 35);
    expect(sections.first.topicIds, ['synonyms', 'reading']);
    expect(sections.first.topicWeights, {'synonyms': 2.0, 'reading': 1.0});
  });

  test('defaults uniform topic weights when omitted', () {
    final sections = BlueprintSection.parseList(
      jsonEncode([
        {
          'id': 'general',
          'name': 'General Information',
          'questionCount': 10,
          'suggestedMinutes': 12,
          'topicIds': ['constitution', 'current_events'],
        },
      ]),
    );

    expect(
      sections.single.topicWeights,
      {'constitution': 1.0, 'current_events': 1.0},
    );
  });

  test('preserves approved placeholder metadata on section figures', () {
    final sections = BlueprintSection.parseList(
      jsonEncode([
        {
          'id': 'verbal',
          'name': 'Verbal Ability',
          'questionCount': {
            'value': 30,
            'placeholder': true,
            'placeholderNote': 'Published per-subject count is unresolved.',
          },
          'suggestedMinutes': 35,
          'sectionalMinutes': {
            'value': 35,
            'placeholder': true,
            'placeholderNote': 'Published section time is unresolved.',
          },
          'topicIds': ['synonyms'],
        },
      ]),
    );

    final section = sections.single;
    expect(section.questionCount, 30);
    expect(section.questionCountFigure.isPlaceholder, isTrue);
    expect(
      section.questionCountFigure.placeholderNote,
      'Published per-subject count is unresolved.',
    );
    expect(section.sectionalMinutes, 35);
    expect(section.sectionalMinutesFigure?.isPlaceholder, isTrue);
  });

  test('throws BlueprintParseException for malformed json', () {
    expect(
      () => BlueprintSection.parseList('{not-json'),
      throwsA(isA<BlueprintParseException>()),
    );
  });

  test('throws when questionCount or suggestedMinutes is non-positive', () {
    expect(
      () => BlueprintSection.parseList(
        jsonEncode([
          {
            'id': 'bad',
            'name': 'Bad',
            'questionCount': 0,
            'suggestedMinutes': 1,
            'topicIds': ['topic'],
          },
        ]),
      ),
      throwsA(isA<BlueprintParseException>()),
    );

    expect(
      () => BlueprintSection.parseList(
        jsonEncode([
          {
            'id': 'bad',
            'name': 'Bad',
            'questionCount': 1,
            'suggestedMinutes': 0,
            'topicIds': ['topic'],
          },
        ]),
      ),
      throwsA(isA<BlueprintParseException>()),
    );
  });
}
