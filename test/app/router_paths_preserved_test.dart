import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';

void main() {
  test('route split preserves every declared path from W1 base', () {
    const before = <String>[
      '/home',
      '/study',
      '/quiz',
      '/progress',
      '/onboarding',
      '/onboarding/custom/name',
      '/onboarding/custom/subjects',
      '/notifications/rationale',
      '/plan/dossier/:mockId',
      '/progress/how-you-work',
      '/progress/your-record',
      '/quiz/today/:examId',
      '/quiz/resume/:examId',
      '/quiz/quick/:examId',
      '/quiz/practice/:examId',
      '/quiz/practice/:examId/run',
      '/quiz/retake/:examId',
      '/quiz/inline/:examId/:lessonId',
      '/quiz/debrief/:attemptId',
      '/quiz/flagged/:examId',
      '/quiz/results/:attemptId',
      '/quiz/mock/setup',
      '/quiz/mock/start',
      '/quiz/mock/resume/:attemptId',
      '/quiz/mock/custom-setup',
      '/lesson/:lessonId',
      '/study/ending/:topicId',
      '/assessment/:examId',
      'results',
      '/review',
      '/mock/results/:attemptId',
      '/mock/review/:attemptId',
      '/mock-exam',
      '/wrapped/:artifactId',
      '/paywall',
      '/settings',
      '/settings/sessions',
      '/more',
      '/settings/exam',
      '/settings/exam/change',
      '/settings/exam/included',
      '/settings/account',
      '/settings/account/delete',
      '/settings/pro',
      '/settings/subscription',
      '/settings/backup',
      '/update-required',
      '/settings/about',
      '/settings/_debug',
      '/legal/:doc',
    ];
    expect(collectRoutePaths(), unorderedEquals(before));
  });
  test('branch roots are selected by path, not family list position', () {
    final shell =
        buildAppRoutes(_RouteRef()).whereType<StatefulShellRoute>().single;
    expect(
      shell.branches.map((branch) => (branch.routes.single as GoRoute).path),
      ['/home', '/study', '/quiz', '/settings'],
    );
  });
}

class _RouteRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
