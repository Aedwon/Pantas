import 'package:pantas/core/content/sanity/groq_queries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GROQ delta queries include updatedAt since filter', () {
    expect(GroqQueries.examsDelta, contains(r'_updatedAt > $since'));
    expect(GroqQueries.questionsDelta, contains(r'_updatedAt > $since'));
    expect(GroqQueries.lessonsDelta, contains(r'_updatedAt > $since'));
  });

  test('GROQ query registry exposes all Spec 2 doctypes', () {
    expect(
      GroqQueries.fullByDoctype.keys,
      containsAll([
        'exam',
        'subject',
        'topic',
        'question',
        'lesson',
        'mockExam',
        'mockBlueprint',
        'diagnosticSet',
      ]),
    );
  });
}
