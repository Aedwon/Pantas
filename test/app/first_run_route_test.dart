import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';

class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('/try sits above the web shell, like the lesson', () {
    final routes = buildAppRoutes(_FakeRef(), web: true);
    final top = routes.whereType<GoRoute>().map((r) => r.path).toSet();
    expect(top, contains('/try'));
    final shell = routes.whereType<ShellRoute>().single;
    final inShell =
        shell.routes.whereType<GoRoute>().map((r) => r.path).toSet();
    expect(inShell, isNot(contains('/try')));
  });

  test('/try is a top-level page on the phone app', () {
    final routes = buildAppRoutes(_FakeRef(), web: false);
    final top = routes.whereType<GoRoute>().map((r) => r.path).toSet();
    expect(top, contains('/try'));
  });
}
