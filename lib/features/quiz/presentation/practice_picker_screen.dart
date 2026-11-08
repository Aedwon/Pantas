import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/view_swap.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
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
          _failure = ref.read(contentLimitReachedProvider)
              ? contentLimitMessage
              : 'Could not start your quiz.';
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
    firstScreenReady(
      context,
      ref,
      ready: asyncIndex.hasError ||
          asyncPace.hasError ||
          asyncPicks.hasError ||
          (!asyncIndex.isLoading &&
              !asyncPace.isLoading &&
              !asyncPicks.isLoading),
    );
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
          titleStyle: PantasType.phoneTitle1
              .copyWith(color: context.colors.textPrimary)
              .copyWith(height: 1.15),
          fixedTitle: true,
          backLabel: 'Quiz',
          backPadding: const EdgeInsets.only(
            left: PantasSpace.s4,
            right: PantasSpace.s12,
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            PantasSpace.s4,
            PantasSpace.s4,
            PantasSpace.s4,
            PantasSpace.s18,
          ),
          onBack: () => unawaited(_back()),
          bottomInset: 260,
          headerTrailing: barSummary.isEmpty ? null : _clearButton(),
          children: [
            ScopePicker(
              phoneBoardRows: true,
              subjects: subjects,
              selectedIds: _selection.selectedLessonIds,
              atLeastOne: false,
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
    final hairline = Padding(
      padding:
          const EdgeInsets.only(left: PantasSpace.s56, right: PantasSpace.s20),
      child: Divider(height: 1, thickness: 1, color: t.colors.divider),
    );
    final still = MediaQuery.disableAnimationsOf(context);
    Widget unfold(PracticeTopicEntry topic, Widget lessons) => still
        ? lessons
        : AnimatedSize(
            key: ValueKey('web-lessons-${topic.id}'),
            duration: const Duration(milliseconds: 600),
            curve: PantasCurves.house,
            child: lessons,
          );
    final tree = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final subject in index.subjects) ...[
          WebText(subject.name, kind: WebTextKind.eyebrow),
          WebCard(
            child: Column(
              children: [
                for (final (ti, topic) in subject.topics.indexed) ...[
                  CheckboxRow(
                    squareEdges: true,
                    title: topic.name,
                    selected:
                        _selection.topicState(topic) == PracticeCheckState.on,
                    mixed: _selection.topicState(topic) ==
                        PracticeCheckState.partial,
                    onTap: topic.hasQuestions
                        ? () => selection(_selection.toggleTopic(topic))
                        : null,
                    // Board CZ_None: a topic with a second line is 71 px, not
                    // the one-line row's padding around two lines.
                    padding: topic.hasQuestions
                        ? const EdgeInsets.fromLTRB(
                            PantasSpace.s20,
                            PantasSpace.s18,
                            PantasSpace.s8,
                            PantasSpace.s18,
                          )
                        : const EdgeInsets.fromLTRB(
                            PantasSpace.s20,
                            PantasSpace.s16,
                            PantasSpace.s8,
                            PantasSpace.s16,
                          ),
                    gap: 16,
                    minHeight: 62,
                    standardDensity: true,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.name,
                          style: PantasType.webRowTitle
                              .copyWith(color: t.colors.textPrimary),
                        ),
                        if (!topic.hasQuestions)
                          Text(
                            'No questions yet',
                            style: PantasType.webRowSub
                                .copyWith(color: t.colors.textSecondary),
                          ),
                      ],
                    ),
                    trailing: topic.canUnfold
                        ? Padding(
                            padding:
                                const EdgeInsets.only(right: PantasSpace.s20),
                            child: SizedBox.square(
                              dimension: 32,
                              child: IconButton(
                                tooltip: _webOpenTopics.contains(topic.id)
                                    ? 'Hide lessons in ${topic.name}'
                                    : 'Show lessons in ${topic.name}',
                                padding: EdgeInsets.zero,
                                onPressed: () => setState(() {
                                  if (!_webOpenTopics.remove(topic.id)) {
                                    _webOpenTopics.add(topic.id);
                                  }
                                }),
                                // One caret that turns, as on the phone.
                                icon: AnimatedRotation(
                                  key: ValueKey('web-caret-${topic.id}'),
                                  turns: _webOpenTopics.contains(topic.id)
                                      ? .5
                                      : 0,
                                  curve: PantasCurves.house,
                                  duration: still
                                      ? Duration.zero
                                      : const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 14,
                                    color: t.colors.iconChevron,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                  // The phone's unfold: 600 ms houseOut. Closed, the lessons
                  // are absent, so they leave the tab order and semantics.
                  unfold(
                    topic,
                    _webOpenTopics.contains(topic.id)
                        ? ColoredBox(
                            color: t.dark
                                ? t.colors.bgPage
                                : t.colors.surfaceInset,
                            child: Column(
                              children: [
                                for (final lesson in topic.lessons)
                                  CheckboxRow(
                                    squareEdges: true,
                                    title: lesson.title,
                                    selected:
                                        _selection.lessonSelected(lesson.id),
                                    onTap: lesson.questionCount == 0
                                        ? null
                                        : () => selection(
                                              _selection.toggleLesson(
                                                topic,
                                                lesson,
                                              ),
                                            ),
                                    padding: const EdgeInsets.fromLTRB(
                                      PantasSpace.s56,
                                      PantasSpace.s12,
                                      PantasSpace.s20,
                                      PantasSpace.s12,
                                    ),
                                    gap: 16,
                                    minHeight: 45,
                                    standardDensity: true,
                                    markSize: 20,
                                    content: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            lesson.title,
                                            style: PantasType
                                                .webRowTitleSettings
                                                .copyWith(
                                              color: t.colors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (!lesson.isRead)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: PantasSpace.s8,
                                              vertical: PantasSpace.s2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: t.disabledBackground,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                PantasRadius.full,
                                              ),
                                            ),
                                            child: Text(
                                              'Unread',
                                              style: PantasType.webTag.copyWith(
                                                color: t.colors.textSecondary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (ti + 1 < subject.topics.length) hairline,
                ],
              ],
            ),
          ),
          const SizedBox(height: PantasSpace.s24),
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
            meta: '${selected.length} '
                "${selected.length == 1 ? 'lesson' : 'lessons'}",
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
                  ? 'Only ${lesson.questionCount} '
                      "${lesson.questionCount == 1 ? 'question' : 'questions'} "
                      'so far'
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

    final minutes = summary.estimatedMinutes ?? 0;
    final timeLabel = _underMinute(summary)
        ? 'under 1 min'
        : _mode == PracticeUnitMode.minutes && minutes < 60
            ? minutes == 1
                ? '1 minute'
                : '$minutes minutes'
            : _time(minutes);
    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s4,
            PantasSpace.s0,
            PantasSpace.s4,
            PantasSpace.s8,
          ),
          child: Row(
            children: [
              Expanded(child: Text('YOUR QUIZ', style: t.eb)),
              if (!summary.isEmpty)
                _fadeIn(
                  TextButton(
                    onPressed: () => selection(const PracticeSelection.empty()),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Clear',
                      style: PantasType.webLabel
                          .copyWith(color: t.colors.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
        ),
        WebCard(
          padding: summary.isEmpty
              ? const EdgeInsets.all(PantasSpace.s24)
              : const EdgeInsets.fromLTRB(
                  PantasSpace.s20,
                  PantasSpace.s20,
                  PantasSpace.s20,
                  PantasSpace.s20,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _swap(
                empty: summary.isEmpty,
                children: summary.isEmpty
                    ? [
                        Text('Nothing picked yet', style: t.h3),
                        const SizedBox(height: PantasSpace.s14),
                        Text('Pick a topic or a lesson', style: t.sub),
                      ]
                    : [
                        Text(
                          pickedLabel,
                          style: t.sm.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: PantasSpace.s16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${_mode == PracticeUnitMode.minutes ? '~' : ''}'
                              '${summary.totalQuestions}',
                              style: t.big,
                            ),
                            const SizedBox(width: PantasSpace.s8),
                            // Expanded, not a Flexible beside a Spacer: they
                            // would share the room and leave the time short
                            // of the card's edge.
                            Expanded(
                              child: Text(
                                'questions',
                                overflow: TextOverflow.ellipsis,
                                style: PantasType.webLead
                                    .copyWith(color: t.colors.textSecondary),
                              ),
                            ),
                            Text(
                              _mode == PracticeUnitMode.questions
                                  ? '~$timeLabel'
                                  : timeLabel,
                              style: t.sub,
                            ),
                          ],
                        ),
                        const SizedBox(height: PantasSpace.s16),
                        Divider(
                          height: .5,
                          thickness: .5,
                          color: t.colors.divider,
                        ),
                        const SizedBox(height: PantasSpace.s16),
                        Text('HOW LONG?', style: t.eb),
                        const SizedBox(height: PantasSpace.s16),
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
                        const SizedBox(height: PantasSpace.s16),
                        ViewSwap(
                          index: _mode.index,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _mode == PracticeUnitMode.questions
                                    ? 'You set the questions. Time follows.'
                                    : 'You set the time. Questions follow.',
                                style: t.sm,
                              ),
                              const SizedBox(height: PantasSpace.s16),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: t.colors.bgPage,
                                  borderRadius:
                                      BorderRadius.circular(PantasRadius.back),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(PantasSpace.s2),
                                  child: Row(
                                    children: [
                                      for (final value in (<int>{
                                        ...(_mode == PracticeUnitMode.questions
                                            ? const [
                                                3,
                                                4,
                                                5,
                                                6,
                                                8,
                                                10,
                                                15,
                                                20,
                                                30,
                                                50,
                                              ]
                                            : const [
                                                5,
                                                10,
                                                15,
                                                20,
                                                30,
                                                45,
                                                60,
                                              ]),
                                        // Keep saved phone values visible.
                                        _value,
                                      }.toList()
                                        ..sort()))
                                        Expanded(
                                          child: SizedBox(
                                            height: PantasSize.btnXs,
                                            child: TextButton(
                                              onPressed: _invalid(
                                                summary.unitCount,
                                                pace,
                                              ).contains(_values.indexOf(value))
                                                  ? null
                                                  : () => _change(() {
                                                        _value = value;
                                                        _adjustments = {};
                                                      }),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                backgroundColor: _value == value
                                                    ? t.colors.accentFill
                                                    : Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    PantasRadius.sm,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                '$value',
                                                style: t
                                                    .style(
                                                      15,
                                                      weight: FontWeight.w600,
                                                      color: _value == value
                                                          ? t.colors.onAccent
                                                          : t.colors
                                                              .secondaryLabel,
                                                    )
                                                    .copyWith(
                                                      decoration: _invalid(
                                                        summary.unitCount,
                                                        pace,
                                                      ).contains(
                                                        _values.indexOf(value),
                                                      )
                                                          ? TextDecoration
                                                              .lineThrough
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
                            ],
                          ),
                        ),
                        const SizedBox(height: PantasSpace.s16),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: PantasSpace.s4),
                                child: Text(
                                  'Split by lesson',
                                  style: t.sm
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PantasSpace.s8,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: PantasType.webLabel
                                    .copyWith(color: t.colors.textPrimary),
                              ),
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
                                for (final (ri, row) in rows.indexed)
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      PantasSpace.s4,
                                      PantasSpace.s12,
                                      PantasSpace.s4,
                                      PantasSpace.s12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: ri + 1 < rows.length
                                          ? Border(
                                              bottom: BorderSide(
                                                color: t.colors.divider,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                row.title,
                                                style: PantasType
                                                    .webRowTitleSettings
                                                    .copyWith(
                                                  color: t.colors.textPrimary,
                                                ),
                                              ),
                                              if (row.meta != null)
                                                Text(
                                                  row.meta!,
                                                  style: PantasType.webRowSub
                                                      .copyWith(
                                                    color:
                                                        t.colors.textSecondary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: PantasSpace.s12),
                                        if (_adjusting) ...[
                                          _webStep(
                                            summary,
                                            row.keys,
                                            -1,
                                            row.title,
                                          ),
                                          const SizedBox(
                                            width: PantasSpace.s12,
                                          ),
                                        ],
                                        if (_adjusting)
                                          SizedBox(
                                            width: PantasSpace.s28,
                                            child: Text(
                                              '${_count(summary, row.keys)}',
                                              textAlign: TextAlign.center,
                                              style:
                                                  PantasType.webButton.copyWith(
                                                color: t.colors.textPrimary,
                                              ),
                                            ),
                                          )
                                        else
                                          Text(
                                            '${_count(summary, row.keys)}',
                                            style:
                                                PantasType.webButton.copyWith(
                                              color: t.colors.textPrimary,
                                            ),
                                          ),
                                        if (_adjusting) ...[
                                          const SizedBox(
                                            width: PantasSpace.s12,
                                          ),
                                          _webStep(
                                            summary,
                                            row.keys,
                                            1,
                                            row.title,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
              ),
              if (_failure != null) ...[
                const SizedBox(height: PantasSpace.s14),
                if (_launchFailed)
                  StateView(message: _failure!, onRetry: start)
                else
                  saveFailureLine(_save),
              ],
              SizedBox(height: summary.isEmpty ? 14 : 16),
              WebButton(
                label: 'Start',
                large: true,
                expand: true,
                keyHint: 'Enter',
                onPressed: canStart ? start : null,
                busy: _starting,
              ),
            ],
          ),
        ),
      ],
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            unawaited(_back()),
      },
      child: Focus(
        // Clicking a group's chevron leaves focus on it, and Enter must still
        // press Start, as its label says. A control reached by Tab keeps Enter.
        onKeyEvent: enterKeyHandler(
          start,
          keepsEnter: (_) => webFocusFromPointer,
        ),
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: PantasSpace.s4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => unawaited(_back()),
                          icon: Icon(PantasIcons.back, size: 20),
                          label: const Text('Quiz'),
                        ),
                      ),
                    ),
                    const SizedBox(height: PantasSpace.s10),
                    const WebText('Customize your own', kind: WebTextKind.h1),
                    const SizedBox(height: PantasSpace.s24),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: context.webPageBottomInset),
                sliver: constraints.maxWidth < 850
                    ? SliverToBoxAdapter(child: Column(children: [tree, panel]))
                    : SliverCrossAxisGroup(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fades [child] in over 200 ms as it appears, as the phone's Clear does.
  Widget _fadeIn(Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      child: child,
      builder: (context, value, child) => IgnorePointer(
        ignoring: value == 0,
        child: Opacity(opacity: value, child: child),
      ),
    );
  }

  /// The Your quiz card changes between nothing picked and a pick. Its body
  /// cross-fades and the card sizes to it over 200 ms.
  Widget _swap({required bool empty, required List<Widget> children}) {
    final body = Column(
      key: ValueKey(empty),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    if (MediaQuery.disableAnimationsOf(context)) return body;
    const duration = Duration(milliseconds: 200);
    return AnimatedSize(
      duration: duration,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        // The body that is leaving lies over the new one and takes no room,
        // so the card sizes to what is arriving.
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [
            for (final old in previous)
              Positioned(left: 0, right: 0, top: 0, child: old),
            if (current != null) current,
          ],
        ),
        child: body,
      ),
    );
  }

  Widget _clearButton() {
    final button = TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.only(
          left: PantasSpace.s12,
          right: PantasSpace.s16,
        ),
      ),
      onPressed: () => _change(() {
        _selection = const PracticeSelection.empty();
        _adjustments = {};
      }),
      child: Text(
        'Clear',
        style: PantasType.phoneBody
            .copyWith(color: context.colors.textPrimary)
            .copyWith(color: context.colors.accent),
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
              style: PantasType.phoneExplanation.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: PantasSpace.s2),
            if (barSummary.isEmpty)
              Text(
                'Pick a topic or a lesson',
                style: PantasType.phoneFootnote
                    .copyWith(color: context.colors.textSecondary)
                    .copyWith(
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
                      style: PantasType.phoneFootnote
                          .copyWith(color: context.colors.textSecondary)
                          .copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.colors.accent,
                          ),
                    ),
                  ),
                  const SizedBox(width: PantasSpace.s2),
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
      height: PantasSize.btn,
      radius: PantasRadius.full,
      fullWidth: false,
      horizontalPadding: PantasSpace.s24,
      busy: _starting,
      onPressed: barSummary.isEmpty ||
              summary.totalQuestions < summary.unitCount ||
              _starting
          ? null
          : () => unawaited(_start(index, summary)),
    );
    final large = MediaQuery.textScalerOf(context).scale(15) > 20;
    return FloatingBar.content(
      radius: PantasRadius.full,
      inset: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s20,
          PantasSpace.s8,
          PantasSpace.s8,
          PantasSpace.s8,
        ),
        child: large
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  size,
                  const SizedBox(height: PantasSpace.s8),
                  Align(alignment: Alignment.centerRight, child: start),
                ],
              )
            : Row(
                children: [
                  Expanded(child: size),
                  const SizedBox(width: PantasSpace.s8),
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

  /// Written as the Quiz tab and the mock write it: "1 hr 6 min".
  String _time(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    return minutes % 60 == 0 ? '$hours hr' : '$hours hr ${minutes % 60} min';
  }

  /// The big figure over the word "hours": one decimal, as "1.1".
  String _hours(int minutes) {
    final precision = minutes % 60 == 0 ? 0 : 1;
    return ((minutes / 6).round() / 10).toStringAsFixed(precision);
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
            meta: '${selected.length} '
                "${selected.length == 1 ? 'lesson' : 'lessons'}",
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
                      style: PantasType.phoneTitle2.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (derived) const SizedBox(width: PantasSpace.s2),
                  Flexible(
                    child: Text(
                      number,
                      style: PantasType.phoneLargeTitle.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PantasSpace.s2),
              Text(
                label,
                style: PantasType.phoneFootnote
                    .copyWith(color: context.colors.textSecondary)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s20,
        PantasSpace.s8,
        PantasSpace.s20,
        PantasSpace.s32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                // Board (QZS_1b): the handle is #D1D1D6 in light mode.
                color: Theme.of(context).brightness == Brightness.dark
                    ? context.colors.borderControl
                    : context.colors.dividerStrong,
                borderRadius: BorderRadius.circular(PantasRadius.sm),
              ),
            ),
          ),
          const SizedBox(height: PantasSpace.s12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'How long?',
                  style: PantasType.phoneTitle3.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _lengthOpen = false),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.standard,
                  minimumSize: const Size(0, 30),
                  padding:
                      const EdgeInsets.symmetric(horizontal: PantasSpace.s12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Done',
                  style: PantasType.phoneBody
                      .copyWith(color: context.colors.textPrimary)
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.accent,
                      ),
                ),
              ),
            ],
          ),
          // QZE_*: the 36 px track starts 14 px under the title.
          SizedBox(height: context.wideWeb ? 12 : 6.5),
          SegmentedSwitch(
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
          const SizedBox(height: PantasSpace.s8),
          ViewSwap(
            index: _mode.index,
            child: Column(
              children: [
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
                const SizedBox(height: PantasSpace.s4),
                Text(
                  _mode == PracticeUnitMode.questions
                      ? 'You set the questions. Time follows.'
                      : 'You set the time. Questions follow.',
                  textAlign: TextAlign.center,
                  style: PantasType.phoneFootnote
                      .copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: PantasSpace.s14),
          Divider(height: .5, thickness: .5, color: context.colors.divider),
          const SizedBox(height: PantasSpace.s14),
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
                  color: context.colors.divider,
                ),
                figure(
                  _underMinute(summary)
                      ? '<1'
                      : minutes >= 60
                          ? _hours(minutes)
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
          const SizedBox(height: PantasSpace.s6),
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
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.standard,
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _adjusting ? 'Reset' : 'Adjust',
                  style: PantasType.phoneExplanation
                      .copyWith(color: context.colors.textPrimary)
                      .copyWith(
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
                color: context.colors.bgPage,
                borderRadius: BorderRadius.circular(PantasRadius.md),
              ),
              child: SingleChildScrollView(
                key: const ValueKey('practice-pick-list'),
                padding:
                    const EdgeInsets.symmetric(horizontal: PantasSpace.s14),
                child: Column(
                  children: [
                    for (final (i, row) in rows.indexed) ...[
                      if (i > 0)
                        Divider(
                          height: .5,
                          thickness: .5,
                          color: context.colors.divider,
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical:
                              _adjusting ? PantasSpace.s6 : PantasSpace.s8,
                        ),
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
                                      style:
                                          PantasType.phoneExplanation.copyWith(
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (row.meta != null) ...[
                                    const SizedBox(width: PantasSpace.s6),
                                    Flexible(
                                      child: Text(
                                        row.meta!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            PantasType.phoneFootnote.copyWith(
                                          color: context.colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: PantasSpace.s12),
                            if (_adjusting)
                              _step(summary, row.keys, -1, row.title),
                            Text(
                              '${_count(summary, row.keys)}',
                              key: ValueKey('practice-count-${row.title}'),
                              style: PantasType.phoneExplanation.copyWith(
                                color: _adjusting
                                    ? context.colors.textPrimary
                                    : context.colors.textSecondary,
                                fontWeight: _adjusting
                                    ? FontWeight.w700
                                    : FontWeight.w400,
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
        padding: const EdgeInsets.all(PantasSpace.s6),
        icon: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.surfaceCard,
          ),
          child: Icon(
            delta > 0 ? Icons.add : Icons.remove,
            size: 16,
            color: next == null
                ? context.colors.textSecondary
                : context.colors.accent,
          ),
        ),
      ),
    );
  }

  Widget _webStep(
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
    final t = context.webTokens;
    return SizedBox.square(
      dimension: 28,
      child: IconButton(
        tooltip: '${delta > 0 ? 'Increase' : 'Decrease'} $title',
        onPressed:
            next == null ? null : () => _change(() => _adjustments = next),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        icon: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PantasRadius.sm),
            color: t.colors.bgPage,
          ),
          child: Icon(
            delta > 0 ? Icons.add : Icons.remove,
            size: 16,
            color: next == null ? t.colors.textSecondary : t.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
