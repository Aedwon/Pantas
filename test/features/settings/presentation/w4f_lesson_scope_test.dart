import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'lesson selection persists a partial topic and guards the last lesson',
      (tester) async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(content.close);
    await seedContentExam(content, examId: 'e', code: 'CSE');
    await seedContentSubject(
      content,
      subjectId: 's',
      examId: 'e',
      name: 'Math',
    );
    await seedContentTopic(
      content,
      topicId: 't',
      subjectId: 's',
      name: 'Algebra',
    );
    for (final id in ['l1', 'l2']) {
      await seedContentLesson(content, lessonId: id, topicId: 't', title: id);
    }
    await tester.pumpAppWithProviders(
      const WhatsIncludedPage(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        activeExamFocusProvider.overrideWith(
          (ref) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scope-expand-t')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scope-select-l1')));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WhatsIncludedPage)),
    );
    final repo = container.read(customTrackRepositoryProvider);
    expect(await repo.excludedLessonIds('e'), {'l1'});
    expect(await repo.excludedTopicIds('e'), isEmpty);
    expect(find.byKey(const ValueKey('scope-partial-t')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scope-select-l2')));
    await tester.pumpAndSettle();
    expect(await repo.excludedLessonIds('e'), {'l1'});
    expect(find.text('At least one topic stays ticked.'), findsOneWidget);
  });
}
