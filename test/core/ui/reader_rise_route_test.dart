import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/reader_transition.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

/// Item 5, option A. A lesson opened from the study page fades in and rises
/// while the page behind it, and its sidebar or tab bar, do not move at all.
/// Going back plays the same motion in reverse.
void main() {
  const studyKey = ValueKey('study-page');
  const lessonKey = ValueKey('lesson-page');
  const tabBarKey = ValueKey('tab-bar');
  const step = Duration(milliseconds: 80);
  const curve = Cubic(0.32, 0.72, 0, 1);

  late GoRouter router;

  /// Mirrors how the app wires a lesson on each platform: on web the page
  /// sits in the shell and the lesson is a sibling of the shell, wrapped in
  /// its own copy of it; on a phone there is no shell, only a tab bar.
  GoRouter buildRouter({required bool web}) {
    Widget study() => Scaffold(
          body: const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('Study', key: studyKey),
            ),
          ),
          bottomNavigationBar:
              web ? null : const SizedBox(key: tabBarKey, height: 64),
        );
    Widget lesson(GoRouterState state) {
      const page = Scaffold(
        body: Center(child: Text('Lesson', key: lessonKey)),
      );
      return web ? WebRouteShell(path: state.uri.path, child: page) : page;
    }

    return GoRouter(
      initialLocation: '/study',
      routes: [
        if (web)
          ShellRoute(
            // WebShellFrame is what the app's shell builds around a sidebar
            // route. It reads kIsWeb, which a test cannot set, so web is
            // passed in.
            builder: (context, state, child) => WebShellFrame(
              web: true,
              activeIndex: 1,
              person: '',
              exam: 'CSE',
              plan: 'Free',
              onNavigate: (_) {},
              onSearch: () {},
              child: child,
            ),
            routes: [GoRoute(path: '/study', builder: (_, __) => study())],
          )
        else
          GoRoute(path: '/study', builder: (_, __) => study()),
        GoRoute(
          path: '/lesson/:id',
          pageBuilder: (_, state) => readerPage(
            key: state.pageKey,
            child: lesson(state),
          ),
        ),
      ],
    );
  }

  Future<void> pumpApp(WidgetTester tester, {required bool web}) async {
    debugWebPlatformOverride = web ? true : null;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = web ? const Size(1440, 900) : const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    router = buildRouter(web: web);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: buildLightTheme(web: web),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double fadeOf(WidgetTester tester, Key key) => tester
      .widgetList<FadeTransition>(
        find.ancestor(
          of: find.byKey(key, skipOffstage: false),
          matching: find.byType(FadeTransition),
        ),
      )
      .fold<double>(1, (product, fade) => product * fade.opacity.value);

  /// The route is created on the first frame after a push and starts moving
  /// on the next, so frame zero of the animation is the second pump.
  Future<void> pushLesson(WidgetTester tester) async {
    unawaited(router.push<void>('/lesson/a'));
    await tester.pump();
    await tester.pump();
  }

  Rect rectOf(WidgetTester tester, Finder finder) =>
      tester.getRect(finder.first);

  /// What stays put: every rect and fade of the page being left.
  void expectBehindUntouched(
    WidgetTester tester, {
    required bool web,
    required Rect study,
    required Rect? sidebar,
    required Rect? tabBar,
    required String frame,
  }) {
    expect(
      rectOf(tester, find.byKey(studyKey, skipOffstage: false)),
      study,
      reason: 'page behind at $frame',
    );
    expect(fadeOf(tester, studyKey), 1, reason: 'page fade at $frame');
    if (web) {
      expect(
        rectOf(tester, find.byType(WebSidebar, skipOffstage: false)),
        sidebar,
        reason: 'sidebar at $frame',
      );
    } else {
      expect(
        rectOf(tester, find.byKey(tabBarKey, skipOffstage: false)),
        tabBar,
        reason: 'tab bar at $frame',
      );
    }
  }

  for (final web in [true, false]) {
    final where = web ? 'wide web' : 'phone';

    testWidgets('$where: the lesson rises in and the page behind never moves',
        (tester) async {
      await pumpApp(tester, web: web);
      final study = rectOf(tester, find.byKey(studyKey));
      final sidebar = web ? rectOf(tester, find.byType(WebSidebar)) : null;
      final tabBar = web ? null : rectOf(tester, find.byKey(tabBarKey));
      final window = Offset.zero & tester.view.physicalSize;

      // Learn where the lesson rests, then open it again for the frames.
      unawaited(router.push<void>('/lesson/a'));
      await tester.pumpAndSettle();
      final rest = rectOf(tester, find.byKey(lessonKey));
      expect(fadeOf(tester, lessonKey), 1);
      expect(
        rectOf(
          tester,
          find.ancestor(
            of: find.byKey(lessonKey),
            matching: find.byType(Scaffold),
          ),
        ),
        window,
        reason: 'the lesson covers the whole window, sidebar included',
      );
      router.pop();
      await tester.pumpAndSettle();
      expectBehindUntouched(
        tester,
        web: web,
        study: study,
        sidebar: sidebar,
        tabBar: tabBar,
        frame: 'before opening',
      );

      await pushLesson(tester);
      for (var i = 0; i <= 4; i++) {
        if (i > 0) await tester.pump(step);
        final progress = i / 4;
        final eased = curve.transform(progress);
        final frame = '${i * 25} percent';
        final top = rectOf(tester, find.byKey(lessonKey)).top;

        expect(
          top - rest.top,
          closeTo((1 - eased) * readerRiseTravel, 0.6),
          reason: 'lesson rise at $frame',
        );
        expect(
          fadeOf(tester, lessonKey),
          closeTo(eased, 0.03),
          reason: 'lesson fade at $frame',
        );
        expectBehindUntouched(
          tester,
          web: web,
          study: study,
          sidebar: sidebar,
          tabBar: tabBar,
          frame: frame,
        );
      }
      await tester.pumpAndSettle();
      expect(rectOf(tester, find.byKey(lessonKey)), rest);
      expect(fadeOf(tester, lessonKey), 1);
    });

    testWidgets('$where: going back plays the arrival in reverse',
        (tester) async {
      await pumpApp(tester, web: web);
      final study = rectOf(tester, find.byKey(studyKey));
      final sidebar = web ? rectOf(tester, find.byType(WebSidebar)) : null;
      final tabBar = web ? null : rectOf(tester, find.byKey(tabBarKey));

      await pushLesson(tester);
      final arriving = <double>[];
      final arrivingTop = <double>[];
      for (var i = 0; i <= 4; i++) {
        if (i > 0) await tester.pump(step);
        arriving.add(fadeOf(tester, lessonKey));
        arrivingTop.add(rectOf(tester, find.byKey(lessonKey)).top);
      }
      await tester.pumpAndSettle();

      router.pop();
      await tester.pump();
      for (var i = 0; i <= 4; i++) {
        if (i > 0) await tester.pump(step);
        final mirror = 4 - i;
        final frame = '${i * 25} percent of the way back';
        if (i < 4) {
          expect(
            fadeOf(tester, lessonKey),
            closeTo(arriving[mirror], 0.03),
            reason: 'fade $frame',
          );
          expect(
            rectOf(tester, find.byKey(lessonKey)).top,
            closeTo(arrivingTop[mirror], 0.6),
            reason: 'position $frame',
          );
        }
        expectBehindUntouched(
          tester,
          web: web,
          study: study,
          sidebar: sidebar,
          tabBar: tabBar,
          frame: frame,
        );
      }
      await tester.pumpAndSettle();
      expect(find.byKey(lessonKey), findsNothing);
      expectBehindUntouched(
        tester,
        web: web,
        study: study,
        sidebar: sidebar,
        tabBar: tabBar,
        frame: 'the end',
      );
    });

    testWidgets('$where: reduced motion shows the lesson at once',
        (tester) async {
      await pumpApp(tester, web: web);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      final study = rectOf(tester, find.byKey(studyKey));
      final sidebar = web ? rectOf(tester, find.byType(WebSidebar)) : null;
      final tabBar = web ? null : rectOf(tester, find.byKey(tabBarKey));

      await pushLesson(tester);
      final first = rectOf(tester, find.byKey(lessonKey));
      expect(fadeOf(tester, lessonKey), 1);
      await tester.pump(step);
      expect(rectOf(tester, find.byKey(lessonKey)), first);
      await tester.pumpAndSettle();
      expect(rectOf(tester, find.byKey(lessonKey)), first);
      expect(fadeOf(tester, lessonKey), 1);
      expectBehindUntouched(
        tester,
        web: web,
        study: study,
        sidebar: sidebar,
        tabBar: tabBar,
        frame: 'reduced motion',
      );
    });
  }
}
