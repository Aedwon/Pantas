import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

class PracticePickerScreen extends ConsumerStatefulWidget {
  const PracticePickerScreen({required this.examId, super.key});
  final String examId;

  @override
  ConsumerState<PracticePickerScreen> createState() =>
      _PracticePickerScreenState();
}

class _PracticePickerScreenState extends ConsumerState<PracticePickerScreen> {
  PracticeSelection _selection = const PracticeSelection.empty();
  PracticeUnitMode _mode = PracticeUnitMode.questions;
  int _value = 10;
  Map<String, int> _adjustments = {};
  bool _lengthOpen = false;
  final Set<String> _webOpenTopics = {};
  bool _adjusting = false;
  bool _starting = false;
  String? _initializedExam;
  String? _failure;
  bool _launchFailed = false;
  Future<void> _writes = Future<void>.value();
  int _writeVersion = 0;
  PracticeSummary? _barHold;
  Timer? _barDelay;
  int? _conversionTarget;
  Map<String, int>? _conversionPools;
  int? _conversionPace;

  @override
  void dispose() {
    _barDelay?.cancel();
    super.dispose();
  }

  void _stopBarHold() {
    _barDelay?.cancel();
    _barDelay = null;
    _barHold = null;
  }

  List<int> get _values => _mode == PracticeUnitMode.questions
      ? [for (var n = 3; n <= 50; n++) n]
      : [for (var n = 5; n <= 60; n += 5) n];

  Set<int> _invalid(int count, int? pace) => _mode == PracticeUnitMode.questions
      ? {}
      : {
          for (final (i, n) in _values.indexed)
            if ((n * 60000) ~/ BuildPracticeSummary.effectiveResponseMs(pace) <
                count)
              i,
        };

  int _snap(int desired, int count, int? pace) {
    final invalid = _invalid(count, pace);
    final valid = [
      for (final (i, n) in _values.indexed)
        if (!invalid.contains(i)) n,
    ];
    if (valid.isEmpty) valid.addAll(_values);
    valid.sort((a, b) {
      final distance = (a - desired).abs().compareTo((b - desired).abs());
      return distance == 0 ? a.compareTo(b) : distance;
    });
    return valid.first;
  }

  void _save() {
    final repository = ref.read(practicePreferencesRepositoryProvider);
    final examId = widget.examId;
    final ids = _selection.selectedLessonIds;
    final mode = _mode;
    final value = _value;
    final adjustments = Map<String, int>.of(_adjustments);
    final version = ++_writeVersion;
    _writes = _writes.then((_) async {
      try {
        await repository.save(
          examId,
          lessonIds: ids,
          mode: mode,
          value: value,
          adjustments: adjustments,
        );
        if (mounted &&
            version == _writeVersion &&
            _failure != null &&
            !_launchFailed) {
          setState(() => _failure = null);
        }
      } catch (_) {
        if (mounted && version == _writeVersion) {
          setState(
            () {
              _launchFailed = false;
              _failure = 'Could not save your progress.';
            },
          );
        }
      }
    });
  }

  void _change(VoidCallback update, {bool modeOnly = false}) {
    setState(() {
      _stopBarHold();
      if (!modeOnly) _conversionTarget = null;
      update();
    });
    _save();
  }

