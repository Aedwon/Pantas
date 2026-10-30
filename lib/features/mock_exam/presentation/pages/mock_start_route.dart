import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_persistence_scheduler.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_session_controller.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/application/strict_mode_lifecycle.dart';
import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_snapshot.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/use_cases/start_mock.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_preparation_page.dart';
import 'package:pantas/features/mock_exam/presentation/part_transition_page.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_skeletons.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:uuid/uuid.dart';

/// Where a mock closes to when there is nothing to go back to.
const mockExitLocation = '/quiz';

class MockStartRoute extends ConsumerStatefulWidget {
  const MockStartRoute({
    required this.examId,
    required this.blueprintId,
    this.strictMode = false,
    super.key,
  }) : resumeAttemptId = null;

  const MockStartRoute.resume({
    required this.resumeAttemptId,
    super.key,
  })  : examId = null,
        blueprintId = null,
        strictMode = null;

  final String? examId;
  final String? blueprintId;
  final bool? strictMode;
  final String? resumeAttemptId;

  @override
  ConsumerState<MockStartRoute> createState() => _MockStartRouteState();
}

class _MockStartRouteState extends ConsumerState<MockStartRoute>
    with WidgetsBindingObserver {
  MockSessionController? _controller;
  Widget? _lastPaper;
  MockPersistenceScheduler? _persistenceScheduler;
  MockAttemptRepo? _attemptRepo;
  Timer? _timer;
  Stopwatch? _stopwatch;
  StrictModeLifecycle? _strictModeLifecycle;
  VoidCallback? _retryError;
  String? _recoverableAttemptId;
  late MockSample _sample;
  late String _examId;
  ScoreBands? _scoreBands;
  var _strictMode = false;
  bool _submitting = false;
  Future<void> _flushChain = Future<void>.value();
  Future<void> _lastEnqueuedFlush = Future<void>.value();
  Completer<void>? _partStartFinished;
  var _elapsedBaseSeconds = 0;
  var _accumulatedPausedSeconds = 0;
  DateTime? _pausedAt;
  DateTime? _strictBackgroundedAt;
  MockSessionInProgress? _lastSessionSnapshot;
  ParsedMockBlueprint? _preparedBlueprint;
  MockSample? _preparedSample;
  List<MockSessionPart>? _preparedParts;
  var _startingPaper = false;
  var _startingNextPart = false;
  Map<String, String> _questionSubjects = const {};
  var _pauseWarningSeen = false;

  static const _snapshotCodec = MockSessionSnapshotCodec();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    unawaited(_loadPauseWarningSeen());
  }

  Future<void> _loadPauseWarningSeen() async {
    final seen = await ref.read(mockExamPreferencesProvider).pauseWarningSeen();
    if (mounted) setState(() => _pauseWarningSeen = seen);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _stopwatch?.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_strictMode) _strictBackgroundedAt ??= now;
      _strictModeLifecycle?.paused(now);
      if (_controller != null) {
        // Leaving a paper that is not strict pauses it, and the student
        // finds it paused on return.
        if (state != AppLifecycleState.inactive && _pauseMock()) return;
        if (_controller!.state is MockSessionPaused) _accruePausedTime();
        unawaited(_bestEffortForceFlush());
      }
    } else if (state == AppLifecycleState.resumed) {
      _strictModeLifecycle?.resumed(now);
      _strictBackgroundedAt = null;
      if (_controller != null) {
        if (_controller!.state is MockSessionPaused) _accruePausedTime();
        unawaited(_bestEffortForceFlush());
      }
    }
  }

  Future<void> _load() {
    return widget.resumeAttemptId == null ? _loadFresh() : _loadResume();
  }

  Future<void> _loadFresh() async {
    try {
      final parsed = await ref
          .read(mockSetupParsedBlueprintProvider(widget.examId!).future);
      if (parsed == null) {
        throw Exception('Blueprint not found');
      }
      if (!mounted) return;
      setState(() => _preparedBlueprint = parsed);

      final pools =
          await ref.read(mockQuestionPoolsProvider(widget.examId!).future);
      final sampler = ref.read(mockSamplerProvider);
      final recentIds = await ref
          .read(mockAttemptRepoProvider)
          .recentQuestionIds(mockAttemptLocalUserId, widget.examId!);

      final sample = sampler.sample(
        sections: parsed.sections,
        poolsByTopic: pools.poolsByTopic,
        recentlySampledQuestionIds: recentIds,
        seed: DateTime.now().millisecondsSinceEpoch,
        passageSetsByTopic: pools.passageSetsByTopic,
      );
      final questionIds = [
        for (final section in sample.sections) ...section.questionIds,
      ];
      final parts = _partsFor(parsed, sample, questionIds.length);

      if (!mounted) return;
      setState(() {
        _preparedSample = sample;
        _preparedParts = parts;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      unawaited(ref.read(telemetryProvider).recordError(e, stackTrace));
      if (mounted) {
        setState(() {
          _retryError = () {
            ref
              ..invalidate(mockSetupParsedBlueprintProvider(widget.examId!))
              ..invalidate(mockQuestionPoolsProvider(widget.examId!));
            unawaited(_loadFresh());
          };
        });
      }
    }
  }

  Future<void> _startPreparedMock() async {
    if (_startingPaper) return;
    final parsed = _preparedBlueprint;
    final sample = _preparedSample;
    final parts = _preparedParts;
    if (parsed == null || sample == null || parts == null) return;

    setState(() => _startingPaper = true);
    try {
      final questionIds = [
        for (final section in sample.sections) ...section.questionIds,
      ];
      final attemptId = const Uuid().v4();
      final startMock = ref.read(startMockUseCaseProvider);
      final strictMode = widget.strictMode!;
      final startedAt = DateTime.now();
      final isSectional =
          parsed.blueprint.sectionalTiming == SectionalTiming.sectional;

      await startMock.call(
        MockStartRequest(
          id: attemptId,
          userId: mockAttemptLocalUserId,
          examId: widget.examId!,
          blueprintId: widget.blueprintId!,
          blueprintName: parsed.blueprint.name,
          durationMinutes: parsed.blueprint.durationMinutes,
          strictMode: strictMode,
          sample: sample,
          partsTimedSeparately: isSectional,
          parts: _persistedParts(parts),
          startedAt: startedAt,
        ),
      );

      if (!mounted) return;

      _elapsedBaseSeconds = DateTime.now().difference(startedAt).inSeconds;
      _sample = sample;
      _questionSubjects = _subjectsFor(sample);
      _examId = widget.examId!;
      _scoreBands = parsed.blueprint.scoreBands;
      _strictMode = strictMode;
      final controller = MockSessionController.initial(
        attemptId: attemptId,
        durationSeconds: parsed.blueprint.durationMinutes * 60,
        questionIds: questionIds,
        parts: parts,
        strictMode: strictMode,
        onWarning: (_) {},
        onSubmit: _handleSubmit,
        telemetry: ref.read(telemetryProvider),
      );

      _installController(controller);
    } catch (e, stackTrace) {
      if (!mounted) return;
      unawaited(ref.read(telemetryProvider).recordError(e, stackTrace));
      if (mounted) {
        setState(() {
          _retryError = _startPreparedMock;
          _startingPaper = false;
        });
      }
    }
  }

  Future<void> _loadResume() async {
    try {
      final requestedAttemptId = widget.resumeAttemptId!;
      final resumeNow = DateTime.now();
      final resumed = await ref.read(resumeMockUseCaseProvider)(
        attemptId: requestedAttemptId,
        userId: mockAttemptLocalUserId,
        now: resumeNow,
      );
      final attempt = resumed.attempt;
      if (attempt == null || attempt.id != requestedAttemptId) {
        throw StateError('Mock attempt is no longer available');
      }

      _recoverableAttemptId = attempt.id;
      final restored = _snapshotCodec.decode(
        sampledQuestionsJson: attempt.sampledQuestionsJson,
        answersJson: attempt.answersJson,
        flagsJson: attempt.flagsJson,
      );
      final questionIds = [
        for (final section in restored.sample.sections) ...section.questionIds,
      ];
      final currentBlueprint = await _findCurrentBlueprint(attempt);
      final frozenParts = restored.parts;
      final parts = frozenParts == null
          ? currentBlueprint == null
              ? throw StateError('Saved mock blueprint is no longer available')
              : _partsFor(
                  currentBlueprint,
                  restored.sample,
                  questionIds.length,
                )
          : [
              for (final part in frozenParts)
                MockSessionPart(
                  name: part.name,
                  startIndex: part.startIndex,
                  count: part.count,
                  minutes: part.minutes,
                ),
            ];
      final currentPartIndex = restored.currentPartIndex ??
          _partIndexFor(parts, attempt.currentIndex);

      if (!mounted) return;
      _sample = restored.sample;
      _questionSubjects = _subjectsFor(restored.sample);
      _examId = attempt.examId;
      _scoreBands = currentBlueprint?.blueprint.scoreBands;
      _strictMode = attempt.strictMode;
      _elapsedBaseSeconds = attempt.elapsedSeconds;
      _accumulatedPausedSeconds = attempt.accumulatedPausedSeconds;
      _strictBackgroundedAt = restored.strictBackgroundedAt;
      final controller = MockSessionController.restored(
        attemptId: attempt.id,
        durationSeconds: attempt.durationMinutes * 60,
        questionIds: questionIds,
        currentIndex: attempt.currentIndex,
        elapsedSeconds: attempt.elapsedSeconds,
        answers: restored.answers,
        flags: restored.flags,
        strictMode: attempt.strictMode,
        parts: parts,
        currentPartIndex: currentPartIndex,
        partStartedAtSeconds: restored.partStartedAtSeconds,
        betweenParts: restored.betweenParts,
        endedEarly: restored.endedEarly,
        onWarning: (_) {},
        onSubmit: _handleSubmit,
        telemetry: ref.read(telemetryProvider),
      );
      _recoverableAttemptId = null;
      if (restored.betweenParts) _pausedAt = resumeNow;
      _installController(controller);

      if (_strictForfeitOccurredFirst(
        attempt: attempt,
        backgroundedAt: restored.strictBackgroundedAt,
        now: resumeNow,
        openPart: parts[currentPartIndex],
        partStartedAtSeconds: restored.partStartedAtSeconds,
        atGate: restored.betweenParts,
      )) {
        _strictBackgroundedAt = null;
        scheduleMicrotask(controller.strictBackgroundExceeded);
      } else if (attempt.elapsedSeconds >= attempt.durationMinutes * 60) {
        scheduleMicrotask(
          () => controller.tickTo(attempt.durationMinutes * 60),
        );
      } else if (!restored.betweenParts &&
          controller.remainingInPart <= Duration.zero) {
        // The open part ran out while the app was closed.
        _strictBackgroundedAt = null;
        scheduleMicrotask(() => controller.tickTo(attempt.elapsedSeconds));
      } else if (_strictBackgroundedAt != null) {
        _strictBackgroundedAt = null;
        unawaited(_bestEffortForceFlush());
      }
    } catch (e, stackTrace) {
      final recoverable = await _discardableAttemptId();
      if (!mounted) return;
      unawaited(ref.read(telemetryProvider).recordError(e, stackTrace));
      if (mounted) {
        setState(() {
          _retryError = _loadResume;
          _recoverableAttemptId = recoverable;
        });
      }
    }
  }

  /// A saved mock that cannot be opened stays on the device until it is
  /// discarded. Only the student's own unfinished attempt can be offered.
  Future<String?> _discardableAttemptId() async {
    try {
      final attempt = await ref
          .read(mockAttemptRepoProvider)
          .findById(widget.resumeAttemptId!);
      if (attempt != null &&
          attempt.userId == mockAttemptLocalUserId &&
          attempt.status == MockAttemptStatus.inProgress) {
        return attempt.id;
      }
    } on Object {
      // Without the attempt there is nothing to discard.
    }
    return null;
  }

  /// Strict mode forgives leaving for [StrictModeLifecycle.guardDelay]. If the
  /// open part ran out before that grace ended, the paper was not handed in
  /// by leaving: the part's own end governs. A part that has not started
  /// (the stopped gate) has no end, so the grace alone decides.
  bool _strictForfeitOccurredFirst({
    required MockAttempt attempt,
    required DateTime? backgroundedAt,
    required DateTime now,
    required MockSessionPart openPart,
    required int partStartedAtSeconds,
    required bool atGate,
  }) {
    if (!attempt.strictMode || backgroundedAt == null) return false;
    final forfeitAt = backgroundedAt.add(StrictModeLifecycle.guardDelay);
    if (!now.isAfter(forfeitAt)) return false;
    if (atGate) return true;
    final overall = attempt.durationMinutes * 60;
    final partMinutes = openPart.minutes;
    final deadline = partMinutes == null
        ? overall
        : math.min(overall, partStartedAtSeconds + partMinutes * 60);
    final endsAt = attempt.startedAt.add(
      Duration(seconds: deadline + attempt.accumulatedPausedSeconds),
    );
    return forfeitAt.isBefore(endsAt);
  }

  Future<ParsedMockBlueprint?> _findCurrentBlueprint(
    MockAttempt attempt,
  ) async {
    final setup =
        await ref.read(mockSetupParsedBlueprintProvider(attempt.examId).future);
    if (setup?.blueprint.id == attempt.blueprintId) return setup;
    final result =
        await ref.read(mockBlueprintsForExamProvider(attempt.examId).future);
    for (final candidate in result.blueprints) {
      if (candidate.blueprint.id == attempt.blueprintId) return candidate;
    }
    return null;
  }

  Map<String, String> _subjectsFor(MockSample sample) => {
        for (final section in sample.sections)
          for (final id in section.questionIds) id: section.name,
      };

  List<MockPersistedPart> _persistedParts(List<MockSessionPart> parts) => [
        for (final part in parts)
          MockPersistedPart(
            name: part.name,
            startIndex: part.startIndex,
            count: part.count,
            minutes: part.minutes,
          ),
      ];

  List<MockSessionPart> _partsFor(
    ParsedMockBlueprint parsed,
    MockSample sample,
    int questionCount,
  ) {
    if (parsed.blueprint.sectionalTiming != SectionalTiming.sectional) {
      return [
        MockSessionPart(name: '', startIndex: 0, count: questionCount),
      ];
    }

    final parts = <MockSessionPart>[];
    var startIndex = 0;
    for (final sampledSection in sample.sections) {
      final section = parsed.sections.firstWhere(
        (candidate) => candidate.id == sampledSection.sectionId,
      );
      parts.add(
        MockSessionPart(
          name: section.name,
          startIndex: startIndex,
          count: sampledSection.questionIds.length,
          minutes: section.sectionalMinutes ?? section.suggestedMinutes,
        ),
      );
      startIndex += sampledSection.questionIds.length;
    }
    return parts;
  }

  int _partIndexFor(List<MockSessionPart> parts, int currentIndex) {
    final index = parts.indexWhere((part) => part.contains(currentIndex));
    if (index < 0) throw StateError('Saved mock position is invalid');
    return index;
  }

  void _installController(MockSessionController controller) {
    _attemptRepo ??= ref.read(mockAttemptRepoProvider);
    _lastSessionSnapshot = _sessionSnapshot(controller);
    _strictModeLifecycle = StrictModeLifecycle(
      strictMode: _strictMode,
      onForfeit: controller.strictBackgroundExceeded,
    );
    _persistenceScheduler = MockPersistenceScheduler(onFlush: _enqueueFlush);
    setState(() => _controller = controller);
    _stopwatch = Stopwatch();
    if (controller.state is MockSessionInProgress) _stopwatch!.start();
    const timerStep = Duration(milliseconds: 100);
    _timer = Timer.periodic(timerStep, (_) => _onTimer(timerStep));
  }

  Future<void> _handleSubmit(MockSubmitReason reason) async {
    if (!mounted || _submitting) return;
    setState(() => _submitting = true);
    _timer?.cancel();
    _stopwatch?.stop();

    try {
      final snapshot = _sessionSnapshot(_controller!);
      await _forceFlush();
      final questionsById = await ref.read(
        mockScoringQuestionsProvider(snapshot.attemptId).future,
      );
      final results = ref.read(computeMockResultsUseCaseProvider)(
        examId: _examId,
        sample: _sample,
        questionsById: questionsById,
        answers: snapshot.answers,
        totalTimeSeconds: snapshot.elapsedSeconds,
        wasStrict: _strictMode,
        scoreBands: _scoreBands,
      );
      await ref.read(submitMockUseCaseProvider)(
        attemptId: snapshot.attemptId,
        results: results,
        submittedAt: DateTime.now(),
        status: reason == MockSubmitReason.strictBackground
            ? MockAttemptStatus.forfeited
            : MockAttemptStatus.completed,
      );
      ref.invalidate(mockResultsProvider(snapshot.attemptId));
      // The mock is saved; recording its answers for reviews must never
      // block the results screen. A failure here is healed by
      // MockAnswerRecorder.reconcile before the next plan is built.
      try {
        await ref.read(mockAnswerRecorderProvider).record(snapshot.attemptId);
        ref.read(roadmapRevisionProvider.notifier).bump();
      } on Object catch (error, stackTrace) {
        if (mounted) {
          unawaited(ref.read(telemetryProvider).recordError(error, stackTrace));
        }
      }
      if (mounted) {
        final controller = _controller!;
        final finaleInput = buildMockFinaleInput(
          reason: reason,
          questionIds: snapshot.questionIds,
          partRanges: [
            for (final part in controller.parts)
              (
                name: part.name,
                startIndex: part.startIndex,
                count: part.count,
              ),
          ],
          questionsById: questionsById,
          answers: snapshot.answers,
          currentPartIndex: controller.currentPartIndex,
          currentQuestionIndex: snapshot.currentIndex,
        );
        context.pushReplacement(
          '/mock/results/${snapshot.attemptId}?fresh=1&endedPart=${controller.currentPartIndex + 1}',
          extra: finaleInput,
        );
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      unawaited(ref.read(telemetryProvider).recordError(e, stackTrace));
      if (mounted) {
        setState(() {
          _retryError = () {
            ref.invalidate(
              mockScoringQuestionsProvider(
                _sessionSnapshot(_controller!).attemptId,
              ),
            );
            _handleSubmit(reason);
          };
          _submitting = false;
        });
      }
    }
  }

  void _onTimer(Duration step) {
    if (!mounted || _controller == null) return;
    _strictModeLifecycle?.elapse(step);
    final controller = _controller!;
    if (controller.state is! MockSessionInProgress) return;

    final elapsed = _elapsedBaseSeconds + (_stopwatch?.elapsed.inSeconds ?? 0);
    final current = controller.state as MockSessionInProgress;
    if (elapsed != current.elapsedSeconds) {
      final previousPartIndex = controller.currentPartIndex;
      final previousQuestionIndex = current.currentIndex;
      setState(() => controller.tickTo(elapsed));
      final updated = controller.state;
      if (updated is MockSessionBetweenParts) {
        _partClosed();
      } else if (updated is MockSessionInProgress &&
          (controller.currentPartIndex != previousPartIndex ||
              updated.currentIndex != previousQuestionIndex)) {
        _markChanged();
      }
    }
    if (controller.state is MockSessionInProgress) {
      _persistenceScheduler
        ?..heartbeat(_flushPayload())
        ..elapse(step);
    }
  }

  MockSessionInProgress _sessionSnapshot(MockSessionController controller) {
    final snapshot = switch (controller.state) {
      final MockSessionInProgress state => state,
      final MockSessionPaused state => state.snapshot,
      final MockSessionBetweenParts state => state.snapshot,
      final MockSessionSubmitted state => state.snapshot,
      _ => _lastSessionSnapshot,
    };
    if (snapshot == null) {
      throw StateError('Mock session has no resumable snapshot');
    }
    _lastSessionSnapshot = snapshot;
    return snapshot;
  }

  MockFlushPayload _flushPayload({
    bool? pausedAtLastFlush,
    bool? betweenParts,
  }) {
    final controller = _controller!;
    if (controller.state is MockSessionBetweenParts) _accruePausedTime();
    final snapshot = _sessionSnapshot(controller);
    return MockFlushPayload(
      attemptId: snapshot.attemptId,
      elapsedSeconds: snapshot.elapsedSeconds,
      accumulatedPausedSeconds: _accumulatedPausedSeconds,
      pausedAtLastFlush:
          pausedAtLastFlush ?? controller.state is MockSessionPaused,
      answersJson: _snapshotCodec.encodeAnswers(snapshot.answers),
      flagsJson: _snapshotCodec.encodeFlags(snapshot.flags),
      currentIndex: snapshot.currentIndex,
      currentPartIndex: controller.currentPartIndex,
      partStartedAtSeconds: controller.partStartedAtSeconds,
      strictBackgroundedAt: _strictBackgroundedAt,
      betweenParts: betweenParts ?? controller.state is MockSessionBetweenParts,
      endedEarly: (betweenParts ?? true) &&
          controller.state is MockSessionBetweenParts &&
          (controller.state as MockSessionBetweenParts).endedEarly,
    );
  }

  void _enqueueFlush(MockFlushPayload payload) {
    final attemptRepo = _attemptRepo;
    final write = _flushChain.then((_) async {
      if (attemptRepo == null) {
        throw StateError('Mock progress store is unavailable');
      }
      await attemptRepo.flushProgress(
        attemptId: payload.attemptId,
        elapsedSeconds: payload.elapsedSeconds,
        accumulatedPausedSeconds: payload.accumulatedPausedSeconds,
        pausedAtLastFlush: payload.pausedAtLastFlush,
        answersJson: payload.answersJson,
        flagsJson: payload.flagsJson,
        sampledQuestionsJson: _snapshotCodec.encodeSample(
          _sample,
          currentPartIndex: payload.currentPartIndex,
          partStartedAtSeconds: payload.partStartedAtSeconds,
          partsTimedSeparately:
              _controller!.parts.any((part) => part.minutes != null),
          parts: _persistedParts(_controller!.parts),
          strictBackgroundedAt: payload.strictBackgroundedAt,
          betweenParts: payload.betweenParts,
          endedEarly: payload.endedEarly,
        ),
        currentIndex: payload.currentIndex,
        flushedAt: DateTime.now(),
      );
    });
    _lastEnqueuedFlush = write;
    _flushChain = write.catchError((Object error, StackTrace stackTrace) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Could not save your mock progress.')),
        );
      }
    });
  }

  Future<void> _forceFlush({
    bool? pausedAtLastFlush,
    bool? betweenParts,
    bool startingNextPart = false,
  }) async {
    // A lifecycle checkpoint must observe the acknowledged Start outcome,
    // rather than queue a stale gate snapshot behind that write.
    if (!startingNextPart) await _partStartFinished?.future;
    if (_controller == null || _persistenceScheduler == null) return;
    _persistenceScheduler!.forceFlush(
      _flushPayload(
        pausedAtLastFlush: pausedAtLastFlush,
        betweenParts: betweenParts,
      ),
    );
    // This write's own acknowledgement cannot be replaced by a later success.
    await _lastEnqueuedFlush;
  }

  Future<void> _bestEffortForceFlush({bool? pausedAtLastFlush}) async {
    try {
      await _forceFlush(pausedAtLastFlush: pausedAtLastFlush);
    } catch (_) {
      // The queued flush records and shows the failure.
      // A later heartbeat retries.
    }
  }

  Future<void> _discardCorruptAttempt() async {
    final attemptId = _recoverableAttemptId;
    if (attemptId == null) return;
    try {
      await ref.read(discardMockUseCaseProvider)(
        attemptId: attemptId,
        discardedAt: DateTime.now(),
      );
      if (!mounted) return;
      _leaveMock();
    } catch (error, stackTrace) {
      if (!mounted) return;
      unawaited(ref.read(telemetryProvider).recordError(error, stackTrace));
      setState(() => _retryError = _discardCorruptAttempt);
    }
  }

  /// Closes the mock. A deep link has nothing to pop back to, so it goes to
  /// the Quiz tab, where every mock starts.
  void _leaveMock() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(mockExitLocation);
    }
  }

  /// Stops the clock and saves the paused paper. Returns false when this
  /// paper cannot pause: strict mode never pauses, and a stopped gate or a
  /// paper already paused has nothing to stop.
  bool _pauseMock() {
    final controller = _controller;
    if (controller == null ||
        controller.state is! MockSessionInProgress ||
        !controller.canPause) {
      return false;
    }
    _stopwatch?.stop();
    _pausedAt = DateTime.now();
    setState(controller.pause);
    unawaited(_bestEffortForceFlush(pausedAtLastFlush: true));
    return true;
  }

  void _partClosed() {
    _stopwatch?.stop();
    _pausedAt = DateTime.now();
    unawaited(_bestEffortForceFlush());
  }

  Future<void> _startNextPart() async {
    final controller = _controller;
    if (controller == null ||
        controller.state is! MockSessionBetweenParts ||
        _startingNextPart ||
        _submitting) {
      return;
    }
    _startingNextPart = true;
    final finished = Completer<void>();
    _partStartFinished = finished;
    _accruePausedTime();
    try {
      // Save Start after the gate write, before accepting any new progress.
      await _forceFlush(
        betweenParts: false,
        pausedAtLastFlush: false,
        startingNextPart: true,
      );
      if (!mounted ||
          _submitting ||
          controller.state is! MockSessionBetweenParts) {
        return;
      }
      setState(controller.startNextPart);
      _elapsedBaseSeconds = _sessionSnapshot(controller).elapsedSeconds;
      _stopwatch
        ?..reset()
        ..start();
      _pausedAt = null;
    } catch (_) {
      // The saved transition remains authoritative. Start can be retried.
    } finally {
      _startingNextPart = false;
      _partStartFinished = null;
      finished.complete();
    }
  }

  void _markChanged() {
    _persistenceScheduler?.markChanged(_flushPayload());
  }

  void _accruePausedTime() {
    final pausedAt = _pausedAt;
    if (pausedAt == null) return;
    final now = DateTime.now();
    final elapsed = now.difference(pausedAt).inSeconds;
    if (elapsed > 0) {
      _accumulatedPausedSeconds += elapsed;
      _pausedAt = pausedAt.add(Duration(seconds: elapsed));
    }
  }

  @override
  Widget build(BuildContext context) {
    firstScreenReady(
      context,
      ref,
      ready: _retryError != null ||
          (_controller?.state is MockSessionPaused) ||
          (_controller?.state is MockSessionBetweenParts) ||
          _preparedSample != null,
    );
    if (_retryError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              errorFor('mock', () {
                final retry = _retryError!;
                setState(() => _retryError = null);
                retry();
              }),
              if (_recoverableAttemptId != null)
                TextButton(
                  onPressed: _discardCorruptAttempt,
                  child: const Text('Discard saved mock'),
                ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      final preparedBlueprint = _preparedBlueprint;
      if (widget.resumeAttemptId == null && preparedBlueprint != null) {
        return MockStartPreparationPage(
          parsedBlueprint: preparedBlueprint,
          sample: _preparedSample,
          onStart: _startPreparedMock,
        );
      }
      return const MockSessionSkeleton();
    }

    final state = controller.state;

    if (state is MockSessionBetweenParts) {
      final closed = controller.parts[controller.currentPartIndex - 1];
      final closedIds =
          state.snapshot.questionIds.skip(closed.startIndex).take(closed.count);
      return PartTransitionPage(
        partNames: [for (final part in controller.parts) part.name],
        nextPartIndex: controller.currentPartIndex,
        answeredQuestions: [
          for (final id in closedIds)
            (state.snapshot.answers[id]?.selectedIndex ?? -1) >= 0,
        ],
        endedEarly: state.endedEarly,
        onStartNext: _startNextPart,
      );
    }

    if (state is MockSessionPaused) {
      final openPart = controller.currentPart;
      return PausePage(
        paper: _lastPaper,
        partNames: [for (final part in controller.parts) part.name],
        currentPartIndex: controller.currentPartIndex,
        remaining: controller.remainingInPart,
        partLength: openPart.minutes == null
            ? Duration(seconds: state.snapshot.durationSeconds)
            : Duration(minutes: openPart.minutes!),
        answeredCount: state.snapshot.answers.values
            .where((answer) => answer.selectedIndex >= 0)
            .length,
        onResume: () {
          _accruePausedTime();
          setState(controller.resume);
          _elapsedBaseSeconds = state.snapshot.elapsedSeconds;
          _stopwatch
            ?..reset()
            ..start();
          _pausedAt = null;
          unawaited(_bestEffortForceFlush(pausedAtLastFlush: false));
        },
        onDiscard: () async {
          _accruePausedTime();
          await _forceFlush(pausedAtLastFlush: true);
          final discardMock = ref.read(discardMockUseCaseProvider);
          await discardMock(
            attemptId: state.snapshot.attemptId,
            discardedAt: DateTime.now(),
          );
          if (mounted) _leaveMock();
        },
      );
    }

    if (state is! MockSessionInProgress) {
      return const MockSessionSkeleton();
    }

    return _lastPaper = MockSessionPage(
      state: state,
      remainingInPart: controller.remainingInPart,
      partPosition: state.currentIndex - controller.currentPart.startIndex + 1,
      partTotal: controller.currentPart.count,
      canGoPrevious: controller.canGoPrevious,
      canGoNext: controller.canGoNext,
      onPrevious: () {
        setState(controller.goPrevious);
        _markChanged();
      },
      onNext: () {
        setState(controller.goNext);
        _markChanged();
      },
      onAnswer: (index) {
        setState(() => controller.answerCurrent(index));
        _markChanged();
      },
      onToggleFlag: () {
        setState(controller.toggleFlag);
        _markChanged();
      },
      onEndPartEarly: () {
        setState(controller.endPartEarly);
        if (controller.state is MockSessionBetweenParts) _partClosed();
      },
      currentPartNumber: controller.currentPartIndex + 1,
      onPause: _pauseMock,
      pauseWarningSeen: _pauseWarningSeen,
      onPauseWarningSeenChanged: (seen) {
        setState(() => _pauseWarningSeen = seen);
        unawaited(
          ref
              .read(mockExamPreferencesProvider)
              .setPauseWarningSeen(value: seen),
        );
      },
      closedPartCount: controller.currentPartIndex,
      upcomingParts: [
        for (var i = controller.currentPartIndex + 1;
            i < controller.parts.length;
            i++)
          MockUpcomingPart(
            number: i + 1,
            name: controller.parts[i].name,
            count: controller.parts[i].count,
          ),
      ],
      onGoTo: (index) {
        setState(() => controller.goTo(index));
        _markChanged();
      },
      oneBlock: controller.parts.length == 1,
      partName: controller.currentPart.name,
      questionSubjects: controller.parts.length == 1 ? _questionSubjects : {},
      onSubmitExam: () => setState(controller.submitNow),
    );
  }
}
