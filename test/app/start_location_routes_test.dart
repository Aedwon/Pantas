import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/start_location.dart';

/// Every route, decided once for a direct load or reload on the web.
///
/// A route added later fails the walk below until it is listed here, so
/// whoever adds it decides whether a student can open it cold.

/// Routes that open where they are. Each is checked against the start rules.
const _honored = <String>{
  '/home',
  // The beta gate and the email sign-in link land cold by design.
  '/beta',
  '/auth/email-link',
  '/study',
  '/quiz',
  '/settings',
  '/performance',
  '/performance/topic/:topicId',
  '/record',
  '/tendencies',
  '/plan',
  '/plan/history',
  '/plan/day/:date',
  '/plan/week/:start',
  '/lesson/:lessonId',
  '/quiz/today/:examId',
  '/quiz/resume/:examId',
  '/quiz/practice/:examId',
  '/quiz/viewer/:attemptId',
  '/quiz/flagged/:examId',
  '/quiz/flagged/:examId/view/:questionId',
  '/quiz/all/:attemptId',
  '/quiz/debrief/:attemptId',
  '/quiz/mock/resume/:attemptId',
  '/quiz/mock/custom-setup',
  '/mock/results/:attemptId',
  '/mock/review/:attemptId',
  '/assessment/:examId/results',
  '/onboarding',
  '/guardian',
  '/guardian/waiting',
  '/update-required',
  '/pro',
  '/settings/practice',
  '/settings/appearance',
  '/settings/accessibility',
  '/settings/exam',
  '/settings/exam/change',
  '/settings/exam/transfer',
  '/settings/exam/included',
  '/settings/account',
  '/settings/account/name',
  '/settings/pro',
  '/settings/backup',
  '/settings/about',
  '/settings/beta-feedback',
  '/settings/beta-feedback/survey',
  '/settings/beta-feedback/sent/:id',
  '/legal/:doc',
};

/// Routes that start somewhere else, with where.
const _mapped = <String, String>{
  '/study/ending/:topicId': '/study',
  '/quiz/quick/:examId': '/quiz',
  '/quiz/retake/:examId': '/quiz',
  '/quiz/inline/:examId/:lessonId': '/quiz',
  '/quiz/practice/:examId/run': '/quiz/practice/x',
  '/quiz/mock/start': '/quiz',
  '/quiz/mock/setup': '/quiz',
  '/settings/exam/upgrade': '/settings/exam/change',
  '/settings/account/delete': '/settings/account',
  '/settings/account/adult-check': '/settings/account',
  '/settings/_debug': '/settings',
  '/settings/_gallery': '/settings',
  '/onboarding/custom/name': '/onboarding',
  '/onboarding/custom/subjects': '/onboarding',
  '/assessment/:examId': '/home',
  '/guardian/contact': '/guardian/waiting',
  '/wrapped/:artifactId': '/home',
};

/// A route nested under another reports only its own segment.
const _nested = <String, String>{
  'results': '/assessment/:examId/results',
};

String _sample(String pattern) => pattern.replaceAll(RegExp(r':\w+'), 'x');

String _start(String pattern) => startLocationFor(
      Uri.parse('https://app.example.test${_sample(pattern)}'),
      isWeb: true,
    );

void main() {
  test('every route is decided for a direct load', () {
    final decided = {..._honored, ..._mapped.keys};
    final undecided = [
      for (final path in collectRoutePaths())
        if (!decided.contains(_nested[path] ?? path)) path,
    ];
    expect(
      undecided,
      isEmpty,
      reason: 'Add each route to _honored, or to _mapped with where it '
          'starts, and to the rules in start_location.dart.',
    );
  });

  test('no route is decided twice, and none is listed that is gone', () {
    expect(_honored.intersection(_mapped.keys.toSet()), isEmpty);
    final real = {
      for (final path in collectRoutePaths()) _nested[path] ?? path,
    };
    expect(
      {..._honored, ..._mapped.keys}.difference(real),
      isEmpty,
    );
  });

  test('a listed route starts the way its list says', () {
    for (final pattern in _honored) {
      expect(_start(pattern), _sample(pattern), reason: pattern);
    }
    _mapped.forEach((pattern, target) {
      expect(_start(pattern), target, reason: pattern);
    });
  });
}
