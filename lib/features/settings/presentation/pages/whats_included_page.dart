import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/components/topic_scope_index.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/study_delivery.dart';

final whatsIncludedDataProvider = FutureProvider.family<
    ({Exam exam, List<TopicScopeSubjectData> subjects, Set<TopicId> excluded}),
    ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final excluded = await ref.watch(trackScopeProvider(examId).future);
  final exams = await content.listExams();
  final exam = exams.firstWhere((e) => e.id == examId);

  final subjects = <TopicScopeSubjectData>[];

  if (exam.isCustom) {
    // For custom track: draw from corpusTopics
    final topics = await corpusTopics(content);
    final subjectMap = <String, List<Topic>>{};
    for (final t in topics) {
      final sub = await content.subjectById(t.subjectId);
      final subName = sub?.name ?? t.subjectId;
      subjectMap.putIfAbsent(subName, () => []).add(t);
    }
    for (final entry in subjectMap.entries) {
      subjects.add(
        TopicScopeSubjectData(
          id: entry.key,
          name: entry.key,
          topics: [
            for (final t in entry.value)
              TopicScopeTopicData(
                id: t.id,
                name: t.name,
              ),
          ],
        ),
      );
    }
  } else {
    // For listed exam: draw from exam.subjects
    for (final s in exam.subjects) {
      final topics = await content.topicsBySubject(s.id);
      subjects.add(
        TopicScopeSubjectData(
          id: s.id,
          name: s.name,
          topics: [
            for (final t in topics)
              TopicScopeTopicData(
                id: t.id,
                name: t.name,
              ),
          ],
        ),
      );
    }
  }

  return (exam: exam, subjects: subjects, excluded: excluded);
});

class WhatsIncludedPage extends ConsumerWidget {
  const WhatsIncludedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final styles = context.textStyles;
    final activeFocus = ref.watch(activeExamFocusProvider).valueOrNull;
    final examId = activeFocus?.exam?.id;

    if (examId == null) {
      return const PageScaffold(body: FaintBars());
    }

    final dataAsync = ref.watch(whatsIncludedDataProvider(examId));

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: "What's included", backLabel: 'Exam'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Text(
              "Unticking something hides it. Nothing you've done is deleted.",
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
          ),
          dataAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: FaintBars(),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (data) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TopicScopeIndex(
                  subjects: data.subjects,
                  topicState: (topic) {
                    final isExcluded = data.excluded.contains(topic.id);
                    return isExcluded
                        ? TopicScopeCheckState.off
                        : TopicScopeCheckState.on;
                  },
                  subjectState: (subject) {
                    final topicIds = subject.topics.map((t) => t.id).toList();
                    if (topicIds.isEmpty) return TopicScopeCheckState.on;
                    final onCount = topicIds
                        .where((id) => !data.excluded.contains(id))
                        .length;
                    if (onCount == 0) return TopicScopeCheckState.off;
                    if (onCount == topicIds.length) {
                      return TopicScopeCheckState.on;
                    }
                    return TopicScopeCheckState.partial;
                  },
                  onToggleTopic: (topic) async {
                    final newExclusions = Set<TopicId>.from(data.excluded);
                    if (newExclusions.contains(topic.id)) {
                      newExclusions.remove(topic.id);
                    } else {
                      newExclusions.add(topic.id);
                    }
                    final publish = await ref
                        .read(studySettingsCaptureProvider)(examId: examId);
                    await publish.apply(
                      () => ref
                          .read(customTrackRepositoryProvider)
                          .setExcluded(examId: examId, topicIds: newExclusions),
                    );
                    ref
                      ..invalidate(trackScopeProvider(examId))
                      ..invalidate(scopedTopicsProvider(examId))
                      ..invalidate(scopedSubjectsProvider(examId))
                      ..invalidate(whatsIncludedDataProvider(examId));
                  },
                  onToggleSubject: (subject) async {
                    final topicIds = subject.topics.map((t) => t.id).toList();
                    final onCount = topicIds
                        .where((id) => !data.excluded.contains(id))
                        .length;
                    final newExclusions = Set<TopicId>.from(data.excluded);

                    if (onCount > 0) {
                      // Turn off all topics in subject
                      newExclusions.addAll(topicIds);
                    } else {
                      // Turn on all topics in subject
                      newExclusions.removeAll(topicIds);
                    }

                    final publish = await ref
                        .read(studySettingsCaptureProvider)(examId: examId);
                    await publish.apply(
                      () => ref
                          .read(customTrackRepositoryProvider)
                          .setExcluded(examId: examId, topicIds: newExclusions),
                    );
                    ref
                      ..invalidate(trackScopeProvider(examId))
                      ..invalidate(scopedTopicsProvider(examId))
                      ..invalidate(scopedSubjectsProvider(examId))
                      ..invalidate(whatsIncludedDataProvider(examId));
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
