import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  test('the reader, quiz and mock sessions are focus pages; tab pages not', () {
    for (final path in [
      '/lesson/l1',
      '/quiz/resume/e',
      '/quiz/quick/e',
      '/quiz/retake/e',
      '/quiz/inline/e/l1',
      '/quiz/practice/e/run',
      '/quiz/viewer/a',
      '/quiz/flagged/e/view/q',
      '/quiz/mock/start',
      '/quiz/mock/resume/a',
      '/mock/review/a',
    ]) {
      expect(webFocusRoute(path), isTrue, reason: path);
    }
    for (final path in [
      '/home',
      '/study',
      '/quiz',
      '/quiz/practice/e',
      '/quiz/all/a',
      '/quiz/flagged/e',
      '/mock/results/a',
      '/assessment/e',
    ]) {
      expect(webFocusRoute(path), isFalse, reason: path);
    }
  });

  // 7W-18, 3K-9a: from 1024 to 1279 the reader and the sessions take the
  // whole window, so their bars sit 28 px above its bottom with no padding.
  for (final (path, focus) in [
    ('/lesson/l1', true),
    ('/quiz/resume/e', true),
    ('/quiz/mock/resume/a', true),
    ('/quiz/all/a', false),
  ]) {
    testWidgets('$path at 1100 px: focus=$focus', (tester) async {
      debugWebPlatformOverride = true;
      tester.view
        ..physicalSize = const Size(1100, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const page = Placeholder(key: ValueKey('page'));
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: WebRouteShell(path: path, child: page),
          ),
        ),
      );
      expect(find.byType(AppNavBar), focus ? findsNothing : findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('page'))).height,
        focus ? 900 : 900 - 72,
      );
    });
  }
}
