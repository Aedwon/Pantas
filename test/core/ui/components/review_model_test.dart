import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/ui/components/review_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dummyQuestion = Question(
    id: 'q_1',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 'topic_1',
    language: 'en',
    stem: 'Stem 1',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Option A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Option B', isCorrect: true),
    ],
    explanation: 'Explanation',
  );

  final entries = [
    // 1: correct, not flagged, Math
    const ReviewEntry(
      number: 1,
      question: dummyQuestion,
      chosenChoiceId: 'c_b',
      isFlagged: false,
      subjectName: 'Mathematics',
      label: 'Q1',
      labelIsStem: false,
    ),
    // 2: correct, flagged, Science
    const ReviewEntry(
      number: 2,
      question: dummyQuestion,
      chosenChoiceId: 'c_b',
      isFlagged: true,
      subjectName: 'Science',
      label: 'Q2',
      labelIsStem: false,
    ),
    // 3: correct, not flagged, Math
    const ReviewEntry(
      number: 3,
      question: dummyQuestion,
      chosenChoiceId: 'c_b',
      isFlagged: false,
      subjectName: 'Mathematics',
      label: 'Q3',
      labelIsStem: false,
    ),
    // 4: wrong, flagged, Science
    const ReviewEntry(
      number: 4,
      question: dummyQuestion,
      chosenChoiceId: 'c_a',
      isFlagged: true,
      subjectName: 'Science',
      label: 'Q4',
      labelIsStem: false,
    ),
    // 5: blank (wrong), not flagged, Math
    const ReviewEntry(
      number: 5,
      question: dummyQuestion,
      isFlagged: false,
      subjectName: 'Mathematics',
      label: 'Q5',
      labelIsStem: false,
    ),
  ];

  test('counts split the paper three ways', () {
    final counts = FilterReviewEntries.count(entries);
    expect(counts.all, 5);
    expect(counts.wrong, 2); // the wrong one and the blank one
    expect(counts.flagged, 2);
  });

  test('the wrong filter keeps blanks', () {
    expect(
      FilterReviewEntries.call(entries, ReviewFilter.wrong)
          .map((e) => e.number),
      equals([4, 5]),
    );
  });

  test('the flagged filter keeps only flags', () {
    expect(
      FilterReviewEntries.call(entries, ReviewFilter.flagged)
          .map((e) => e.number),
      equals([2, 4]),
    );
  });

  test('the all filter keeps the order it was given', () {
    expect(
      FilterReviewEntries.call(entries, ReviewFilter.all).map((e) => e.number),
      equals([1, 2, 3, 4, 5]),
    );
  });

  test('grouping keeps subjects in first-seen order', () {
    final grouped = FilterReviewEntries.groupBySubject(entries);
    expect(grouped.keys, equals(['Mathematics', 'Science']));
  });

  test('grouping keeps question order inside a subject', () {
    final grouped = FilterReviewEntries.groupBySubject(entries);
    expect(
      grouped['Mathematics']!.map((e) => e.number),
      equals([1, 3, 5]),
    );
    expect(
      grouped['Science']!.map((e) => e.number),
      equals([2, 4]),
    );
  });
}
