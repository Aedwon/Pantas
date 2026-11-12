import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/app/web_address.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/report_failure.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/presentation/completed_quiz_provider.dart';
import 'package:pantas/features/quiz/presentation/questions_unavailable.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_boundary.dart';
import 'package:pantas/features/quiz/presentation/quiz_question_viewer.dart';
import 'package:pantas/features/quiz/presentation/review_providers.dart';

typedef _LoadedReview = ({
  CompletedQuizData data,
  Map<String, Passage> passages
});

class QuizReviewPage extends ConsumerStatefulWidget {
  const QuizReviewPage({
    required this.attemptId,
    this.initialIndex = 0,
    this.openNotes = false,
    this.fromAll = false,
    this.mistakesOnly = false,
    super.key,
  });
  final String attemptId;
  final int initialIndex;
  final bool openNotes;
  final bool fromAll;

  /// Opened from the list of mistakes: step through the wrong answers only,
  /// as the list does. [initialIndex] still counts every question.
  final bool mistakesOnly;
  @override
  ConsumerState<QuizReviewPage> createState() => _QuizReviewPageState();
}

class _QuizReviewPageState extends ConsumerState<QuizReviewPage> {
  late final AppDatabase _db;
  String? _lifetime;
  AuthState? _auth;
  String? _authUid;
  String? _examId;
  late final Future<QuizNoteBoundary?> _boundary;
  late Future<_LoadedReview> _future;
  ProviderSubscription<AsyncValue<CompletedQuizData>>? _dataSubscription;
  CompletedQuizRequest get _request => (
        boundary: _boundary,
        attemptId: widget.attemptId,
        session: null,
        attempt: null,
        custom: false
      );

  @override
  void initState() {
    super.initState();
    _db = ref.read(appDatabaseProvider);
    _auth = ref.read(authStateProvider).unwrapPrevious().asData?.value;
    _authUid = switch (_auth) {
      AnonymousAuthState(:final uid) => uid,
      SignedInAuthState(:final user) => user.uid,
      _ => null,
    };
    _lifetime = ref.read(todayQuizPreparerProvider).accountLifetimeToken;
    _examId = ref
        .read(activeExamFocusProvider)
        .unwrapPrevious()
        .asData
        ?.value
        .exam
        ?.id;
    _boundary = QuizNoteBoundary.capture(_db, isCurrent: _current);
    _future = _load();
  }

  bool _current() =>
      mounted &&
      _lifetime != null &&
      _authUid != null &&
      ref.read(authStateProvider).unwrapPrevious().asData?.value == _auth &&
      identical(ref.read(appDatabaseProvider), _db) &&
      ref.read(todayQuizPreparerProvider).accountLifetimeToken == _lifetime &&
      (_examId == null ||
          ref
                  .read(activeExamFocusProvider)
                  .unwrapPrevious()
                  .asData
                  ?.value
                  .exam
                  ?.id ==
              _examId);

  Future<_LoadedReview> _load() async {
    final boundary = await _boundary;
    if (boundary == null ||
        !await boundary.allows() ||
        (boundary.ownerUid != null && boundary.ownerUid != _authUid)) {
      throw StateError('Review ownership changed');
    }
    final focus = await ref.read(activeExamFocusProvider.future);
    _examId ??= focus.exam?.id;
    if (_examId == null || !_current()) throw StateError('Review exam changed');
    _dataSubscription ??= ref.listenManual(
      completedQuizProvider(_request),
      (_, __) {},
    );
    final data = await ref.read(completedQuizProvider(_request).future);
    if (data.attempt.examId != _examId || data.session.questions.isEmpty) {
      throw StateError('Review exam is unavailable');
    }
    final content = ref.read(contentRepositoryProvider);
    final passages = <String, Passage>{};
    for (final id in data.session.questions
        .map((q) => q.passageId)
        .whereType<String>()
        .toSet()) {
      final passage = await content.passageById(id);
      if (passage == null) throw StateError('Original passage is unavailable');
      passages[id] = passage;
    }
    if (!await boundary.allows()) throw StateError('Review ownership changed');
    return (data: data, passages: passages);
  }

  void _retry() {
    ref.invalidate(completedQuizProvider(_request));
    // Observe an expired boundary before the next frame subscribes.
    final future = _load()..ignore();
    setState(() {
      _future = future;
    });
  }

  Future<void> _save(String questionId, MistakeTag? tag, String? note) async {
    try {
      await _write(questionId, tag, note);
    } catch (error, stack) {
      // The note editor shows its retry line and nothing else, so the cause
      // would be lost without this.
      reportFailure(ref.read(telemetryProvider), 'quiz.note', error, stack);
      rethrow;
    }
  }

  Future<void> _write(String questionId, MistakeTag? tag, String? note) async {
    final boundary = await _boundary;
    if (boundary == null) throw StateError('Review ownership changed');
    Future<bool> canPersist() async {
      if (!_current() ||
          !(ref.read(proForActiveExamProvider).unwrapPrevious().asData?.value ??
              false)) {
        return false;
      }
      final valid = await boundary.allows();
      return valid &&
          _current() &&
          (ref.read(proForActiveExamProvider).unwrapPrevious().asData?.value ??
              false);
    }

    if (!await canPersist()) throw StateError('Review is unavailable');
    await ref.read(attemptsRepositoryProvider).tagItem(
          attemptId: widget.attemptId,
          questionId: questionId,
          tag: tag,
          note: note,
          replaceNote: true,
          canPersist: canPersist,
        );
  }

