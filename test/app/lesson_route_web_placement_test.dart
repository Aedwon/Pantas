import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';

/// On the web a lesson has to open above the shell, so it can cover the
/// sidebar while the page and sidebar underneath stay put. Native builds have
/// no web shell and keep the flat list.
void main() {
  bool isLesson(RouteBase route) =>
      route is GoRoute && route.path == '/lesson/:lessonId';

  bool holdsLesson(RouteBase route) =>
      isLesson(route) || route.routes.any(holdsLesson);

  test('on web the lesson is a sibling of the shell, not inside it', () {
    final routes = buildAppRoutes(_RouteRef(), web: true);
    final shell = routes.whereType<ShellRoute>().single;

    expect(routes.where(isLesson), hasLength(1));
    expect(holdsLesson(shell), isFalse);
  });

  test('on web the lesson is the only route lifted out of the shell', () {
    final flat = buildAppRoutes(_RouteRef());
    final routes = buildAppRoutes(_RouteRef(), web: true);
    final shell = routes.whereType<ShellRoute>().single;

    expect(shell.routes.length, flat.length - 1);
    expect(routes.length, 2);
  });

  test('the web shell still holds the study tab', () {
    final shell =
        buildAppRoutes(_RouteRef(), web: true).whereType<ShellRoute>().single;

    expect(shell.routes.whereType<StatefulShellRoute>(), hasLength(1));
  });

  test('off web the list is flat and the lesson stays where it was', () {
    final routes = buildAppRoutes(_RouteRef(), web: false);

    expect(routes.whereType<ShellRoute>(), isEmpty);
    expect(routes.where(isLesson), hasLength(1));
  });

  test('the lesson path is still reachable on both', () {
    expect(
      collectRoutePaths(includeDebugGallery: false),
      contains('/lesson/:lessonId'),
    );
  });
}

class _RouteRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
