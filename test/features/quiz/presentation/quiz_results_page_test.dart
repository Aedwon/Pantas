import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/exam_marks_offer.dart';

class MockQuestion extends Mock implements Question {}

void main() {
  late MockQuestion mockQuestion1;
  late MockQuestion mockQuestion2;

  setUp(() {
    mockQuestion1 = MockQuestion();
    when(() => mockQuestion1.id).thenReturn('q-101');
    when(() => mockQuestion1.stem).thenReturn('Stem 1');
    when(() => mockQuestion1.choices).thenReturn([
      const Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: true),
      const Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: false),
    ]);
    when(() => mockQuestion1.correctChoice).thenReturn(
      const Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: true),
    );

    mockQuestion2 = MockQuestion();
    when(() => mockQuestion2.id).thenReturn('q-102');
    when(() => mockQuestion2.stem).thenReturn('Stem 2');
    when(() => mockQuestion2.choices).thenReturn([
      const Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: true),
    ]);
    when(() => mockQuestion2.correctChoice).thenReturn(
      const Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: true),
    );
  });

  testWidgets('the practice review is flat and offers nothing', (tester) async {
    final entry = ReviewEntry(
      number: 1,
      question: mockQuestion1,
      chosenChoiceId: 'c_b',
      isFlagged: false,
      subjectName: 'Science',
      label: 'Short label',
      labelIsStem: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ReviewList(
            entries: [entry],
            proIsActive: false,
            grouped: false,
            onToggleFlag: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final reviewListWidget = tester.widget<ReviewList>(find.byType(ReviewList));
    expect(reviewListWidget.grouped, isFalse);
    expect(find.byType(ExamMarksOffer), findsNothing);
  });

  testWidgets('no raw question id is ever printed', (tester) async {
    final entry = ReviewEntry(
      number: 1,
      question: mockQuestion1,
      chosenChoiceId: 'c_b',
      isFlagged: false,
      subjectName: 'Science',
      label: 'Short label',
      labelIsStem: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ReviewList(
            entries: [entry],
            proIsActive: false,
            grouped: false,
            onToggleFlag: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('q-101'), findsNothing);
  });

  testWidgets('the practice review also opens on Wrong', (tester) async {
    final entry1 = ReviewEntry(
      number: 1,
      question: mockQuestion1,
      chosenChoiceId: 'c_b',
      isFlagged: false,
      subjectName: 'Science',
      label: 'Wrong Question',
      labelIsStem: false,
    );
    final entry2 = ReviewEntry(
      number: 2,
      question: mockQuestion2,
      chosenChoiceId: 'c_a',
      isFlagged: false,
      subjectName: 'Science',
      label: 'Correct Question',
      labelIsStem: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ReviewList(
            entries: [entry1, entry2],
            proIsActive: false,
            grouped: false,
            onToggleFlag: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wrong Question'), findsOneWidget);
    expect(find.text('Correct Question'), findsNothing);
  });
}
