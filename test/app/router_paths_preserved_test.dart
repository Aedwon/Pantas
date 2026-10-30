import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';

void main() {
  test('route split preserves W1 paths and approved quiz additions', () {
    const before = <String>[
      '/home',
      '/study',
      '/quiz',
      '/onboarding',
      '/onboarding/custom/name',
      '/onboarding/custom/subjects',
      '/plan',
      '/plan/day/:date',
      '/plan/week/:start',
      '/plan/history',
      '/performance',
      '/record',
      '/tendencies',
      '/performance/topic/:topicId',
      '/quiz/today/:examId',
      '/quiz/resume/:examId',
      '/quiz/quick/:examId',
      '/quiz/practice/:examId',
      '/quiz/practice/:examId/run',
      '/quiz/retake/:examId',
      '/quiz/inline/:examId/:lessonId',
      '/quiz/viewer/:attemptId',
      '/quiz/flagged/:examId/view/:questionId',
      '/quiz/all/:attemptId',
      '/quiz/debrief/:attemptId',
      '/quiz/flagged/:examId',
      '/quiz/mock/setup',
      '/quiz/mock/start',
      '/quiz/mock/resume/:attemptId',
      '/quiz/mock/custom-setup',
      '/lesson/:lessonId',
      '/study/ending/:topicId',
      '/assessment/:examId',
      'results',
      '/mock/results/:attemptId',
      '/mock/review/:attemptId',
      '/wrapped/:artifactId',
      '/pro',
      '/settings',
      '/settings/practice',
      '/settings/appearance',
      '/settings/account/name',
      '/settings/exam',
      '/settings/exam/change',
      '/settings/exam/upgrade',
      '/settings/exam/transfer',
      '/settings/exam/included',
      '/settings/account',
      '/settings/account/delete',
      '/settings/pro',
      '/settings/backup',
      '/update-required',
      '/settings/about',
      '/settings/_debug',
      '/legal/:doc',
    ];
    expect(
      collectRoutePaths(includeDebugGallery: false),
      unorderedEquals(before),
    );
  });
  test('interim redirects are retired after family integration', () {
    final paths = collectRoutePaths();
    for (final path in [
      '/notifications/rationale',
      '/quiz/results/:attemptId',
      '/review',
      '/mock-exam',
      '/paywall',
      '/settings/sessions',
      '/more',
      '/settings/subscription',
    ]) {
      expect(paths, isNot(contains(path)));
    }
  });
  test('retired Progress and dossier routes are absent', () {
    expect(
      collectRoutePaths(includeDebugGallery: false).where(
        (path) =>
            path.startsWith('/progress') || path.startsWith('/plan/dossier'),
      ),
      isEmpty,
    );
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
