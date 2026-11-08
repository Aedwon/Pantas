// Design system 4.0, Onboarding, assessment and guardian family: every screen
// at 390, 1100 and 1440 wide, light and dark, at text scale 1.0 and 2.0, with
// no layout overflow.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_motion.dart';
import 'package:pantas/features/assessment/presentation/assessment_skeletons.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';
import 'package:pantas/features/guardian/presentation/guardian_screen.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/onboarding_steps_harness.dart';

/// The three widths of the family: a phone, the compact sidebar range and the
/// full width.
final _cells = <DsCell>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
];

/// The wide web layouts only exist from 1024 up.
final _wideCells = [
  for (final cell in _cells)
    if (cell.width >= 1024) cell,
];

const _question = Question(
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
    Choice(id: 'd', label: 'D', text: 'Golgi apparatus', isCorrect: false),
  ],
);

/// The pieces of the phone results page, in a grouped section.
class _PhoneResults extends StatelessWidget {
  const _PhoneResults();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const AssessmentScoreGauge(correct: 18, total: 30),
          const SizedBox(height: 20),
          GroupedSection(
            header: 'BY SUBJECT · WEAKEST FIRST',
            children: [
              for (final (i, name)
                  in ['Mathematics', 'English', 'Science'].indexed)
                AssessmentSubjectRow(
                  name: name,
                  correct: 4 + i * 2,
                  total: 10,
                  divider: i < 2,
                ),
            ],
          ),
        ],
      );
}

void main() {
  setUpAll(loadGeist);

  group('onboarding steps in the frame', () {
    for (final step in framedOnboardingSteps) {
      for (final cell in _cells) {
        testWidgets('$step ($cell)', (tester) async {
          await pumpFramedStep(
            tester,
            step,
            wide: cell.width >= 1024,
            dark: cell.dark,
            width: cell.width,
            scale: cell.scale,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('assessment', () {
    dsMatrix(
      'question',
      (context) => SizedBox(
        height: 900,
        child: WebAssessmentLayout(
          question: _question,
          subject: 'Science · Biology',
          examName: 'CSE',
          index: 7,
          total: 30,
          chosenId: 'c',
          onPick: (_) {},
          onNext: () {},
          onLeave: () {},
        ),
      ),
      scroll: false,
      cells: _wideCells,
    );
    dsMatrix(
      'results',
      (context) => SizedBox(
        height: 900,
        child: WebAssessmentResults(
          examName: 'CSE',
          correct: 18,
          total: 30,
          elapsed: const Duration(minutes: 12),
          weakestTopic: 'Fractions and decimals',
          weakestSubject: 'Mathematics',
          subjects: const [
            (name: 'Mathematics', correct: 4, total: 10),
            (name: 'English', correct: 6, total: 10),
            (name: 'Science', correct: 8, total: 10),
          ],
          onAcknowledge: () {},
        ),
      ),
      scroll: false,
      cells: _wideCells,
    );
    dsMatrix(
      'phone results: gauge and subject rows',
      (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: _PhoneResults(),
      ),
      cells: [
        for (final cell in _cells)
          if (cell.width < 1024) cell,
      ],
    );
    dsMatrix(
      'results skeleton',
      (context) => const AssessmentResultsSkeleton(),
      scroll: false,
      cells: _cells,
    );
    for (final cell in _cells) {
      testWidgets('leave dialog ($cell)', (tester) async {
        await pumpDs(
          tester,
          cell,
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => WebAssessmentLeaveDialog(
                  onKeepGoing: () {},
                  onLeave: () {},
                ),
              ),
              child: const Text('open'),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Leave the assessment?'), findsOneWidget);
        expect(find.text('Keep Going'), findsOneWidget);
        expect(find.text('Leave'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('guardian frame', () {
    dsMatrix(
      'title, detail and actions',
      (context) => SizedBox(
        height: 900,
        child: GuardianScreen(
          title: 'Waiting for your parent or guardian',
          detail: 'We emailed m***@g***.com. Pantas opens here once they '
              'confirm.',
          actions: [
            FilledButton(onPressed: () {}, child: const Text('Check Again')),
            TextButton(onPressed: () {}, child: const Text('Resend Email')),
          ],
        ),
      ),
      scroll: false,
      cells: _cells,
    );
  });

  group('steps screen', () {
    dsMatrix(
      'restoring',
      (context) => SizedBox(
        height: 900,
        child: StepsScreen(
          title: 'Restoring your progress',
          subtitle: 'This takes a moment.',
          buttonLabel: 'Continue',
          onContinue: () {},
          steps: const [
            WorkStep(label: 'Account', state: WorkStepState.done),
            WorkStep(label: 'Progress', state: WorkStepState.active),
            WorkStep(
              label: 'Plan',
              state: WorkStepState.pending,
              detail: 'Almost there',
            ),
          ],
        ),
      ),
      scroll: false,
      cells: _cells,
    );
  });

  group('scope picker', () {
    for (final settings in [false, true]) {
      dsMatrix(
        'scope picker ${settings ? 'settings rows' : 'plain'}',
        (context) => ProviderScope(
          child: ScopePicker(
            settingsRows: settings,
            subjects: const [
              ScopeSubject(
                title: 'Mathematics',
                topics: [
                  ScopeTopic(
                    id: 't1',
                    title: 'Fractions',
                    lessons: [
                      ScopeLesson(id: 'l1', title: 'Adding fractions'),
                      ScopeLesson(id: 'l2', title: 'Unread one', unread: true),
                    ],
                  ),
                  ScopeTopic(id: 't2', title: 'Decimals'),
                ],
              ),
            ],
            selectedIds: const {'t2'},
            onChanged: (_) {},
          ),
        ),
        cells: _cells,
      );
    }
  });
}
