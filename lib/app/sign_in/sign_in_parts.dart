import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/platform/welcome/welcome_handover_providers.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:url_launcher/url_launcher.dart';

/// The width from which the sign-in screens use the laptop boards.
const signInWideFrom = 720.0;

const supportEmail = 'support@pantas.study';

/// Colors and text styles of the sign-in boards, read from the app's tokens.
///
/// The boards put the field on the page's own surface: white in light and the
/// raised charcoal in dark, with the page white in light and the base charcoal
/// in dark. The code boxes sit one step off the page.
class SignInStyle {
  SignInStyle(BuildContext context, {required this.wide})
      : c = context.colors,
        dark = Theme.of(context).brightness == Brightness.dark;

  final bool wide;
  final bool dark;
  final PantasColors c;

  Color get page => dark ? c.bgPage : c.surfaceCard;
  Color get field => c.surfaceCard;
  Color get box => dark ? c.surfaceCard : c.bgPage;
  Color get accent => c.accent;
  Color get accentHover => c.accentHover;
  Color get accentFill => c.accentFill;
  Color get accentFillHover => c.accentFillHover;
  Color get onAccent => c.onAccent;
  Color get accentTint => c.accentTint;
  Color get accentTintHover => c.accentTintHover;
  Color get accentTintText => c.accentTintText;
  Color get label => c.textPrimary;
  Color get secondary => c.textSecondary;
  Color get tertiary => c.textSecondary;
  Color get red => c.dangerText;
  Color get redTint => c.dangerTint;
  Color get border => c.divider;
  Color get placeholder => c.textSecondary;
  Color get lock => dark ? tertiary : c.iconChevron;

  double get letter => wide ? 0 : PantasType.phoneBody.letterSpacing!;

  TextStyle get title =>
      (wide ? PantasType.webDisplay : PantasType.phoneLargeTitle)
          .copyWith(color: label);

  TextStyle get subtitle =>
      PantasType.webLead.copyWith(letterSpacing: letter, color: secondary);

  TextStyle get emphasis => subtitle.copyWith(
        color: label,
        fontWeight: FontWeight.w600,
      );

  TextStyle get fieldLabel =>
      PantasType.webFieldLabel.copyWith(color: secondary);

  TextStyle get input => PantasType.phoneBody.copyWith(
        color: label,
        letterSpacing: letter,
      );

  /// The button label: 17/600 on phones, 16/600 when [small].
  TextStyle button({bool small = false, Color? color}) =>
      (small ? PantasType.webButton : PantasType.phoneHeadline).copyWith(
        letterSpacing: letter,
        color: color ?? label,
      );

  TextStyle get small => PantasType.phoneFootnote.copyWith(color: tertiary);
}

/// The page every sign-in state sits on. It tells the app the first screen is
/// ready, as the old frame did.
class SignInFrame extends ConsumerWidget {
  const SignInFrame({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(welcomeHandoverProvider).appReady(holdForTap: false);
      }
    });
    final style = SignInStyle(context, wide: false);
    return FirstScreenReady(
      child: Scaffold(
        backgroundColor: style.page,
        body: SafeArea(child: child),
      ),
    );
  }
}

/// A scroll view whose content is at least as tall as the window, so a column
/// inside can push its last block to the bottom (`spaceBetween`) and still
/// scroll when the window is short or the keyboard is open.
class SignInScroll extends StatelessWidget {
  const SignInScroll({required this.builder, super.key});

  /// Builds the content, given the height of the window.
  final Widget Function(double viewportHeight) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          child: ConstrainedBox(
            // Full width as well, so centered content stays centered on wide
            // windows instead of sitting at the scroll view's left edge.
            constraints: BoxConstraints(
              minWidth: box.maxWidth,
              minHeight: box.maxHeight,
            ),
            child: builder(box.maxHeight),
          ),
        ),
      );
}

