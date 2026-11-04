import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/dev/local_onboarding_presets.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/domain/age_policy.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

class OnboardingAgeGateStep extends ConsumerStatefulWidget {
  const OnboardingAgeGateStep({
    required this.onAgeGatePassed,
    required this.currentYear,
    this.onGuardianNeeded,
    this.onBack,
    super.key,
  });
  final VoidCallback onAgeGatePassed;

  /// Called for a student under 18. The age gate is not passed yet: a parent
  /// or guardian has to agree first.
  final VoidCallback? onGuardianNeeded;
  final VoidCallback? onBack;
  final int currentYear;
  @override
  ConsumerState<OnboardingAgeGateStep> createState() =>
      _OnboardingAgeGateStepState();
}

class _OnboardingAgeGateStepState extends ConsumerState<OnboardingAgeGateStep> {
  late final List<int> _years =
      List.generate(101, (i) => widget.currentYear - 100 + i);
  late int _selectedYear = takeSeededBirthYear(
        () {
          if (mounted) unawaited(_continue());
        },
      ) ??
      widget.currentYear - 14;
  late final _yearController = TextEditingController(text: '$_selectedYear');
  final _yearFocus = FocusNode();
  @override
  void dispose() {
    _yearFocus.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _changeYear(int delta) {
    setState(() {
      _selectedYear = (_selectedYear + delta)
          .clamp(widget.currentYear - 100, widget.currentYear);
      _yearController.text = '$_selectedYear';
    });
  }

  bool _blocked = false;
  int _blockedMinimum = AgePolicy.forExam(null).minimumAge;
  bool _saving = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreBlock());
    // The board draws the year field focused, so typing and Enter work as soon
    // as the step opens, with no click first. The step's own Continue button
    // also asks for focus when it builds, so this asks once that is done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_blocked && context.wideWeb) _yearFocus.requestFocus();
    });
  }

  /// The block outlasts a reload. Only support clears it.
  Future<void> _restoreBlock() async {
    try {
      final minimum =
          await ref.read(appPreferencesRepositoryProvider).blockedMinimumAge();
      if (minimum != null && mounted) {
        setState(() {
          _blocked = true;
          _blockedMinimum = minimum;
        });
      }
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
    }
  }

  bool get _validYear {
    final year = int.tryParse(_yearController.text);
    return year != null &&
        year >= widget.currentYear - 100 &&
        year <= widget.currentYear;
  }

  Future<void> _continue() async {
    if (_saving || (context.wideWeb && !_validYear)) return;
    final policy = AgePolicy.forExam(null);
    final outcome = policy.evaluate(
      birthYear: _selectedYear,
      currentYear: widget.currentYear,
    );
    final telemetry = ref.read(telemetryProvider);
    final prefs = ref.read(appPreferencesRepositoryProvider);
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      switch (outcome) {
        case AgeOutcome.underMinimum:
          await prefs.setBlockedMinimumAge(policy.minimumAge);
          if (mounted) {
            setState(() {
              _blocked = true;
              _blockedMinimum = policy.minimumAge;
            });
          }
        case AgeOutcome.minor:
          // Only the group is kept, never the birth year.
          await prefs.setAgeGroup('minor');
          ref.invalidate(appPreferencesRepositoryProvider);
          if (mounted) widget.onGuardianNeeded?.call();
        case AgeOutcome.adult:
          await prefs.setAgeGroup('adult');
          await prefs.setPassedAgeGate(value: true);
          ref.invalidate(appPreferencesRepositoryProvider);
          if (mounted) widget.onAgeGatePassed();
      }
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _blockedDetail =>
      "Sorry, this app isn't available for users under $_blockedMinimum.";

  static const _blockedHelp =
      'Entered the wrong year? Email contact@pantas.study.';

  @override
  Widget build(BuildContext context) {
    final back = widget.onBack ?? () => Navigator.of(context).maybePop();
    if (context.wideWeb && _blocked) {
      final t = context.webTokens;
      // Board: 40 top, 120 bottom, so the block sits above center.
      final block = Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 120),
        child: Center(
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.string(
                  '<svg viewBox="0 0 24 24" fill="none" '
                  'stroke="currentColor" stroke-width="1.5" '
                  'stroke-linecap="round" stroke-linejoin="round"> '
                  '<rect x="5" y="10.5" width="14" height="10" '
                  'rx="2"/> '
                  '<path d="M8 10.5V7.5a4 4 0 0 1 8 0v3"/></svg>',
                  width: 44,
                  height: 44,
                  colorFilter: ColorFilter.mode(
                    t.colors.tertiaryLabel,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  "Pantas isn't available yet",
                  textAlign: TextAlign.center,
                  style: t
                      .style(
                        34,
                        weight: FontWeight.w700,
                        height: 1.15,
                      )
                      .copyWith(letterSpacing: -.748),
                ),
                const SizedBox(height: 8),
                Text(
                  _blockedDetail,
                  textAlign: TextAlign.center,
                  style: t.style(
                    17,
                    height: 1.45,
                    color: t.colors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _blockedHelp,
                  textAlign: TextAlign.center,
                  style: t.style(
                    15,
                    height: 1.45,
                    color: t.colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      // The phone's blocked page fades in over 300 ms; so does this block.
      final fading = PantasEffects.fade(
        duration: const Duration(milliseconds: 300),
        builder: (_, progress, child) => IgnorePointer(
          ignoring: progress == 0,
          child: ExcludeFocus(excluding: progress == 0, child: child!),
        ),
        child: block,
      );
      final host = OnboardingFrameScope.hostOf(context);
      // Inside the onboarding frame the top bar is already on screen.
      if (host != null) {
        return OnboardingFrameClaim(
          host: host,
          spec: const OnboardingFrameSpec(bare: true),
          onBack: back,
          child: fading,
        );
      }
      return Material(
        color: t.colors.background,
        child: Column(
          children: [
            const WebTopBar(
              leading: PantasLogo(size: 28),
              title: Text(
                'Pantas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(child: fading),
          ],
        ),
      );
    }
    if (_blocked) {
      final blocked = [
        StateView.onboardingBlocked(
          message: "Pantas isn't available yet",
          detail: _blockedDetail,
          icon: const OnboardingLogo(size: 72),
        ),
        const SizedBox(height: 22),
        Text(
          _blockedHelp,
          textAlign: TextAlign.center,
          style: context.type.subhead.copyWith(
            color: context.colors.secondaryLabel,
          ),
        ),
      ];
      final host = OnboardingFrameScope.hostOf(context);
      // Wide web has no way back from the block (it replaced "Try a Different
      // Year"), so the phone draws no Back either. Only support clears it.
      final page = host != null
          ? OnboardingFrameClaim(
              host: host,
              spec: const OnboardingFrameSpec(
                surfaceBackground: true,
                hideBack: true,
              ),
              onBack: null,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 36)
                          .clamp(0, double.infinity),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: blocked,
                    ),
                  ),
                ),
              ),
            )
          : OnboardingWebPage(
              title: '',
              onBack: back,
              centerBody: true,
              surfaceBackground: true,
              children: blocked,
            );
      return PantasEffects.fade(
        duration: const Duration(milliseconds: 300),
        builder: (_, progress, child) => IgnorePointer(
          ignoring: progress == 0,
          child: ExcludeFocus(excluding: progress == 0, child: child!),
        ),
        child: page,
      );
    }
    final page = OnboardingWebPage(
      title: 'When were you born?',
      detail: 'We only ask this once and never keep it.',
      progress: 1,
      onBack: back,
      bottom: OnboardingButton(
        label: 'Continue',
        onPressed:
            _saving || (context.wideWeb && !_validYear) ? null : _continue,
        busy: _saving,
      ),
      children: [
        if (context.wideWeb) ...[
          Text('YEAR', style: context.webTokens.eb),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 240,
              height: 64,
              child: OnboardingShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                      _changeYear(1),
                  const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                      _changeYear(-1),
                },
                child: TextField(
                  controller: _yearController,
                  focusNode: _yearFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: context.webTokens.style(28, weight: FontWeight.w600),
                  onChanged: (text) => setState(
                    () => _selectedYear =
                        int.tryParse(text) ?? widget.currentYear,
                  ),
                  onSubmitted: (_) {
                    if (int.tryParse(_yearController.text) != null) {
                      _continue();
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.webTokens.colors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.webTokens.colors.accent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.webTokens.colors.accent,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.webTokens.colors.accent,
                        width: 2,
                      ),
                    ),
                    suffixIcon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Next year',
                            onPressed: () => _changeYear(1),
                            icon: const Icon(
                              Icons.keyboard_arrow_up,
                              size: 14,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Earlier year',
                            onPressed: () => _changeYear(-1),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Type it, or use ↑ and ↓.', style: context.webTokens.sm),
        ] else
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ValueWheel.birthYear(
              values: [for (final year in _years) '$year'],
              selectedIndex: _years.indexOf(_selectedYear),
              label: 'Birth year',
              onSelected: (index) =>
                  setState(() => _selectedYear = _years[index]),
            ),
          ),
        if (_failed) saveFailureLine(_continue),
      ],
    );
    return page;
  }
}
