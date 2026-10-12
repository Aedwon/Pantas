import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
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
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_question_grid.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:uuid/uuid.dart';

class MockStartRoute extends ConsumerStatefulWidget {
  const MockStartRoute({
    required this.examId,
    required this.blueprintId,
    super.key,
  }) : resumeAttemptId = null;

  const MockStartRoute.resume({
    required this.resumeAttemptId,
    super.key,
  })  : examId = null,
        blueprintId = null;

  final String? examId;
  final String? blueprintId;
  final String? resumeAttemptId;

  @override
  ConsumerState<MockStartRoute> createState() => _MockStartRouteState();
}

class _MockStartRouteState extends ConsumerState<MockStartRoute>
    with WidgetsBindingObserver {
  MockSessionController? _controller;
  MockPersistenceScheduler? _persistenceScheduler;
  MockAttemptRepo? _attemptRepo;
  Timer? _timer;
  Stopwatch? _stopwatch;
  StrictModeLifecycle? _strictModeLifecycle;
  String? _errorMessage;
  String? _recoverableAttemptId;
  late MockSample _sample;
  late String _examId;
  ScoreBands? _scoreBands;
  var _strictMode = false;
  bool _submitting = false;
  Future<void> _flushChain = Future<void>.value();
  Object? _lastFlushError;
  var _elapsedBaseSeconds = 0;
  var _accumulatedPausedSeconds = 0;
  DateTime? _pausedAt;
  DateTime? _strictBackgroundedAt;
  MockSessionInProgress? _lastSessionSnapshot;

  static const _snapshotCodec = MockSessionSnapshotCodec();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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

      final attemptId = const Uuid().v4();
      final startMock = ref.read(startMockUseCaseProvider);
      final strictMode =
          await ref.read(mockExamPreferencesProvider).strictMockMode();

      final isSectional =
          parsed.blueprint.sectionalTiming == SectionalTiming.sectional;
      final parts = <MockSessionPart>[];

      if (isSectional) {
        var startIndex = 0;
        for (final sampledSection in sample.sections) {
          final sectionDef = parsed.sections
              .firstWhere((s) => s.id == sampledSection.sectionId);
          parts.add(
            MockSessionPart(
              name: sectionDef.name,
              startIndex: startIndex,
              count: sampledSection.questionIds.length,
              minutes:
                  sectionDef.sectionalMinutes ?? sectionDef.suggestedMinutes,
            ),
          );
          startIndex += sampledSection.questionIds.length;
        }
      } else {
        parts.add(
          MockSessionPart(
            name: '',
            startIndex: 0,
            count: questionIds.length,
          ),
        );
      }

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
          startedAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      _sample = sample;
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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
        onWarning: (_) {},
        onSubmit: _handleSubmit,
        telemetry: ref.read(telemetryProvider),
      );
      _recoverableAttemptId = null;
      _installController(controller);

      if (_strictForfeitOccurredFirst(
        attempt: attempt,
        backgroundedAt: restored.strictBackgroundedAt,
        now: resumeNow,
      )) {
        _strictBackgroundedAt = null;
        scheduleMicrotask(controller.strictBackgroundExceeded);
      } else if (attempt.elapsedSeconds >= attempt.durationMinutes * 60) {
        scheduleMicrotask(
          () => controller.tickTo(attempt.durationMinutes * 60),
        );
      } else if (_strictBackgroundedAt != null) {
        _strictBackgroundedAt = null;
        unawaited(_bestEffortForceFlush());
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  bool _strictForfeitOccurredFirst({
    required MockAttempt attempt,
    required DateTime? backgroundedAt,
    required DateTime now,
  }) {
    if (!attempt.strictMode || backgroundedAt == null) return false;
    final forfeitAt = backgroundedAt.add(StrictModeLifecycle.guardDelay);
    final expiresAt = attempt.startedAt.add(
      Duration(
        seconds:
            attempt.durationMinutes * 60 + attempt.accumulatedPausedSeconds,
      ),
    );
    return now.isAfter(forfeitAt) && forfeitAt.isBefore(expiresAt);
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
    _stopwatch = Stopwatch()..start();
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
        debugPrint('Mock answers not recorded yet: $error\n$stackTrace');
      }
      if (mounted) {
        context.pushReplacement('/mock/results/${snapshot.attemptId}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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
      if (updated is MockSessionInProgress &&
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
      final MockSessionSubmitted state => state.snapshot,
      _ => _lastSessionSnapshot,
    };
    if (snapshot == null) {
      throw StateError('Mock session has no resumable snapshot');
    }
    _lastSessionSnapshot = snapshot;
    return snapshot;
  }

  MockFlushPayload _flushPayload({bool? pausedAtLastFlush}) {
    final controller = _controller!;
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
    );
  }

  void _enqueueFlush(MockFlushPayload payload) {
    final attemptRepo = _attemptRepo;
    if (attemptRepo == null) {
      _lastFlushError = StateError('Mock progress store is unavailable');
      return;
    }
    _flushChain = _flushChain.then((_) async {
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
        ),
        currentIndex: payload.currentIndex,
        flushedAt: DateTime.now(),
      );
      _lastFlushError = null;
    }).catchError((Object error, StackTrace stackTrace) {
      _lastFlushError = error;
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Could not save your mock progress.')),
        );
      }
    });
  }

  Future<void> _forceFlush({bool? pausedAtLastFlush}) async {
    if (_controller == null || _persistenceScheduler == null) return;
    _persistenceScheduler!.forceFlush(
      _flushPayload(pausedAtLastFlush: pausedAtLastFlush),
    );
    await _flushChain;
    final error = _lastFlushError;
    if (error != null) throw StateError('Could not save mock progress: $error');
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
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
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
    if (elapsed > 0) _accumulatedPausedSeconds += elapsed;
    _pausedAt = now;
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorBanner(
                message: _errorMessage!,
                variant: ErrorBannerVariant.error,
              ),
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
      return const Scaffold(body: Center(child: FaintBars()));
    }

    final state = controller.state;

    if (state is MockSessionPaused) {
      return PausePage(
        partName: controller.currentPart.name,
        remaining: controller.remainingInPart,
        answered: state.snapshot.answers.length,
        total: state.snapshot.questionIds.length,
        flagged: state.snapshot.flags.length,
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
          if (context.mounted) {
            context.pop();
          }
        },
      );
    }

    if (state is! MockSessionInProgress) {
      return const Scaffold(body: Center(child: FaintBars()));
    }

    return MockSessionPage(
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
        _markChanged();
      },
      currentPartNumber: controller.currentPartIndex + 1,
      onLeave: () async {
        try {
          await _forceFlush();
          return true;
        } catch (_) {
          return false;
        }
      },
      onPause: () {
        if (controller.canPause) {
          _stopwatch?.stop();
          _pausedAt = DateTime.now();
          setState(controller.pause);
          unawaited(_bestEffortForceFlush(pausedAtLastFlush: true));
        }
      },
      onShowNavigator: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: MockQuestionGrid(
                  parts: [
                    for (var i = 0; i < controller.parts.length; i++)
                      MockGridPart(
                        name: controller.parts[i].name,
                        startIndex: controller.parts[i].startIndex,
                        count: controller.parts[i].count,
                        isOpen: i == controller.currentPartIndex ||
                            controller.parts.length == 1,
                      ),
                  ],
                  currentIndex: state.currentIndex,
                  answeredIndexes: state.answers.keys
                      .map(state.questionIds.indexOf)
                      .where((i) => i >= 0)
                      .toSet(),
                  flaggedIndexes: state.flags
                      .map(state.questionIds.indexOf)
                      .where((i) => i >= 0)
                      .toSet(),
                  onTap: (index) {
                    Navigator.pop(context);
                    setState(() => controller.goTo(index));
                    _markChanged();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
