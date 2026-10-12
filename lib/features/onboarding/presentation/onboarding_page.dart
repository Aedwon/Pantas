import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  OnboardingFlow? _flow;
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
    setState(() => _flow!.back());
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
    if (_loggedSteps.add(step)) _logStep(step);
    switch (step) {
      case OnboardingStep.customName:
      case OnboardingStep.customSubjects:
      case OnboardingStep.studyDays:
      case OnboardingStep.reminders:
        // Screen tasks wire these branches; Reminders waits for W4f.
        return const SizedBox.shrink();
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
            onCompleted: () => _setStep(OnboardingStep.name),
          ),
        );
      case OnboardingStep.name:
        return KeyedSubtree(
          key: const ValueKey('name'),
          child: OnboardingNameStep(
            onCompleted: () {
              _setStep(OnboardingStep.reminders);
            },
          ),
        );
    }
  }
}
