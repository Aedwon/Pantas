import 'package:flutter/services.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/components/page_title.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

/// The Cover mark's size on the wide welcome and on the phone welcome (boards
/// OB_Welcome, O_Welcome).
const double _logoWide = 120;
const double _logoPhone = 104;

/// Wide web: the Get Started button's width, as the HTML welcome has it.
const double _buttonWidth = 260;

/// Phone: space above the mark, which sets the title at the board's height.
const double _phoneLogoTop = 180;

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({
    required this.onAdvance,
    this.underCover = false,
    super.key,
  });
  final VoidCallback onAdvance;

  /// The HTML Welcome screen is still up over this step. It is the page, so
  /// this step draws only the background and the tap that removes the screen
  /// leaves nothing of a second Welcome to flash.
  final bool underCover;

  @override
  Widget build(BuildContext context) => underCover
      ? ColoredBox(
          color: context.wideWeb
              ? context.webTokens.colors.background
              : context.colors.background,
        )
      : _AfterSplash(child: _content(context));

  Widget _content(BuildContext context) {
    if (context.wideWeb) {
      final t = context.webTokens;
      return OnboardingShortcuts(
        bindings: {
          const SingleActivator(
            LogicalKeyboardKey.enter,
            includeRepeats: false,
          ): onAdvance,
        },
        child: KeyFocusKeeper(
          skipTraversal: true,
          child: Material(
            // Pick B (Nov 5): the splash, this step and the first frame
            // after it share the app background.
            color: t.colors.background,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _WelcomePop(
                    key: ValueKey('welcome-logo-pop'),
                    child: OnboardingLogo(size: _logoWide),
                  ),
                  const SizedBox(height: PantasSpace.s32),
                  _WelcomePop(
                    key: const ValueKey('welcome-title-pop'),
                    child: Text(
                      'Welcome to Pantas',
                      style: PantasType.webDisplay
                          .copyWith(color: t.colors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s12),
                  Text(
                    'Your personal review companion for Philippine exams.',
                    style: PantasType.webLead
                        .copyWith(color: t.colors.textSecondary),
                  ),
                  const SizedBox(height: PantasSpace.s44),
                  // The HTML welcome the first visit shows has a 260 px button
                  // (OB_Welcome). This step, shown after Back, matches it.
                  SizedBox(
                    width: _buttonWidth,
                    child: WebButton(
                      label: 'Get Started',
                      large: true,
                      expand: true,
                      keyHint: 'Enter',
                      onPressed: onAdvance,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return ColoredBox(
      color: context.colors.background,
      child: SafeArea(
        // From 600 px the phone layout sits in the 640 px column the other
        // pages use, so the button does not run the width of a tablet.
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: PantasLayout.tabletColumn),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      PantasSpace.s20,
                      _phoneLogoTop,
                      PantasSpace.s20,
                      PantasSpace.s24,
                    ),
                    child: Column(
                      children: [
                        const OnboardingLogo(size: _logoPhone),
                        const SizedBox(height: PantasSpace.s28),
                        Semantics(
                          header: true,
                          liveRegion: true,
                          child: PantasTitle(
                            'Welcome to Pantas',
                            textAlign: TextAlign.center,
                            style: context.type.largeTitle,
                          ),
                        ),
                        const SizedBox(height: PantasSpace.s10),
                        Text(
                          'Your personal review companion\n'
                          'for Philippine exams.',
                          textAlign: TextAlign.center,
                          style: PantasType.webLead.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s20,
                    PantasSpace.s12,
                    PantasSpace.s20,
                    PantasSpace.s32,
                  ),
                  child:
                      PantasButton(label: 'Get Started', onPressed: onAdvance),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps the step invisible while the HTML splash still fades out, then
/// brings it in. A page that began from the splash used to show this step
/// settled underneath, so two logos and two titles overlapped for the length
/// of the fade (4P-2). With no splash, or reduced motion, it shows at once.
class _AfterSplash extends StatefulWidget {
  const _AfterSplash({required this.child});
  final Widget child;

  @override
  State<_AfterSplash> createState() => _AfterSplashState();
}

class _AfterSplashState extends State<_AfterSplash> {
  bool _covered = false;
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    if (MediaQuery.disableAnimationsOf(context) || !pageBeganFromSplash()) {
      return;
    }
    _covered = true;
    afterSplashGone(() {
      if (mounted) setState(() => _covered = false);
    });
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: _covered,
        child: AnimatedOpacity(
          key: const ValueKey('welcome-after-splash'),
          opacity: _covered ? 0 : 1,
          duration: _covered ? Duration.zero : PantasDurations.flip,
          curve: PantasCurves.fade,
          child: widget.child,
        ),
      );
}

/// The wide welcome's logo and title: the launch logo's 750 ms pop, the same
/// rise, overshoot and settle on `popC`. It waits [_splashFade] so the page's
/// logo has faded before this one rises, and two logos never show at once.
const _splashFade = 250;

class _WelcomePop extends StatefulWidget {
  const _WelcomePop({required this.child, super.key});
  final Widget child;

  @override
  State<_WelcomePop> createState() => _WelcomePopState();
}

class _WelcomePopState extends State<_WelcomePop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750 + _splashFade),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A page that began from the splash already showed the logo's pop. This
    // step then sits settled under the fading splash, with no second pop.
    if (MediaQuery.disableAnimationsOf(context) || pageBeganFromSplash()) {
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final milliseconds =
              _controller.value * (750 + _splashFade) - _splashFade;
          final rising = ((milliseconds - 150) / 360).clamp(0.0, 1.0);
          final settling = ((milliseconds - 510) / 240).clamp(0.0, 1.0);
          final scale = milliseconds <= 510
              ? .4 + .72 * PantasCurves.spring.transform(rising)
              : 1.12 - .12 * PantasCurves.spring.transform(settling);
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: PantasCurves.spring.transform(rising).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: widget.child,
      );
}

class OnboardingLaunchStep extends StatefulWidget {
  const OnboardingLaunchStep({required this.onCompleted, super.key});
  final VoidCallback onCompleted;

  @override
  State<OnboardingLaunchStep> createState() => _OnboardingLaunchStepState();
}

class _OnboardingLaunchStepState extends State<OnboardingLaunchStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..addListener(() {
      if (_controller.value >= 1) _finish();
    });
  bool _started = false;
  bool _finished = false;

  void _finish() {
    if (_finished) return;
    _finished = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onCompleted();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _finish();
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: context.colors.background,
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final milliseconds = _controller.value == 1
                    ? 750.0
                    : (_controller.lastElapsedDuration?.inMicroseconds ?? 0) /
                        1000;
                final rising = ((milliseconds - 150) / 360).clamp(0.0, 1.0);
                final settling = ((milliseconds - 510) / 240).clamp(0.0, 1.0);
                final scale = milliseconds <= 510
                    ? .4 + .72 * PantasCurves.spring.transform(rising)
                    : 1.12 - .12 * PantasCurves.spring.transform(settling);
                final opacity =
                    PantasCurves.spring.transform(rising).clamp(0.0, 1.0);
                return Opacity(
                  key: const ValueKey('launch-page-fade'),
                  opacity: PantasCurves.fade
                      .transform((milliseconds / 300).clamp(0.0, 1.0)),
                  child: Transform.scale(
                    key: const ValueKey('launch-logo-scale'),
                    scale: scale,
                    child: Opacity(
                      key: const ValueKey('launch-logo-opacity'),
                      opacity: opacity,
                      child: child,
                    ),
                  ),
                );
              },
              child: const OnboardingLogo(
                key: ValueKey('launch-logo'),
                size: 120,
              ),
            ),
          ),
        ),
      );
}

class OnboardingLogo extends PantasLogo {
  const OnboardingLogo({required super.size, super.key});
}
