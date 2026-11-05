import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_card.dart';
import 'package:pantas/features/home/presentation/widgets/web_performance_layout.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  Future<PerformanceViewData> load(
    String examId,
    Map<String, List<bool>> answers,
  ) async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    try {
      for (final entry in answers.entries) {
        await seedContentTopicWithQuestions(
          contentDb,
          examId: examId,
          subjectId: 'subject_${entry.key}',
          topicId: 'topic_cse_pro_${entry.key}',
          topicName: entry.key,
          questionIds: [
            for (var i = 0; i < entry.value.length; i++) '${entry.key}_$i',
          ],
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
                for (final entry in answers.entries)
                  for (var i = 0; i < entry.value.length; i++)
                    {
                      'questionId': '${entry.key}_$i',
                      'questionVersion': 1,
                      'chosenChoiceId': entry.value[i] ? 'a' : 'b',
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

  Future<void> expectGauge(
    WidgetTester tester,
    PerformanceViewData data,
    double expected,
  ) async {
    addTearDown(() => debugWebPlatformOverride = null);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final web in [false, true]) {
      debugWebPlatformOverride = web;
      tester.view.physicalSize = Size(web ? 1440 : 390, 900);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: web),
          home: PerformancePage(
            data: data,
            pro: true,
            paused: false,
            onTopic: (_) {},
            onPro: () {},
            onBack: () {},
          ),
        ),
      );
      expect(
        find.byType(WebPerformanceLayout),
        web ? findsOneWidget : findsNothing,
      );
      expect(
        tester.widget<HalfRingGauge>(find.byType(HalfRingGauge)).fraction,
        closeTo(expected, 1e-12),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: web),
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomePerformanceCard(
                rows: data.subjects,
                overallAccuracy: data.overallAccuracy,
                pro: true,
                web: web,
                onOpen: () {},
              ),
            ),
          ),
        ),
      );
      expect(
        tester.widget<HalfRingGauge>(find.byType(HalfRingGauge)).fraction,
        closeTo(expected, 1e-12),
      );
    }
  }

  const answers = {
    'vocabulary': [true, true, true, false],
    'text_types': [false, false],
    'logical_verbal_reasoning': [false],
    'data_interpretation': [true, true, true],
    'arithmetic_number_sense': [true, false],
    'algebra': [true, true],
    'philippine_constitution': [false],
    'geometry': [true, true, true, true],
  };

  testWidgets('CSE Professional overall accuracy uses CSC areas',
      (tester) async {
    final view = await load('exam_cse_pro', answers);
    // Verbal 3/6, Analytical 3/4, Numerical 3/4, General Information 0/1.
    await expectGauge(tester, view, .6375);
    expect(
      view.subjects.firstWhere((r) => r.id == 'subject_geometry').accuracy,
      1,
    );
  });

  testWidgets('an unanswered area is left out of the weights', (tester) async {
    final view = await load('exam_cse_pro', {
      'text_types': [true, true],
      'data_interpretation': [false],
    });
    await expectGauge(tester, view, 30 / 65);
  });

  for (final exam in ['exam_cse_sub', 'exam_upcat']) {
    testWidgets('$exam keeps correct divided by answered', (tester) async {
      final view = await load(exam, answers);
      await expectGauge(tester, view, 13 / 19);
    });
  }
}
