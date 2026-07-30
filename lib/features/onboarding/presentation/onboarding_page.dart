import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_picker_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _OnboardingStep { welcome, ageGate, picker, examDate, name }

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  _OnboardingStep? _step;

  void _logStep(_OnboardingStep step) {
    final stepName = switch (step) {
      _OnboardingStep.welcome => 'welcome',
      _OnboardingStep.ageGate => 'age_gate',
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

  @override
  Widget build(BuildContext context) {
    _step ??= _initialStep();
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _buildStep(_step!),
      ),
    );
  }

  _OnboardingStep _initialStep() {
    final passed = ref.read(passedAgeGateProvider).valueOrNull ?? false;
    if (!passed) return _OnboardingStep.welcome;
    final focus = ref.read(activeExamFocusProvider).valueOrNull;
    if (focus?.needsSelection ?? true) return _OnboardingStep.picker;
    // The exam is chosen but onboarding is not complete, or the router would
    // not have sent us here. Resume at the first step that follows it.
    return _OnboardingStep.examDate;
  }

  Widget _buildStep(_OnboardingStep step) {
    _logStep(step);
    switch (step) {
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
            onAgeGatePassed: () => _setStep(_OnboardingStep.picker),
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
