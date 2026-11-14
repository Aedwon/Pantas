import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/app/update_coordinator_provider.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/features/mock_exam/application/mock_leave_guard.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_session.dart';
import 'package:pantas/features/mock_exam/application/strict_mode_lifecycle.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/mock_exam/presentation/part_transition_page.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_skeletons.dart';

/// The mock on the web. The server pins the paper, owns the clock and keeps
/// the answers (startMock, getMockPaper, controlMock, submitMock); this screen
/// shows them with the same paper and pause screens as the phone.
///
/// Starting is explicit. If a mock is already open the server returns that
/// one, whatever exam is selected now, and it is shown as it is.
class ServerMockRoute extends ConsumerStatefulWidget {
  const ServerMockRoute({
    required this.examId,
    required this.strictMode,
    this.resumeMockId,
    super.key,
  });

  final String examId;
  final bool strictMode;
  final String? resumeMockId;

  @override
  ConsumerState<ServerMockRoute> createState() => _ServerMockRouteState();
}

class _ServerMockRouteState extends ConsumerState<ServerMockRoute>
    with WidgetsBindingObserver {
  ServerMockSession? _session;
  Widget? _lastPaper;
  Object? _loadError;
  Timer? _tick;
  StrictModeLifecycle? _strict;
  var _pauseWarningSeen = false;
  var _finishing = false;
  ServerMockEndReason? _terminalReason;
  var _disposed = false;
  var _identityLost = false;
  var _leaving = false;
  var _awaitingAccount = false;
  String? _originalUid;
  MockLeaveGuard? _guard;

  @override
  void initState() {
    super.initState();
    ref.read(updateCoordinatorProvider).quizStarted();
    WidgetsBinding.instance.addObserver(this);
    final guard = ref.read(mockLeaveGuardProvider)..running = _allowLeave;
    _guard = guard;
    ref
      ..listenManual(serverMockIdentityProvider, (previous, next) {
        final original = _originalUid;
        if (original != null && next != original) {
          _identityLost = true;
          unawaited(_close());
        }
      })
      ..listenManual(mockAccountGateProvider, (previous, next) {
        if (!mounted || _disposed) return;
        if (next == MockAccountGate.needsAccount) _askForAccount();
        if (next == MockAccountGate.ready && _awaitingAccount) {
          unawaited(_load());
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    unawaited(_loadPauseWarning());
  }

  @override
  void dispose() {
    _disposed = true;
    _guard?.detach(_allowLeave);
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _session
      ?..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  /// The Quiz tab reads the open-mock status of the exam it shows. A resumed
  /// mock arrives with no exam in its address, so the exam comes from the
  /// paper the server pinned, and from the exam this screen was asked for.
  void _refreshAvailability() {
    final ids = {
      if (widget.examId.isNotEmpty) widget.examId,
      if (_session?.paper.examId case final String id) id,
    };
    for (final id in ids) {
      ref.invalidate(serverMockAvailabilityProvider(id));
    }
  }

  /// Browser Back reaches the route's `onExit` instead of this page's pop
  /// handling. While a mock runs it does what the app's Back does: ask to
  /// pause, or explain that strict mode has no Back. Leaving the screen
  /// itself (results, close, a failed load) is always allowed.
  Future<bool> _allowLeave() async {
    final session = _session;
    if (!mounted ||
        _disposed ||
        _leaving ||
        _finishing ||
        _identityLost ||
        _loadError != null ||
        session == null ||
        session.stale ||
        session.submitted) {
      return true;
    }
    // The paused page has no Back, in the app or in the browser.
    if (session.paused) return false;
    await Navigator.maybePop(context);
    return false;
  }

  Future<void> _loadPauseWarning() async {
    final seen = await ref.read(mockExamPreferencesProvider).pauseWarningSeen();
    if (mounted) setState(() => _pauseWarningSeen = seen);
  }

  /// A student with no named account has no mock to open. The Quiz tab holds
  /// the card that asks for one, so this address sends them there.
  void _askForAccount() {
    if (_leaving || _session != null) return;
    _leaving = true;
    context.go(mockExitLocation);
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    // While the account is unknown the skeleton shows, and the gate's change
    // loads or leaves. Nothing here may fail as "unauthenticated" first.
    switch (ref.read(mockAccountGateProvider)) {
      case MockAccountGate.checking:
        _awaitingAccount = true;
        return;
      case MockAccountGate.needsAccount:
        _askForAccount();
        return;
      case MockAccountGate.ready:
        _awaitingAccount = false;
    }
    final actor = ref.read(serverMockActorProvider);
    final uid = actor();
    _originalUid ??= uid;
    try {
      if (uid == null) throw const ServerMockException(code: 'unauthenticated');
      final api = ref.read(serverMockApiProvider);
      ServerMockPaper paper;
      if (widget.resumeMockId != null) {
        final current = await api.read();
        if (_disposed || !mounted || (_identityLost || actor() != uid)) return;
        if (current is ServerMockOpen) {
          paper = current.paper;
        } else {
          final id = current is ServerMockEnded
              ? current.ended.mockId
              : widget.resumeMockId!;
          await api.results(id);
          if (_disposed || !mounted || (_identityLost || actor() != uid)) {
            return;
          }
          // The mock ended while the Quiz tab still showed it as open.
          _leaving = true;
          _refreshAvailability();
          context.pushReplacement('/mock/results/$id');
          return;
        }
      } else {
        try {
          paper = (await api.start(
            examId: widget.examId,
            strict: widget.strictMode,
          ))
              .paper;
        } on ServerMockException catch (refusal) {
          // The server refuses a start for reasons that are normal states, not
          // failures: the Free limit, no paper yet, too few questions. Its
          // status says which. Only that status is trusted, never the wording.
          if (refusal.code != 'failed-precondition') rethrow;
          final notOpen =
              await serverMockNotOpenAfterRefusal(api, widget.examId);
          if (notOpen == null) rethrow;
          throw notOpen;
        }
      }
      final restored = await _restoredIndexes(paper);
      final saved = await ref
          .read(serverMockViewCacheProvider)
          .read(uid: uid, mockId: paper.mockId);
      // The account may have changed while the paper was coming.
      if (_disposed || !mounted) return;
      if (_identityLost || actor() != uid) {
        await _close();
        return;
      }
      final session = ServerMockSession(
        api: ref.read(serverMockApiProvider),
        paper: paper,
        uid: uid,
        currentUid: () => _identityLost ? null : actor(),
        elapsed: ref.read(serverMockElapsedProvider),
        restoredIndexes: restored,
        cursor: saved?.cursor ?? 0,
        flags: saved?.flags ?? const {},
        viewStore: ref.read(serverMockViewCacheProvider),
      )..addListener(_onSession);
      _strict = StrictModeLifecycle(
        strictMode: paper.strict,
        onForfeit: () => unawaited(_leave(ServerMockEndReason.strictExit)),
      );
      _tick = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => _onTick(const Duration(milliseconds: 250)),
      );
      setState(() => _session = session);
      // The server now holds an open mock; the Quiz tab must not say otherwise.
      _refreshAvailability();
    } on Object catch (error, stackTrace) {
      if (!mounted || _disposed) return;
      if (_identityLost || actor() != uid) {
        await _close();
        return;
      }
      if (error is ServerMockNotOpen) {
        // Quiz and setup read the same status; make them read it again.
        _refreshAvailability();
        ref.invalidate(serverMockSetupCountProvider(widget.examId));
      } else {
        unawaited(ref.read(telemetryProvider).recordError(error, stackTrace));
      }
      setState(() => _loadError = error);
    }
  }

  /// A mock reopened from the server shows the choice the student made, so
  /// each answered question is read once to find that choice's position.
  Future<Map<String, int>> _restoredIndexes(ServerMockPaper paper) async {
    final chosen = {
      for (final entry in paper.answers.entries)
        if (entry.value.chosen != null) entry.key: entry.value.chosen!,
    };
    if (chosen.isEmpty) return const {};
    final questions =
        await ref.read(contentRepositoryProvider).questionsByIds(chosen.keys);
    return {
      for (final entry in chosen.entries)
        if (questions[entry.key] != null)
          if (_indexOfChoice(questions[entry.key]!, entry.value) >= 0)
            entry.key: _indexOfChoice(questions[entry.key]!, entry.value),
    };
  }

  static int _indexOfChoice(Question question, String choiceId) =>
      question.choices.indexWhere((choice) => choice.id == choiceId);

  void _onSession() {
    if (!mounted || _disposed) return;
    final session = _session!;
    if (session.stale) {
      unawaited(_close());
      return;
    }
    if (session.submitted && !_finishing) {
      _finishing = true;
      _showResults();
      return;
    }
    setState(() {});
  }

  void _onTick(Duration step) {
    final session = _session;
    if (session == null || !mounted || _disposed) return;
    if (session.stale) {
      _tick?.cancel();
      unawaited(_close());
      return;
    }
    _strict?.elapse(step);
    if (session.byPart) {
      // The server closes a part, never this screen. At zero it is asked what
      // happens next, and the answer is shown.
      session.tick();
    } else if (session.timeIsUp &&
        !_finishing &&
        !session.submissionRequested &&
        !session.paused) {
      unawaited(_leave(ServerMockEndReason.student));
    }
    setState(() {});
  }

  /// Only acknowledged submission opens the authoritative result.
  Future<void> _leave(ServerMockEndReason reason) async {
    final session = _session;
    if (session == null || _finishing || session.submissionRequested) return;
    _finishing = true;
    _terminalReason ??= reason;
    final ok = await session.submit(reason);
    if (ok && mounted) {
      _showResults();
    } else if (mounted) {
      setState(() => _finishing = false);
    }
  }

  void _showResults() {
    final session = _session;
    if (!mounted || _disposed || session == null || session.stale) return;
    _tick?.cancel();
    _leaving = true;
    final paper = session.paper;
    MockFinaleQuestion finaleQuestion(String id) => MockFinaleQuestion(
          id: id,
          outcome: session.answers[id]?.chosen == null
              ? MockFinaleOutcome.blank
              : session.answers[id]!.correct
                  ? MockFinaleOutcome.correct
                  : MockFinaleOutcome.wrong,
        );
    final input = MockFinaleInput(
      reason: _terminalReason == ServerMockEndReason.strictExit
          ? MockSubmitReason.strictBackground
          : session.timeIsUp || session.endedByServer
              ? MockSubmitReason.timeUp
              : MockSubmitReason.manual,
      currentPartIndex: session.partIndex,
      currentQuestionIndex:
          session.byPart ? session.partPosition - 1 : session.cursor,
      parts: session.byPart
          // A paper by part shows its real parts.
          ? [
              for (final section in paper.sections)
                MockFinalePart(
                  name: section.name,
                  questions: [
                    for (final question in section.questions)
                      finaleQuestion(question.id),
                  ],
                ),
            ]
          : [
              MockFinalePart(
                name: serverMockExamName(
                  paper.examId,
                  examName: paper.examName,
                ),
                questions: [
                  for (final id in paper.questionIds) finaleQuestion(id),
                ],
              ),
            ],
    );
    ref
      ..invalidate(serverMockResultProvider(paper.mockId))
      ..invalidate(serverMockHistoryProvider);
    _refreshAvailability();
    context.pushReplacement(
      '/mock/results/${paper.mockId}?fresh=1',
      extra: input,
    );
  }

  Future<void> _close() async {
    if (!mounted) return;
    if (_session?.stale ?? false) {
      // Mask the outgoing route before its navigation transition can retain it.
      setState(() {});
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }
    _leaving = true;
    _refreshAvailability();
    context.go(mockExitLocation);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = _session;
    if (session == null || _finishing) return;
    final now = DateTime.now();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _strict?.paused(now);
      unawaited(session.flush());
      if (!session.strict && state != AppLifecycleState.inactive) {
        unawaited(session.pause());
      }
    } else if (state == AppLifecycleState.resumed) {
      _strict?.resumed(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_identityLost) {
      return const MockSessionSkeleton();
    }
    final error = _loadError;
    if (error is ServerMockNotOpen) {
      return MockNotOpenView(error, onBack: () => context.go(mockExitLocation));
    }
    if (error != null) {
      return Scaffold(
        body: errorFor(
          'mock',
          _load,
          error: error,
        ),
      );
    }
    final session = _session;
    if (session == null) {
      return const MockSessionSkeleton();
    }
    if (session.stale) {
      return const MockSessionSkeleton();
    }
    final paper = session.paper;
    final failure = session.failure;
    final page = session.waiting
        ? _betweenParts(session)
        : session.paused
            ? PausePage(
                paper: _lastPaper,
                partNames: session.byPart
                    ? [for (final section in paper.sections) section.name]
                    : const [''],
                currentPartIndex: session.partIndex,
                remaining: session.remaining,
                partLength: session.partLimit,
                answeredCount: session.answers.length,
                onResume: () => unawaited(session.resume()),
                onDiscard: () async {
                  if (!await session.discard() || !mounted) return;
                  // The server keeps the paper and restarts the clock on
                  // discard, so the clock would run while nobody is here.
                  // Stop it.
                  await session.pause();
                  if (mounted) await _close();
                },
              )
            : (_lastPaper = _paper(session));
    if (failure == null) return page;
    return Stack(
      children: [
        page,
        Positioned(
          left: 16,
          right: 16,
          bottom: 100,
          child: Material(
            color: Colors.transparent,
            child: saveFailureLine(() => unawaited(session.retry())),
          ),
        ),
      ],
    );
  }

  /// A custom exam is named as the Quiz card names it. A listed one keeps its
  /// own title.
  static String _examTitle(ServerMockPaper paper) => paper.examName != null
      ? '${paper.examName} simulation'
      : switch (paper.examId) {
          'exam_cse_pro' => 'CSE Professional simulation',
          'exam_cse_sub' => 'CSE Subprofessional simulation',
          _ => 'Mock exam',
        };

  /// The part that just closed has run out or been ended, and the next one
  /// waits for the student, or for the strict break to end.
  Widget _betweenParts(ServerMockSession session) {
    final sections = session.paper.sections;
    return PartTransitionPage(
      key: ValueKey('part-transition-${session.partIndex}'),
      partNames: [for (final section in sections) section.name],
      nextPartIndex: session.partIndex,
      answeredQuestions: [
        for (final question in sections[session.partIndex - 1].questions)
          session.answers[question.id]?.chosen != null,
      ],
      endedEarly: session.endedEarly,
      onStartNext: () => unawaited(session.startPart()),
      starting: session.startingPart,
      breakRemaining: session.breakRemaining,
      examTitle: _examTitle(session.paper),
    );
  }

  Widget _paper(ServerMockSession session) {
    final paper = session.paper;
    final ids = paper.questionIds;
    final state = MockSessionInProgress(
      attemptId: paper.mockId,
      durationSeconds: paper.limit.inSeconds,
      questionIds: ids,
      currentIndex: session.cursor,
      elapsedSeconds: session.used.inSeconds,
      answers: {
        for (final entry in session.answers.entries)
          if (session.selectedIndexOf(entry.key) != null)
            entry.key: MockAnswer(
              selectedIndex: session.selectedIndexOf(entry.key)!,
              atSec: 0,
            ),
      },
      flags: session.flags,
      strictMode: paper.strict,
    );
    final byPart = session.byPart;
    return MockSessionPage(
      state: state,
      examTitle: _examTitle(paper),
      remainingInPart: session.remaining,
      partLength: session.partLimit,
      partPosition: session.partPosition,
      partTotal: session.partTotal,
      canGoPrevious: session.canGoPrevious,
      canGoNext: session.canGoNext,
      onPrevious: () => session.goTo(session.cursor - 1),
      onNext: () => session.goTo(session.cursor + 1),
      onGoTo: session.goTo,
      onAnswer: (index) => unawaited(_answer(session, index)),
      onToggleFlag: () => session.toggleFlag(ids[session.cursor]),
      onPause: () => unawaited(session.pause()),
      pauseWarningSeen: _pauseWarningSeen,
      onPauseWarningSeenChanged: (seen) {
        setState(() => _pauseWarningSeen = seen);
        unawaited(
          ref
              .read(mockExamPreferencesProvider)
              .setPauseWarningSeen(value: seen),
        );
      },
      oneBlock: !byPart,
      questionSubjects: byPart
          ? const {}
          : {
              for (final id in ids) id: paper.sectionNameOf(id) ?? '',
            },
      onSubmitExam: () => unawaited(_leave(ServerMockEndReason.student)),
      // A paper by part: the part, the parts after it, and how it ends.
      closedPartCount: session.closedPartCount,
      currentPartNumber: session.partNumber,
      partName: byPart ? session.partName : '',
      partNames: byPart
          ? [for (final section in paper.sections) section.name]
          : const [],
      partStarted: session.startedByServer,
      upcomingParts: byPart
          ? [
              for (var i = session.partIndex + 1;
                  i < paper.sections.length;
                  i++)
                MockUpcomingPart(
                  number: i + 1,
                  name: paper.sections[i].name,
                  count: paper.sections[i].questions.length,
                ),
            ]
          : const [],
      onEndPartEarly: byPart ? () => unawaited(_endPart(session)) : null,
    );
  }

  /// Ends the part now. The last part is not ended: the paper is submitted,
  /// as a student's own submission.
  Future<void> _endPart(ServerMockSession session) async {
    if (session.isLastPart) {
      await _leave(ServerMockEndReason.student);
    } else {
      await session.endPart();
    }
  }

  Future<void> _answer(ServerMockSession session, int index) async {
    final id = session.paper.questionIds[session.cursor];
    final hydrated = await ref.read(hydratedMockQuestionProvider(id).future);
    final choices = hydrated?.question.choices;
    if (choices == null || index < 0 || index >= choices.length) return;
    if (!mounted || _disposed || session.stale) return;
    session.answer(
      id,
      chosen: choices[index].id,
      selectedIndex: index,
      correct: choices[index].isCorrect,
    );
  }
}

/// Which screen opens a mock: the server's on the web, the phone's otherwise.
/// One owner is chosen here and nowhere else.
Widget buildMockRunRoute({
  required String examId,
  required String blueprintId,
  required bool strictMode,
  bool? web,
}) =>
    (web ?? kIsWeb)
        ? ServerMockRoute(examId: examId, strictMode: strictMode)
        : MockStartRoute(
            examId: examId,
            blueprintId: blueprintId,
            strictMode: strictMode,
          );
