// Home with an assessment left part way (C2B_Home, C2B_HomeWide) and the leave
// dialog that keeps the answers (C2B_Leave, C2B_LeaveWide).
//
// The PNGs come from the CI image (`[update-goldens]`); none are committed from
// a local run.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/assessment/application/assessment_progress_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_progress.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import 'fixtures/study_fixtures.dart';
import 'screen_harness.dart';

AssessmentProgress _eightOfThirty() => AssessmentProgress(
      examId: 'e1',
      attemptId: 'a1',
      startedAt: DateTime.utc(2026, 11, 9),
      questionIds: [for (var i = 0; i < 30; i++) 'q$i'],
      picks: {for (var i = 0; i < 8; i++) 'q$i': 'c'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final dark in [false, true]) {
    goldenScreen(
      'home_continue${dark ? '_dark' : ''}',
      (tester, width) => pumpStudyScreen(
        tester,
        width,
        const HomeTab(),
        shell: true,
        shellTab: 0,
        dark: dark,
        overrides: [
          nowProvider.overrideWithValue(() => screenNow),
          assessmentProgressProvider('e1')
              .overrideWith((ref) async => _eightOfThirty()),
        ],
      ),
    );
  }
  goldenScreen(
    'assessment_leave',
    (tester, width) => pumpScreen(
      tester,
      width,
      scaffolded(
        Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0x57000000))),
            Center(
              child: WebAssessmentLeaveDialog(
                onKeepGoing: () {},
                onLeave: () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