/// Fades a block in while it drifts up, the boards' `up` entrance.
class SignInRise extends StatefulWidget {
  const SignInRise({
    required this.child,
    this.duration = PantasDurations.long1,
    this.delay = Duration.zero,
    this.distance = 12,
    this.curve = PantasCurves.enter,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double distance;
  final Curve curve;

  @override
  State<SignInRise> createState() => _SignInRiseState();
}

class _SignInRiseState extends State<SignInRise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + widget.duration,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = (widget.delay + widget.duration).inMilliseconds;
    final curve = widget.delay == Duration.zero
        ? widget.curve
        : Interval(widget.delay.inMilliseconds / total, 1, curve: widget.curve);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = curve.transform(_controller.value);
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, widget.distance * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Builds [child] once [delay] has passed. Until then it shows [placeholder].
class StartAfter extends StatefulWidget {
  const StartAfter({
    required this.delay,
    required this.child,
    this.placeholder = const SizedBox.shrink(),
    super.key,
  });

  final Duration delay;
  final Widget child;
  final Widget placeholder;

  @override
  State<StartAfter> createState() => _StartAfterState();
}

class _StartAfterState extends State<StartAfter> {
  Timer? _timer;
  bool _go = false;
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    if (widget.delay == Duration.zero ||
        MediaQuery.disableAnimationsOf(context)) {
      _go = true;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _go = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _go ? widget.child : widget.placeholder;
}

/// Replays the board shake each time [tick] changes. The child is never
/// rebuilt from scratch, so a text field inside keeps its focus.
class SignInShake extends StatefulWidget {
  const SignInShake({required this.tick, required this.child, super.key});
  final int tick;
  final Widget child;

  @override
  State<SignInShake> createState() => _SignInShakeState();
}

class _SignInShakeState extends State<SignInShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(SignInShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tick != widget.tick &&
        !MediaQuery.disableAnimationsOf(context)) {
      unawaited(_controller.forward(from: 0));
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
        child: widget.child,
        builder: (context, child) => Transform.translate(
          offset: Offset(PantasEffects.shakeOffset(_controller.value), 0),
          child: child,
        ),
      );
}

/// Lets a block change height smoothly (240 ms, shared ease). With reduced
/// motion it changes at once; an animated size cannot run with no duration.
class SmoothSize extends StatelessWidget {
  const SmoothSize({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedSize(
      duration: PantasDurations.medium1,
      curve: PantasCurves.move,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: child,
    );
  }
}

/// Swaps one step's block for the next without touching the rest of the
/// screen. The old block fades out where it stands; the new one rises in.
class StepSwitcher extends StatelessWidget {
  const StepSwitcher({
    required this.stepKey,
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Object stepKey;
  final Widget child;

  /// How long the new block waits before it rises (the form trails the title).
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    const rise = PantasDurations.long1;
    final total = delay + rise;
    return SmoothSize(
      child: AnimatedSwitcher(
        duration: still ? Duration.zero : total,
        reverseDuration:
            still ? Duration.zero : const Duration(milliseconds: 120),
        switchInCurve: delay == Duration.zero
            ? PantasCurves.enter
            : Interval(
                delay.inMilliseconds / total.inMilliseconds,
                1,
                curve: PantasCurves.enter,
              ),
        switchOutCurve: PantasCurves.fade,
        transitionBuilder: (child, animation) => AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final value = animation.value;
            final leaving = animation.status == AnimationStatus.reverse;
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, leaving ? 0 : 12 * (1 - value)),
                child: child,
              ),
            );
          },
        ),
        layoutBuilder: (current, previous) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            for (final old in previous)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(child: ExcludeSemantics(child: old)),
              ),
            if (current != null) current,
          ],
        ),
        child: KeyedSubtree(key: ValueKey<Object>(stepKey), child: child),
      ),
    );
  }
}

/// A message under a field. It rises in, and the room for it opens smoothly.
class SignInMessage extends StatelessWidget {
  const SignInMessage({
    required this.message,
    required this.style,
    required this.top,
    required this.gap,
    this.error = false,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    super.key,
  });

  /// Null leaves only the gap before the button.
  final String? message;
  final SignInStyle style;

  /// Space above the message (8 under the email field, 10 under the code).
  final double top;

  /// Space below the message, or the whole gap when there is no message.
  final double gap;
  final bool error;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return SmoothSize(
      child: text == null
          ? SizedBox(width: double.infinity, height: gap)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SignInRise(
                  key: ValueKey<String>(text),
                  distance: 6,
                  duration: duration,
                  delay: delay,
                  curve: PantasCurves.fade,
                  child: Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        PantasSpace.s4,
                        top,
                        PantasSpace.s4,
                        PantasSpace.s0,
                      ),
                      child: Text(
                        text,
                        style: style.fieldLabel.copyWith(
                          fontWeight: FontWeight.w400,
                          color: error ? style.red : style.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: gap),
              ],
            ),
    );
  }
}

/// The small spinner in a button while it waits (22 px, 0.9 s a turn).
class SignInSpinner extends StatefulWidget {
  const SignInSpinner({required this.color, super.key});
  final Color color;

  @override
  State<SignInSpinner> createState() => _SignInSpinnerState();
}

