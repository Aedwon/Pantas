import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_card.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  Future<PerformanceViewData> load(String examId) async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    const slugs = [
      'vocabulary',
      'logical_verbal_reasoning',
      'algebra',
      'philippine_constitution',
    ];
    try {
      for (final slug in slugs) {
        await seedContentTopicWithQuestions(
          contentDb,
          examId: examId,
          subjectId: 'subject_$slug',
          topicId: 'topic_cse_pro_$slug',
          topicName: slug,
          questionIds: ['${slug}_0', '${slug}_1'],
        );
      }
      await AppPreferencesRepository(db).setSelectedExamId(examId);
      await db.into(db.attemptsLocal).insert(
            AttemptsLocalCompanion.insert(
              id: 'attempt',
              examId: examId,
              startedAt: DateTime(2026, 8),
              completedAt: Value(DateTime(2026, 8, 1, 0, 20)),
              itemsJson: jsonEncode([
                for (final slug in slugs)
                  for (var i = 0; i < 2; i++)
                    {
                      'questionId': '${slug}_$i',
                      'questionVersion': 1,
                      'chosenChoiceId': i == 0 ? 'a' : 'b',
                      'correctChoiceId': 'a',
                      'responseMs': 1000,
                    },
              ]),
            ),
          );
      return await container.read(performanceViewProvider.future);
    } finally {
      container.dispose();
      await db.close();
      await contentDb.close();
    }
  }

  const weighted = [
    'Verbal Ability (30%)',
    'Analytical Ability (35%)',
    'Numerical Ability (30%)',
    'General Information (5%)',
  ];

  test('CSE Professional part rows carry their weight', () async {
    final view = await load('exam_cse_pro');
    expect(
      [for (final row in view.subjects) row.title],
      unorderedEquals(weighted),
    );
  });

  test('Subprofessional rows show no weight', () async {
    final view = await load('exam_cse_sub');
    expect(view.subjects, isNotEmpty);
    for (final row in view.subjects) {
      expect(row.title, isNot(contains('%')));
    }
  });

  test('another exam shows no weight', () async {
    final view = await load('exam_upcat');
    for (final row in view.subjects) {
      expect(row.title, isNot(contains('%')));
    }
  });

  testWidgets('Home card shows the weights on phone and wide', (tester) async {
    final data = await tester.runAsync(() => load('exam_cse_pro'));
    addTearDown(() => debugWebPlatformOverride = null);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final web in [false, true]) {
      debugWebPlatformOverride = web;
      tester.view.physicalSize = Size(web ? 1440 : 390, 1600);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: web),
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomePerformanceCard(
                rows: data!.subjects,
                overallAccuracy: data.overallAccuracy,
                pro: true,
                web: web,
                onOpen: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in weighted) {
        expect(find.text(label), findsOneWidget, reason: 'web=$web $label');
      }
    }
  });

  testWidgets('Performance page shows the weights, header in capitals',
      (tester) async {
    final data = await tester.runAsync(() => load('exam_cse_pro'));
    addTearDown(() => debugWebPlatformOverride = null);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final web in [false, true]) {
      debugWebPlatformOverride = web;
      tester.view.physicalSize = Size(web ? 1440 : 390, 1600);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: web),
          home: PerformancePage(
            data: data!,
            pro: true,
            paused: false,
            onTopic: (_) {},
            onPro: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in weighted) {
        expect(
          find.textContaining(label),
          findsOneWidget,
          reason: 'web=$web $label',
        );
      }
    }
    // Phone: choosing a part scopes the list and the header names it.
    debugWebPlatformOverride = false;
    tester.view.physicalSize = const Size(390, 1600);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: PerformancePage(
          data: data!,
          pro: true,
          paused: false,
          onTopic: (_) {},
          onPro: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Analytical Ability (35%)'));
    await tester.pumpAndSettle();
    expect(find.text('ANALYTICAL ABILITY (35%)'), findsOneWidget);
  });
}
