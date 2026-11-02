import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/list_routes.dart' as routes;

void main() {
  group('listRoutes on the real route files', () {
    late List<routes.PanelRoute> found;

    setUpAll(() {
      found = routes.listRoutes(Directory('lib/app'));
    });

    test('lists the Home and lesson routes', () {
      final paths = found.map((route) => route.path).toList();
      expect(paths, contains('/home'));
      expect(paths, contains('/lesson/:lessonId'));
    });

    test('lists each path once', () {
      final paths = found.map((route) => route.path).toList();
      expect(paths.toSet().length, paths.length);
    });

    test('joins a nested path to its parent', () {
      final paths = found.map((route) => route.path).toList();
      expect(paths, contains('/assessment/:examId/results'));
      expect(paths, isNot(contains('results')));
    });

    test('leaves out routes a profile build does not register', () {
      final paths = found.map((route) => route.path).toList();
      expect(paths.where((path) => path.contains('/_')), isEmpty);
    });

    test('names the cards the approved board shows', () {
      String label(String path) =>
          found.singleWhere((route) => route.path == path).label;
      expect(label('/home'), 'Home');
      expect(label('/plan'), 'Plan');
      expect(label('/plan/history'), 'Plan history');
      expect(label('/performance'), 'Performance');
      expect(label('/study'), 'Study');
      expect(label('/quiz'), 'Quiz');
      expect(label('/quiz/today/:examId'), "Today's quiz");
      expect(label('/lesson/:lessonId'), 'Lesson');
      expect(label('/quiz/mock/setup'), 'Mock setup');
      expect(label('/settings'), 'Settings');
      expect(label('/pro'), 'Pro');
      expect(label('/mock/results/:attemptId'), 'Mock results');
    });

    test('puts each route in the group the plan names', () {
      String group(String path) =>
          found.singleWhere((route) => route.path == path).group;
      expect(group('/home'), 'Home and plan');
      expect(group('/plan/history'), 'Home and plan');
      expect(group('/study'), 'Study and quiz');
      expect(group('/quiz/today/:examId'), 'Study and quiz');
      expect(group('/assessment/:examId'), 'Study and quiz');
      expect(group('/quiz/mock/setup'), 'Mock');
      expect(group('/mock/results/:attemptId'), 'Mock');
      expect(group('/settings'), 'Settings and Pro');
      expect(group('/pro'), 'Settings and Pro');
      expect(group('/legal/:doc'), 'Settings and Pro');
      expect(group('/onboarding'), 'Other');
    });
  });

  group('routesIn', () {
    test('resolves nesting and ignores paths that are not routes', () {
      const source = '''
final a = [
  GoRoute(
    path: '/top/:id',
    builder: (_, __) => Foo(Uri(path: '/not-a-route')),
    routes: [
      GoRoute(path: 'child', builder: (_, __) => Bar()),
    ],
  ),
  GoRoute(path: '/other', redirect: (_, s) => s.uri.replace(path: '/x')),
];
''';
      expect(
        routes.routesIn(source),
        ['/top/:id', '/top/:id/child', '/other'],
      );
    });
  });

  test('the script prints a JSON list of path, label and group', () {
    final result = Process.runSync('dart', ['run', 'tool/list_routes.dart']);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final decoded = jsonDecode(result.stdout as String) as List<Object?>;
    expect(decoded, isNotEmpty);
    final first = decoded.first! as Map<String, Object?>;
    expect(first.keys, containsAll(['path', 'label', 'group']));
    final paths =
        decoded.map((row) => (row! as Map<String, Object?>)['path']).toList();
    expect(paths, contains('/home'));
    expect(paths.toSet().length, paths.length);
  });
}
