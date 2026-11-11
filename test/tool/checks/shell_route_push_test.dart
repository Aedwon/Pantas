import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/check.dart';
import '../../../tool/checks/shell_route_push.dart';

List<Violation> scan(Map<String, String> sources) => findShellPushes(
      sources: sources,
      roots: const {'lib/lesson_page.dart'},
      shellRoutes: const {'/settings/pro', '/quiz', '/plan/:id'},
      aboveRoutes: const {'/lesson/:lessonId', '/quiz/viewer/:attemptId'},
    );

void main() {
  test('a push to a shell route from a page above the shell fails', () {
    final found = scan({
      'lib/lesson_page.dart': "void a(c) => c.push('/settings/pro?benefit=x');",
    });
    expect(found.single.where, 'lib/lesson_page.dart:1');
    expect(found.single.message, contains('/settings/pro'));
  });

  test('so does one from code it imports, with an interpolated path', () {
    final found = scan({
      'lib/lesson_page.dart': "import 'widgets/sheet.dart';",
      'lib/widgets/sheet.dart': r"void a(c, id) => c.push<void>('/plan/$id');",
    });
    expect(found.single.where, 'lib/widgets/sheet.dart:1');
  });

  test('so does a constant path', () {
    final found = scan({
      'lib/lesson_page.dart': """
const paywall = '/settings/pro?benefit=x';
void a(c) => c.push(paywall);
""",
    });
    expect(found.single.where, 'lib/lesson_page.dart:2');
  });

  test('pushes to routes above the shell pass', () {
    expect(
      scan({
        'lib/lesson_page.dart': r"""
void a(c, id) {
  c.push('/lesson/$id?from=x');
  c.push('/quiz/viewer/${id.a(b)}?index=1' '&notes=true');
}
""",
      }),
      isEmpty,
    );
  });

  test('a go, a guarded push, and code nothing imports all pass', () {
    expect(
      scan({
        'lib/lesson_page.dart': """
void a(c, router) {
  c.go('/settings/pro');
  if (kIsWeb && matches.last is! ShellRouteMatch) {
    router.go(paywall);
  } else {
    router.push('/settings/pro');
  }
  c.canPop() ? c.pop() : c.pushReplacement('/quiz');
}
""",
        'lib/other.dart': "void a(c) => c.push('/settings/pro');",
      }),
      isEmpty,
    );
  });

  test('an unguarded replacement fails', () {
    expect(
      scan(
        {'lib/lesson_page.dart': "void a(c) => c.pushReplacement('/quiz');"},
      ),
      hasLength(1),
    );
  });
}
