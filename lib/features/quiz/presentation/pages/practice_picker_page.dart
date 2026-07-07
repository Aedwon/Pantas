import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_checkbox.dart';
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
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
    // The session is built here, before routing, so the run screen renders a
    // session that already matches the selection rather than rebuilding one
    // from arguments and risking a different draw.
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
                    for (final subject in index.subjects) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          subject.name,
                          style: styles.headlineSmall
                              .copyWith(color: colors.inkMuted),
                        ),
                      ),
                      for (final topic in subject.topics) ...[
                        _TopicRow(
                          topic: topic,
                          state: _selection.topicState(topic),
                          isUnfolded: _unfolded.contains(topic.id),
                          onToggle: () => setState(
                            () => _selection = _selection.toggleTopic(topic),
                          ),
                          onUnfold: () => setState(() {
                            if (_unfolded.contains(topic.id)) {
                              _unfolded.remove(topic.id);
                            } else {
                              _unfolded.add(topic.id);
                            }
                          }),
                        ),
                        if (_unfolded.contains(topic.id))
                          for (final lesson in topic.lessons)
                            _LessonRow(
                              lesson: lesson,
                              state: _selection.lessonSelected(lesson.id)
                                  ? PracticeCheckState.on
                                  : PracticeCheckState.off,
                              onToggle: () => setState(
                                () => _selection =
                                    _selection.toggleLesson(topic, lesson),
                              ),
                            ),
                      ],
                    ],
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

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.state,
    required this.isUnfolded,
    required this.onToggle,
    required this.onUnfold,
  });

  final PracticeTopicEntry topic;
  final PracticeCheckState state;
  final bool isUnfolded;
  final VoidCallback onToggle;
  final VoidCallback onUnfold;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.ruleFaint,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: topic.hasQuestions ? onToggle : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    InkCheckbox(
                      state: state.asInkCheckState,
                      enabled: topic.hasQuestions,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topic.name,
                        style: topic.hasQuestions
                            ? styles.bodyMedium
                            : styles.bodyMedium
                                .copyWith(color: colors.inkMuted),
                      ),
                    ),
                    if (!topic.hasQuestions)
                      Text(
                        'no questions yet',
                        style:
                            styles.bodySmall.copyWith(color: colors.inkMuted),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (topic.canUnfold)
            InkWell(
              key: ValueKey('caret_${topic.id}'),
              onTap: onUnfold,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  isUnfolded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: colors.inkMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.state,
    required this.onToggle,
  });

  final PracticeLessonEntry lesson;
  final PracticeCheckState state;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.ruleFaint,
          ),
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              const SizedBox(width: 22),
              InkCheckbox(state: state.asInkCheckState, size: 14),
              const SizedBox(width: 12),
              Expanded(child: Text(lesson.title, style: styles.bodyMedium)),
              if (!lesson.isRead)
                Text(
                  'not read yet',
                  style: styles.bodySmall.copyWith(color: colors.rust),
                ),
            ],
          ),
        ),
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

/// The picker's tri-state, drawn with the shared checkbox.
///
/// The mapping lives here rather than in `domain/` so the domain never
/// imports a widget.
extension _CheckGlyph on PracticeCheckState {
  InkCheckState get asInkCheckState => switch (this) {
        PracticeCheckState.off => InkCheckState.off,
        PracticeCheckState.partial => InkCheckState.partial,
        PracticeCheckState.on => InkCheckState.on,
      };
}
