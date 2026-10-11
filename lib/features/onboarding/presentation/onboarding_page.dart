import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_picker_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

enum _OnboardingStep {
  launch,
  welcome,
  ageGate,
  consent,
  picker,
  examDate,
  name
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  _OnboardingStep? _step;
  final Set<_OnboardingStep> _loggedSteps = {};

  void _logStep(_OnboardingStep step) {
    final stepName = switch (step) {
      _OnboardingStep.launch => 'launch',
      _OnboardingStep.welcome => 'welcome',
      _OnboardingStep.ageGate => 'age_gate',
      _OnboardingStep.consent => 'consent',
      _OnboardingStep.picker => 'picker',
      _OnboardingStep.examDate => 'exam_date',
      _OnboardingStep.name => 'name',
    };
    ref.read(telemetryProvider).log(
      TelemetryEvent.onboardingStepReached,
      properties: {'step': stepName},
    );
  }

  void _setStep(_OnboardingStep next) {
    setState(() => _step = next);
  }

  void _back() {
    final previous = switch (_step) {
      _OnboardingStep.ageGate => _OnboardingStep.welcome,
      _OnboardingStep.consent => _OnboardingStep.ageGate,
      _OnboardingStep.picker => _OnboardingStep.consent,
      _OnboardingStep.examDate => _OnboardingStep.picker,
      _OnboardingStep.name => _OnboardingStep.examDate,
      _ => null,
    };
    if (previous != null) _setStep(previous);
  }

  @override
  Widget build(BuildContext context) {
    _step ??= _initialStep();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return PopScope<void>(
      canPop:
          _step == _OnboardingStep.welcome || _step == _OnboardingStep.launch,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: disableAnimations
              ? Duration.zero
              : Duration(
                  milliseconds: _step == _OnboardingStep.welcome ? 300 : 380,
                ),
          reverseDuration: Duration.zero,
          transitionBuilder: (child, animation) {
            final fade = child.key == const ValueKey('welcome') ||
                child.key == const ValueKey('launch');
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

  _OnboardingStep _initialStep() {
    final passed = ref.read(passedAgeGateProvider).valueOrNull ?? false;
    if (!passed) {
      return MediaQuery.disableAnimationsOf(context)
          ? _OnboardingStep.welcome
          : _OnboardingStep.launch;
    }
    final focus = ref.read(activeExamFocusProvider).valueOrNull;
    if (focus?.needsSelection ?? true) return _OnboardingStep.picker;
    // The exam is chosen but onboarding is not complete, or the router would
    // not have sent us here. Resume at the first step that follows it.
    return _OnboardingStep.examDate;
  }

  Widget _buildStep(_OnboardingStep step) {
    if (_loggedSteps.add(step)) _logStep(step);
    switch (step) {
      case _OnboardingStep.launch:
        return OnboardingLaunchStep(
          key: const ValueKey('launch'),
          onCompleted: () => _setStep(_OnboardingStep.welcome),
        );
      case _OnboardingStep.welcome:
        return KeyedSubtree(
          key: const ValueKey('welcome'),
          child: OnboardingWelcomeStep(
            onAdvance: () => _setStep(_OnboardingStep.ageGate),
          ),
        );
      case _OnboardingStep.ageGate:
        return KeyedSubtree(
          key: const ValueKey('ageGate'),
          child: OnboardingAgeGateStep(
            currentYear: DateTime.now().year,
            onBack: _back,
            onAgeGatePassed: () {
              if (_step == _OnboardingStep.ageGate) {
                _setStep(_OnboardingStep.consent);
              }
            },
          ),
        );
      case _OnboardingStep.consent:
        return KeyedSubtree(
          key: const ValueKey('consent'),
          child: OnboardingConsentStep(
            onBack: _back,
            onCompleted: () {
              if (_step == _OnboardingStep.consent) {
                _setStep(_OnboardingStep.picker);
              }
            },
          ),
        );
      case _OnboardingStep.picker:
        return KeyedSubtree(
          key: const ValueKey('picker'),
          child: OnboardingPickerStep(
            onCompleted: () => setState(() => _step = _OnboardingStep.examDate),
          ),
        );
      case _OnboardingStep.examDate:
        return KeyedSubtree(
          key: const ValueKey('examDate'),
          child: OnboardingExamDateStep(
            onCompleted: () => setState(() => _step = _OnboardingStep.name),
          ),
        );
      case _OnboardingStep.name:
        return KeyedSubtree(
          key: const ValueKey('name'),
          child: OnboardingNameStep(
            onCompleted: () {
              // Router redirect handles navigation once the flag is written.
            },
          ),
        );
    }
  }
}