class _SignInSpinnerState extends State<SignInSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Working',
        child: RotationTransition(
          turns: _controller,
          child: CustomPaint(
            size: const Size.square(22),
            painter: _SpinnerPainter(widget.color),
          ),
        ),
      );
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(12 * unit, 12 * unit), radius: 9 * unit),
      -1.5707963267948966,
      -4.71238898038469,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.4 * unit
        ..color = color.withValues(alpha: .95),
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => color != oldDelegate.color;
}

/// The check that draws itself on "Signed In".
class DrawnCheck extends StatelessWidget {
  const DrawnCheck({
    required this.color,
    this.delay = Duration.zero,
    super.key,
  });
  final Color color;
  final Duration delay;

  @override
  Widget build(BuildContext context) => StartAfter(
        delay: delay,
        placeholder: const SizedBox.square(dimension: 20),
        child: PantasEffects.checkDraw(
          duration: const Duration(milliseconds: 350),
          builder: (context, progress, _) => CustomPaint(
            size: const Size.square(20),
            painter: _CheckPainter(color, progress),
          ),
        ),
      );
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.color, this.progress);
  final Color color;
  final double progress;

  // The board draws a 26-unit dash over a 24-unit box; the path is about 20
  // units long, so the stroke finishes a little before the clock does.
  static const _dash = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    final full = Path()
      ..moveTo(5 * unit, 12.5 * unit)
      ..lineTo(9.5 * unit, 17 * unit)
      ..lineTo(19 * unit, 7 * unit);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3 * unit
      ..color = color;
    for (final metric in full.computeMetrics()) {
      final visible = (_dash * unit * progress).clamp(0.0, metric.length);
      if (visible <= 0) continue;
      canvas.drawPath(metric.extractPath(0, visible), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

enum SignInButtonState { idle, busy, done }

/// The boards' 52 px button. It never disables: while it waits it shows a
/// spinner, and when sign-in works it shows a check and "Signed In".
class SignInButton extends StatelessWidget {
  const SignInButton({
    required this.label,
    required this.onPressed,
    required this.style,
    this.state = SignInButtonState.idle,
    this.keyHint,
    this.tonal = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final SignInStyle style;
  final SignInButtonState state;

  /// A key shown on the button when a keyboard is in use (laptop boards).
  final String? keyHint;

  /// The tinted button of the "not on the list" board.
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final foreground = tonal ? style.accentTintText : style.onAccent;
    final fill = tonal ? style.accentTint : style.accentFill;
    final hover = tonal ? style.accentTintHover : style.accentFillHover;
    final content = switch (state) {
      SignInButtonState.idle => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(label, textAlign: TextAlign.center)),
            if (keyHint != null) ...[
              const SizedBox(width: PantasSpace.s12),
              WebKeyHint(keyHint!, onButton: true),
            ],
          ],
        ),
      SignInButtonState.busy => SignInSpinner(color: foreground),
      SignInButtonState.done => SignInRise(
          distance: 6,
          duration: const Duration(milliseconds: 140),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DrawnCheck(
                color: foreground,
                delay: const Duration(milliseconds: 70),
              ),
              const SizedBox(width: PantasSpace.s8),
              const Text('Signed In'),
            ],
          ),
        ),
    };
    return SizedBox(
      height: PantasSize.btnPhone,
      width: double.infinity,
      child: PressScale(
        child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const WidgetStatePropertyAll(Size.zero),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: PantasSpace.s16),
            ),
            animationDuration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : PantasDurations.short2,
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => style.wide && states.contains(WidgetState.hovered)
                  ? hover
                  : fill,
            ),
            foregroundColor: WidgetStatePropertyAll(foreground),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PantasRadius.lg),
              ),
            ),
            textStyle: WidgetStatePropertyAll(style.button()),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// The boards' quiet 44 px text button.
