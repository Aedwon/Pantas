import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';

final onboardingWebProvider = Provider<bool>((ref) => kIsWeb);

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  OnboardingFlow? _flow;
  String _customName = '';
  String? _customTrackId;
  bool _finishing = false;
  bool _finished = false;
  bool _finishFailed = false;
  Future<void> _finish() async {
    if (_finishing || _finished) return;
    final telemetry = ref.read(telemetryProvider);
    setState(() {
      _finishing = true;
      _finishFailed = false;
    });
    try {
      await ref
          .read(appPreferencesRepositoryProvider)
          .setCompletedOnboarding(value: true);
      if (!mounted) return;
      _finished = true;
      unawaited(
        ref.read(telemetryProvider).log(TelemetryEvent.onboardingCompleted),
      );
      ref
        ..invalidate(appPreferencesRepositoryProvider)
        ..invalidate(onboardingProgressProvider);
      GoRouter.maybeOf(context)?.go('/home');
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _finishFailed = true);
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  OnboardingStep? get _step => _flow?.step;
  final Set<OnboardingStep> _loggedSteps = {};

  void _logStep(OnboardingStep step) {
    final stepName = step.telemetryName;
    ref.read(telemetryProvider).log(
      TelemetryEvent.onboardingStepReached,
      properties: {'step': stepName},
    );
  }

  void _setStep(OnboardingStep next) {
    setState(() => _flow!.reach(next));
  }

  void _back() {
    if (_finishing || _finished) return;
    late final OnboardingStep? previous;
    setState(() => previous = _flow!.back());
    if (previous == OnboardingStep.picker) unawaited(_discardCustomTrack());
  }

  /// Backing out to the picker abandons the custom track this flow created, so
  /// it does not linger in the exam list. One with study data is kept.
  Future<void> _discardCustomTrack() async {
    final id = _customTrackId;
    if (id == null) return;
    _customTrackId = null;
    final telemetry = ref.read(telemetryProvider);
    try {
      final studied =
          await ref.read(attemptsRepositoryProvider).countForExam(id) > 0 ||
              await ref.read(assessmentRepositoryProvider).hasCompletedForExam(
                    id,
                  );
      // A track with study data stays, but this flow lets go of it: the next
      // custom exam must make its own track, not rename or rescope this one.
      if (studied) return;
      await ref.read(customTrackRepositoryProvider).delete(id);
      if (!mounted) return;
      ref
        ..invalidate(examListProvider)
        ..invalidate(activeExamFocusProvider)
        ..invalidate(scopedTopicsProvider)
        ..invalidate(scopedSubjectsProvider);
    } catch (error, stack) {
      _customTrackId ??= id;
      unawaited(telemetry.recordError(error, stack));
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(onboardingProgressProvider);
    if (_flow == null) {
      if (progress.isLoading) return Scaffold(body: loadingFor(progress));
      if (progress.hasError) {
        return Scaffold(
          body: errorFor(
            'progress',
            () => ref.invalidate(onboardingProgressProvider),
          ),
        );
      }
      var first = progress.requireValue.resumeStep;
      if (first == OnboardingStep.welcome &&
          !MediaQuery.disableAnimationsOf(context)) {
        first = OnboardingStep.launch;
      }
      if (first.index >= OnboardingStep.examDate.index &&
          (ref.read(activeExamFocusProvider).valueOrNull?.needsSelection ??
              false)) {
        first = OnboardingStep.picker;
      }
      _flow = OnboardingFlow(first);
    }
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final displayedStep = _step;
    return PopScope<void>(
      canPop: _step == OnboardingStep.welcome || _step == OnboardingStep.launch,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == displayedStep) _back();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: disableAnimations
              ? Duration.zero
              : Duration(
                  milliseconds: _step == OnboardingStep.welcome ||
                          _step == OnboardingStep.picker
                      ? 300
                      : 380,
                ),
          reverseDuration: Duration.zero,
          transitionBuilder: (child, animation) {
            final fade = child.key == const ValueKey('welcome') ||
                child.key == const ValueKey('launch') ||
                child.key == const ValueKey('picker');
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) {
                final progress =
                    (fade ? PantasCurves.ease : PantasCurves.riseIn)
                        .transform(animation.value);
                return ExcludeFocus(
                  excluding: progress == 0,
                  child: ExcludeSemantics(
                    excluding: progress == 0,
                    child: Opacity(
                      opacity: progress,
                      child: Transform.translate(
                        key: const ValueKey('onboarding-incoming-offset'),
                        offset: Offset(fade ? 0 : 40 * (1 - progress), 0),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: _buildStep(_step!),
        ),
      ),
    );
  }

  Widget _buildStep(OnboardingStep step) {
    // Reminders is never shown, so it is not a step a student reached.
    if (step != OnboardingStep.reminders && _loggedSteps.add(step)) {
      _logStep(step);
    }
    switch (step) {
      case OnboardingStep.customName:
        return CustomTrackNameStep(
          key: const ValueKey('customName'),
          initialName: _customName,
          onBack: _back,
          onContinue: (name) {
            _customName = name;
            _setStep(OnboardingStep.customSubjects);
          },
        );
      case OnboardingStep.customSubjects:
        return CustomTrackSubjectsStep(
          key: const ValueKey('customSubjects'),
          name: _customName,
          existingTrackId: _customTrackId,
          onCreated: (id) => _customTrackId = id,
          onBack: _back,
          onCompleted: () {
            if (_step == OnboardingStep.customSubjects) {
              _setStep(OnboardingStep.examDate);
            }
          },
        );
      case OnboardingStep.studyDays:
        return OnboardingStudyDaysStep(
          key: const ValueKey('studyDays'),
          onBack: _back,
          onCompleted: () {
            if (_step == OnboardingStep.studyDays) {
              _setStep(OnboardingStep.name);
            }
          },
        );
      case OnboardingStep.reminders:
        // Native reminders are parked with W4f and excluded from launch, so
        // no platform draws this step. It only finishes what Name started,
        // and also covers a resume after Name was saved but completion was not.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_finishFailed) _finish();
        });
        return _finishFailed
            ? saveFailureLine(_finish)
            : loadingFor(const AsyncLoading<void>());
      case OnboardingStep.launch:
        return OnboardingLaunchStep(
          key: const ValueKey('launch'),
          onCompleted: () => _setStep(OnboardingStep.welcome),
        );
      case OnboardingStep.welcome:
        return KeyedSubtree(
          key: const ValueKey('welcome'),
          child: OnboardingWelcomeStep(
            onAdvance: () => _setStep(OnboardingStep.age),
          ),
        );
      case OnboardingStep.age:
        return KeyedSubtree(
          key: const ValueKey('ageGate'),
          child: OnboardingAgeGateStep(
            currentYear: DateTime.now().year,
            onBack: _back,
            onAgeGatePassed: () {
              if (_step == OnboardingStep.age) {
                _setStep(OnboardingStep.terms);
              }
            },
          ),
        );
      case OnboardingStep.terms:
        return KeyedSubtree(
          key: const ValueKey('consent'),
          child: OnboardingConsentStep(
            onBack: _back,
            onCompleted: () {
              if (_step == OnboardingStep.terms) {
                _setStep(OnboardingStep.picker);
              }
            },
          ),
        );
      case OnboardingStep.picker:
        return KeyedSubtree(
          key: const ValueKey('picker'),
          child: ExamPickerScreen(
            mode: ExamPickerMode.onboarding,
            cseOnly: ref.watch(onboardingWebProvider),
            onCustom: () => _setStep(OnboardingStep.customName),
            onBack: () {
              if (_step == OnboardingStep.picker) _back();
            },
            onPicked: (_) {
              if (_step == OnboardingStep.picker) {
                _setStep(OnboardingStep.examDate);
              }
            },
          ),
        );
      case OnboardingStep.examDate:
        return KeyedSubtree(
          key: const ValueKey('examDate'),
          child: OnboardingExamDateStep(
            onBack: _back,
            onCompleted: () {
              if (_step == OnboardingStep.examDate) {
                _setStep(OnboardingStep.studyDays);
              }
            },
          ),
        );
      case OnboardingStep.name:
        return KeyedSubtree(
          key: const ValueKey('name'),
          child: OnboardingNameStep(
            onBack: _back,
            onCompleted: () {
              if (_step == OnboardingStep.name) {
                _setStep(OnboardingStep.reminders);
              }
            },
          ),
        );
    }
  }
}
