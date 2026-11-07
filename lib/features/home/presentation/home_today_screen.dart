import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/paused_quiz_notice.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/performance/topic_accuracy_provider.dart';
import 'package:pantas/features/home/application/settling_retry.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/data/study_writes.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/home/presentation/practice_launcher.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_day.dart';
import 'package:pantas/features/home/presentation/widgets/home_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/domain/paused_quiz_conflict.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:uuid/uuid.dart';

/// The calm line above Today. The boards print it only above a plan that still
/// has work: a day off, an exam day, a quiet day or a finished day has no line,
/// because "Unfinished items are added to today" would contradict what it says.
String? homeDayNoteLabel(HomeTodayData data) {
  final snapshot = data.today.snapshot;
  final view = homeTodayViewFor(
    state: snapshot.state,
    plan: snapshot.plan,
    originalDone: data.today.originalDone,
    canAdvance: data.canAdvance,
    examDate: snapshot.digest.examDate,
  );
  if (view.kind != HomeTodayKind.checklist || data.today.originalDone) {
    return null;
  }
  return switch (data.extras.note) {
    HomeDayNote.carried => 'Unfinished items are added to today.',
    HomeDayNote.welcomeBack => "Items you missed are in today's reviews.",
    HomeDayNote.mockMoved =>
      'Your ${data.examShortName} simulation moved to today.',
    null => null,
  };
}

/// The longest Home waits for a lesson's content before opening it anyway.
const _lessonReadWait = Duration(milliseconds: 500);

/// Owns one Home request, including its retries and every asynchronous launch.
/// Closing the page invalidates the original captured account/exam boundary.
class HomeTodayScreen extends ConsumerStatefulWidget {
  const HomeTodayScreen({
    required this.examId,
    required this.pageBuilder,
    this.onSetDate,
    this.noteTopGap = 6,
    super.key,
  });
  final String examId;

  /// Space above the day's note on a phone. Home's boards put it 6 px under
  /// the greeting. A page whose title already sits close above it sets 0.
  final double noteTopGap;

  /// Draws the page around Today. The loaded data is null while loading or
  /// after a failure, so the page can react to it (for example the greeting).
  final Widget Function(Widget today, HomeTodayData? data) pageBuilder;

  /// Opens Home's date sheet. Owned by Home, which hosts the sheet.
  final VoidCallback? onSetDate;
  @override
  ConsumerState<HomeTodayScreen> createState() => _HomeTodayScreenState();
}

class _HomeTodayScreenState extends ConsumerState<HomeTodayScreen> {
  late Future<Future<bool> Function()> _guard;
  late Future<HomeTodayData> _request;
  String? _sheet;
  HomeTodayLesson? _lesson;
  bool _busy = false;
  bool _failed = false;

  /// The failed start was refused because another quiz is paused.
  bool _pausedBlock = false;
  bool _discarding = false;
  int _generation = 0;
  StudyAdvance? _pendingAdvance;

  /// A first read that fails only because the app is still settling is retried
  /// here, and the page keeps its skeleton meanwhile. An error shows only once
  /// the failure is real: it is not a settling failure, or the retries ran out.
  late final SettlingRetry _settling = SettlingRetry(retry: _retryQuietly);
  bool _holding = false;
  final ScreenTimer _timing = ScreenTimer('screen.home');

  /// The plan last built, kept on screen while a rebuild runs so a change to
  /// the plan never flashes the skeleton again.
  HomeTodayData? _shown;

  /// A build is running. Plan copies that arrive meanwhile are not built on;
  /// the build's end checks them once.
  bool _pending = false;
  bool _missedPlan = false;

