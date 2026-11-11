import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/dev/local_onboarding_presets.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/hold_to_repeat.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
// ds-raw: bare age numeral field and icon-only step buttons
import 'package:pantas/core/ui/raw_controls.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/domain/age_policy.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

/// Wide web: the blocked page keeps this much below its block, so the block
/// sits above the center (board OB_Age_Blocked).
const double _blockedBottom = 120;

// ds-board: Aedwon Idea 3 note, Nov 10. Three taps, each within 1.5 s of the
// last, show the "Hold + or − to go faster." tip.
const Duration _tapWindow = Duration(milliseconds: 1500);

// ds-board: Aedwon Idea 3 note, Nov 10. A step slides the new number in by 45%
// of its height, from the side it came from.
const double _rollSlide = .45;

// ds-board: Aedwon Idea 3 note, Nov 10. Under reduced motion the number fades
// in from 40% and does not slide.
const double _rollFadeFrom = .4;

const int _minAge = 5;
const int _maxAge = 100;
const int _startAge = 17;
const int _quickTaps = 3;
const int _pageStep = 10;

bool _inRange(int age) => age >= _minAge && age <= _maxAge;

class OnboardingAgeGateStep extends ConsumerStatefulWidget {
  const OnboardingAgeGateStep({
    required this.onAgeGatePassed,
    this.onGuardianNeeded,
    this.onBack,
    this.recheck = false,
    super.key,
  });
  final VoidCallback onAgeGatePassed;

  /// Called for a student under 18. The age gate is not passed yet: a parent
  /// or guardian has to agree first.
  final VoidCallback? onGuardianNeeded;
  final VoidCallback? onBack;

  /// Settings, "I'm 18 now": the same age check for a student already marked
  /// under 18. An adult result tells the server and then calls
  /// [onAgeGatePassed]. Any other result changes nothing.
  final bool recheck;
  @override
  ConsumerState<OnboardingAgeGateStep> createState() =>
      _OnboardingAgeGateStepState();
}

