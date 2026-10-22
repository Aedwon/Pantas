import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/review_providers.dart';

class FlaggedListPage extends ConsumerStatefulWidget {
  const FlaggedListPage({
    required this.examId,
    this.proIsActive = false,
    super.key,
  });
  final ExamId examId;
  final bool proIsActive;
  @override
  ConsumerState<FlaggedListPage> createState() => _FlaggedListPageState();
}

class _FlaggedListPageState extends ConsumerState<FlaggedListPage> {
  final Set<String> _removing = {};
  String? _failedFlag;
  bool _starting = false;
  bool _startFailed = false;
  int _generation = 0;

  @override
  void didUpdateWidget(FlaggedListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.examId != widget.examId) {
      _generation++;
      _starting = false;
      _startFailed = false;
      _failedFlag = null;
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz');
    }
  }

  void _refresh() {
    ref
      ..invalidate(flaggedIdsProvider)
      ..invalidate(flaggedExamReviewProvider(widget.examId));
  }

  Future<void> _open(ReviewEntry entry) async {
    await context.push<void>(
      '/quiz/flagged/${Uri.encodeComponent(widget.examId)}/view/'
      '${Uri.encodeComponent(entry.question.id)}',
    );
    if (mounted) _refresh();
  }

  Future<void> _remove(String id) async {
    if (_removing.contains(id)) return;
    setState(() {
      _removing.add(id);
      _failedFlag = null;
    });
    try {
      await ref.read(questionFlagControllerProvider.notifier).setFlagged(
            id,
            flagged: false,
          );
    } on Object {
      if (mounted) setState(() => _failedFlag = id);
    } finally {
      if (mounted) setState(() => _removing.remove(id));
    }
  }

  Future<void> _start() async {
    if (_starting) return;
    final generation = _generation;
    final examId = widget.examId;
    setState(() {
      _starting = true;
      _startFailed = false;
    });
    try {
      final entries = await ref.read(flaggedExamReviewProvider(examId).future);
      if (!mounted || generation != _generation || entries.isEmpty) return;
      final ids = entries.map((entry) => entry.question.id).toList();
      await ref
          .read(quizControllerProvider.notifier)
          .startPracticeFromQuestionIds(
            examId: examId,
            questionIds: ids,
            origin: SessionOrigin.flagged,
          );
      if (!mounted || generation != _generation) return;
      final state = ref.read(quizControllerProvider);
      if (state is! QuizRunning ||
          state.session.examId != examId ||
          state.session.origin != SessionOrigin.flagged ||
          state.session.questions.length != ids.length ||
          state.session.questions.any((q) => !ids.contains(q.id))) {
        throw StateError('Flagged quiz did not start');
      }
      await context.push<void>(
        '/quiz/practice/${Uri.encodeComponent(examId)}/run',
      );
      if (mounted && generation == _generation) _refresh();
    } on Object {
      if (mounted && generation == _generation) {
        setState(() => _startFailed = true);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _starting = false);
      }
    }
  }

  Widget _row(ReviewEntry entry) => Row(
        children: [
          Expanded(
            child: ListRow(
              title: entry.label,
              titleWidget: entry.labelIsStem
                  ? DefaultTextStyle(
                      style: context.type.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      child: MathText(entry.label),
                    )
                  : null,
              leading: SizedBox(
                width: 30,
                child: Text(
                  '${entry.number}',
                  style: context.type.subheadStrong.copyWith(
                    color: context.colors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              onTap: () => unawaited(_open(entry)),
            ),
          ),
          IconButton(
            tooltip: 'Remove flag from question ${entry.number}',
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: _removing.contains(entry.question.id)
                ? null
                : () => unawaited(_remove(entry.question.id)),
            icon: PennantMark(
              isSet: true,
              color: context.colors.accent,
              animate: false,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(flaggedExamReviewProvider(widget.examId));
    final entries = value.asData?.value;
    return PantasPage(
      title: 'Flagged questions',
      backLabel: 'Quiz',
      onBack: _back,
      bottom: entries == null || entries.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: PantasButton(
                  label: 'Practice these ${entries.length}',
                  busy: _starting,
                  onPressed: _starting ? null : () => unawaited(_start()),
                ),
              ),
            ),
      children: [
        value.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          loading: () => loadingFor(value),
          error: (error, _) => errorFor('questions', _refresh, error: error),
          data: (entries) {
            if (entries.isEmpty) {
              return StateView(
                message: 'Flag anything you want to come back to',
                detail: 'Questions you flag during quizzes will appear here.',
                actionLabel: 'Go back',
                onRetry: _back,
              );
            }
            final groups = FilterReviewEntries.groupBySubject(entries);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_failedFlag != null)
                  saveFailureLine(() => unawaited(_remove(_failedFlag!))),
                if (_startFailed)
                  StateView(
                    message: 'Could not start your quiz.',
                    onRetry: () => unawaited(_start()),
                  ),
                for (final group in groups.entries) ...[
                  GroupedSection(
                    header: group.key,
                    children: [
                      for (var i = 0; i < group.value.length; i++) ...[
                        _row(group.value[i]),
                        if (i < group.value.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 58),
                            child: Divider(
                              height: .5,
                              thickness: .5,
                              color: context.colors.separator,
                            ),
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
