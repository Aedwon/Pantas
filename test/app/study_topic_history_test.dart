import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/paywall/paywall.dart';

import '../helpers/in_memory_database.dart';

/// 3M-9. The map's open topic is a remembered choice kept per exam, not a
/// page. Opening, switching and closing it never writes a browser history
/// entry, so Back leaves Study in one press instead of stepping through topics
/// that all share the address /study.
void main() {
  testWidgets('opening and switching topics adds no browser entry',
      (tester) async {
    final db = inMemoryDatabase();
    final contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Science',
    );
    for (final id in ['t1', 't2']) {
      await seedContentTopic(
        contentDb,
        topicId: id,
        subjectId: 's1',
        name: 'Topic $id',
      );
      await seedContentLesson(
        contentDb,
        lessonId: 'l$id',
        topicId: id,
        title: 'Lesson $id',
        bodyJson: jsonEncode(<Map<String, Object?>>[]),
        estimatedMinutes: 10,
      );
      await seedContentQuestion(
        contentDb,
        questionId: 'l${id}_q',
        topicId: id,
        examId: 'e1',
        lessonId: 'l$id',
      );
    }
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('e1');
    await NotificationRationaleRepository(db).markShown();
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    final reports = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.navigation,
      (call) async {
        if (call.method == 'routeInformationUpdated') reports.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.navigation, null),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          entitlementProvider
              .overrideWith((_) => Stream.value(const Entitlement.free())),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
    final container =
        ProviderScope.containerOf(tester.element(find.byType(App)));
    container.read(routerProvider).go('/study');
    await tester.pumpAndSettle();
    reports.clear();

    await tester.tap(find.text('Topic t1'));
    await tester.pumpAndSettle();
    expect(container.read(openTopicProvider).valueOrNull, 't1');
    await tester.tap(find.text('Topic t2'));
    await tester.pumpAndSettle();
    expect(container.read(openTopicProvider).valueOrNull, 't2');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(reports, isEmpty, reason: 'no history entry for a topic');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });
}
