import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/sign_in/sign_in_parts.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';

/// The time left before the beta starts, in whole days, hours and minutes.
///
/// The time left is rounded up to the next whole minute, so the tiles never
/// read zero while the beta has not started. The start is one instant, so the
/// count runs straight across Philippine midnight.
@immutable
class BetaCountdown {
  const BetaCountdown({
    required this.days,
    required this.hours,
    required this.minutes,
  });

  factory BetaCountdown.until(DateTime start, DateTime now) {
    final left = start.difference(now).inMilliseconds;
    if (left <= 0) return const BetaCountdown(days: 0, hours: 0, minutes: 0);
    final total = (left + _minute - 1) ~/ _minute;
    return BetaCountdown(
      days: total ~/ (24 * 60),
      hours: total % (24 * 60) ~/ 60,
      minutes: total % 60,
    );
  }

  static const _minute = 60000;

  /// How long until the tiles next change. Zero once the start has come.
  static Duration untilChange(DateTime start, DateTime now) {
    final left = start.difference(now).inMilliseconds;
    if (left <= 0) return Duration.zero;
    return Duration(milliseconds: (left - 1) % _minute + 1);
  }

  final int days;
  final int hours;
  final int minutes;

  String get daysText => '$days';
  String get hoursText => hours.toString().padLeft(2, '0');
  String get minutesText => minutes.toString().padLeft(2, '0');

  /// What a screen reader says, as in "1 day, 9 hours and 41 minutes to go".
  String get spoken => '${_count(days, 'day')}, ${_count(hours, 'hour')} and '
      '${_count(minutes, 'minute')} to go';

  static String _count(int n, String unit) => '$n $unit${n == 1 ? '' : 's'}';

  @override
  bool operator ==(Object other) =>
      other is BetaCountdown &&
      other.days == days &&
      other.hours == hours &&
      other.minutes == minutes;

  @override
  int get hashCode => Object.hash(days, hours, minutes);
}

/// What a selected tester sees before the beta starts: the logo, the start
/// date and a live countdown. At zero it asks the server again and the gate
/// opens the app without a reload.
class BetaWaitingPage extends ConsumerStatefulWidget {
  const BetaWaitingPage({required this.until, required this.email, super.key});

  /// When the beta starts, in UTC.
  final DateTime until;
  final String email;

  @override
  ConsumerState<BetaWaitingPage> createState() => _BetaWaitingPageState();
}

class _BetaWaitingPageState extends ConsumerState<BetaWaitingPage> {
  late DateTime _now = ref.read(betaClockProvider)();
  Timer? _timer;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(BetaWaitingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.until != widget.until) {
      _now = ref.read(betaClockProvider)();
      _schedule();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(BetaCountdown.untilChange(widget.until, _now), _tick);
  }

  void _tick() {
    if (!mounted) return;
    final now = ref.read(betaClockProvider)();
    if (!now.isBefore(widget.until)) {
      // The beta has started. Ask again; the gate opens the app.
      ref.invalidate(betaAccessProvider);
      return;
    }
    setState(() => _now = now);
    _schedule();
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on Object {
      // The page stays; the button works again.
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= signInWideFrom;
    final style = SignInStyle(context, wide: wide);
    final countdown = BetaCountdown.until(widget.until, _now);
    final top = _Top(
      style: style,
      email: widget.email,
      countdown: countdown,
    );
    final bottom = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SignInButton(
          label: 'Use a Different Email',
          style: style,
          tonal: true,
          state: _signingOut ? SignInButtonState.busy : SignInButtonState.idle,
          onPressed: _signOut,
        ),
        const SizedBox(height: 14),
        SupportLine(style: style),
      ],
    );
    if (wide) {
      return SignInFrame(
        child: SignInScroll(
          builder: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [top, const SizedBox(height: 32), bottom],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SignInFrame(
      child: SignInScroll(
        builder: (_) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: const EdgeInsets.only(top: 132), child: top),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
              child: bottom,
            ),
          ],
        ),
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({
    required this.style,
    required this.email,
    required this.countdown,
  });

  final SignInStyle style;
  final String email;
  final BetaCountdown countdown;

  @override
  Widget build(BuildContext context) {
    final wide = style.wide;
    final subtitle = style.subtitle.copyWith(letterSpacing: 0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 0 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _WaitingLogo(size: wide ? 120 : 104)),
          SizedBox(height: wide ? 32 : 26),
          SignInRise(
            delay: const Duration(milliseconds: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'The beta starts Nov 9',
                  textAlign: TextAlign.center,
                  style: style.title,
                ),
                SizedBox(height: wide ? 12 : 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: "You're signed in as "),
                      TextSpan(
                        text: email,
                        style: subtitle.copyWith(
                          color: style.label,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: subtitle,
                ),
              ],
            ),
          ),
          SizedBox(height: wide ? 32 : 28),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: _Tiles(style: style, countdown: countdown),
            ),
          ),
        ],
      ),
    );
  }
}

