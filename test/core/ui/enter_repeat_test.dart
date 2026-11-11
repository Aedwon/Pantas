import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

/// A held Enter key repeats. A repeat must never advance a screen, because
/// the next screen would otherwise act on the same press.
Future<void> heldEnter(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
  await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
  await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
}

void main() {
  void wide(WidgetTester tester) {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('a held Enter advances the welcome step once', (tester) async {
    wide(tester);
    var advanced = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: OnboardingWelcomeStep(onAdvance: () => advanced++),
      ),
    );
    await tester.pump();
    await heldEnter(tester);
    expect(advanced, 1);
  });

  testWidgets('a held Enter acknowledges assessment results once',
      (tester) async {
    wide(tester);
    var done = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: WebAssessmentResults(
            examName: 'CSE',
            correct: 18,
            total: 30,
            subjects: const [(name: 'Math', correct: 9, total: 10)],
            onAcknowledge: () => done++,
          ),
        ),
      ),
    );
    await heldEnter(tester);
    expect(done, 1);
  });

  testWidgets('a held Enter moves a question screen on once', (tester) async {
    wide(tester);
    var next = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: WebAssessmentLayout(
            question: const Question(
              id: 'q',
              version: 1,
              examIds: ['e'],
              language: 'en',
              topicId: 't',
              stem: 'Which organelle makes ATP?',
              explanation: 'x',
              choices: [
                Choice(id: 'a', label: 'A', text: 'Nucleus', isCorrect: false),
                Choice(id: 'c', label: 'C', text: 'Mito', isCorrect: true),
              ],
            ),
            subject: 'Science',
            examName: 'CSE',
            index: 1,
            total: 30,
            chosenId: 'a',
            onPick: (_) {},
            onNext: () => next++,
            onLeave: () {},
          ),
        ),
      ),
    );
    await heldEnter(tester);
    expect(next, 1);
  });

  test('every Enter shortcut in lib ignores key repeats', () {
    final pattern = RegExp(r'SingleActivator\(\s*LogicalKeyboardKey\.enter\b');
    final bad = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final text = file.readAsStringSync();
      for (final m in pattern.allMatches(text)) {
        final end = text.indexOf(')', m.end);
        if (!text.substring(m.start, end).contains('includeRepeats: false')) {
          bad.add(file.path);
        }
      }
    }
    expect(bad, isEmpty);
  });
}