class _OnboardingAgeGateStepState extends ConsumerState<OnboardingAgeGateStep>
    with SingleTickerProviderStateMixin {
  late int _age = takeSeededAge(
        () {
          if (mounted) unawaited(_continue());
        },
      ) ??
      _rememberedAge ??
      _startAge;

  /// The age chosen earlier in this visit, when it is still a valid choice.
  int? get _rememberedAge {
    final age = ref.read(onboardingAgeProvider);
    return age != null && _inRange(age) ? age : null;
  }

  late final _controller = TextEditingController(text: '$_age');
  final _focus = FocusNode();

  /// Rolls the number on each step: 0 is just changed, 1 is settled.
  late final AnimationController _roll = AnimationController(
    vsync: this,
    duration: PantasDurations.short3,
    value: 1,
  );

  /// 1 when the last step went up, -1 when it went down.
  int _rollDirection = 1;

  int _quickTapCount = 0;
  Timer? _tapTimer;
  bool _tipShown = false;

  @override
  void dispose() {
    _tapTimer?.cancel();
    _roll.dispose();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  int? get _typed => int.tryParse(_controller.text);
  bool get _valid => _typed != null && _inRange(_typed!);

  /// Shown for any typed number outside the range. An empty field shows
  /// nothing but still turns Continue off.
  bool get _outOfRange => _controller.text.isNotEmpty && !_valid;

  /// Moves the age to [target], kept inside the range, and rolls the number.
  /// Returns false, and changes nothing, when it is already there, which also
  /// stops a held button.
  bool _moveTo(int target) {
    final next = target.clamp(_minAge, _maxAge);
    if (next == _age && _controller.text == '$next') return false;
    setState(() {
      _rollDirection = next >= _age ? 1 : -1;
      _age = next;
      _controller.value = TextEditingValue(
        text: '$next',
        selection: TextSelection.collapsed(offset: '$next'.length),
      );
    });
    unawaited(_roll.forward(from: 0));
    unawaited(HapticFeedback.lightImpact());
    return true;
  }

  bool _step(int delta) => _moveTo(_age + delta);

  void _typedChanged(String text) {
    setState(() {
      final age = int.tryParse(text);
      if (age != null && _inRange(age)) _age = age;
    });
  }

  /// A tap counts toward the tip; a hold clears it.
  void _released({required bool wasHold}) {
    if (wasHold) {
      _tapTimer?.cancel();
      _quickTapCount = 0;
      if (_tipShown) setState(() => _tipShown = false);
      return;
    }
    _quickTapCount++;
    _tapTimer?.cancel();
    _tapTimer = Timer(_tapWindow, () => _quickTapCount = 0);
    if (_quickTapCount >= _quickTaps && !_tipShown) {
      setState(() => _tipShown = true);
    }
  }

  bool _blocked = false;
  int _blockedMinimum = AgePolicy.forExam(null).minimumAge;
  bool _saving = false;
  bool _failed = false;
  bool _stillMinor = false;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreBlock());
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

  Future<void> _continue() async {
    if (_saving || !_valid) return;
    final age = _typed!;
    final policy = AgePolicy.forExam(null);
    // Memory only, so Back from the next step shows the same age. A recheck
    // is not part of onboarding, so it writes nothing there.
    if (!widget.recheck) {
      ref.read(onboardingAgeProvider.notifier).state = age;
    }
    final outcome = policy.evaluateAge(age);
    final telemetry = ref.read(telemetryProvider);
    final prefs = ref.read(appPreferencesRepositoryProvider);
    setState(() {
      _age = age;
      _saving = true;
      _failed = false;
      _stillMinor = false;
    });
    try {
      if (widget.recheck) {
        if (outcome != AgeOutcome.adult) {
          if (mounted) setState(() => _stillMinor = true);
          return;
        }
        // The server first, so a failure leaves the student a minor here too.
        await ref.read(guardianGatewayProvider).markAdult();
        await prefs.setAgeGroup('adult');
        await prefs.setAgeCheckNoticeVersion(AgePolicy.ageCheckNoticeVersion);
        await prefs.setPassedAgeGate(value: true);
        ref.invalidate(appPreferencesRepositoryProvider);
        if (mounted) widget.onAgeGatePassed();
        return;
      }
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
          // Only the group is kept, never the age.
          await prefs.setAgeGroup('minor');
          await prefs.setAgeCheckNoticeVersion(AgePolicy.ageCheckNoticeVersion);
          ref.invalidate(appPreferencesRepositoryProvider);
          if (mounted) widget.onGuardianNeeded?.call();
        case AgeOutcome.adult:
          await prefs.setAgeGroup('adult');
          await prefs.setAgeCheckNoticeVersion(AgePolicy.ageCheckNoticeVersion);
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

  static const _ageCheckLine = 'Pantas uses your age once, on this device, '
      'to set your age group. We do not save your age. '
      'Choosing Continue means you agree to this check.';

  static const _stillMinorLine = 'You are still under 18.';

  static const _blockedHelp =
      'Entered the wrong age? Email support@pantas.study.';

  @override
  Widget build(BuildContext context) {
    final back = widget.onBack ?? () => Navigator.of(context).maybePop();
    if (context.wideWeb && _blocked) {
      final t = context.webTokens;
      // Board: 40 top, 120 bottom, so the block sits above center.
      final block = Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s40,
          PantasSpace.s40,
          PantasSpace.s40,
          _blockedBottom,
        ),
        child: Center(
          child: SizedBox(
            width: PantasLayout.modal,
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
                  width: PantasSize.avatarLg,
                  height: PantasSize.avatarLg,
                  colorFilter: ColorFilter.mode(
                    t.colors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: PantasSpace.s20),
                Text(
                  "Pantas isn't available yet",
                  textAlign: TextAlign.center,
                  style: t.h1,
                ),
                const SizedBox(height: PantasSpace.s8),
                Text(
                  _blockedDetail,
                  textAlign: TextAlign.center,
                  style: PantasType.webLead
                      .copyWith(color: t.colors.textSecondary),
                ),
                const SizedBox(height: PantasSpace.s20),
                Text(
                  _blockedHelp,
                  textAlign: TextAlign.center,
                  style:
                      PantasType.webSub.copyWith(color: t.colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
      // The phone's blocked page fades in over 300 ms; so does this block.
      final fading = PantasEffects.fade(
        duration: PantasDurations.flip,
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
            const OnboardingTopBar(logoInset: false),
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
        const SizedBox(height: PantasSpace.s20),
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
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s4,
                    PantasSpace.s16,
                    PantasSpace.s32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - PantasSpace.s32)
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
        duration: PantasDurations.flip,
        builder: (_, progress, child) => IgnorePointer(
          ignoring: progress == 0,
          child: ExcludeFocus(excluding: progress == 0, child: child!),
        ),
        child: page,
      );
    }
    // Stepper not in DS4: built from DS4 parts (secondary Button, the display
    // type, the focus ring, KeyHint).
    final wide = context.wideWeb;
    return OnboardingWebPage(
      title: 'How old are you?',
      detail: widget.recheck
          ? 'We do not save the age you enter.'
          : 'We only ask this once and never keep it.',
      progress: 1,
      // On a phone the keyboard waits for a tap on the number.
      focusTarget: wide ? _focus : null,
      onBack: back,
      bottom: OnboardingButton(
        label: 'Continue',
        onPressed: _saving || !_valid ? null : _continue,
        busy: _saving,
      ),
      children: [
        Text(
          _ageCheckLine,
          textAlign: TextAlign.center,
          style: wide
              ? context.webTokens.sm
              : context.type.subhead
                  .copyWith(color: context.colors.secondaryLabel),
        ),
        if (wide) ..._wideBody(context) else ..._phoneBody(context),
        if (_stillMinor)
          Padding(
            padding: const EdgeInsets.only(top: PantasSpace.s12),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _stillMinorLine,
                textAlign: TextAlign.center,
                style: wide
                    ? context.webTokens.sm
                        .copyWith(color: context.webTokens.colors.dangerText)
                    : context.type.subhead
                        .copyWith(color: context.colors.secondaryLabel),
              ),
            ),
          ),
        if (_failed) saveFailureLine(_continue),
      ],
    );
  }

  List<Widget> _phoneBody(BuildContext context) => [
        const SizedBox(height: PantasSpace.s32),
        Center(child: _number(context, wide: false)),
        const SizedBox(height: PantasSpace.s12),
        _statusLine(context, wide: false),
        const SizedBox(height: PantasSpace.s24),
        Row(
          children: [
            Expanded(child: _stepButton(context, up: false, wide: false)),
            const SizedBox(width: PantasSpace.s12),
            Expanded(child: _stepButton(context, up: true, wide: false)),
          ],
        ),
      ];

  List<Widget> _wideBody(BuildContext context) => [
        Row(
          children: [
            _stepButton(context, up: false, wide: true),
            const SizedBox(width: PantasSpace.s16),
            Expanded(child: Center(child: _number(context, wide: true))),
            const SizedBox(width: PantasSpace.s16),
            _stepButton(context, up: true, wide: true),
          ],
        ),
        const SizedBox(height: PantasSpace.s16),
        // Key hints wait for the first hardware key press (KeyHint README);
        // the line keeps its room so nothing moves when they appear.
        Visibility(
          visible: WebKeyboardHints.visibleOf(context),
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: PantasSpace.s6,
            runSpacing: PantasSpace.s6,
            children: [
              Text('Type it, or use', style: context.webTokens.sm),
              const WebKeyHint('\u2191'),
              const WebKeyHint('\u2193'),
            ],
          ),
        ),
        const SizedBox(height: PantasSpace.s8),
        _statusLine(context, wide: true),
      ];

  /// The tip or the range message. The line always has its height, so
  /// Continue does not move when it comes and goes.
  Widget _statusLine(BuildContext context, {required bool wide}) {
    final colors = context.colors;
    final base = wide
        ? context.webTokens.sm
        : context.type.footnote.copyWith(color: colors.secondaryLabel);
    // The line keeps the height of one line of the error type, so Continue
    // does not move when the tip or the error comes and goes.
    final line =
        MediaQuery.textScalerOf(context).scale(PantasType.webSmall.fontSize!) *
            PantasType.webSmall.height!;
    final Widget content;
    if (_outOfRange) {
      content = const Center(
        child: PantasFieldMessage(
          'Enter an age from $_minAge to $_maxAge.',
          error: true,
        ),
      );
    } else {
      content = Text(
        _tipShown ? 'Hold + or \u2212 to go faster.' : '',
        textAlign: TextAlign.center,
        style: base,
      );
    }
    return Semantics(
      liveRegion: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: line),
        child: content,
      ),
    );
  }

  /// The age as one large number you can type into.
  Widget _number(BuildContext context, {required bool wide}) {
    final colors = context.colors;
    final style = (wide ? PantasType.webDisplay : PantasType.phoneDisplayL)
        .copyWith(color: colors.textPrimary);
    final scaler = MediaQuery.textScalerOf(context);
    // Three digits wide, as the board sizes it (3ch), plus room for the caret.
    double digitsWidth(TextScaler scale) {
      final painter = TextPainter(
        text: TextSpan(text: '000', style: style),
        textDirection: TextDirection.ltr,
        textScaler: scale,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    const radius = BorderRadius.all(Radius.circular(PantasRadius.md));
    final reduced = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // At a large text size the number stops growing once it fills the row.
        final room = constraints.maxWidth - PantasSpace.s8;
        final natural = digitsWidth(TextScaler.noScaling);
        final fit = natural <= 0 ? 1.0 : room / natural;
        final capped = fit.isFinite && fit < scaler.scale(1)
            ? TextScaler.linear(fit)
            : scaler;
        final width = digitsWidth(capped) + PantasSpace.s8;
        final field = OnboardingShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowUp): () => _step(1),
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                _step(-1),
            const SingleActivator(LogicalKeyboardKey.pageUp): () =>
                _step(_pageStep),
            const SingleActivator(LogicalKeyboardKey.pageDown): () =>
                _step(-_pageStep),
            const SingleActivator(LogicalKeyboardKey.home): () =>
                _moveTo(_minAge),
            const SingleActivator(LogicalKeyboardKey.end): () =>
                _moveTo(_maxAge),
          },
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: capped),
            // Flutter 3.44 cannot name the spinbutton role (its debug checks
            // reject it), and increase/decrease actions would turn a web text
            // field into a range input. So the number carries its name and
            // range, and the step buttons carry the changes.
            child: Semantics(
              label: 'Age',
              minValue: '$_minAge',
              maxValue: '$_maxAge',
              child: TextField(
                // ds-raw: bare age numeral, no label or well (board Idea 3)
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                textAlign: TextAlign.center,
                style: style,
                onChanged: _typedChanged,
                onSubmitted: (_) {
                  if (_valid) unawaited(_continue());
                },
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: PantasSpace.s4,
                    vertical: wide ? PantasSpace.s8 : PantasSpace.s0,
                  ),
                ),
              ),
            ),
          ),
        );
        return OffsetFocusRing(
          borderRadius: radius,
          child: ClipRRect(
            borderRadius: radius,
            child: SizedBox(
              key: const ValueKey('age-roll'),
              width: width,
              child: AnimatedBuilder(
                animation: _roll,
                child: field,
                builder: (context, child) {
                  final t = PantasCurves.move.transform(_roll.value);
                  return Opacity(
                    opacity:
                        reduced ? _rollFadeFrom + (1 - _rollFadeFrom) * t : t,
                    child: FractionalTranslation(
                      translation: reduced
                          ? Offset.zero
                          : Offset(0, _rollDirection * _rollSlide * (1 - t)),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// A DS4 secondary Button with an icon only: 52 tall and full width on a
  /// phone, 44 by 44 on wide web. It steps on press and keeps stepping while
  /// held.
  Widget _stepButton(
    BuildContext context, {
    required bool up,
    required bool wide,
  }) {
    final atLimit = up ? _age >= _maxAge && _valid : _age <= _minAge && _valid;
    return HoldToRepeat(
      key: ValueKey(up ? 'age-plus' : 'age-minus'),
      onStep: () => _step(up ? 1 : -1),
      onReleased: _released,
      builder: (context, onPressed) => _StepGlyphButton(
        label: up ? '1 year older' : '1 year younger',
        icon: up ? PantasIcons.plus : PantasIcons.minus,
        wide: wide,
        onPressed: atLimit ? null : onPressed,
      ),
    );
  }
}

/// The face of a step button: the secondary kind of the design system's
/// Button, with the glyph centered and the system's press, hover and focus.
class _StepGlyphButton extends StatelessWidget {
  const _StepGlyphButton({
    required this.label,
    required this.icon,
    required this.wide,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final bool wide;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final metrics = pantasButtonMetrics(
      wide ? PantasButtonSize.standard : PantasButtonSize.phone,
      PantasButtonKind.secondary,
    );
    final enabled = onPressed != null;
    final palette = pantasButtonPalette(
      context.colors,
      PantasButtonKind.secondary,
      null,
      enabled: enabled,
    );
    final reduced = MediaQuery.disableAnimationsOf(context);
    // ds-raw: PantasButton has no icon-only form (label only), so the step
    // buttons take the secondary kind's metrics and palette on a TextButton
    final button = TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        animationDuration: reduced ? Duration.zero : PantasDurations.short2,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        minimumSize: WidgetStatePropertyAll(
          // The focus ring's Stack loosens the width, so a phone button asks
          // for all of it and is capped by its Expanded slot.
          Size(wide ? PantasSize.btn : double.infinity, metrics.height),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => enabled &&
                  ((s.contains(WidgetState.hovered) && wide) ||
                      s.contains(WidgetState.pressed))
              ? palette.hoverFill
              : palette.fill,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => enabled &&
                  ((s.contains(WidgetState.hovered) && wide) ||
                      s.contains(WidgetState.pressed))
              ? palette.hoverLabel
              : palette.label,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStatePropertyAll(palette.ring ?? BorderSide.none),
        shape: WidgetStatePropertyAll(metrics.shape()),
      ),
      child: Icon(icon, size: PantasSize.icon),
    );
    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      onTap: onPressed,
      excludeSemantics: true,
      child: PressScale(
        scale: pantasPressScale,
        enabled: enabled,
        child: OffsetFocusRing(
          borderRadius: BorderRadius.circular(metrics.radius),
          child: button,
        ),
      ),
    );
  }
}