  Future<void> _back() async {
    await _writes;
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz');
    }
  }

  Future<void> _start(PracticeIndex index, PracticeSummary summary) async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _failure = null;
      _launchFailed = false;
    });
    final units = _selection.units(index);
    final examId = widget.examId;
    try {
      final controller = ref.read(quizControllerProvider.notifier);
      final ownerGuard = await controller.captureLaunchGuard(examId: examId);
      bool pageCurrent() => mounted && widget.examId == examId;
      Future<bool> guard() async {
        if (!pageCurrent()) return false;
        final current = await ownerGuard();
        return pageCurrent() && current;
      }

      await _writes;
      if (!mounted || widget.examId != examId) return;
      if (!await guard()) throw StateError('Quiz account changed');
      await controller.startPractice(
        examId: examId,
        units: units,
        perUnit: summary.perUnit,
        countsByUnit: summary.countsByUnit,
        canPersist: guard,
      );
      if (!mounted || widget.examId != examId) return;
      if (!await guard()) throw StateError('Quiz account changed');
      if (!mounted) return;
      final state = ref.read(quizControllerProvider);
      if (state is! QuizRunning || state.session.examId != examId) {
        throw StateError('Custom quiz did not start');
      }
      await context.push(
        '/quiz/practice/$examId/run',
        extra: (customSessionId: state.session.sessionId),
      );
      if (!mounted) return;
      ref
        ..invalidate(practiceIndexProvider(examId))
        ..invalidate(practicePaceProvider(examId));
    } on Object {
      if (mounted) {
        setState(() {
          _launchFailed = true;
          _failure = 'Could not start your quiz.';
        });
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncIndex = ref.watch(practiceIndexProvider(widget.examId));
    final asyncPace = ref.watch(practicePaceProvider(widget.examId));
    final asyncPicks = ref.watch(savedPracticePicksProvider(widget.examId));
    final index = asyncIndex.valueOrNull;
    if (asyncIndex.hasError || asyncPace.hasError || asyncPicks.hasError) {
      return PantasPage(
        title: 'Customize your own',
        backLabel: 'Quiz',
        onBack: () => unawaited(_back()),
        children: [
          errorFor(
            'picks',
            () {
              ref
                ..invalidate(practiceIndexProvider(widget.examId))
                ..invalidate(practicePaceProvider(widget.examId))
                ..invalidate(savedPracticePicksProvider(widget.examId));
            },
          ),
        ],
      );
    }
    final saved = asyncPicks.valueOrNull;
    if (index == null ||
        saved == null ||
        (asyncPace.isLoading && !asyncPace.hasValue)) {
      return PantasPage(
        title: 'Customize your own',
        backLabel: 'Quiz',
        onBack: () => unawaited(_back()),
        children: const [
          SkeletonGroups(groups: 3, rows: 4, rowHeight: 47),
        ],
      );
    }
    final pace = asyncPace.valueOrNull;
    if (_initializedExam != widget.examId) {
      _stopBarHold();
      _conversionTarget = null;
      _initializedExam = widget.examId;
      _selection = PracticeSelection.fromLessonIds(index, saved.lessonIds);
      _mode = saved.mode;
      _value = _snap(saved.value, _selection.units(index).length, pace);
      _adjustments = Map<String, int>.of(saved.adjustments);
    } else {
      _selection =
          PracticeSelection.fromLessonIds(index, _selection.selectedLessonIds);
      _value = _snap(_value, _selection.units(index).length, pace);
    }
    final units = _selection.units(index);
    final summary = BuildPracticeSummary.call(
      units: units,
      index: index,
      wheelValue: _value,
      mode: _mode,
      averageResponseMs: pace,
      adjustments: _adjustments,
    );
    final effectivePace = BuildPracticeSummary.effectiveResponseMs(pace);
    if (!mapEquals(_conversionPools, summary.availableByUnit) ||
        _conversionPace != effectivePace) {
      _conversionTarget = null;
    }
    _conversionPools = summary.availableByUnit;
    _conversionPace = effectivePace;
    if (units.isEmpty || MediaQuery.disableAnimationsOf(context)) {
      _stopBarHold();
    }
    final barSummary = _barHold ?? summary;
    final questions = '${barSummary.totalQuestions} '
        'question${barSummary.totalQuestions == 1 ? '' : 's'}';
    final time = _time(barSummary.estimatedMinutes ?? 0);
    final caption = _mode == PracticeUnitMode.questions
        ? '$questions · ${_underMinute(barSummary) ? 'under 1 min' : '~$time'}'
        : '~$questions · $time';
    final pickedLabel = '${barSummary.unitCount} '
        'lesson${barSummary.unitCount == 1 ? '' : 's'} picked';
    final subjects = [
      for (final subject in index.subjects)
        ScopeSubject(
          title: subject.name,
          topics: [
            for (final topic in subject.topics)
              ScopeTopic(
                id: topic.id,
                title: topic.name,
                hasQuestions:
                    topic.lessons.any((lesson) => lesson.questionCount > 0),
                lessons: [
                  for (final lesson in topic.lessons)
                    ScopeLesson(
                      id: lesson.id,
                      title: lesson.title,
                      unread: !lesson.isRead,
                      hasQuestions: lesson.questionCount > 0,
                    ),
                ],
              ),
          ],
        ),
    ];
    if (context.wideWeb) return _web(index, summary, pace, pickedLabel);
    final page = Stack(
      children: [
        PantasPage(
          title: 'Customize your own',
          titleStyle: context.type.pageTitleCompact.copyWith(height: 1.15),
          fixedTitle: true,
          backLabel: 'Quiz',
          backIconSize: 24,
          backIconGap: 2,
          headerPadding: const EdgeInsets.only(top: 6),
          backPadding: const EdgeInsets.only(left: 4, right: 12),
          titlePadding: const EdgeInsets.fromLTRB(4, 4, 4, 18),
          onBack: () => unawaited(_back()),
          bottomInset: 260,
          headerTrailing: barSummary.isEmpty ? null : _clearButton(),
          children: [
            ScopePicker(
              subjects: subjects,
              selectedIds: _selection.selectedLessonIds,
              atLeastOne: false,
              checkIconSize: 13,
              onChanged: (ids) => _change(() {
                _selection = PracticeSelection.fromLessonIds(index, ids);
                _adjustments = {};
                _value = _snap(_value, _selection.units(index).length, pace);
                if (!_selection.isEmpty &&
                    !MediaQuery.disableAnimationsOf(context)) {
                  _barHold = barSummary;
                  _barDelay = Timer(const Duration(milliseconds: 200), () {
                    if (mounted) setState(_stopBarHold);
                  });
                }
              }),
            ),
            if (_failure != null)
              _launchFailed
                  ? StateView(
                      message: _failure!,
                      onRetry: () => unawaited(_start(index, summary)),
                    )
                  : saveFailureLine(_save),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 26 + MediaQuery.paddingOf(context).bottom,
          child: _bar(index, summary, barSummary, caption, pickedLabel),
        ),
      ],
    );
    return Material(
      type: MaterialType.transparency,
      child: PantasSheet(
        page: page,
        label: 'How long?',
        open: _lengthOpen,
        onDismiss: () => setState(() => _lengthOpen = false),
        child: _length(index, summary, pace),
      ),
    );
  }

  Widget _web(
    PracticeIndex index,
    PracticeSummary summary,
    int? pace,
    String pickedLabel,
  ) {
    final t = context.webTokens;
    void selection(PracticeSelection next) => _change(() {
          _selection = next;
          _adjustments = {};
          _value = _snap(_value, next.units(index).length, pace);
        });
    final tree = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final subject in index.subjects) ...[
          WebText(subject.name, kind: WebTextKind.eyebrow),
          WebCard(
            child: Column(
              children: [
                for (final topic in subject.topics) ...[
                  WebRow(
                    title: topic.name,
                    dimmed: !topic.hasQuestions,
                    subtitle: topic.hasQuestions ? null : 'No questions yet',
                    leading: Checkbox(
                      tristate: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      value: switch (_selection.topicState(topic)) {
                        PracticeCheckState.off => false,
                        PracticeCheckState.on => true,
                        PracticeCheckState.partial => null,
                      },
                      onChanged: topic.hasQuestions
                          ? (_) => selection(_selection.toggleTopic(topic))
                          : null,
                    ),
                    trailing: topic.canUnfold
                        ? IconButton(
                            tooltip: 'Lessons in ${topic.name}',
                            onPressed: () => setState(() {
                              if (!_webOpenTopics.remove(topic.id)) {
                                _webOpenTopics.add(topic.id);
                              }
                            }),
                            icon: Icon(
                              _webOpenTopics.contains(topic.id)
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                            ),
                          )
                        : null,
                    onPressed: () => selection(_selection.toggleTopic(topic)),
                  ),
                  if (_webOpenTopics.contains(topic.id))
                    for (final lesson in topic.lessons)
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: WebRow(
                          title: lesson.title,
                          compact: true,
                          titleStyle: t.style(16),
                          dimmed: lesson.questionCount == 0,
                          leading: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            value: _selection.lessonSelected(lesson.id),
                            onChanged: lesson.questionCount == 0
                                ? null
                                : (_) => selection(
                                      _selection.toggleLesson(topic, lesson),
                                    ),
                          ),
                          trailing: !lesson.isRead
                              ? Text('Unread', style: t.sm)
                              : null,
                          onPressed: () =>
                              selection(_selection.toggleLesson(topic, lesson)),
                        ),
                      ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
    final rows = <({String title, String? meta, Set<String> keys})>[];
    for (final topic in index.allTopics) {
      final selected =
          topic.lessons.where((l) => _selection.lessonSelected(l.id)).toList();
      if (selected.length > 1 &&
          _selection.topicState(topic) == PracticeCheckState.on) {
        rows.add(
          (
            title: topic.name,
            meta: '${selected.length} lessons',
            keys: {for (final l in selected) 'lesson:${l.id}'}
          ),
        );
      } else {
        for (final lesson in selected) {
          rows.add(
            (
              title: lesson.title,
              meta: summary.availableByUnit['lesson:${lesson.id}'] ==
                          summary.countsByUnit['lesson:${lesson.id}'] &&
                      lesson.questionCount < _value &&
                      _mode == PracticeUnitMode.questions
                  ? 'Only ${lesson.questionCount} questions so far'
                  : null,
              keys: {'lesson:${lesson.id}'}
            ),
          );
        }
      }
    }
    final canStart = !summary.isEmpty &&
        summary.totalQuestions >= summary.unitCount &&
        !_starting;
    void start() {
      if (canStart) unawaited(_start(index, summary));
    }

    final timeLabel = _underMinute(summary)
        ? 'under 1 min'
        : _time(summary.estimatedMinutes ?? 0);
    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
          child: Row(
            children: [
              Expanded(child: Text('Your quiz', style: t.eb)),
              if (!summary.isEmpty)
                TextButton(
                  onPressed: () => selection(const PracticeSelection.empty()),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style: t.style(
                      14,
                      weight: FontWeight.w600,
                      color: t.colors.secondaryLabel,
                    ),
                  ),
                ),
            ],
          ),
        ),
        WebCard(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (summary.isEmpty) ...[
                Text(
                  'Nothing picked yet',
                  style: t.style(17, weight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text('Pick a topic or a lesson', style: t.sub),
              ] else ...[
                Text(
                  pickedLabel,
                  style: t.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${_mode == PracticeUnitMode.minutes ? '~' : ''}'
                      '${summary.totalQuestions}',
                      style: t.big,
                    ),
                    const SizedBox(width: 6),
                    Text('questions', style: t.sub),
                    const Spacer(),
                    Text(
                      '${_mode == PracticeUnitMode.questions ? '~' : ''}'
                      '$timeLabel',
                      style: t.sub,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: .5, thickness: .5, color: t.colors.separator),
                const SizedBox(height: 16),
                Text(
                  'How long?',
                  style: t.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                WebSegmentedControl(
                  labels: const ['Questions per lesson', 'Total time'],
                  selected: _mode.index,
                  onChanged: (i) {
                    if (i == _mode.index) return;
                    _change(
                      () {
                        _conversionTarget ??= summary.totalQuestions;
                        _mode = PracticeUnitMode.values[i];
                        _value = BuildPracticeSummary.closestValue(
                              units: _selection.units(index),
                              index: index,
                              totalQuestions: _conversionTarget!,
                              values: _values,
                              mode: _mode,
                              averageResponseMs: pace,
                            ) ??
                            _snap(_value, summary.unitCount, pace);
                        _adjustments = {};
                      },
                      modeOnly: true,
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  _mode == PracticeUnitMode.questions
                      ? 'You set the questions. Time follows.'
                      : 'You set the time. Questions follow.',
                  style: t.sm,
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.colors.background,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        for (final value in (<int>{
                          ...(_mode == PracticeUnitMode.questions
                              ? const [3, 4, 5, 6, 8, 10, 15, 20, 30, 50]
                              : const [5, 10, 15, 20, 30, 45, 60]),
                          // Keep saved phone values visible.
                          _value,
                        }.toList()
                          ..sort()))
                          Expanded(
                            child: SizedBox(
                              height: 34,
                              child: TextButton(
                                onPressed: _invalid(summary.unitCount, pace)
                                        .contains(_values.indexOf(value))
                                    ? null
                                    : () => _change(() {
                                          _value = value;
                                          _adjustments = {};
                                        }),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: _value == value
                                      ? t.colors.accentFill
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                child: Text(
                                  '$value',
                                  style: t
                                      .style(
                                        15,
                                        weight: FontWeight.w600,
                                        color: _value == value
                                            ? Colors.white
                                            : t.colors.secondaryLabel,
                                      )
                                      .copyWith(
                                        decoration: _invalid(
                                          summary.unitCount,
                                          pace,
                                        ).contains(
                                          _values.indexOf(value),
                                        )
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Split by lesson',
                        style: t.style(15, weight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_adjusting) {
                          _change(() {
                            _adjustments = {};
                            _adjusting = false;
                          });
                        } else {
                          setState(() => _adjusting = true);
                        }
                      },
                      child: Text(_adjusting ? 'Reset' : 'Adjust'),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final row in rows)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(row.title, style: t.style(15)),
                                      if (row.meta != null)
                                        Text(row.meta!, style: t.sm),
                                    ],
                                  ),
                                ),
                                if (_adjusting)
                                  _step(summary, row.keys, -1, row.title),
                                Text(
                                  '${_count(summary, row.keys)}',
                                  style: t.sub,
                                ),
                                if (_adjusting)
                                  _step(summary, row.keys, 1, row.title),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_failure != null) ...[
                const SizedBox(height: 14),
                if (_launchFailed)
                  StateView(message: _failure!, onRetry: start)
                else
                  saveFailureLine(_save),
              ],
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerRight,
                child: WebButton(
                  label: 'Start',
                  large: true,
                  keyHint: 'Enter',
                  onPressed: canStart ? start : null,
                  busy: _starting,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): start,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            unawaited(_back()),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => unawaited(_back()),
                        icon: Icon(PantasIcons.back, size: 20),
                        label: const Text('Quiz'),
                      ),
                    ),
                    const WebText('Customize your own', kind: WebTextKind.h1),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
              if (constraints.maxWidth < 850)
                SliverToBoxAdapter(child: Column(children: [tree, panel]))
              else
                SliverCrossAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(child: tree),
                    const SliverConstrainedCrossAxis(
                      maxExtent: 28,
                      sliver: SliverToBoxAdapter(child: SizedBox()),
                    ),
                    SliverConstrainedCrossAxis(
                      maxExtent: 400,
                      sliver: PinnedHeaderSliver(child: panel),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clearButton() {
    final button = TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.only(left: 12, right: 16),
      ),
      onPressed: () => _change(() {
        _selection = const PracticeSelection.empty();
        _adjustments = {};
      }),
      child: Text(
        'Clear',
        style: context.type.body.copyWith(color: context.colors.accent),
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      return Opacity(
        key: const ValueKey('practice-clear-opacity'),
        opacity: 1,
        child: button,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      child: button,
      builder: (context, value, child) => IgnorePointer(
        ignoring: value == 0,
        child: ExcludeFocus(
          excluding: value == 0,
          child: ExcludeSemantics(
            excluding: value == 0,
            child: Opacity(
              key: const ValueKey('practice-clear-opacity'),
              opacity: value,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bar(
    PracticeIndex index,
    PracticeSummary summary,
    PracticeSummary barSummary,
    String caption,
    String pickedLabel,
  ) {
    final size = InkWell(
      key: const ValueKey('practice-size'),
      onTap:
          barSummary.isEmpty ? null : () => setState(() => _lengthOpen = true),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              barSummary.isEmpty ? 'Nothing picked yet' : pickedLabel,
              style: context.type.subheadStrong.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            if (barSummary.isEmpty)
              Text(
                'Pick a topic or a lesson',
                style: context.type.footnote.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      caption,
                      style: context.type.footnote.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.colors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      PantasIcons.next,
                      size: 13,
                      color: context.colors.accent,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    final start = PantasButton(
      label: 'Start',
      disabledOpacity: .35,
      height: 44,
      radius: 99,
      fullWidth: false,
      horizontalPadding: 26,
      busy: _starting,
      onPressed: barSummary.isEmpty ||
              summary.totalQuestions < summary.unitCount ||
              _starting
          ? null
          : () => unawaited(_start(index, summary)),
    );
    final large = MediaQuery.textScalerOf(context).scale(15) > 20;
    return FloatingBar.content(
      radius: 99,
      inset: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
        child: large
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  size,
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: start),
                ],
              )
            : Row(
                children: [
                  Expanded(child: size),
                  const SizedBox(width: 8),
                  start,
                ],
              ),
      ),
    );
  }

  bool _underMinute(PracticeSummary summary) =>
      _mode == PracticeUnitMode.questions &&
      summary.totalQuestions > 0 &&
      summary.estimatedMinutes == 0;

  String _time(int minutes) {
    if (minutes < 60) return '$minutes min';
    final precision = minutes % 60 == 0 ? 0 : 1;
    final hours = (minutes / 6).round() / 10;
    return '${hours.toStringAsFixed(precision)} hr';
  }

  Widget _length(PracticeIndex index, PracticeSummary summary, int? pace) {
    final rows = <({String title, String? meta, Set<String> keys})>[];
    for (final topic in index.allTopics) {
      final selected =
          topic.lessons.where((l) => _selection.lessonSelected(l.id)).toList();
      if (selected.isEmpty) continue;
      if (selected.length > 1 &&
          _selection.topicState(topic) == PracticeCheckState.on) {
        rows.add(
          (
            title: topic.name,
            meta: '${selected.length} lessons',
            keys: {for (final lesson in selected) 'lesson:${lesson.id}'}
          ),
        );
      } else {
        for (final lesson in selected) {
          rows.add(
            (title: lesson.title, meta: null, keys: {'lesson:${lesson.id}'}),
          );
        }
      }
    }
    final minutes = summary.estimatedMinutes ?? 0;
    final scale = MediaQuery.textScalerOf(context).scale(15) / 15;
    Widget figure(String number, String label, {required bool derived}) =>
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (derived)
                    Text(
                      '~',
                      style: context.type.body.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.264,
                        color: context.colors.secondaryLabel,
                      ),
                    ),
                  if (derived) const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      number,
                      style: context.type.largeTitle.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.68,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style:
                    context.type.footnote.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: context.colors.controlOutline,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'How long?',
                  style: context.type.body.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.24,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _lengthOpen = false),
                child: Text(
                  'Done',
                  style: context.type.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedSwitch(
            unselectedFontWeight: FontWeight.w600,
            labels: const ['Questions per lesson', 'Total time'],
            selected: _mode.index,
            onChanged: (i) {
              if (i == _mode.index) return;
              _change(
                () {
                  // Repeated mode toggles must not compound quantization.
                  _conversionTarget ??= summary.totalQuestions;
                  _mode = PracticeUnitMode.values[i];
                  _value = BuildPracticeSummary.closestValue(
                        units: _selection.units(index),
                        index: index,
                        totalQuestions: _conversionTarget!,
                        values: _values,
                        mode: _mode,
                        averageResponseMs: pace,
                      ) ??
                      _snap(_value, summary.unitCount, pace);
                  _adjustments = {};
                },
                modeOnly: true,
              );
            },
          ),
          const SizedBox(height: 14),
          ValueWheel.horizontal(
            key: ValueKey(_mode),
            values: [for (final n in _values) '$n'],
            selectedIndex: _values.indexOf(_value),
            invalidIndices: _invalid(summary.unitCount, pace),
            label: _mode == PracticeUnitMode.questions
                ? 'Questions per lesson'
                : 'Total minutes',
            onSelected: (i) => _change(() {
              _value = _values[i];
              _adjustments = {};
            }),
          ),
          const SizedBox(height: 14),
          Text(
            _mode == PracticeUnitMode.questions
                ? 'You set the questions. Time follows.'
                : 'You set the time. Questions follow.',
            textAlign: TextAlign.center,
            style: context.type.footnote,
          ),
          const SizedBox(height: 14),
          Divider(height: .5, thickness: .5, color: context.colors.separator),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                figure(
                  '${summary.totalQuestions}',
                  'questions',
                  derived: _mode == PracticeUnitMode.minutes,
                ),
                Container(
                  key: const ValueKey('practice-summary-divider'),
                  width: .5,
                  color: context.colors.separator,
                ),
                figure(
                  _underMinute(summary)
                      ? '<1'
                      : minutes >= 60
                          ? _time(minutes).split(' ').first
                          : '$minutes',
                  _underMinute(summary)
                      ? 'minute'
                      : minutes >= 60
                          ? 'hours'
                          : 'minutes',
                  derived: _mode == PracticeUnitMode.questions,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (_adjusting) {
                    _change(() {
                      _adjustments = {};
                      _adjusting = false;
                    });
                  } else {
                    setState(() => _adjusting = true);
                  }
                },
                child: Text(
                  _adjusting ? 'Reset' : 'Adjust',
                  style: context.type.subhead.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.accent,
                  ),
                ),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 156 * scale),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                key: const ValueKey('practice-pick-list'),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    for (final (i, row) in rows.indexed) ...[
                      if (i > 0)
                        Divider(
                          height: .5,
                          thickness: .5,
                          color: context.colors.separator,
                        ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: _adjusting ? 6 : 9),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      row.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.type.body.copyWith(
                                        fontSize: 15,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  if (row.meta != null) ...[
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        row.meta!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.type.footnote,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_adjusting)
                              _step(summary, row.keys, -1, row.title),
                            Text(
                              '${_count(summary, row.keys)}',
                              key: ValueKey('practice-count-${row.title}'),
                              style: context.type.body.copyWith(
                                fontSize: 15,
                                fontWeight: _adjusting
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                letterSpacing: 0,
                                color: _adjusting
                                    ? context.colors.label
                                    : context.colors.secondaryLabel,
                              ),
                            ),
                            if (_adjusting)
                              _step(summary, row.keys, 1, row.title),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _count(PracticeSummary summary, Set<String> keys) =>
      keys.fold<int>(0, (sum, key) => sum + (summary.countsByUnit[key] ?? 0));

  Widget _step(
    PracticeSummary summary,
    Set<String> keys,
    int delta,
    String title,
  ) {
    final next = BuildPracticeSummary.adjust(
      summary,
      keys,
      delta,
      preserveTotal: _mode == PracticeUnitMode.minutes,
    );
    return SizedBox.square(
      dimension: 44,
      child: IconButton(
        tooltip: '${delta > 0 ? 'Increase' : 'Decrease'} $title',
        onPressed:
            next == null ? null : () => _change(() => _adjustments = next),
        padding: const EdgeInsets.all(7),
        icon: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.surface,
          ),
          child: Icon(
            delta > 0 ? Icons.add : Icons.remove,
            size: 16,
            color: next == null
                ? context.colors.tertiaryLabel
                : context.colors.accent,
          ),
        ),
      ),
    );
  }
}
