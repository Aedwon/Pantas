// Route /assessment/:examId and its results. The wide layouts are the only
// ones the matrix tests cover.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';

import 'screen_harness.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'assessment_question',
    widths: [1440],
    (tester, width) => pumpScreen(
      tester,
      width,
      scaffolded(
        WebAssessmentLayout(
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
    ),
  );
  goldenScreen(
    'assessment_results',
    widths: [1440],
    (tester, width) => pumpScreen(
      tester,
      width,
      scaffolded(
        WebAssessmentResults(
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
      frames: 12,
    ),
  );
}