/// The logo pops in. Its tassel then swings once and settles.
class _WaitingLogo extends StatelessWidget {
  const _WaitingLogo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => StartAfter(
        delay: const Duration(milliseconds: 100),
        placeholder: SizedBox.square(dimension: size),
        child: PantasEffects.pop(
          duration: const Duration(milliseconds: 600),
          builder: (context, _, child) => child!,
          child: _SwingingLogo(size: size),
        ),
      );
}

class _SwingingLogo extends StatefulWidget {
  const _SwingingLogo({required this.size});
  final double size;

  @override
  State<_SwingingLogo> createState() => _SwingingLogoState();
}

class _SwingingLogoState extends State<_SwingingLogo>
    with SingleTickerProviderStateMixin {
  // The swing waits 0.5 s from the start of the page, then runs 2.2 s. This
  // widget appears 0.1 s in, so it waits 0.4 s more.
  static const _wait = 400;
  static const _swing = 2200;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _wait + _swing),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      unawaited(_controller.forward());
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
        builder: (context, _) {
          final t = ((_controller.value * (_wait + _swing) - _wait) / _swing)
              .clamp(0.0, 1.0);
          return PantasLogo(
            size: widget.size,
            tasselAngle: PantasEffects.tasselSwing(t) * math.pi / 180,
          );
        },
      );
}

/// The three tiles. The value in a tile rolls when it changes.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.style, required this.countdown});
  final SignInStyle style;
  final BetaCountdown countdown;

  @override
  Widget build(BuildContext context) {
    final tiles = <(String, String, Key)>[
      (
        countdown.daysText,
        countdown.days == 1 ? 'day' : 'days',
        const ValueKey('beta-days'),
      ),
      (
        countdown.hoursText,
        countdown.hours == 1 ? 'hour' : 'hours',
        const ValueKey('beta-hours'),
      ),
      (countdown.minutesText, 'min', const ValueKey('beta-minutes')),
    ];
    return Semantics(
      container: true,
      liveRegion: true,
      label: countdown.spoken,
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: SignInRise(
                  distance: 10,
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 400 + 80 * i),
                  child: Container(
                    height: 88,
                    decoration: BoxDecoration(
                      color: style.box,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RollingNumber(
                          key: tiles[i].$3,
                          text: tiles[i].$1,
                          style: style,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tiles[i].$2,
                          style: style.small.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: style.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A number that rolls when it changes: the old value rolls up and out, the
/// new one rolls in from below, in teal. With reduced motion it swaps at once.
class _RollingNumber extends StatefulWidget {
  const _RollingNumber({required this.text, required this.style, super.key});
  final String text;
  final SignInStyle style;

  @override
  State<_RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<_RollingNumber>
    with SingleTickerProviderStateMixin {
  static const _height = 40.0;

  late final AnimationController _roll = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    value: 1,
  );
  String _previous = '';
  bool _previousRolled = false;
  bool _rolled = false;

  @override
  void didUpdateWidget(_RollingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text == widget.text) return;
    _previous = oldWidget.text;
    _previousRolled = _rolled;
    _rolled = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _roll.value = 1;
    } else {
      unawaited(_roll.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _roll.dispose();
    super.dispose();
  }

  Widget _text(String text, Color color) => Center(
        child: Text(
          text,
          maxLines: 1,
          style: widget.style.title.copyWith(
            fontSize: 34,
            letterSpacing: -0.68,
            height: 1.12,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    return SizedBox(
      width: 52,
      height: _height,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _roll,
          builder: (context, _) {
            final t = _roll.value;
            const shift = _height * 1.1;
            final out = PantasCurves.checkDraw.transform(t);
            final inn = PantasCurves.riseIn.transform(t);
            return Stack(
              children: [
                if (t < 1)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 1 - out,
                      child: Transform.translate(
                        offset: Offset(0, -shift * out),
                        child: _text(
                          _previous,
                          _previousRolled ? s.accent : s.label,
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Opacity(
                    opacity: inn.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, shift * (1 - inn)),
                      child: _text(widget.text, _rolled ? s.accent : s.label),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
