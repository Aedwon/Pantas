import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_session.dart';
import 'package:pantas/features/mock_exam/application/strict_mode_lifecycle.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';

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
    super.key,
  });

  final String examId;
  final bool strictMode;

  @override
  ConsumerState<ServerMockRoute> createState() => _ServerMockRouteState();
}

class _ServerMockRouteState extends ConsumerState<ServerMockRoute>
    with WidgetsBindingObserver {
  ServerMockSession? _session;
  Object? _loadError;
  Timer? _tick;
  StrictModeLifecycle? _strict;
  var _pauseWarningSeen = false;
  var _finishing = false;
  var _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    unawaited(_loadPauseWarning());
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _session
      ?..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadPauseWarning() async {
    final seen = await ref.read(mockExamPreferencesProvider).pauseWarningSeen();
    if (mounted) setState(() => _pauseWarningSeen = seen);
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    final actor = ref.read(serverMockActorProvider);
    final uid = actor();
    try {
      if (uid == null) throw const ServerMockException(code: 'unauthenticated');
      final started = await ref.read(serverMockApiProvider).start(
            examId: widget.examId,
            strict: widget.strictMode,
          );
      final paper = started.paper;
      final restored = await _restoredIndexes(paper);
      final saved = await ref
          .read(serverMockViewCacheProvider)
          .read(uid: uid, mockId: paper.mockId);
      // The account may have changed while the paper was coming.
      if (_disposed || !mounted || actor() != uid) return;
      final session = ServerMockSession(
        api: ref.read(serverMockApiProvider),
        paper: paper,
        uid: uid,
        currentUid: actor,
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
    } on Object catch (error) {
      if (mounted && !_disposed) setState(() => _loadError = error);
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
      unawaited(_close());
      return;
    }
    setState(() {});
  }

  void _onTick(Duration step) {
    final session = _session;
    if (session == null || !mounted || _disposed) return;
    _strict?.elapse(step);
    if (session.timeIsUp && !_finishing && !session.paused) {
      unawaited(_leave(ServerMockEndReason.student));
    }
    setState(() {});
  }

  /// Submits and closes. The result screens wait for the server's reader of
  /// completed mocks, so the student returns to the Quiz tab for now.
  Future<void> _leave(ServerMockEndReason reason) async {
    final session = _session;
    if (session == null || _finishing) return;
    final ok = await session.submit(reason);
    if (ok && mounted) {
      _finishing = true;
      await _close();
    }
  }

  Future<void> _close() async {
    if (!mounted) return;
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
    final error = _loadError;
    if (error != null) {
      return Scaffold(
        body: errorFor(
          'mock',
          _load,
          error: error,
          message: error is ServerMockException &&
                  error.code == 'failed-precondition'
              ? error.message
              : null,
        ),
      );
    }
    final session = _session;
    if (session == null) {
      return const Scaffold(body: Center(child: FaintBars()));
    }
    final paper = session.paper;
    final failure = session.failure;
    final page = session.paused
        ? PausePage(
            partNames: const [''],
            currentPartIndex: 0,
            remaining: session.remaining,
            partLength: paper.limit,
            answeredCount: session.answers.length,
            onResume: () => unawaited(session.resume()),
            onDiscard: () async {
              if (await session.discard() && mounted) await _close();
            },
          )
        : _paper(session);
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
    return MockSessionPage(
      state: state,
      remainingInPart: session.remaining,
      partLength: paper.limit,
      partPosition: session.cursor + 1,
      partTotal: ids.length,
      canGoPrevious: session.cursor > 0,
      canGoNext: session.cursor < ids.length - 1,
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
      oneBlock: true,
      questionSubjects: {
        for (final id in ids) id: paper.sectionNameOf(id) ?? '',
      },
      onSubmitExam: () => unawaited(_leave(ServerMockEndReason.student)),
    );
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
