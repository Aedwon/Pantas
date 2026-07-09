import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_result.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_result_providers.dart';
import 'package:cse_cet_reviewer/features/home/presentation/home_providers.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/home_stats_band.dart';
import 'package:cse_cet_reviewer/features/metrics/atoms/atom.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/home_atom_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness({
  required int? accuracyPct,
  required int read,
  required int total,
  String? lately,
}) {
  const examId = 'exam_1';
  final now = DateTime(2026, 8, 2, 20);

  AssessmentResult? result;
  if (accuracyPct != null) {
    result = AssessmentResult(
      examId: examId,
      completedAt: now,
      topicMasteries: [
        TopicMastery(
          topic: const Topic(
            id: 'topic_1',
            subjectId: 'sub_1',
            name: 'Topic 1',
            ordering: 1,
          ),
          correct: accuracyPct,
          total: 100,
        ),
      ],
    );
  }

  AtomChip? chip;
  if (lately != null) {
    chip = AtomChip(text: lately);
  }

  return ProviderScope(
    overrides: [
      assessmentResultProvider(examId).overrideWith((ref) async => result),
      lessonsReadProvider(examId)
          .overrideWith((ref) async => LessonsRead(read: read, total: total)),
      homeAtomProvider.overrideWith((ref, arg) async => chip),
    ],
    child: MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: HomeStatsBand(examId: examId, now: now),
      ),
    ),
  );
}

void main() {
  testWidgets('prints accuracy and lessons read, centred', (tester) async {
    await tester.pumpWidget(
      harness(accuracyPct: 64, read: 41, total: 96),
    );
    await tester.pumpAndSettle();

    expect(find.text('64%'), findsOneWidget);
    expect(find.text('accuracy'), findsOneWidget);
    expect(find.text('41'), findsOneWidget);
    expect(find.text('/96'), findsOneWidget);
    expect(find.text('lessons read'), findsOneWidget);

    expect(tester.widget<StatsBand>(find.byType(StatsBand)).centred, isTrue);
  });

  testWidgets('days to exam is not repeated here', (tester) async {
    await tester.pumpWidget(harness(accuracyPct: 64, read: 41, total: 96));
    await tester.pumpAndSettle();
    expect(find.textContaining('days'), findsNothing);
  });

  testWidgets('no assessment result drops the band entirely', (tester) async {
    await tester.pumpWidget(harness(accuracyPct: null, read: 41, total: 96));
    await tester.pumpAndSettle();
    expect(find.byType(StatsBand), findsNothing);
  });

  testWidgets('the Lately line renders beneath, with no em dash',
      (tester) async {
    await tester.pumpWidget(
      harness(
        accuracyPct: 64,
        read: 41,
        total: 96,
        lately: 'day 6 streak, your longest this month.',
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Lately: day 6 streak, your longest this month.'),
      findsOneWidget,
    );
    expect(find.textContaining('—'), findsNothing);
  });

  testWidgets('no Lately atom renders no line', (tester) async {
    await tester.pumpWidget(
      harness(accuracyPct: 64, read: 41, total: 96, lately: null),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Lately'), findsNothing);
  });
}