  bool _current() =>
      mounted &&
      ref
              .read(activeExamFocusProvider)
              .unwrapPrevious()
              .asData
              ?.value
              .exam
              ?.id ==
          widget.examId;
  @override
  void initState() {
    super.initState();
    _guard = _captureGuard();
    _reload();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => PerfTimeline.mark('home.firstframe'),
    );
  }

  Future<Future<bool> Function()> _captureGuard() => ref
      .read(todayQuestionLauncherProvider)
      .captureGuard(widget.examId, isAlive: _current);

  void _reload() {
    final request =
        _request = ref.read(homeTodayLoaderProvider)(widget.examId, _guard);
    _holding = false;
    _pending = true;
    unawaited(
      request.then<void>(
        (data) {
          _settling.reset();
          if (!mounted || !identical(request, _request)) return;
          _pending = false;
          _shown = data;
          _rebuildIfPlanMoved(data);
        },
        onError: (Object error, StackTrace __) {
          if (!mounted || !identical(request, _request)) return;
          _pending = false;
          // Errors after data keep today's handling: the error shows, not
          // the plan from before it.
          _shown = null;
          if (_missedPlan && _current()) {
            // A plan copy arrived while this build failed, so try again with
            // it instead of showing a failure it may have cured.
            _missedPlan = false;
            _retry();
            return;
          }
          setState(() => _holding = _settling.failed(error));
        },
      ),
    );
  }

  /// True when [data] was built from the plan [roadmap] now describes: same
  /// revision, day, planned ids and what is left of them.
  bool _builtFrom(HomeTodayData data, StudyRoadmap roadmap) {
    final snapshot = data.today.snapshot;
    return snapshot.digest.contentRevision == roadmap.revision &&
        snapshot.plan == roadmap.today &&
        data.today.remaining == roadmap.remaining &&
        data.today.originalDone == roadmap.originalDone &&
        snapshot.state == roadmap.state &&
        data.canAdvance == roadmap.canAdvance;
  }

  /// A plan copy arrived while the build ran. If the build used an older one,
  /// build once more. Otherwise the copy is the same plan and nothing changes.
  void _rebuildIfPlanMoved(HomeTodayData data) {
    if (!_missedPlan) return;
    _missedPlan = false;
    if (!ref.read(studyUsesServerProvider) || !_current()) return;
    final latest =
        ref.read(serverStudyRoadmapProvider(widget.examId)).valueOrNull;
    if (latest != null && !_builtFrom(data, latest)) _retry();
  }

  /// A plan copy from the server. Only a plan unlike the one shown rebuilds.
  void _onPlanCopy(AsyncValue<StudyRoadmap> next) {
    final roadmap = next.valueOrNull;
    if (roadmap == null || !_current()) return;
    if (_pending) {
      _missedPlan = true;
      return;
    }
    final shown = _shown;
    if (shown != null && _builtFrom(shown, roadmap)) return;
    _retry();
  }

  @override
  void dispose() {
    _settling.dispose();
    super.dispose();
  }

  /// A retry recaptures the current owner, so it recovers after a real
  /// context change. Loads already running keep the guard they were given
  /// and still fail, so a stale owner cannot write into the new context.
  void _retry() {
    final previous = _guard;
    setState(() {
      _guard = _captureGuard();
      _reload();
    });
    if (_shown != null) unawaited(_dropShownIfOwnerChanged(previous));
  }

  /// The plan on screen stays while a rebuild runs, but only for the owner it
  /// was built for. If the guard it was built under no longer holds, or cannot
  /// say, the skeleton takes its place.
  Future<void> _dropShownIfOwnerChanged(
    Future<Future<bool> Function()> previous,
  ) async {
    var same = false;
    try {
      same = await (await previous)();
    } on Object {
      // Not provably the same owner.
    }
    if (!same && mounted) setState(() => _shown = null);
  }

  /// The automatic retry of a settling failure. It keeps the count, so a
  /// failure that never clears still reaches the error.
  void _retryQuietly() {
    if (mounted) _retry();
  }

  /// The student's own Try Again starts the count anew.
  void _retryNow() {
    _settling.reset();
    _retry();
  }

  void _dismiss() => setState(() {
        _generation++;
        _sheet = null;
        _busy = false;
        _failed = false;
        _pausedBlock = false;
      });
  void _show(String kind, {HomeTodayLesson? lesson}) => setState(() {
        _generation++;
        _sheet = kind;
        _lesson = lesson;
        _failed = false;
        _pausedBlock = false;
      });

  Future<void> _openLesson(HomeTodayData data, HomeTodayLesson lesson) async {
    if (_busy) return;
    final generation = _generation;
    bool current() => _current() && generation == _generation;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      if (!await (await _guard)() || !mounted || !current()) return;
      // Home stays on screen until the lesson can draw. Opening at once left
      // the screen empty while the lesson read its content (7W-7). A slow
      // read is not waited on for long: the reader draws its skeleton.
      try {
        await ref
            .read(readerContextProvider(lesson.id).future)
            .timeout(_lessonReadWait);
      } on Object {
        // The reader reports its own failure.
      }
      if (!mounted || !current()) return;
      _dismiss();
      await context.push<void>(
        '/lesson/${Uri.encodeComponent(lesson.id)}?from=home',
        extra: LessonDayContext(
          date: data.today.snapshot.day,
          lessonIds: data.today.snapshot.plan.lessonIds,
          index: data.today.snapshot.plan.lessonIds.indexOf(lesson.id),
          moreToDo: data.today.remaining.newQuestionIds.isNotEmpty ||
              data.today.remaining.reviewQuestionIds.isNotEmpty,
        ),
      );
      if (_current()) _retry();
    } on Object catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (current()) {
        // A direct open has no panel. Show the lesson panel in its failure
        // state, which carries the message and the retry.
        setState(() {
          _sheet ??= 'lesson';
          _lesson = lesson;
          _failed = true;
        });
      }
    } finally {
      if (current()) setState(() => _busy = false);
    }
  }

  /// A row opens a panel only when it lists two or more items. With exactly
  /// one item it goes straight in. A row with nothing to start keeps its panel.
  void _openLessons(HomeTodayData data) {
    if (data.lessons.length == 1) {
      unawaited(_openLesson(data, data.lessons.single));
    } else {
      _show('lessons');
    }
  }

  void _openReviews(HomeTodayData data) {
    final work = data.questionWork;
    if (work != null && work.reviewSizes.length == 1) {
      unawaited(_start(data, TodayQuestionKind.reviews));
    } else {
      _show('reviews');
    }
  }

  void _openNew(HomeTodayData data) {
    final work = data.questionWork;
    if (work != null &&
        work.newRows.length == 1 &&
        work.newQuestions.isNotEmpty) {
      unawaited(_start(data, TodayQuestionKind.newQuestions));
    } else {
      _show('new');
    }
  }

  Future<void> _start(HomeTodayData data, TodayQuestionKind kind) async {
    if (_busy || data.questionWork == null) return;
    final generation = _generation;
    bool current() => _current() && generation == _generation;
    setState(() {
      _busy = true;
      _failed = false;
      _pausedBlock = false;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      await ref
          .read(todayQuestionLauncherProvider)
          .start(data.questionWork!, kind: kind, isAlive: current);
      if (!mounted || !current()) return;
      _dismiss();
      await context
          .push<void>('/quiz/resume/${Uri.encodeComponent(widget.examId)}');
      if (_current()) _retry();
    } on Object catch (error, stack) {
      // A paused quiz is the student's own state, not a fault to report.
      if (error is! PausedQuizConflict) {
        unawaited(telemetry.recordError(error, stack));
      }
      if (current()) {
        // A start from the main button has no panel open. Show the panel in
        // its failure state, which carries the message and the retry.
        setState(() {
          _sheet ??= kind == TodayQuestionKind.reviews ? 'reviews' : 'new';
          _failed = true;
          _pausedBlock = error is PausedQuizConflict;
        });
      }
    } finally {
      if (current()) setState(() => _busy = false);
    }
  }

  /// Opens the paused quiz, as the Quiz tab's Resume does.
  Future<void> _resumePaused() async {
    _dismiss();
    await context
        .push<void>('/quiz/resume/${Uri.encodeComponent(widget.examId)}');
    if (_current()) _retry();
  }

  /// Discards the paused quiz, as the Quiz tab's Discard does. The panel then
  /// offers its Start button again.
  Future<void> _discardPaused() async {
    if (_discarding) return;
    setState(() => _discarding = true);
    try {
      await ref.read(quitSessionProvider)(
        userId: todayUserId,
        examId: widget.examId,
        now: ref.read(nowProvider)(),
      );
      if (_current()) setState(() => _failed = _pausedBlock = false);
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
    } finally {
      if (mounted) setState(() => _discarding = false);
    }
  }

  Future<void> _advance() async {
    if (_busy) return;
    final generation = _generation;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      if (!await (await _guard)() ||
          !mounted ||
          !_current() ||
          generation != _generation) {
        return;
      }
      if (ref.read(studyUsesServerProvider)) {
        if (_pendingAdvance == null) {
          final remote =
              await ref.read(serverStudyRoadmapProvider(widget.examId).future);
          final reader =
              await ref.read(studySnapshotReaderProvider(widget.examId).future);
          if (!await (await _guard)()) throw StateError('Home owner changed');
          _pendingAdvance = StudyAdvance(
            reader.request,
            requestId: const Uuid().v4(),
            expectedDay: dayKey(remote.today.day),
            expectedRevision: remote.revision,
          );
        }
        await _pendingAdvance!.send();
        _pendingAdvance = null;
        ref.invalidate(serverStudyRoadmapProvider(widget.examId));
      } else {
        await ref
            .read(roadmapControllerProvider)
            .advance(widget.examId, originalGuard: _guard);
      }
      if (_current() && generation == _generation) _retry();
    } on Object catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (error is FirebaseFunctionsException &&
          !const {
            'unavailable',
            'deadline-exceeded',
            'resource-exhausted',
            'network-request-failed',
          }.contains(error.code)) {
        _pendingAdvance = null;
        ref.invalidate(serverStudyRoadmapProvider(widget.examId));
      }
      if (_current() && generation == _generation) {
        setState(() => _failed = true);
      }
    } finally {
      if (_current() && generation == _generation) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _mock() async {
    if (!await (await _guard)() || !mounted || !_current()) {
      return;
    }
    await context.push<void>(
      '/quiz/mock/setup?examId=${Uri.encodeComponent(widget.examId)}',
    );
    if (_current()) _retry();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(activeExamFocusProvider);
    if (ref.watch(studyUsesServerProvider)) {
      ref.listen(
        serverStudyRoadmapProvider(widget.examId),
        (_, next) => _onPlanCopy(next),
      );
    }
    return FutureBuilder<HomeTodayData>(
      future: _request,
      builder: (context, snapshot) {
        final done = snapshot.connectionState == ConnectionState.done;
        // A waiting snapshot still carries the error of the read before it, so
        // only a finished read can be a failure to show.
        final failed = done && snapshot.hasError;
        final holding = failed && _holding;
        firstScreenReady(context, ref, ready: done && !holding);
        // While a rebuild runs the plan from before it stays on screen. A
        // finished read, or a failed one, shows only its own result.
        final data = done ? snapshot.data : (_current() ? _shown : null);
        if (data != null) PerfTimeline.mark('home.data');
        _timing.settled(ready: data != null);
        final today = data == null
            ? failed && !holding
                ? errorFor(
                    'plan',
                    _retryNow,
                    error: snapshot.error,
                    boardLayout: context.wideWeb,
                  )
                : context.wideWeb
                    ? const HomeWebLoading(more: true)
                    : const HomeTodaySkeleton()
            : _checklist(data);
        if (context.wideWeb) {
          return HomeWebOverlay(
            page: widget.pageBuilder(today, data),
            label: _sheet == 'lessons'
                ? 'Lessons'
                : _sheet == 'lesson'
                    ? _lesson?.title ?? 'Lesson'
                    : _sheet == 'reviews'
                        ? 'Reviews'
                        : 'New questions',
            open: _sheet != null && data != null,
            drawer: true,
            onDismiss: _dismiss,
            child: data == null ? const SizedBox.shrink() : _contents(data),
          );
        }
        return PantasSheet(
          page: widget.pageBuilder(today, data),
          label: _sheet == 'lessons'
              ? 'Lessons'
              : _sheet == 'lesson'
                  ? _lesson?.title ?? 'Lesson'
                  : _sheet == 'reviews'
                      ? 'Reviews'
                      : 'New questions',
          open: _sheet != null && data != null,
          onDismiss: _dismiss,
          readerContents: true,
          scrollable: false,
          child: data == null ? const SizedBox.shrink() : _contents(data),
        );
      },
    );
  }

  Future<void> _practiceWeakest() async {
    final telemetry = ref.read(telemetryProvider);
    try {
      final guard = await _guard;
      String? topicId;
      if (ref.read(studyUsesServerProvider)) {
        final insights =
            await ref.read(serverStudyInsightsProvider(widget.examId).future);
        final topics = insights.topics.where((t) => t.answered > 0).toList()
          ..sort((a, b) {
            final accuracy = a.accuracy!.compareTo(b.accuracy!);
            return accuracy != 0 ? accuracy : a.id.compareTo(b.id);
          });
        topicId = topics.firstOrNull?.id;
      } else {
        final topics = await ref.read(topicAccuracyProvider.future);
        topicId = topics.firstWhereOrNull((t) => t.answered > 0)?.topicId;
      }
      if (!await guard() || !mounted || !_current()) return;
      if (topicId == null && !ref.read(studyUsesServerProvider)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No questions are ready right now.')),
        );
        return;
      }
      await startTopicPractice(
        context,
        ref,
        examId: widget.examId,
        topicId: topicId,
        isCurrent: guard,
      );
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted && _current()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not prepare this quiz.')),
        );
      }
    }
  }

  Widget _checklist(HomeTodayData data) {
    final snapshot = data.today.snapshot;
    final view = homeTodayViewFor(
      state: snapshot.state,
      plan: snapshot.plan,
      originalDone: data.today.originalDone,
      canAdvance: data.canAdvance,
      examDate: snapshot.digest.examDate,
    );
    final note = homeDayNoteLabel(data);
    final body = switch (view.kind) {
      HomeTodayKind.checklist => _list(data, view),
      HomeTodayKind.examDay => HomeExamDay(
          examShortName: data.examShortName,
          onPlan: () => unawaited(context.push<void>('/plan')),
          reviewsTotal: data.questionWork?.reviewsTotal ?? 0,
          reviewsDone: data.questionWork?.reviewsDone ?? 0,
          busy: _busy,
          onRow: () => _openReviews(data),
          onStart: () => unawaited(_start(data, TodayQuestionKind.reviews)),
        ),
      HomeTodayKind.assessment || HomeTodayKind.noContent => HomeStateCard(
          state: view.kind == HomeTodayKind.assessment
              ? HomeState.assessment
              : HomeState.noContent,
          examName: data.examName,
          examShortName: data.examShortName,
          onPrimary: () => view.kind == HomeTodayKind.assessment
              ? unawaited(
                  context.push<void>('/assessment/${widget.examId}'),
                )
              : unawaited(context.push<void>('/settings/exam/change')),
        ),
      HomeTodayKind.nothingDue ||
      HomeTodayKind.reviewOnly ||
      HomeTodayKind.dayOff ||
      HomeTodayKind.passed =>
        _quietDay(data, view),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (note != null && !context.wideWeb) ...[
          // Boards (HE_BackAfterBreak, HE_MockMoved): the line sits 6 px lower
          // and the Today label 16 px nearer than the plain gap.
          Padding(
            padding: EdgeInsets.fromLTRB(4, widget.noteTopGap, 4, 0),
            child: Text(
              note,
              style: context.type.subhead.copyWith(
                color: context.colors.secondaryLabel,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        body,
        if (_failed && _sheet == null)
          errorFor('plan', () => unawaited(_advance())),
      ],
    );
  }

  Widget _quietDay(HomeTodayData data, HomeTodayView view) {
    final passed = view.kind == HomeTodayKind.passed;
    final digestDate = data.today.snapshot.digest.examDate.split(':').first;
    final examDay = DateTime.tryParse(digestDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Board (HP_ExamPassed): the label stands alone, with no plan link.
        HomeTodayHeader(
          onPlan: passed && !context.wideWeb
              ? null
              : () => unawaited(context.push<void>('/plan')),
        ),
        HomeStateCard(
          state: switch (view.kind) {
            HomeTodayKind.nothingDue => HomeState.nothingDue,
            HomeTodayKind.reviewOnly => HomeState.reviewOnly,
            HomeTodayKind.dayOff => HomeState.dayOff,
            _ => HomeState.passed,
          },
          examName: data.examName,
          examShortName: data.examShortName,
          hasExamDate: data.today.snapshot.digest.examDate.isNotEmpty,
          examDateLabel: passed && examDay != null
              ? DateFormat('MMMM d', 'en_US').format(examDay)
              : null,
          onPrimary: switch (view.kind) {
            HomeTodayKind.dayOff =>
              view.offersAdvance ? () => unawaited(_advance()) : null,
            HomeTodayKind.passed => widget.onSetDate,
            _ => () => unawaited(_practiceWeakest()),
          },
          onSecondary: () =>
              unawaited(context.push<void>('/settings/exam/change')),
        ),
      ],
    );
  }

  Widget _list(HomeTodayData data, HomeTodayView view) {
    final work = data.questionWork;
    final originals = data.lessons.where((l) => !l.advanced).length;
    final questions = [
      ...data.today.snapshot.plan.reviewQuestionIds,
      ...data.today.snapshot.plan.newQuestionIds,
    ].where((id) => !data.today.snapshot.plan.advancedIds.contains(id)).length;
    final sizes = work?.reviewSizes ?? const <int>[];
    return HomeTodayChecklist(
      web: context.webPlatform,
      onPlan: () => unawaited(context.push<void>('/plan')),
      lessons: data.lessons,
      reviewsDone: work?.reviewsDone ?? 0,
      reviewsTotal: work?.reviewsTotal ?? 0,
      newDone: work?.newDone ?? 0,
      newTotal: work?.newTotal ?? 0,
      canAdvance: data.canAdvance,
      isMockDay: data.today.snapshot.plan.isMockDay,
      mockSubtitle: data.extras.mock?.subtitle,
      mockDuration: data.extras.mock?.duration,
      doneNote: view.doneNote,
      examShortName: data.examShortName,
      originalSummary: '$originals ${originals == 1 ? "lesson" : "lessons"} · '
          '$questions ${questions == 1 ? "question" : "questions"}',
      reviewSubtitle: sizes.length > 1
          ? '${work!.reviewsTotal} due · ${sizes.length} sessions of '
              '${work.preparedReviews.preferences.sessionLength}'
          : 'Questions due today',
      advancing: _busy,
      onLesson: (lesson) => unawaited(_openLesson(data, lesson)),
      onLessons: () => _openLessons(data),
      onReviews: () => _openReviews(data),
      onNew: () => _openNew(data),
      onStartReviews: () => unawaited(_start(data, TodayQuestionKind.reviews)),
      onStartNew: () => unawaited(_start(data, TodayQuestionKind.newQuestions)),
      reviewsStarted: work?.storedReviews != null,
      // Task 6 adds the plan route. Until it exists nothing pushes to it, so
      // the link is not drawn.
      onAdvance: () => unawaited(_advance()),
      onMock: () => unawaited(_mock()),
    );
  }

  Widget _lessonRow(
    HomeTodayData data,
    HomeTodayLesson lesson, {
    bool last = false,
  }) =>
      context.wideWeb
          ? WebRow(
              title: lesson.title,
              // A long title is read in full, as on Performance (3K-14).
              wrapTitle: true,
              titleStyle: context.webTokens.style(
                16,
                color: lesson.read ? context.colors.secondaryLabel : null,
                height: 1.3,
              ),
              boardMetrics: true,
              divider: !last,
              value: lesson.read ? null : '${lesson.minutes} min',
              leading: HomeDrawerRing(
                lesson.read ? 1 : lesson.fraction ?? 0,
                done: lesson.read,
              ),
              compact: true,
              onPressed: () => unawaited(_openLesson(data, lesson)),
            )
          : ListRow(
              title: lesson.title,
              value: lesson.read ? null : '${lesson.minutes} min',
              variant: ListRowVariant.value,
              // The time keeps its own width and the title takes the rest
              // of the row (3K-4, as 2G-21 did for search rows).
              naturalValue: true,
              // A long title is read in full, not cut with dots (Nov 3 rule).
              wrapTitle: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
              minimumHeight: 0,
              titleColor: lesson.read ? context.colors.secondaryLabel : null,
              leading: lesson.read
                  ? const CheckMark()
                  : ProgressRing(fraction: lesson.fraction ?? 0),
              onTap: () => unawaited(_openLesson(data, lesson)),
            );
  Widget _contents(HomeTodayData data) {
    final sheet =
        context.wideWeb ? HomeWebQuestionsSheet.new : TodayQuestionsSheet.new;
    final work = data.questionWork;
    final reviews = _sheet == 'reviews';
    final lessons = _sheet == 'lesson' || _sheet == 'lessons';
    final next = _sheet == 'lesson'
        ? _lesson
        : data.lessons.firstWhereOrNull((l) => !l.read);
    if (lessons) {
      final shown = _sheet == 'lesson' ? [_lesson!] : data.lessons;
      return sheet(
        title: _sheet == 'lesson' ? _lesson!.title : 'Lessons',
        done: data.lessons.where((l) => l.read).length,
        total: data.lessons.length,
        rows: context.wideWeb && _sheet == 'lessons'
            ? [
                for (final group
                    in groupBy(shown, (lesson) => lesson.subject).entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 9),
                          child: WebText(
                            group.key,
                            kind: WebTextKind.eyebrow,
                          ),
                        ),
                        WebCard(
                          child: Column(
                            children: [
                              for (final lesson in group.value)
                                _lessonRow(
                                  data,
                                  lesson,
                                  last: lesson == group.value.last,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ]
            : [
                for (final group
                    in groupBy(shown, (lesson) => lesson.subject).entries) ...[
                  if (_sheet == 'lessons')
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 2),
                        child: Text(
                          group.key.toUpperCase(),
                          style: context.type.sectionHeader.copyWith(
                            fontSize: 12,
                            letterSpacing: .48,
                            color: context.colors.secondaryLabel,
                          ),
                        ),
                      ),
                    ),
                  for (final lesson in group.value)
                    _lessonRow(data, lesson, last: lesson == shown.last),
                ],
              ],
        startLabel: _sheet == 'lesson'
            ? (next?.fraction ?? 0) > 0
                ? 'Resume Lesson'
                : 'Start Lesson'
            : 'Continue Lesson',
        onStart: next == null ? null : () => unawaited(_openLesson(data, next)),
        busy: _busy,
        failure: _failed
            ? StateView(
                message: 'Could not open the lesson.',
                onRetry: () {
                  final retry = _lesson ?? next;
                  if (retry != null) unawaited(_openLesson(data, retry));
                },
              )
            : null,
      );
    }
    if (work == null) return const SizedBox.shrink();
    return sheet(
      title: reviews ? 'Reviews' : 'New questions',
      done: reviews ? work.reviewsDone : work.newDone,
      total: reviews ? work.reviewsTotal : work.newTotal,
      rows: reviews
          ? [
              for (var i = 0; i < work.reviewSizes.length; i++)
                _questionRow(
                  'Session ${i + 1}',
                  work.reviewProgress[i],
                  work.reviewSizes[i],
                  last: i == work.reviewSizes.length - 1,
                ),
            ]
          : [
              for (final row in work.newRows)
                _questionRow(
                  row.title,
                  row.done,
                  row.total,
                  last: row == work.newRows.last,
                ),
            ],
      startLabel: reviews
          ? work.storedReviews == null
              ? 'Start Reviews'
              : 'Continue Reviews'
          : 'Start New Questions',
      onStart:
          (reviews ? work.reviewSizes.isNotEmpty : work.newQuestions.isNotEmpty)
              ? () => unawaited(
                    _start(
                      data,
                      reviews
                          ? TodayQuestionKind.reviews
                          : TodayQuestionKind.newQuestions,
                    ),
                  )
              : null,
      busy: _busy,
      failure: !_failed
          ? null
          : _pausedBlock
              ? PausedQuizNotice(
                  onResume: () => unawaited(_resumePaused()),
                  onDiscard:
                      _discarding ? null : () => unawaited(_discardPaused()),
                )
              : StateView(
                  message: 'Could not start your quiz.',
                  onRetry: () => unawaited(
                    _start(
                      data,
                      reviews
                          ? TodayQuestionKind.reviews
                          : TodayQuestionKind.newQuestions,
                    ),
                  ),
                ),
    );
  }

  Widget _questionRow(
    String title,
    int done,
    int total, {
    bool last = false,
  }) =>
      context.wideWeb
          ? HomeDrawerQuestionRow(
              title: title,
              done: done,
              total: total,
              last: last,
            )
          : ListRow(
              title: title,
              value: '$total',
              variant: ListRowVariant.value,
              naturalValue: true,
              leading: done == total
                  ? const CheckMark()
                  : ProgressRing(fraction: total == 0 ? 0 : done / total),
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
              minimumHeight: 0,
              valueStyle: context.type.subhead
                  .copyWith(color: context.colors.secondaryLabel),
            );
}
