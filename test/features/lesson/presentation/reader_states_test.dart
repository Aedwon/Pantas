import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());
  const focus = ActiveExamFocus.selected(
    Exam(
      id: 'e',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
      language: 'en',
      isActive: true,
      subjects: [],
    ),
  );
  testWidgets('reader failure keeps its back control and retries the load',
      (tester) async {
    var attempts = 0;
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'missing'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeExamFocusProvider.overrideWith((_) async => focus),
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
              matching: find.byType(WebBackLink),
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

  testWidgets(
      'a failed lesson load shows the retry state and Try Again reloads',
      (tester) async {
    var attempts = 0;
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'listed'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeExamFocusProvider.overrideWith((_) async => focus),
        readerContextProvider('listed').overrideWith((_) async {
          attempts++;
          throw const LessonLoadFailure('listed');
        }),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load this lesson.'), findsOneWidget);
    expect(find.text('Lesson not found.'), findsNothing);
    expect(find.text('Try Again'), findsOneWidget);
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
        appDatabaseProvider.overrideWithValue(db),
        activeExamFocusProvider.overrideWith((_) async => focus),
        readerContextProvider('loading').overrideWith((_) => pending.future),
      ],
    );
    await tester.pump();
    expect(find.text('Study'), findsOneWidget);
    expect(find.byType(SkeletonPulse), findsWidgets);
    expect(find.byKey(const ValueKey('loading-shapes-opacity')), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('loading-shapes-opacity')),
      findsOneWidget,
    );
    pending.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Lesson not found.'), findsOneWidget);
    expect(find.byType(SkeletonPulse), findsNothing);
    expect(find.byType(StateView), findsOneWidget);
  });
}
