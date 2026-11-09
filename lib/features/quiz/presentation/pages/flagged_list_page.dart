import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pantas_tooltip.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
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

  /// "Practice these 1" reads wrong for a single question.
  static String _practiceLabel(int count) =>
      count == 1 ? 'Practice this question' : 'Practice these $count';

  Future<void> _start() async {
    if (_starting) return;
    final generation = _generation;
    final examId = widget.examId;
    setState(() {
      _starting = true;
      _startFailed = false;
    });
    try {
      final controller = ref.read(quizControllerProvider.notifier);
      final ownerGuard = await controller.captureLaunchGuard(examId: examId);
      bool pageCurrent() =>
          mounted && widget.examId == examId && generation == _generation;
      Future<bool> guard() async {
        if (!pageCurrent()) return false;
        final current = await ownerGuard();
        return pageCurrent() && current;
      }

      final storedFlags =
          await ref.read(questionFlagsRepositoryProvider).flaggedIds();
      final entries = await ref.read(flaggedExamReviewProvider(examId).future);
      if (!mounted || generation != _generation || entries.isEmpty) return;
      final ids = entries.map((entry) => entry.question.id).toList();
      if (!await guard() || ids.any((id) => !storedFlags.contains(id))) {
        throw StateError('Flagged quiz context changed');
      }
      await controller.startPracticeFromQuestionIds(
        examId: examId,
        questionIds: ids,
        origin: SessionOrigin.flagged,
        canPersist: guard,
      );
      if (!mounted || generation != _generation || !await guard()) return;
      if (!mounted) return;
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

  /// The wide row's shape: a round number, the title, the flag, then the
  /// chevron.
  Widget _row(ReviewEntry entry) => ListRow(
        title: entry.labelIsStem
            ? ContentRenderer.plainText(entry.label)
            : entry.label,
        titleWidget: entry.labelIsStem
            ? PantasTooltip(
                message: ContentRenderer.plainText(entry.label),
                child: DefaultTextStyle(
                  style: PantasType.phoneBody
                      .copyWith(color: context.colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  child: MathText(
                    ContentRenderer.plainText(entry.label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            : null,
        leading: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.accentTint,
          ),
          child: Text(
            '${entry.number}',
            style: PantasType.phoneFootnoteStrong.copyWith(
              color: context.colors.accentTintText,
            ),
          ),
        ),
        trailingWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PantasIconButton(
              tooltip: 'Remove flag from question ${entry.number}',
              onPressed: _removing.contains(entry.question.id)
                  ? null
                  : () => unawaited(_remove(entry.question.id)),
              glyph: PantasIcons.flag,
              accent: true,
            ),
            Icon(PantasIcons.next, size: 16, color: context.colors.iconChevron),
          ],
        ),
        onTap: () => unawaited(_open(entry)),
      );

  /// Wide web: the same list as the phone, in the centered column the wide
  /// session lists use (board QS_All), with the actions the phone puts in its
  /// bottom bar beside the title.
  Widget _wide(AsyncValue<List<ReviewEntry>> value) {
    final t = context.webTokens;
    final entries = value.asData?.value ?? const <ReviewEntry>[];
    Widget row(ReviewEntry entry, {required bool last}) => WebRow(
          boardMetrics: true,
          chevron: WebRowChevron.always,
          mathTitle: entry.labelIsStem,
          title: entry.label,
          leading: Container(
            width: PantasSize.avatar,
            height: PantasSize.avatar,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.colors.accentTint,
            ),
            child: Text(
              '${entry.number}',
              style: PantasType.webFieldLabel.copyWith(color: t.colors.accent),
            ),
          ),
          trailing: PantasIconButton(
            tooltip: 'Remove flag from question ${entry.number}',
            onPressed: _removing.contains(entry.question.id)
                ? null
                : () => unawaited(_remove(entry.question.id)),
            glyph: PantasIcons.flag,
            accent: true,
          ),
          divider: !last,
          onPressed: () => unawaited(_open(entry)),
        );
    return Scaffold(
      backgroundColor: t.colors.bgPage,
      body: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): _back},
        child: Focus(
          autofocus: true,
          child: Column(
            children: [
              WebTopBar(
                leading: Row(
                  children: [
                    WebBackLink(label: 'Quiz', onPressed: _back),
                    // No gap: the link's own right padding is the room.
                    const WebKeyHint('Esc'),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s40,
                    PantasSpace.s24,
                    PantasSpace.s40,
                    PantasSpace.s56,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: PantasLayout.qcol,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const WebText(
                                      'Flagged questions',
                                      kind: WebTextKind.h1,
                                    ),
                                    if (entries.isNotEmpty) ...[
                                      const SizedBox(height: PantasSpace.s4),
                                      WebText(
                                        entries.length == 1
                                            ? '1 question'
                                            : '${entries.length} questions',
                                        kind: WebTextKind.lead,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (entries.isNotEmpty) ...[
                                const SizedBox(width: PantasSpace.s24),
                                WebButton(
                                  label: _practiceLabel(entries.length),
                                  busy: _starting,
                                  onPressed: _starting
                                      ? null
                                      : () => unawaited(_start()),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: PantasSpace.s20),
                          value.when(
                            skipLoadingOnRefresh: false,
                            skipLoadingOnReload: false,
                            loading: () => const SkeletonGroups(
                              rowHeight: 64,
                              headerWidth: 120,
                            ),
                            error: (error, _) =>
                                errorFor('questions', _refresh, error: error),
                            data: (entries) {
                              if (entries.isEmpty) {
                                return StateView(
                                  message: 'Flag anything you want to come '
                                      'back to',
                                  detail: 'Questions you flag during quizzes '
                                      'will appear here.',
                                  actionLabel: 'Go back',
                                  onRetry: _back,
                                );
                              }
                              final groups =
                                  FilterReviewEntries.groupBySubject(entries);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_failedFlag != null)
                                    saveFailureLine(
                                      () => unawaited(_remove(_failedFlag!)),
                                    ),
                                  if (_startFailed)
                                    StateView(
                                      message: 'Could not start your quiz.',
                                      onRetry: () => unawaited(_start()),
                                    ),
                                  for (final group in groups.entries) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: PantasSpace.s10,
                                      ),
                                      child: WebText(
                                        group.key.toUpperCase(),
                                        kind: WebTextKind.eyebrow,
                                      ),
                                    ),
                                    WebCard(
                                      child: Column(
                                        children: [
                                          for (final (i, entry)
                                              in group.value.indexed)
                                            row(
                                              entry,
                                              last: i == group.value.length - 1,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: PantasSpace.s28),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(flaggedExamReviewProvider(widget.examId));
    firstScreenReady(context, ref, ready: !value.isLoading);
    if (context.wideWeb) return _wide(value);
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
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s12,
                  PantasSpace.s16,
                  PantasSpace.s16,
                ),
                child: PantasButton(
                  label: _practiceLabel(entries.length),
                  busy: _starting,
                  onPressed: _starting ? null : () => unawaited(_start()),
                ),
              ),
            ),
      children: [
        value.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          loading: () => const SkeletonGroups(
            rowHeight: 64,
            headerWidth: 120,
          ),
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
                            padding:
                                const EdgeInsets.only(left: PantasSpace.s56),
                            child: Divider(
                              height: .5,
                              thickness: .5,
                              color: context.colors.divider,
                            ),
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: PantasSpace.s24),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
