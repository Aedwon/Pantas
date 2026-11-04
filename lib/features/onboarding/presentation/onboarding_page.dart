import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/platform/welcome/welcome_handover_providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/onboarding/application/onboarding_browser_back.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_exam_date_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_guardian_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_study_days_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';

final onboardingWebProvider = Provider<bool>((ref) => kIsWeb);

/// The longest Finish waits for the study settings to reach the server.
const _settingsWait = Duration(seconds: 4);

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  OnboardingFlow? _flow;
  final OnboardingFrameController _frame = OnboardingFrameController();
  String _customName = '';
  String? _customTrackId;
  bool _finishing = false;
  bool _finished = false;
  bool _finishFailed = false;

  /// Name was just saved in this visit, so the page keeps showing it while
  /// onboarding closes instead of swapping to an empty loading page.
  bool _afterName = false;
  Future<void> _finish() async {
    if (_finishing || _finished) return;
    final telemetry = ref.read(telemetryProvider);
    setState(() {
      _finishing = true;
      _finishFailed = false;
    });
    try {
      final publish = await ref.read(studySettingsCaptureProvider)();
      await publish.apply(
        () => ref
            .read(appPreferencesRepositoryProvider)
            .setCompletedOnboarding(value: true),
      );
      // On web, Home reads the plan from the server as soon as it opens. The
      // settings are still on their way, so a read that beat them failed and
      // showed "Could not load your plan" until they landed. Waiting here,
      // bounded so a student who is offline is not held, lets Home open on a
      // plan that can be built.
      if (ref.read(studyUsesServerProvider)) {
        await ref
            .read(studyWritesProvider)
            .settingsSettled
            .timeout(_settingsWait, onTimeout: () {});
      }
      if (!mounted) return;
      _finished = true;
      ref.read(studyNeedsExamSettingsProvider.notifier).state = false;
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

  OnboardingBrowserBack? _browserBack;

  @override
  void initState() {
    super.initState();
    // The browser's Back and Forward cannot change the step, because every
    // step shares one address. The router reports them here instead, and Back
    // goes to the previous step like the page's own Back. Web only: the phone
    // app has no browser history.
    if (ref.read(onboardingWebProvider)) {
      final guard = ref.read(onboardingBrowserBackProvider)
        ..handler = _onBrowserBack;
      _browserBack = guard;
    }
  }

  void _onBrowserBack() {
    if (mounted) _back();
  }

  @override
  void dispose() {
    _browserBack?.detach(_onBrowserBack);
    _frame.dispose();
    super.dispose();
  }

  /// Screens that draw their whole page, with no top bar, steps list, Back or
  /// progress around them: Welcome, Launch and the save-and-finish screen.
  /// Every other step keeps the frame on screen and changes only its content.
  bool _framed(OnboardingStep step) => step == OnboardingStep.reminders
      ? _afterName && !_finishFailed
      : step != OnboardingStep.welcome && step != OnboardingStep.launch;

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
        firstScreenReady(context, ref);
        return Scaffold(
          body: errorFor(
            'progress',
            () => ref.invalidate(onboardingProgressProvider),
          ),
        );
      }
      var first = ref.read(studyNeedsExamSettingsProvider)
          ? OnboardingStep.picker
          : progress.requireValue.resumeStep;
      final handover = ref.read(welcomeHandoverProvider);
      if (handover.shownThisVisit) {
        // The HTML Welcome screen covers the app until the learner taps Get
        // Started, so Launch and Welcome are not drawn a second time.
        if (first == OnboardingStep.welcome) {
          first = OnboardingStep.age;
          _loggedSteps.add(OnboardingStep.welcome);
          _logStep(OnboardingStep.welcome);
        }
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => handover.appReady(holdForTap: true),
        );
      } else if (first == OnboardingStep.welcome &&
          !MediaQuery.disableAnimationsOf(context) &&
          !context.wideWeb &&
          // The splash already played the logo. Launch would play it again
          // under the splash as it fades (4P-2).
          !pageBeganFromSplash()) {
        first = OnboardingStep.launch;
      }
      if (first.index >= OnboardingStep.examDate.index &&
          (ref.read(activeExamFocusProvider).valueOrNull?.needsSelection ??
              false)) {
        first = OnboardingStep.picker;
      }
      _flow = OnboardingFlow(first);
    }
    firstScreenReady(
      context,
      ref,
      ready: _step != OnboardingStep.picker &&
          _step != OnboardingStep.customSubjects,
    );
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final displayedStep = _step;
    return PopScope<void>(
      canPop: _step == OnboardingStep.welcome || _step == OnboardingStep.launch,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == displayedStep) _back();
      },
      child: Scaffold(
        body: OnboardingFrame(
          controller: _frame,
          enabled: _framed(_step!),
          resetToken: _step!,
          child: AnimatedSwitcher(
            // Content only: the frame around it does not move.
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.passthrough,
              alignment: Alignment.topLeft,
              children: [...previous, if (current != null) current],
            ),
            duration: disableAnimations
                ? Duration.zero
                : Duration(
                    milliseconds: _step == OnboardingStep.welcome ? 300 : 380,
                  ),
            reverseDuration: Duration.zero,
            transitionBuilder: (child, animation) {
              // Only the screens before the framed steps fade. Every framed
              // step, the picker included, slides in the same way.
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
        if (_afterName && !_finishFailed) {
          return KeyedSubtree(
            key: const ValueKey('name'),
            child: OnboardingNameStep(
              finishing: true,
              onCompleted: () {},
            ),
          );
        }
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
            onGuardianNeeded: () {
              if (_step == OnboardingStep.age) {
                _setStep(OnboardingStep.guardian);
              }
            },
          ),
        );
      case OnboardingStep.guardian:
        return KeyedSubtree(
          key: const ValueKey('guardian'),
          child: OnboardingGuardianStep(
            onBack: _back,
            // The link is on its way. The router holds the student on the
            // Waiting screen until a guardian confirms.
            onSent: () {
              if (_step == OnboardingStep.guardian) {
                GoRouter.maybeOf(context)?.go('/guardian/waiting');
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
                _afterName = true;
                _setStep(OnboardingStep.reminders);
              }
            },
          ),
        );
    }
  }
}
