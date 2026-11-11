import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';

class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a page pushed over a lesson sits above the web shell', () {
    final routes = buildAppRoutes(_FakeRef(), web: true);
    final top = routes.whereType<GoRoute>().map((route) => route.path).toSet();

    expect(top, contains('/lesson/:lessonId'));
    expect(top, containsAll(webRoutesAboveLesson));

    final shell = routes.whereType<ShellRoute>().single;
    final inShell =
        shell.routes.whereType<GoRoute>().map((route) => route.path).toSet();
    expect(inShell.intersection(webRoutesAboveLesson), isEmpty);
  });

  test('the phone app keeps its routes as they are', () {
    final routes = buildAppRoutes(_FakeRef(), web: false);
    expect(routes.whereType<ShellRoute>(), isEmpty);
    final top = routes.whereType<GoRoute>().map((route) => route.path).toSet();
    expect(top, containsAll(webRoutesAboveLesson));
  });
}