class SignInTextButton extends StatelessWidget {
  const SignInTextButton({
    required this.label,
    required this.onPressed,
    required this.style,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final SignInStyle style;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PantasSize.targetTouch,
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : PantasDurations.short2,
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => style.wide && states.contains(WidgetState.hovered)
                ? style.accentTint.withValues(alpha: .5)
                : Colors.transparent,
          ),
          foregroundColor: WidgetStatePropertyAll(style.accent),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                style.wide ? PantasRadius.md : PantasRadius.lg,
              ),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            style.button(small: style.wide),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: PantasSpace.s10),
            ],
            Flexible(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

const _googleMark = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/></svg>''';

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_googleMark, width: 18, height: 18);
}

const _lockMark = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="10.5" width="14" height="10" rx="2"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3"/></svg>''';

class LockMark extends StatelessWidget {
  const LockMark({required this.color, super.key});
  final Color color;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
        _lockMark,
        width: 44,
        height: 44,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}

/// A line of small text with one tappable part, such as "Need help?" or
/// "Didn't get it? Resend Code".
class LinkLine extends StatefulWidget {
  const LinkLine({
    required this.prefix,
    required this.link,
    required this.onTap,
    required this.style,
    this.bold = false,
    this.suffix = '',
    super.key,
  });

  final String prefix;
  final String link;
  final String suffix;
  final VoidCallback onTap;
  final SignInStyle style;
  final bool bold;

  @override
  State<LinkLine> createState() => _LinkLineState();
}

class _LinkLineState extends State<LinkLine> {
  late final TapGestureRecognizer _tap = TapGestureRecognizer()
    ..onTap = () => widget.onTap();

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          style: widget.style.small.copyWith(height: 1.5),
          children: [
            TextSpan(text: widget.prefix),
            TextSpan(
              text: widget.link,
              recognizer: _tap,
              mouseCursor: SystemMouseCursors.click,
              style: TextStyle(
                color: widget.style.accent,
                fontWeight: widget.bold ? FontWeight.w600 : null,
              ),
            ),
            if (widget.suffix.isNotEmpty) TextSpan(text: widget.suffix),
          ],
        ),
        textAlign: TextAlign.center,
      );
}

Future<void> openSupportMail() async {
  try {
    await launchUrl(Uri(scheme: 'mailto', path: supportEmail));
  } on Object {
    // No mail app is not a failure the sign-in screen can fix.
  }
}

class SupportLine extends StatelessWidget {
  const SupportLine({required this.style, this.note = '', super.key});
  final SignInStyle style;

  /// A line above "Need help?" (the not-on-the-list board).
  final String note;

  @override
  Widget build(BuildContext context) => LinkLine(
        prefix: '${note}Need help? ',
        link: supportEmail,
        onTap: openSupportMail,
        style: style,
      );
}

/// The email field of the boards: 52 px, radius 14, 2 px border that turns
/// teal on focus and red when the address is refused.
class SignInField extends StatelessWidget {
  const SignInField({
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.invalid,
    required this.onSubmitted,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final SignInStyle style;
  final bool invalid;
  final VoidCallback onSubmitted;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final border = invalid
            ? style.red
            : focusNode.hasFocus
                ? style.accent
                : style.border;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: focusNode.requestFocus,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : PantasDurations.short2,
            curve: PantasCurves.fade,
            height: PantasSize.btnPhone,
            padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s14),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: invalid ? style.redTint : style.field,
              borderRadius: BorderRadius.circular(PantasRadius.lg),
              border: Border.all(
                color: border,
                width: PantasBorder.ringSelected,
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              cursorColor: style.accent,
              style: style.input.copyWith(color: style.label),
              decoration: InputDecoration.collapsed(
                hintText: 'you@example.com',
                hintStyle: style.input.copyWith(color: style.placeholder),
              ),
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
        );
      },
    );
  }
}

