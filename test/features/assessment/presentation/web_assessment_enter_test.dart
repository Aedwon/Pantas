import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';

void main() {
  const question = Question(
    id: 'q',
    version: 1,
    examIds: ['e'],
    language: 'en',
    topicId: 't',
    stem: 'Which organelle makes ATP?',
    explanation: 'Hidden answer',
    choices: [
      Choice(id: 'a', label: 'A', text: 'Nucleus', isCorrect: false),
      Choice(id: 'b', label: 'B', text: 'Ribosome', isCorrect: false),
      Choice(id: 'c', label: 'C', text: 'Mitochondrion', isCorrect: true),
    ],
  );

  testWidgets('Enter runs the focused control, else goes next', (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var next = 0;
    var leave = 0;
    String? picked = 'a';
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(web: true),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: WebAssessmentLayout(
              question: question,
              subject: 'Science',
              examName: 'CSE',
              index: 0,
              total: 5,
              chosenId: picked,
              onPick: (id) => setState(() => picked = id),
              onNext: () => next++,
              onLeave: () => leave++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // On the page: next.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(next, 1);
    // On Leave: Leave runs, the question does not advance.
    Focus.of(tester.element(find.byIcon(Icons.close).first)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(leave, 1);
    expect(next, 1);
    // On an unpicked choice: it is picked, the question does not advance.
    Focus.of(tester.element(find.text('Mitochondrion'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(picked, 'c');
    expect(next, 1);
  });

  testWidgets('Leave dialog: Enter keeps going, a focused Leave leaves',
      (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var keep = 0;
    var leave = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(web: true),
        home: Scaffold(
          body: WebAssessmentLeaveDialog(
            onKeepGoing: () => keep++,
            onLeave: () => leave++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(keep, 1);
    expect(leave, 0);
    Focus.of(tester.element(find.text('Leave').last)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(leave, 1);
    expect(keep, 1);
  });
}
