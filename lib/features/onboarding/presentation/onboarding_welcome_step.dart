import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({required this.onAdvance, super.key});
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) => ColoredBox(
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
                      const _OnboardingLogo(size: 104),
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
              child: const _OnboardingLogo(
                key: ValueKey('launch-logo'),
                size: 120,
              ),
            ),
          ),
        ),
      );
}

class _OnboardingLogo extends StatelessWidget {
  const _OnboardingLogo({required this.size, super.key});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: 'Pantas',
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _PantasLogoPainter(
              ink: context.colors.label,
              tassel: context.colors.accent,
            ),
          ),
        ),
      );
}

// Exact paths and viewBox from O_Launch. Colors come from W1 in both themes.
class _PantasLogoPainter extends CustomPainter {
  const _PantasLogoPainter({required this.ink, required this.tassel});
  final Color ink;
  final Color tassel;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(size.width / 640, size.height / 640)
      ..translate(-307, -309);
    final accentPaint = Paint()..color = tassel;
    canvas
      ..drawLine(
        const Offset(887, 515.69),
        const Offset(887, 664),
        Paint()
          ..color = tassel
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(const Offset(887, 682), 20, accentPaint)
      ..drawPath(
        Path()
          ..moveTo(877, 699)
          ..lineTo(897, 699)
          ..lineTo(912, 774)
          ..quadraticBezierTo(915, 790, 899, 791)
          ..lineTo(875, 791)
          ..quadraticBezierTo(859, 790, 862, 774)
          ..close(),
        accentPaint,
      );
    final paint = Paint()..color = ink;
    canvas
      ..drawPath(
        Path()
          ..moveTo(363.97, 493.76)
          ..lineTo(614.06, 374.19)
          ..arcToPoint(
            const Offset(639.94, 374.19),
            radius: const Radius.circular(30),
          )
          ..lineTo(890.03, 493.76)
          ..arcToPoint(
            const Offset(890.03, 526.24),
            radius: const Radius.circular(18),
          )
          ..lineTo(639.94, 645.81)
          ..arcToPoint(
            const Offset(614.06, 645.81),
            radius: const Radius.circular(30),
          )
          ..lineTo(363.97, 526.24)
          ..arcToPoint(
            const Offset(363.97, 493.76),
            radius: const Radius.circular(18),
          )
          ..close(),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(443.45, 593.06)
          ..lineTo(519.45, 629.40)
          ..arcToPoint(
            const Offset(524, 636.62),
            radius: const Radius.circular(8),
          )
          ..lineTo(524, 878)
          ..arcToPoint(
            const Offset(512, 890),
            radius: const Radius.circular(12),
          )
          ..lineTo(478, 890)
          ..arcToPoint(
            const Offset(432, 844),
            radius: const Radius.circular(46),
          )
          ..lineTo(432, 600.28)
          ..arcToPoint(
            const Offset(443.45, 593.06),
            radius: const Radius.circular(8),
          )
          ..close(),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(728, 638.53)
          ..quadraticBezierTo(728, 632.53, 734, 629.63)
          ..lineTo(814, 591.44)
          ..quadraticBezierTo(820, 588.54, 820, 594.54)
          ..lineTo(820, 696)
          ..arcToPoint(
            const Offset(670, 846),
            radius: const Radius.circular(150),
          )
          ..lineTo(584, 846)
          ..arcToPoint(
            const Offset(572, 834),
            radius: const Radius.circular(12),
          )
          ..lineTo(572, 766)
          ..arcToPoint(
            const Offset(584, 754),
            radius: const Radius.circular(12),
          )
          ..lineTo(670, 754)
          ..arcToPoint(
            const Offset(728, 696),
            radius: const Radius.circular(58),
            clockwise: false,
          )
          ..close(),
        paint,
      );
  }

  @override
  bool shouldRepaint(_PantasLogoPainter oldDelegate) =>
      ink != oldDelegate.ink || tassel != oldDelegate.tassel;
}
