import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/features/mock_exam/application/mock_session_controller.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/application/strict_mode_lifecycle.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/use_cases/start_mock.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_question_grid.dart';
import 'package:uuid/uuid.dart';

class MockStartRoute extends ConsumerStatefulWidget {
  const MockStartRoute({
    required this.examId,
    required this.blueprintId,
    super.key,
  });

  final String examId;
  final String blueprintId;

  @override
  ConsumerState<MockStartRoute> createState() => _MockStartRouteState();
}

class _MockStartRouteState extends ConsumerState<MockStartRoute>
    with WidgetsBindingObserver {
  MockSessionController? _controller;
  Timer? _timer;
  Stopwatch? _stopwatch;
  StrictModeLifecycle? _strictModeLifecycle;
  String? _errorMessage;
  late MockSample _sample;
  bool _submitting = false;

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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _strictModeLifecycle?.paused();
    } else if (state == AppLifecycleState.resumed) {
      _strictModeLifecycle?.resumed();
    }
  }

  Future<void> _load() async {
    try {
      final parsed = await ref
          .read(mockSetupParsedBlueprintProvider(widget.examId).future);
      if (parsed == null) {
        throw Exception('Blueprint not found');
      }

      final pools =
          await ref.read(mockQuestionPoolsProvider(widget.examId).future);
      final sampler = ref.read(mockSamplerProvider);

      final sample = sampler.sample(
        sections: parsed.sections,
        poolsByTopic: pools.poolsByTopic,
        recentlySampledQuestionIds: const {},
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
          userId: 'local', // Local mock user.
          examId: widget.examId,
          blueprintId: widget.blueprintId,
          blueprintName: parsed.blueprint.name,
          durationMinutes: parsed.blueprint.durationMinutes,
          strictMode: strictMode,
          sample: sample,
          startedAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      _sample = sample;
      final currentAttemptId = attemptId;
      late final MockSessionController controller;
      controller = MockSessionController.initial(
        attemptId: currentAttemptId,
        durationSeconds: parsed.blueprint.durationMinutes * 60,
        questionIds: questionIds,
        parts: parts,
        strictMode: strictMode,
        onWarning: (warning) {
          // Toast or effect handled by UI
        },
        onSubmit: (reason) async {
          if (!mounted || _submitting) return;
          setState(() => _submitting = true);

          _timer?.cancel();
          _stopwatch?.stop();

          try {
            final computeMockResults =
                ref.read(computeMockResultsUseCaseProvider);
            final submitMock = ref.read(submitMockUseCaseProvider);
            final contentRepo = ref.read(contentRepositoryProvider);

            final questionsById = <String, Question>{};
            for (final qId in questionIds) {
              final q = await contentRepo.questionById(qId);
              if (q != null) questionsById[qId] = q;
            }

            final answers = controller.state is MockSessionInProgress
                ? (controller.state as MockSessionInProgress).answers
                : (controller.state as MockSessionSubmitted).snapshot.answers;

            final results = computeMockResults(
              sample: _sample,
              questionsById: questionsById,
              answers: answers,
              totalTimeSeconds: _stopwatch?.elapsed.inSeconds ?? 0,
              wasStrict: strictMode,
              scoreBands: parsed.blueprint.scoreBands,
            );

            await submitMock(
              attemptId: currentAttemptId,
              results: results,
              submittedAt: DateTime.now(),
            );

            if (mounted) {
              context.pushReplacement('/mock/results/$currentAttemptId');
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _errorMessage = e.toString();
                _submitting = false;
              });
            }
          }
        },
        telemetry: ref.read(telemetryProvider),
      );

      _strictModeLifecycle = StrictModeLifecycle(
        strictMode: controller.state is MockSessionInProgress &&
            (controller.state as MockSessionInProgress).strictMode,
        onForfeit: () {
          if (mounted) controller.strictBackgroundExceeded();
        },
      );

      setState(() {
        _controller = controller;
      });

      _stopwatch = Stopwatch()..start();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _controller == null) return;
        _strictModeLifecycle?.elapse(const Duration(seconds: 1));

        final state = _controller!.state;
        if (state is MockSessionInProgress) {
          setState(() {
            _controller!.tickTo(_stopwatch!.elapsed.inSeconds);
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: ErrorBanner(
            message: _errorMessage!,
            variant: ErrorBannerVariant.error,
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
          _stopwatch?.start();
          setState(controller.resume);
        },
        onDiscard: () async {
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
      onPrevious: () => setState(controller.goPrevious),
      onNext: () => setState(controller.goNext),
      onAnswer: (index) => setState(() => controller.answerCurrent(index)),
      onToggleFlag: () => setState(controller.toggleFlag),
      onEndPartEarly: () => setState(controller.endPartEarly),
      currentPartNumber: controller.currentPartIndex + 1,
      onPause: () {
        if (controller.canPause) {
          _stopwatch?.stop();
          setState(controller.pause);
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