/// Keeps digits only and at most six. A pasted code replaces what is typed.
/// While [replacing] is true (after a wrong code) the next input starts over.
class CodeDigitsFormatter extends TextInputFormatter {
  CodeDigitsFormatter({this.replacing});
  final bool Function()? replacing;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (replacing?.call() ?? false) {
      final old = oldValue.text;
      text = text.startsWith(old) ? text.substring(old.length) : '';
    }
    if (text.length > 6) {
      final added = text.length - oldValue.text.length;
      text =
          added >= 6 ? text.substring(text.length - 6) : text.substring(0, 6);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

enum CodeTone { normal, bad, fadingBad, ok }

// The code field's long-press menu offers Paste only. On web the browser's
// own menu shows instead, which includes Paste.
Widget _pasteOnlyMenu(BuildContext context, EditableTextState field) {
  final paste = field.contextMenuButtonItems
      .where((item) => item.type == ContextMenuButtonType.paste)
      .toList();
  if (paste.isEmpty) return const SizedBox.shrink();
  return AdaptiveTextSelectionToolbar.buttonItems(
    anchors: field.contextMenuAnchors,
    buttonItems: paste,
  );
}

/// Six boxes driven by one hidden field. The field lies over the boxes with
/// transparent text, so a tap on a box focuses it, and the keyboard, paste
/// and one-time-code autofill all reach it.
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.formatter,
    required this.tone,
    required this.onChanged,
    required this.onSubmitted,
    this.shakeTick = 0,
    this.locked = false,
    this.dimmed = false,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final SignInStyle style;
  final TextInputFormatter formatter;
  final CodeTone tone;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final int shakeTick;

  /// True while a check is running or finished: the field ignores keys.
  final bool locked;

  /// The code is dead (expired or locked): the boxes dim and ignore input.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final height = style.wide ? 64.0 : 60.0;
    final fontSize = style.wide ? 30.0 : 28.0;
    return SignInShake(
      tick: shakeTick,
      child: AnimatedOpacity(
        opacity: dimmed ? .45 : 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: PantasCurves.fade,
        child: SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: ListenableBuilder(
                    listenable: Listenable.merge([controller, focusNode]),
                    builder: (context, _) {
                      final text = controller.text;
                      final entering = tone == CodeTone.normal &&
                          !locked &&
                          !dimmed &&
                          focusNode.hasFocus;
                      return Row(
                        children: [
                          for (var i = 0; i < 6; i++) ...[
                            if (i > 0) const SizedBox(width: PantasSpace.s8),
                            Expanded(
                              child: _CodeBox(
                                index: i,
                                digit: i < text.length ? text[i] : null,
                                active: entering && i == text.length,
                                tone: tone,
                                style: style,
                                fontSize: fontSize,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: Semantics(
                  label: 'Code',
                  // Selection stays on so paste works: the web engine blocks
                  // clipboard events when it is off. The theme hides the
                  // highlight and handles, since the boxes draw the digits.
                  child: TextSelectionTheme(
                    data: const TextSelectionThemeData(
                      selectionColor: Colors.transparent,
                      selectionHandleColor: Colors.transparent,
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      enabled: !dimmed,
                      readOnly: locked,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [formatter],
                      autocorrect: false,
                      enableSuggestions: false,
                      contextMenuBuilder: _pasteOnlyMenu,
                      showCursor: false,
                      cursorWidth: 0,
                      style: TextStyle(
                        color: Colors.transparent,
                        fontSize: fontSize,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        isCollapsed: true,
                      ),
                      onChanged: onChanged,
                      onSubmitted: (_) => onSubmitted(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.index,
    required this.digit,
    required this.active,
    required this.tone,
    required this.style,
    required this.fontSize,
  });

  final int index;
  final String? digit;
  final bool active;
  final CodeTone tone;
  final SignInStyle style;
  final double fontSize;

  static const _radius = BorderRadius.all(Radius.circular(PantasRadius.lg));

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final bad = tone == CodeTone.bad;
    final redDigits = tone == CodeTone.bad || tone == CodeTone.fadingBad;
    final digit = this.digit;
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: style.box, borderRadius: _radius),
        ),
        if (active)
          DecoratedBox(
            decoration: BoxDecoration(
              color: style.field,
              borderRadius: _radius,
              border: Border.all(color: style.accent, width: 2),
            ),
            child: Center(child: _Caret(color: style.accent, wide: style.wide)),
          ),
        AnimatedOpacity(
          opacity: bad ? 1 : 0,
          duration: bad || still ? Duration.zero : PantasDurations.medium1,
          curve: PantasCurves.fade,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: style.redTint,
              borderRadius: _radius,
              border: Border.all(color: style.red, width: 2),
            ),
          ),
        ),
        if (tone == CodeTone.ok)
          StartAfter(
            delay: Duration(milliseconds: 40 * index),
            child: PantasEffects.ring(
              duration: const Duration(milliseconds: 700),
              builder: (context, progress, _) => DecoratedBox(
                decoration: BoxDecoration(
                  color: style.accentTint,
                  borderRadius: _radius,
                  border: Border.all(color: style.accent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color:
                          style.accent.withValues(alpha: .38 * (1 - progress)),
                      spreadRadius: 12 * progress,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (digit != null)
          Center(
            child: AnimatedOpacity(
              opacity: tone == CodeTone.fadingBad ? 0 : 1,
              duration: still ? Duration.zero : PantasDurations.medium1,
              curve: PantasCurves.fade,
              child: KeyedSubtree(
                key: ValueKey<String>('$index$digit'),
                child: PantasEffects.pop(
                  duration: Duration(milliseconds: style.wide ? 420 : 245),
                  builder: (context, _, child) => child!,
                  child: Text(
                    digit,
                    style: style.input.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      color: redDigits ? style.red : style.label,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The blinking caret of the active box: half a second on, half a second off.
class _Caret extends StatefulWidget {
  const _Caret({required this.color, required this.wide});
  final Color color;
  final bool wide;

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      unawaited(_controller.repeat());
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
        builder: (context, child) =>
            Visibility(visible: _controller.value < .5, child: child!),
        child: Container(
          width: 2,
          height: widget.wide ? 28 : 26,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(PantasRadius.full),
          ),
        ),
      );
}
