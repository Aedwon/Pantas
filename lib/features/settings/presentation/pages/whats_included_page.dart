import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson_meta.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/study_delivery.dart';

final whatsIncludedDataProvider = FutureProvider.family<
    ({
      Exam exam,
      List<ScopeSubject> subjects,
      Set<TopicId> excluded,
      Set<LessonId> excludedLessons
    }),
    ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final excluded = await ref.watch(trackScopeProvider(examId).future);
  final exam = (await content.listExams()).firstWhere((e) => e.id == examId);
  final groups = <String, List<Topic>>{};
  if (exam.isCustom) {
    for (final topic in await corpusTopics(content)) {
      final subject = await content.subjectById(topic.subjectId);
      groups.putIfAbsent(subject?.name ?? topic.subjectId, () => []).add(topic);
    }
  } else {
    for (final subject in exam.subjects) {
      groups[subject.name] = await content.topicsBySubject(subject.id);
    }
  }
  final topics = [for (final group in groups.values) ...group];
  final lessons =
      await content.lessonMetaByTopics([for (final t in topics) t.id]);
  final excludedLessons = await ref.watch(lessonScopeProvider(examId).future);
  return (
    excludedLessons: excludedLessons,
    exam: exam,
    excluded: excluded,
    subjects: [
      for (final group in groups.entries)
        ScopeSubject(
          title: group.key,
          topics: [
            for (final topic in group.value)
              ScopeTopic(
                id: topic.id,
                title: topic.name,
                lessons: [
                  for (final l in lessons[topic.id] ?? const <LessonMeta>[])
                    ScopeLesson(id: l.id, title: l.title),
                ],
              ),
          ],
        ),
    ]
  );
});

class WhatsIncludedPage extends ConsumerStatefulWidget {
  const WhatsIncludedPage({super.key});
  @override
  ConsumerState<WhatsIncludedPage> createState() => _WhatsIncludedPageState();
}

class _WhatsIncludedPageState extends ConsumerState<WhatsIncludedPage> {
  bool _saving = false;
  bool _failed = false;
  late Set<String> _pending;
  Future<void> _save(
    String examId,
    List<ScopeSubject> subjects,
    Set<String> selected,
  ) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
      _pending = selected;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      final publish =
          await ref.read(studySettingsCaptureProvider)(examId: examId);
      await publish.apply(
        () => ref.read(customTrackRepositoryProvider).setExcluded(
          examId: examId,
          topicIds: {
            for (final subject in subjects)
              for (final topic in subject.topics)
                if (topic.lessons.isEmpty
                    ? !selected.contains(topic.id)
                    : !topic.lessons.any((l) => selected.contains(l.id)))
                  topic.id,
          },
          lessonIds: {
            for (final subject in subjects)
              for (final topic in subject.topics)
                for (final lesson in topic.lessons)
                  if (!selected.contains(lesson.id)) lesson.id,
          },
        ),
      );
      if (!mounted) return;
      ref
        ..invalidate(trackScopeProvider(examId))
        ..invalidate(lessonScopeProvider(examId))
        ..invalidate(scopedTopicsProvider(examId))
        ..invalidate(scopedSubjectsProvider(examId))
        ..invalidate(whatsIncludedDataProvider(examId));
    } catch (error, stack) {
      await telemetry.recordError(error, stack);
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final focus = ref.watch(activeExamFocusProvider);
    final examId = focus.valueOrNull?.exam?.id;
    final data =
        examId == null ? null : ref.watch(whatsIncludedDataProvider(examId));
    return PantasPage(
      title: 'What’s included',
      backLabel: 'Your exam',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        if (data == null)
          loadingFor(focus)
        else
          data.when(
            loading: () => loadingFor(data),
            error: (error, _) => errorFor(
              'topics',
              () => ref.invalidate(whatsIncludedDataProvider(examId!)),
              error: error,
            ),
            data: (scope) {
              final selected = {
                for (final subject in scope.subjects)
                  for (final topic in subject.topics)
                    if (!scope.excluded.contains(topic.id))
                      if (topic.lessons.isEmpty)
                        topic.id
                      else
                        for (final lesson in topic.lessons)
                          if (!scope.excludedLessons.contains(lesson.id))
                            lesson.id,
              };
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    scope.exam.shortName,
                    style: context.type.body
                        .copyWith(color: context.colors.secondaryLabel),
                  ),
                  const SizedBox(height: 24),
                  IgnorePointer(
                    ignoring: _saving,
                    child: ScopePicker(
                      subjects: scope.subjects,
                      selectedIds: selected,
                      minimumSelectionMessage:
                          'At least one topic stays ticked.',
                      onChanged: (selected) =>
                          unawaited(_save(examId!, scope.subjects, selected)),
                    ),
                  ),
                  Text(
                    'Untick what you don’t need. '
                    'It gets removed from your plan, '
                    'and your answers on it won’t be deleted.',
                    style: context.type.footnote,
                  ),
                  if (_failed)
                    saveFailureLine(
                      () => _save(examId!, scope.subjects, _pending),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}
