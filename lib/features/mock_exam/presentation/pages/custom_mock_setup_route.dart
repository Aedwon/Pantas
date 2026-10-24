import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';

final customBlueprintRepositoryProvider = Provider<CustomBlueprintRepository>(
  (ref) => CustomBlueprintRepository(ref.watch(appDatabaseProvider)),
);

/// What the setup screen needs, read from the student's own track.
final customMockSetupDataProvider =
    FutureProvider<CustomMockSetupData?>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final exam = focus.exam;
  if (exam == null) return null;

  final topics = await ref.watch(scopedTopicsProvider(exam.id).future);
  final subjects = await ref.watch(scopedSubjectsProvider(exam.id).future);
  final content = ref.watch(contentRepositoryProvider);

  final topicsBySubject = <SubjectId, List<Topic>>{};
  for (final topic in topics) {
    (topicsBySubject[topic.subjectId] ??= []).add(topic);
  }

  // Counted from the scoped topics, so it follows the track rather than
  // the whole corpus.
  var available = 0;
  for (final topic in topics) {
    available += (await content.questionsByTopic(topic.id)).length;
  }

  final row = await ref.watch(customBlueprintRepositoryProvider).read(exam.id);
  return CustomMockSetupData(
    examId: exam.id,
    subjects: subjects,
    topicsBySubject: topicsBySubject,
    availableQuestions: available,
    saved: row == null ? null : savedCustomBlueprint(row, subjects),
  );
});

/// Reads a saved setup back into what the form shows. The stored sections
/// carry the subject's name, so a breakdown maps back to its subjects.
CustomBlueprint savedCustomBlueprint(
  CustomBlueprintRow row,
  List<Subject> subjects,
) {
  final sections = <CustomBlueprintSectionDraft>[];
  final decoded = jsonDecode(row.sectionsJson) as List<dynamic>;
  final oneBlock = decoded.length == 1 &&
      (decoded.first as Map<String, dynamic>)['id'] == 'section_all';
  if (!oneBlock) {
    for (final value in decoded) {
      final map = value as Map<String, dynamic>;
      final name = map['name'] as String;
      final subject = subjects.where((s) => s.name == name).firstOrNull;
      sections.add(
        CustomBlueprintSectionDraft(
          subjectId: subject?.id,
          name: name,
          questions: map['questionCount'] as int,
          minutes: map['suggestedMinutes'] as int,
        ),
      );
    }
  }
  return CustomBlueprint(
    examId: row.examId,
    totalQuestions: row.totalQuestions,
    totalMinutes: row.totalMinutes,
    sections: sections,
    sectionsTimedSeparately: row.sectionsTimedSeparately,
  );
}

class CustomMockSetupRoute extends ConsumerWidget {
  const CustomMockSetupRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(customMockSetupDataProvider).valueOrNull;
    if (data == null) {
      return const Scaffold(body: Center(child: FaintBars()));
    }

    return CustomMockSetupPage(
      data: data,
      onBack: () => context.pop(),
      onTickMoreSubjects: () => context.push('/settings/exam/included'),
      onSave: (blueprint) async {
        await ref.read(customBlueprintRepositoryProvider).save(
              blueprint,
              topicsBySubject: {
                for (final entry in data.topicsBySubject.entries)
                  entry.key: [for (final topic in entry.value) topic.id],
              },
              now: DateTime.now(),
            );
        if (context.mounted) context.pop();
      },
    );
  }
}
