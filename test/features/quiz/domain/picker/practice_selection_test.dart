import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';

PracticeLessonEntry lesson(String id, {int questionCount = 4}) =>
    PracticeLessonEntry(
      id: id,
      title: 'Lesson $id',
      isRead: false,
      questionCount: questionCount,
    );

final algebra = PracticeTopicEntry(
  id: 'topic_algebra',
  name: 'Algebra',
  questionCount: 20,
  lessons: [lesson('l_1'), lesson('l_2'), lesson('l_3')],
);

const untagged = PracticeTopicEntry(
  id: 'topic_geometry',
  name: 'Geometry',
  questionCount: 20,
  lessons: [],
);

final index = PracticeIndex([
  PracticeSubjectEntry(
    id: 'subject_maths',
    name: 'Mathematics',
    topics: [algebra, untagged],
  ),
]);

void main() {
  test('nothing is selected to begin with', () {
    const selection = PracticeSelection.empty();

    expect(selection.isEmpty, isTrue);
    expect(selection.topicState(algebra), PracticeCheckState.off);
    expect(selection.units(index), isEmpty);
  });

  test('selecting a topic selects every lesson beneath it', () {
    final selection = const PracticeSelection.empty().toggleTopic(algebra);

    expect(selection.topicState(algebra), PracticeCheckState.on);
    expect(selection.lessonSelected('l_1'), isTrue);
    expect(selection.lessonSelected('l_3'), isTrue);
  });

  test('a fully selected topic is one unit per lesson', () {
    final selection = const PracticeSelection.empty().toggleTopic(algebra);

    final units = selection.units(index);
    expect(units, hasLength(3));
    expect(units.map((u) => u.lessonId), ['l_1', 'l_2', 'l_3']);
  });

  test('deselecting one lesson drops the topic to the dash', () {
    final selection = const PracticeSelection.empty()
        .toggleTopic(algebra)
        .toggleLesson(algebra, lesson('l_2'));

    expect(selection.topicState(algebra), PracticeCheckState.partial);
  });

  test('a partly selected topic is one unit per kept lesson', () {
    final selection = const PracticeSelection.empty()
        .toggleTopic(algebra)
        .toggleLesson(algebra, lesson('l_2'));

    final units = selection.units(index);
    expect(units, hasLength(2));
    expect(units.every((unit) => unit.topicId == 'topic_algebra'), isTrue);
    expect(
      units.map((unit) => unit.lessonId),
      unorderedEquals(['l_1', 'l_3']),
    );
  });

  test('deselecting the last lesson turns the topic off', () {
    var selection = const PracticeSelection.empty().toggleTopic(algebra);
    for (final entry in algebra.lessons) {
      selection = selection.toggleLesson(algebra, entry);
    }

    expect(selection.topicState(algebra), PracticeCheckState.off);
    expect(selection.isEmpty, isTrue);
  });

  test('selecting one lesson alone leaves the topic on the dash', () {
    final selection =
        const PracticeSelection.empty().toggleLesson(algebra, lesson('l_1'));

    expect(selection.topicState(algebra), PracticeCheckState.partial);
    expect(selection.units(index), hasLength(1));
  });

  test('a topic that cannot unfold is all or nothing', () {
    final selection = const PracticeSelection.empty().toggleTopic(untagged);

    expect(selection.topicState(untagged), PracticeCheckState.on);
    expect(selection.units(index).single.lessonId, isNull);
  });

  test('clearing drops everything', () {
    final selection =
        const PracticeSelection.empty().toggleTopic(algebra).cleared();

    expect(selection.isEmpty, isTrue);
  });

  test('toggling a selected topic turns it off', () {
    final selection = const PracticeSelection.empty()
        .toggleTopic(algebra)
        .toggleTopic(algebra);

    expect(selection.topicState(algebra), PracticeCheckState.off);
  });

  test('toggling a partly selected topic fills it', () {
    final selection = const PracticeSelection.empty()
        .toggleTopic(algebra)
        .toggleLesson(algebra, lesson('l_2'))
        .toggleTopic(algebra);

    expect(selection.topicState(algebra), PracticeCheckState.on);
  });
}