  void _back() {
    if (widget.fromAll && context.canPop()) {
      context.pop();
    } else {
      // The label names the list the student came from, so Back goes there.
      unawaited(
        pushReplacementEntry<void>(
          context,
          '/quiz/all/${widget.attemptId}'
          '${widget.mistakesOnly ? '?mistakes=true' : ''}',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(authStateProvider)
      ..watch(activeExamFocusProvider)
      ..watch(appDatabaseProvider);
    final pro =
        ref.watch(proForActiveExamProvider).unwrapPrevious().asData?.value ??
            false;
    final paused = ref.watch(entitlementProvider).valueOrNull?.state ==
        EntitlementState.paused;
    return FutureBuilder<_LoadedReview>(
      future: _future,
      builder: (context, snapshot) {
        firstScreenReady(
          context,
          ref,
          ready: snapshot.connectionState == ConnectionState.done,
        );
        if (snapshot.hasError || !_current()) {
          return Scaffold(
            body: QuestionsUnavailable(
              onRetry: _retry,
              notFound: snapshot.error is CompletedQuizNotFound,
            ),
          );
        }
        final loaded = snapshot.data;
        if (loaded == null) {
          return const Scaffold(body: SafeArea(child: SkeletonQuestionPage()));
        }
        final all = loaded.data.session.questions;
        final answers = loaded.data.attempt.items;
        // Positions in the whole session that the viewer steps through.
        final shown = [
          for (var i = 0; i < all.length; i++)
            if (!widget.mistakesOnly ||
                (i < answers.length && !answers[i].isCorrect))
              i,
        ];
        if (shown.isEmpty) {
          return Scaffold(body: QuestionsUnavailable(onRetry: _retry));
        }
        final start = shown.indexOf(widget.initialIndex);
        return PopScope(
          canPop: widget.fromAll,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: QuizQuestionViewer(
            questions: [for (final i in shown) all[i]],
            items: widget.mistakesOnly
                ? [for (final i in shown) answers[i]]
                : answers,
            subjectNames: loaded.data.subjectNames,
            topicNames: loaded.data.topicNames,
            passages: loaded.passages,
            pro: pro,
            proPaused: paused,
            initialIndex: start < 0 ? 0 : start,
            openNotes: widget.openNotes,
            backLabel: widget.mistakesOnly ? 'Your mistakes' : 'All questions',
            onIndexChanged: (position) => replaceWebAddress(
              context,
              Uri.parse(
                '/quiz/viewer/${widget.attemptId}?index=${shown[position]}'
                '&notes=false&fromAll=${widget.fromAll}'
                '${widget.mistakesOnly ? '&mistakes=true' : ''}',
              ),
            ),
            onReload: _retry,
            onBack: _back,
            onNote: _save,
            onReport: (id) =>
                openQuestionReport(context, id, queue: ReportQueue(_db)),
          ),
        );
      },
    );
  }
}

class FlaggedQuestionViewerPage extends ConsumerWidget {
  const FlaggedQuestionViewerPage({
    required this.examId,
    required this.questionId,
    super.key,
  });
  final String examId;
  final String questionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(flaggedExamReviewProvider(examId));
    firstScreenReady(context, ref, ready: !entries.isLoading);
    void retry() => ref.invalidate(flaggedExamReviewProvider(examId));
    return entries.when(
      loading: () =>
          const Scaffold(body: SafeArea(child: SkeletonQuestionPage())),
      error: (_, __) => Scaffold(body: QuestionsUnavailable(onRetry: retry)),
      data: (rows) {
        final index = rows.indexWhere((r) => r.question.id == questionId);
        if (index < 0) {
          return Scaffold(
            body: QuestionsUnavailable(onRetry: retry, notFound: true),
          );
        }
        return QuizQuestionViewer(
          key: ValueKey('$examId:$questionId'),
          questions: [for (final row in rows) row.question],
          items: const [],
          subjectNames: {
            for (final row in rows) row.question.topicId: row.subjectName,
          },
          topicNames: {
            for (final row in rows)
              if (row.topicName.isNotEmpty) row.question.topicId: row.topicName,
          },
          onIndexChanged: (position) => replaceWebAddress(
            context,
            Uri.parse(
              '/quiz/flagged/${Uri.encodeComponent(examId)}/view/'
              '${Uri.encodeComponent(rows[position].question.id)}',
            ),
          ),
          passages: {
            for (final row in rows)
              if (row.passage != null) row.passage!.id: row.passage!,
          },
          initialIndex: index,
          backLabel: 'Flagged questions',
          pro: false,
          onReload: retry,
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              unawaited(
                pushReplacementEntry<void>(context, '/quiz/flagged/$examId'),
              );
            }
          },
          onNote: (_, __, ___) async {
            throw StateError('No completed answer');
          },
          onReport: (id) => openQuestionReport(
            context,
            id,
            queue: ReportQueue(ref.read(appDatabaseProvider)),
          ),
        );
      },
    );
  }
}
