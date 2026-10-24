import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/performance/topic_accuracy_provider.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/data/study_writes.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/home/presentation/practice_launcher.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_day.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:uuid/uuid.dart';

/// Owns one Home request, including its retries and every asynchronous launch.
/// Closing the page invalidates the original captured account/exam boundary.
class HomeTodayScreen extends ConsumerStatefulWidget {
  const HomeTodayScreen({
    required this.examId,
    required this.pageBuilder,
    this.onSetDate,
    super.key,
  });
  final String examId;

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
  int _generation = 0;
  StudyAdvance? _pendingAdvance;

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
    _guard = ref
        .read(todayQuestionLauncherProvider)
        .captureGuard(widget.examId, isAlive: _current);
    _reload();
  }

  void _reload() {
    _request = ref.read(homeTodayLoaderProvider)(widget.examId, _guard);
    unawaited(
      _request.then<void>((_) {}, onError: (Object _, StackTrace __) {}),
    );
  }

  void _retry() => setState(_reload);
  void _dismiss() => setState(() {
        _generation++;
        _sheet = null;
        _busy = false;
        _failed = false;
      });
  void _show(String kind, {HomeTodayLesson? lesson}) => setState(() {
        _generation++;
        _sheet = kind;
        _lesson = lesson;
        _failed = false;
      });

  Future<void> _openLesson(HomeTodayData data, HomeTodayLesson lesson) async {
    final generation = _generation;
    if (!await (await _guard)() ||
        !mounted ||
        !_current() ||
        generation != _generation) {
      return;
    }
    _dismiss();
    await context.push<void>(
      '/lesson/${Uri.encodeComponent(lesson.id)}?from=home',
      extra: LessonDayContext(
        date: data.today.snapshot.day,
        lessonIds: data.today.snapshot.plan.lessonIds,
        index: data.today.snapshot.plan.lessonIds.indexOf(lesson.id),
      ),
    );
    if (_current()) _retry();
  }

  Future<void> _start(HomeTodayData data, TodayQuestionKind kind) async {
    if (_busy || data.questionWork == null) return;
    final generation = _generation;
    bool current() => _current() && generation == _generation;
    setState(() {
      _busy = true;
      _failed = false;
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
      unawaited(telemetry.recordError(error, stack));
      if (current()) setState(() => _failed = true);
    } finally {
      if (current()) setState(() => _busy = false);
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
      ref.listen(serverStudyRoadmapProvider(widget.examId), (_, next) {
        if (next.hasValue && _current()) _retry();
      });
    }
    return FutureBuilder<HomeTodayData>(
      future: _request,
      builder: (context, snapshot) {
        final data = snapshot.connectionState == ConnectionState.done
            ? snapshot.data
            : null;
        final today = data == null
            ? snapshot.hasError
                ? errorFor('plan', _retry, error: snapshot.error)
                : loadingFor(const AsyncLoading<HomeTodayData>())
            : _checklist(data);
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

  String? _noteText(HomeTodayData data) => switch (data.extras.note) {
        HomeDayNote.carried => 'Unfinished items are added to today.',
        HomeDayNote.welcomeBack => "Items you missed are in today's reviews.",
        HomeDayNote.mockMoved =>
          'Your ${data.examShortName} simulation moved to today.',
        null => null,
      };

  Widget _checklist(HomeTodayData data) {
    final snapshot = data.today.snapshot;
    final view = homeTodayViewFor(
      state: snapshot.state,
      plan: snapshot.plan,
      originalDone: data.today.originalDone,
      canAdvance: data.canAdvance,
      examDate: snapshot.digest.examDate,
    );
    final note = _noteText(data);
    final body = switch (view.kind) {
      HomeTodayKind.checklist => _list(data, view),
      HomeTodayKind.examDay => HomeExamDay(
          examShortName: data.examShortName,
          onPlan: () => unawaited(context.push<void>('/plan')),
          reviewsTotal: data.questionWork?.reviewsTotal ?? 0,
          reviewsDone: data.questionWork?.reviewsDone ?? 0,
          busy: _busy,
          onRow: () => _show('reviews'),
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
        if (note != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              note,
              style: context.type.subhead.copyWith(
                color: context.colors.secondaryLabel,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 22),
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
        HomeTodayHeader(onPlan: () => unawaited(context.push<void>('/plan'))),
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
              ? DateFormat('d MMMM', 'en_US').format(examDay)
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
      onLesson: (lesson) => _show('lesson', lesson: lesson),
      onLessons: () => _show('lessons'),
      onReviews: () => _show('reviews'),
      onNew: () => _show('new'),
      // Task 6 adds the plan route. Until it exists nothing pushes to it, so
      // the link is not drawn.
      onAdvance: () => unawaited(_advance()),
      onMock: () => unawaited(_mock()),
    );
  }

  Widget _lessonRow(HomeTodayData data, HomeTodayLesson lesson) => ListRow(
        title: lesson.title,
        value: lesson.read ? null : '${lesson.minutes} min',
        variant: ListRowVariant.value,
        contentPadding: const EdgeInsets.symmetric(vertical: 9),
        minimumHeight: 0,
        titleColor: lesson.read ? context.colors.secondaryLabel : null,
        leading: lesson.read
            ? const CheckMark()
            : ProgressRing(fraction: lesson.fraction ?? 0),
        onTap: () => unawaited(_openLesson(data, lesson)),
      );
  Widget _contents(HomeTodayData data) {
    final work = data.questionWork;
    final reviews = _sheet == 'reviews';
    final lessons = _sheet == 'lesson' || _sheet == 'lessons';
    final next = _sheet == 'lesson'
        ? _lesson
        : data.lessons.firstWhereOrNull((l) => !l.read);
    if (lessons) {
      final shown = _sheet == 'lesson' ? [_lesson!] : data.lessons;
      return TodayQuestionsSheet(
        title: _sheet == 'lesson' ? _lesson!.title : 'Lessons',
        done: data.lessons.where((l) => l.read).length,
        total: data.lessons.length,
        rows: [
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
            for (final lesson in group.value) _lessonRow(data, lesson),
          ],
        ],
        startLabel: _sheet == 'lesson'
            ? (next?.fraction ?? 0) > 0
                ? 'Resume Lesson'
                : 'Start Lesson'
            : 'Continue Lesson',
        onStart: next == null ? null : () => unawaited(_openLesson(data, next)),
      );
    }
    if (work == null) return const SizedBox.shrink();
    return TodayQuestionsSheet(
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
                ),
            ]
          : [
              for (final row in work.newRows)
                _questionRow(row.title, row.done, row.total),
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
      failure: _failed
          ? StateView(
              message: 'Could not start your quiz.',
              onRetry: () => unawaited(
                _start(
                  data,
                  reviews
                      ? TodayQuestionKind.reviews
                      : TodayQuestionKind.newQuestions,
                ),
              ),
            )
          : null,
    );
  }

  Widget _questionRow(String title, int done, int total) => ListRow(
        title: title,
        value: '$total',
        variant: ListRowVariant.value,
        leading: done == total
            ? const CheckMark()
            : ProgressRing(fraction: total == 0 ? 0 : done / total),
        contentPadding: const EdgeInsets.symmetric(vertical: 9),
        minimumHeight: 0,
        valueStyle:
            context.type.subhead.copyWith(color: context.colors.secondaryLabel),
      );
}
