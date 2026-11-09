import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/metrics/overall_accuracy.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson_meta.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/paywall/application/custom_subject_tiers.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/settings/domain/custom_tier_raise.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';

typedef WhatsIncludedScope = ({
  Exam exam,
  List<ScopeSubject> subjects,
  Set<TopicId> excluded,
  Set<LessonId> excludedLessons
});

final whatsIncludedDataProvider =
    FutureProvider.family<WhatsIncludedScope, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final excluded = await ref.watch(trackScopeProvider(examId).future);
  final exam = (await content.listExams()).firstWhere((e) => e.id == examId);
  final groups = <String, List<Topic>>{};
  if (csePartsForExam(examId).isNotEmpty) {
    final topics = await content.topicsByExam(examId);
    for (final part in csePartsForExam(examId)) {
      groups[part.name] = [
        for (final name in part.topicNames)
          ...topics.where((t) => t.name == name),
      ];
    }
  } else if (exam.isCustom) {
    for (final topic in await corpusTopics(content)) {
      final subject = await content.subjectById(topic.subjectId);
      groups.putIfAbsent(subject?.name ?? topic.subjectId, () => []).add(topic);
    }
  } else {
    // Owned subjects first, then the shared subjects its questions are
    // tagged to, so a student sees every topic the exam covers.
    for (final subject in exam.subjects) {
      groups[subject.name] = [];
    }
    for (final topic in await content.topicsByExam(examId)) {
      final subject = await content.subjectById(topic.subjectId);
      groups.putIfAbsent(subject?.name ?? topic.subjectId, () => []).add(topic);
    }
  }
  final topics = [for (final group in groups.values) ...group];
  final lessons = await content.lessonMetaByTopics(
    [for (final t in topics) t.id],
    examId: examId,
  );
  final excludedLessons = await ref.watch(lessonScopeProvider(examId).future);
  return (
    excludedLessons: excludedLessons,
    exam: exam,
    excluded: excluded,
    subjects: [
      for (final group in groups.entries)
        if (group.value.any((topic) => lessons[topic.id]!.isNotEmpty))
          ScopeSubject(
            title: group.key,
            topics: [
              for (final topic in group.value)
                if (lessons[topic.id]!.isNotEmpty)
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

/// The topics a set of ticked ids keeps. A topic with lessons is kept while
/// one of its lessons is ticked, and a topic with none while it is ticked.
Set<TopicId> _includedTopics(
  List<ScopeSubject> subjects,
  Set<String> selected,
) =>
    {
      for (final subject in subjects)
        for (final topic in subject.topics)
          if (topic.lessons.isEmpty
              ? selected.contains(topic.id)
              : topic.lessons.any((l) => selected.contains(l.id)))
            topic.id,
    };

String _tierLine(
  CustomSubjectTiers tiers,
  List<ScopeSubject> subjects,
  Set<String> selected,
) {
  final tier = tiers.tierOf(_includedTopics(subjects, selected));
  return 'Studying is free. For Pro, this is a '
      '${CustomSubjectTiers.levelLabel(tier)} exam.';
}

/// The subjects with the "-level" mark on each one above Student.
List<ScopeSubject> _markedSubjects(
  List<ScopeSubject> subjects,
  CustomSubjectTiers tiers,
) =>
    [
      for (final subject in subjects)
        ScopeSubject(
          title: subject.title,
          topics: subject.topics,
          mark: switch (tiers.tierOf([for (final t in subject.topics) t.id])) {
            PriceTier.student => null,
            final tier => CustomSubjectTiers.levelLabel(tier),
          },
        ),
    ];

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
    Set<String> selected, {
    required Set<TopicId> hidden,
  }) async {
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
            // Saving replaces the whole set, so what the student cannot see
            // stays as it was.
            ...hidden,
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

  /// A tick on a custom exam that would lift its tier above what the student's
  /// plan covers waits for an answer. Undo Change drops the tick: nothing is
  /// written, and the ticks stay as saved. See Plans opens the upgrade
  /// screen for the new tier. Returns true when the change may be saved: after
  /// a purchase or Save on Free there, never on backing out.
  Future<bool> _confirmRaise({
    required Exam exam,
    required List<ScopeSubject> subjects,
    required Set<String> current,
    required Set<String> next,
  }) async {
    final CustomSubjectTiers tiers;
    try {
      tiers = await ref.read(customSubjectTiersProvider.future);
    } on Object {
      // Not knowing the tier must not block a save. The server decides
      // coverage either way.
      return true;
    }
    final before = tiers.tierOf(_includedTopics(subjects, current));
    final after = tiers.tierOf(_includedTopics(subjects, next));
    if (after.index <= before.index) return true;
    Entitlement entitlement;
    try {
      entitlement = await ref.read(entitlementProvider.future);
    } on Object {
      entitlement = const Entitlement.free();
    }
    final plan = entitlement.tier ?? entitlement.coverage().tier;
    // Ask only when the plan covers the exam as saved and would stop covering
    // it. A plan that already misses the saved tier has nothing more to lose.
    if (!entitlement.proIsActive ||
        plan == null ||
        !tierCovers(plan, before) ||
        tierCovers(plan, after)) {
      return true;
    }
    if (!mounted) return false;
    final level = CustomSubjectTiers.levelLabel(after);
    final answer = await showDialog<bool>(
      context: context,
      barrierColor: context.colors.scrim,
      builder: (context) => CenteredDialog(
        title: '${exam.shortName} becomes a $level exam',
        message: 'Your ${CustomSubjectTiers.levelName(plan)} plan does not '
            'cover $level exams, so unlimited mocks, days ahead in your plan '
            'and Pro study figures stop on ${exam.shortName}. Wrong-choice '
            'notes stay on questions that '
            '${CustomSubjectTiers.levelLabel(plan)} exams also use.',
        primaryLabel: 'See Plans',
        secondaryLabel: 'Undo Change',
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (!(answer ?? false) || !mounted) return false;
    // The upgrade screen prices this exam at its new tier. It returns true on
    // a successful purchase or Save on Free, and nothing otherwise.
    final proceed = await context.push<bool>(
      Uri(
        path: '/settings/exam/upgrade',
        queryParameters: {'target': exam.id},
      ).toString(),
      extra: CustomTierRaise(examName: exam.name, tier: after),
    );
    return proceed ?? false;
  }

  Future<void> _change(
    String examId,
    WhatsIncludedScope scope,
    Set<String> current,
    Set<String> next, {
    required Set<TopicId> hidden,
  }) async {
    if (scope.exam.isCustom &&
        !await _confirmRaise(
          exam: scope.exam,
          subjects: scope.subjects,
          current: current,
          next: next,
        )) {
      return;
    }
    if (!mounted) return;
    await _save(examId, scope.subjects, next, hidden: hidden);
  }

  @override
  Widget build(BuildContext context) {
    final focus = ref.watch(activeExamFocusProvider);
    final tiers = ref.watch(customSubjectTiersProvider).valueOrNull;
    final examId = focus.valueOrNull?.exam?.id;
    final data =
        examId == null ? null : ref.watch(whatsIncludedDataProvider(examId));
    firstScreenReady(context, ref, ready: data != null && !data.isLoading);
    return SettingsPanePage(
      section: 'Your exam',
      title: "What's included",
      description: focus.valueOrNull?.exam?.shortName,
      compactTitle: true,
      titleLineHeight: 1.2,
      titleGap: PantasSpace.s6,
      backLabel: 'Your exam',
      onBack: () => leavePage(context, fallback: '/settings/exam'),
      children: [
        if (data == null)
          const WhatsIncludedSkeleton()
        else
          data.when(
            loading: () => const WhatsIncludedSkeleton(),
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
              // A custom exam leaves out a topic with no question. If it was
              // left out of the exam too, it must stay left out.
              final hidden = scope.exam.isCustom
                  ? scope.excluded.difference({
                      for (final subject in scope.subjects)
                        for (final topic in subject.topics) topic.id,
                    })
                  : <TopicId>{};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!context.wideWeb) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: PantasSpace.s4),
                      child: Text(
                        scope.exam.shortName,
                        style: context.type.body
                            .copyWith(color: context.colors.secondaryLabel),
                      ),
                    ),
                    const SizedBox(height: PantasSpace.s20),
                  ],
                  IgnorePointer(
                    ignoring: _saving,
                    child: ScopePicker(
                      subjects: scope.exam.isCustom && tiers != null
                          ? _markedSubjects(scope.subjects, tiers)
                          : scope.subjects,
                      settingsRows: true,
                      selectedIds: selected,
                      minimumSelectionMessage:
                          'At least one topic stays ticked.',
                      onChanged: (next) => unawaited(
                        _change(
                          examId!,
                          scope,
                          selected,
                          next,
                          hidden: hidden,
                        ),
                      ),
                    ),
                  ),
                  if (scope.exam.isCustom && tiers != null)
                    Padding(
                      padding: context.wideWeb
                          ? EdgeInsets.zero
                          : const EdgeInsets.fromLTRB(
                              PantasSpace.s16,
                              PantasSpace.s6,
                              PantasSpace.s16,
                              PantasSpace.s0,
                            ),
                      child: Text(
                        _tierLine(tiers, scope.subjects, selected),
                        style: context.type.footnote,
                      ),
                    ),
                  Padding(
                    padding: context.wideWeb
                        ? EdgeInsets.zero
                        : const EdgeInsets.fromLTRB(
                            PantasSpace.s16,
                            PantasSpace.s6,
                            PantasSpace.s16,
                            PantasSpace.s0,
                          ),
                    child: Text(
                      "Untick what you don't need. "
                      'It gets removed from your plan, '
                      "and your answers on it won't be deleted.",
                      style: context.type.footnote,
                    ),
                  ),
                  if (_failed)
                    saveFailureLine(
                      () => _save(
                        examId!,
                        scope.subjects,
                        _pending,
                        hidden: hidden,
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// The exam name, then each subject's topic group (the scope picker).
class WhatsIncludedSkeleton extends StatelessWidget {
  const WhatsIncludedSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBlock(width: 120, height: 22),
            SizedBox(height: PantasSpace.s24),
            SkeletonGroups(rows: 4, rowHeight: 47, headerWidth: 110),
          ],
        ),
      );
}
