import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/reader_transition.dart';

/// A lesson moves aside only for another lesson. Anything else laid over it,
/// such as the figure viewer, a dialog or a sheet, leaves it where it is.
void main() {
  late GoRouter router;
  late BuildContext lessonContext;
  const lessonKey = ValueKey('lesson-a');

  Future<void> pumpReader(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    router = GoRouter(
      initialLocation: '/lesson/a',
      routes: [
        GoRoute(
          path: '/lesson/:id',
          pageBuilder: (_, state) => readerPage(
            key: state.pageKey,
            child: Builder(
              builder: (context) {
                if (state.pathParameters['id'] == 'a') lessonContext = context;
                return Scaffold(
                  body: Center(
                    child: Text(
                      'lesson ${state.pathParameters['id']}',
                      key: state.pathParameters['id'] == 'a' ? lessonKey : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  double lessonOpacity(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find
            .ancestor(
              of: find.byKey(lessonKey),
              matching: find.byType(FadeTransition),
            )
            .first,
      )
      .opacity
      .value;

  Future<void> expectLessonStaysStill(
    WidgetTester tester,
    Future<Object?> Function() cover,
  ) async {
    final home = tester.getRect(find.byKey(lessonKey));
    unawaited(cover());
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getRect(find.byKey(lessonKey)), home);
      expect(lessonOpacity(tester), 1);
    }
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(lessonKey, skipOffstage: false)), home);
  }

  testWidgets('a full screen viewer pushed over a lesson leaves it still',
      (tester) async {
    await pumpReader(tester);
    await expectLessonStaysStill(
      tester,
      () => Navigator.of(lessonContext).push<void>(
        PageRouteBuilder<void>(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (_, __, ___) => const Material(color: Color(0xE00A0A0C)),
        ),
      ),
    );
  });

  testWidgets('a dialog over a lesson leaves it still', (tester) async {
    await pumpReader(tester);
    await expectLessonStaysStill(
      tester,
      () => showDialog<void>(
        context: lessonContext,
        builder: (_) => const Dialog(child: SizedBox(width: 200, height: 100)),
      ),
    );
  });

  testWidgets('a sheet over a lesson leaves it still', (tester) async {
    await pumpReader(tester);
    await expectLessonStaysStill(
      tester,
      () => showModalBottomSheet<void>(
        context: lessonContext,
        builder: (_) => const SizedBox(height: 200),
      ),
    );
  });

  testWidgets('a page that is not a lesson leaves the lesson still',
      (tester) async {
    await pumpReader(tester);
    await expectLessonStaysStill(
      tester,
      () => Navigator.of(lessonContext).push<void>(
        MaterialPageRoute<void>(builder: (_) => const Scaffold()),
      ),
    );
  });

  testWidgets('another lesson still carries the first one aside',
      (tester) async {
    await pumpReader(tester);
    final home = tester.getRect(find.byKey(lessonKey));
    unawaited(router.push('/lesson/b'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 190));
    final moving = tester.getRect(find.byKey(lessonKey, skipOffstage: false));
    expect(moving.left, lessThan(home.left));
    expect(lessonOpacity(tester), lessThan(1));
    await tester.pumpAndSettle();
    expect(find.text('lesson b'), findsOneWidget);
  });
}
