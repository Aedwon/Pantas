import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/exam_subject_groups.dart';
import 'package:pantas/core/metrics/overall_accuracy.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/mock_exam/application/mock_panel_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_skeletons.dart';

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
  final scopedSubjects =
      await ref.watch(scopedSubjectsProvider(exam.id).future);
  final content = ref.watch(contentRepositoryProvider);

  final isCse = csePartsForExam(exam.id).isNotEmpty;
  final eligible = isCse
      ? await content.lessonMetaByTopics(
          [for (final topic in topics) topic.id],
          examId: exam.id,
        )
      : null;
  final groups = examSubjectGroups(
    examId: exam.id,
    subjects: scopedSubjects,
    topics: [
      for (final topic in topics)
        if (eligible == null || eligible[topic.id]!.isNotEmpty) topic,
    ],
  );
  final subjects = isCse
      ? [
          for (final (index, group) in groups.indexed)
            Subject(
              id: group.id,
              examId: exam.id,
              name: group.name,
              ordering: index,
            ),
        ]
      : scopedSubjects;
  final topicsBySubject = <SubjectId, List<Topic>>{
    for (final group in groups) group.id: group.topics,
  };

  // Counted from the scoped topics, so it follows the track rather than
  // the whole corpus. A section draws on one subject, so each is counted.
  final availableBySubject = await countAvailableBySubject(
    content,
    topicsBySubject,
    examId: exam.id,
  );
  final available = availableBySubject.values.fold<int>(0, (a, b) => a + b);

  final row = await ref.watch(customBlueprintRepositoryProvider).read(exam.id);
  return CustomMockSetupData(
    examId: exam.id,
    subjects: subjects,
    topicsBySubject: topicsBySubject,
    availableQuestions: available,
    availableBySubject: availableBySubject,
    saved: row == null ? null : savedCustomBlueprint(row, subjects),
  );
});

/// How many questions the topics hold for [examId]. It reads the index rows
/// only, so on web it does not fetch every question set from the server just
/// to show a number.
Future<int> countAvailableQuestions(
  ContentRepository content,
  List<TopicId> topicIds, {
  required ExamId examId,
}) async {
  final grouped = await content.selectionRowsByTopics(
    topicIds,
    examId: examId,
  );
  return grouped.values.fold<int>(0, (sum, rows) => sum + rows.length);
}

/// How many questions each subject's topics hold for [examId], from the index
/// rows only. A subject whose topics hold none counts 0.
Future<Map<SubjectId, int>> countAvailableBySubject(
  ContentRepository content,
  Map<SubjectId, List<Topic>> topicsBySubject, {
  required ExamId examId,
}) async {
  final grouped = await content.selectionRowsByTopics(
    [
      for (final topics in topicsBySubject.values)
        for (final topic in topics) topic.id,
    ],
    examId: examId,
  );
  return {
    for (final entry in topicsBySubject.entries)
      entry.key: entry.value
          .fold<int>(0, (sum, topic) => sum + (grouped[topic.id]?.length ?? 0)),
  };
}

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
    final state = ref.watch(customMockSetupDataProvider);
    firstScreenReady(context, ref, ready: !state.isLoading);
    final data = state.valueOrNull;
    if (data == null) {
      return const MockSetupSkeleton();
    }

    return CustomMockSetupPage(
      data: data,
      onBack: () => leavePage(
        context,
        fallback: '/quiz',
        respectPopScope: false,
      ),
      onTickMoreSubjects: () => context.push('/settings/exam/included'),
      onSave: (blueprint) => _save(context, data, blueprint),
    );
  }
}

/// Saves the paper on this device, then hands it to the server.
///
/// On the web the student waits for the server, because the panel and the
/// start page read the paper from there. If the server cannot be reached the
/// error goes to the page, which stays open with the saved row kept: the next
/// publish carries it. On a phone the send runs in the background, as for
/// other settings.
Future<void> _save(
  BuildContext context,
  CustomMockSetupData data,
  CustomBlueprint blueprint,
) async {
  // The student may leave while the server answers, so nothing below reads
  // through the widget.
  final container = ProviderScope.containerOf(context, listen: false);
  final examId = data.examId;
  final web = container.read(mockUsesServerProvider);
  final telemetry = container.read(telemetryProvider);
  try {
    final publication =
        await container.read(studySettingsCaptureProvider)(examId: examId);
    await publication.apply(
      () => container.read(customBlueprintRepositoryProvider).save(
            blueprint,
            topicsBySubject: {
              for (final entry in data.topicsBySubject.entries)
                entry.key: [for (final topic in entry.value) topic.id],
            },
            now: DateTime.now(),
          ),
    );
    if (web) await publication.settled;
  } on Object catch (error, stack) {
    unawaited(telemetry.recordError(error, stack));
    rethrow;
  }
  // The panel, the start page and this page cached the old paper, and the
  // server's reading of it.
  container
    ..invalidate(customMockSetupDataProvider)
    ..invalidate(customMockSummaryProvider(examId))
    ..invalidate(mockSetupParsedBlueprintProvider(examId))
    ..invalidate(mockSetupQuestionCountProvider(examId));
  if (web) {
    container
      ..invalidate(serverMockSetupCountProvider(examId))
      ..invalidate(serverMockAvailabilityProvider(examId));
  }
  if (context.mounted) {
    leavePage(context, fallback: '/quiz', respectPopScope: false);
  }
}
