import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('reader failure keeps its back control and retries the load',
      (tester) async {
    var attempts = 0;
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'missing'),
      overrides: [
        readerContextProvider('missing').overrideWith((_) async {
          attempts++;
          throw Exception('private database path');
        }),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load this lesson.'), findsOneWidget);
    expect(find.text('Study'), findsOneWidget);
    expect(
      tester
          .getSize(
            find.ancestor(
              of: find.text('Study'),
              matching: find.byType(TextButton),
            ),
          )
          .height,
      44,
    );
    expect(find.textContaining('private'), findsNothing);
    expect(find.byType(StateView), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
  });

  testWidgets('reader loading announces immediately and delays its shapes',
      (tester) async {
    final pending = Completer<ReaderContext?>();
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'loading'),
      overrides: [
        readerContextProvider('loading').overrideWith((_) => pending.future),
      ],
    );
    expect(find.text('Study'), findsOneWidget);
    expect(find.byType(LoadingShapes), findsOneWidget);
    expect(find.byKey(const ValueKey('loading-shapes-opacity')), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('loading-shapes-opacity')),
      findsOneWidget,
    );
    pending.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Lesson not found.'), findsOneWidget);
    expect(find.byType(LoadingShapes), findsNothing);
    expect(find.byType(StateView), findsOneWidget);
  });
}
