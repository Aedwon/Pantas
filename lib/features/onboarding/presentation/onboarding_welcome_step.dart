import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({required this.onAdvance, super.key});
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      final t = context.webTokens;
      return CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.enter): onAdvance},
        child: Focus(
          autofocus: true,
          child: Material(
            color: t.colors.surface,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OnboardingLogo(size: 120),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome to Pantas',
                    style: t
                        .style(48, weight: FontWeight.w700, height: 1.08)
                        .copyWith(letterSpacing: -1.44),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your personal review companion for Philippine exams.',
                    style: t.style(
                      19,
                      height: 1.45,
                      color: t.colors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 44),
                  WebButton(
                    label: 'Get Started',
                    large: true,
                    keyHint: 'Enter',
                    onPressed: onAdvance,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return ColoredBox(
      color: context.colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 180, 20, 24),
                child: Column(
                  children: [
                    const OnboardingLogo(size: 104),
                    const SizedBox(height: 28),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        'Welcome to Pantas',
                        textAlign: TextAlign.center,
                        style: context.type.largeTitle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your personal review companion\n'
                      'for Philippine exams.',
                      textAlign: TextAlign.center,
                      style: context.type.body.copyWith(
                        color: context.colors.secondaryLabel,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
              child: PantasButton(label: 'Get Started', onPressed: onAdvance),
            ),
          ],
        ),
      ),
    );
  }
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
        color: context.colors.surface,
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
                    ? .4 + .72 * PantasCurves.popC.transform(rising)
                    : 1.12 - .12 * PantasCurves.popC.transform(settling);
                final opacity =
                    PantasCurves.popC.transform(rising).clamp(0.0, 1.0);
                return Opacity(
                  key: const ValueKey('launch-page-fade'),
                  opacity: PantasCurves.ease
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
