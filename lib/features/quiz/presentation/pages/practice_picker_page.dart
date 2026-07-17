import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/topic_scope_index.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_selection.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_summary.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/practice_picker_providers.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/length_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PracticePickerPage extends ConsumerStatefulWidget {
  const PracticePickerPage({required this.examId, super.key});

  final String examId;

  @override
  ConsumerState<PracticePickerPage> createState() => _PracticePickerPageState();
}

class _PracticePickerPageState extends ConsumerState<PracticePickerPage> {
  PracticeSelection _selection = const PracticeSelection.empty();
  final Set<TopicId> _unfolded = {};
  PracticeUnitMode _mode = PracticeUnitMode.questions;
  int _wheelValue = 10;

  void _switchMode(PracticeUnitMode mode) {
    setState(() {
      _mode = mode;
      _wheelValue = snapToNearest(_wheelValue, wheelValues(mode));
    });
  }

  Future<void> _start(PracticeIndex index) async {
    await ref.read(quizControllerProvider.notifier).startPractice(
          examId: widget.examId,
          units: _selection.units(index),
          perUnit: _wheelValue,
        );
    if (!mounted) return;
    await context.push('/quiz/practice/${widget.examId}/run');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final asyncIndex = ref.watch(practiceIndexProvider(widget.examId));
    final asyncPace = ref.watch(practicePaceProvider(widget.examId));

    final pace = asyncPace.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Quiz', style: styles.headlineMedium),
        actions: [
          if (!_selection.isEmpty)
            TextButton(
              onPressed: () =>
                  setState(() => _selection = _selection.cleared()),
              child: Text(
                'Clear',
                style: styles.bodySmall.copyWith(
                  color: colors.board,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: asyncIndex.when(
        loading: () => const PageScaffold(body: FaintBars()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (index) {
          final summary = BuildPracticeSummary.call(
            units: _selection.units(index),
            index: index,
            wheelValue: _wheelValue,
            mode: _mode,
            averageResponseMs: pace,
          );

          final scopeSubjects = [
            for (final subject in index.subjects)
              TopicScopeSubjectData(
                id: subject.id,
                name: subject.name,
                topics: [
                  for (final topic in subject.topics)
                    TopicScopeTopicData(
                      id: topic.id,
                      name: topic.name,
                      hasQuestions: topic.hasQuestions,
                      lessons: [
                        for (final lesson in topic.lessons)
                          TopicScopeLessonData(
                            id: lesson.id,
                            title: lesson.title,
                            isRead: lesson.isRead,
                          ),
                      ],
                    ),
                ],
              ),
          ];

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  children: [
                    Text('Choose what to practice', style: styles.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      "Lessons you haven't read yet are marked.",
                      style: styles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: colors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TopicScopeIndex(
                      subjects: scopeSubjects,
                      showLessons: true,
                      unfoldedTopicIds: _unfolded,
                      onToggleUnfold: (topicId) => setState(() {
                        if (_unfolded.contains(topicId)) {
                          _unfolded.remove(topicId);
                        } else {
                          _unfolded.add(topicId);
                        }
                      }),
                      topicState: (topicData) {
                        final entry = index.subjects
                            .expand((s) => s.topics)
                            .firstWhere((t) => t.id == topicData.id);
                        return switch (_selection.topicState(entry)) {
                          PracticeCheckState.off => TopicScopeCheckState.off,
                          PracticeCheckState.partial =>
                            TopicScopeCheckState.partial,
                          PracticeCheckState.on => TopicScopeCheckState.on,
                        };
                      },
                      onToggleTopic: (topicData) {
                        final entry = index.subjects
                            .expand((s) => s.topics)
                            .firstWhere((t) => t.id == topicData.id);
                        setState(
                          () => _selection = _selection.toggleTopic(entry),
                        );
                      },
                      lessonState: (lesson) =>
                          _selection.lessonSelected(lesson.id)
                              ? TopicScopeCheckState.on
                              : TopicScopeCheckState.off,
                      onToggleLesson: (topicData, lessonData) {
                        final topicEntry = index.subjects
                            .expand((s) => s.topics)
                            .firstWhere((t) => t.id == topicData.id);
                        final lessonEntry = topicEntry.lessons
                            .firstWhere((l) => l.id == lessonData.id);
                        setState(
                          () => _selection = _selection.toggleLesson(
                            topicEntry,
                            lessonEntry,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colors.rule,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SummaryView(summary: summary),
                      const SizedBox(height: 8),
                      _UnitControl(
                        mode: _mode,
                        minutesAvailable: pace != null,
                        onChanged: _switchMode,
                      ),
                      LengthWheel(
                        mode: _mode,
                        value: _wheelValue,
                        onChanged: (value) =>
                            setState(() => _wheelValue = value),
                      ),
                      const SizedBox(height: 8),
                      BoardButton(
                        label: 'Start',
                        onPressed: summary.isEmpty ? null : () => _start(index),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.summary});

  final PracticeSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    if (summary.isEmpty) {
      return Column(
        children: [
          Text(
            '—',
            style: styles.displaySmall.copyWith(
              fontSize: 21,
              color: colors.inkMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            summary.detail,
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      );
    }

    final minutes = summary.estimatedMinutes;

    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${summary.totalQuestions}',
                style: styles.displaySmall.copyWith(
                  fontSize: 21,
                  color: colors.ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              TextSpan(
                text: ' question${summary.totalQuestions == 1 ? '' : 's'}',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
              if (minutes != null) ...[
                TextSpan(
                  text: ' · ',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
                TextSpan(
                  text: 'about $minutes min',
                  style: styles.bodySmall.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          summary.detail,
          style: styles.bodySmall.copyWith(color: colors.inkMuted),
        ),
      ],
    );
  }
}

class _UnitControl extends StatelessWidget {
  const _UnitControl({
    required this.mode,
    required this.minutesAvailable,
    required this.onChanged,
  });

  final PracticeUnitMode mode;
  final bool minutesAvailable;
  final ValueChanged<PracticeUnitMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged(PracticeUnitMode.questions),
          child: Text(
            'questions',
            style: styles.bodySmall.copyWith(
              fontSize: 12,
              color: mode == PracticeUnitMode.questions
                  ? colors.ink
                  : colors.inkMuted,
              fontWeight: mode == PracticeUnitMode.questions
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ),
        if (minutesAvailable) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 9),
            width: AppDimensions.hairline,
            height: 11,
            color: colors.rule,
          ),
          GestureDetector(
            onTap: () => onChanged(PracticeUnitMode.minutes),
            child: Text(
              'minutes',
              style: styles.bodySmall.copyWith(
                fontSize: 12,
                color: mode == PracticeUnitMode.minutes
                    ? colors.ink
                    : colors.inkMuted,
                fontWeight: mode == PracticeUnitMode.minutes
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
