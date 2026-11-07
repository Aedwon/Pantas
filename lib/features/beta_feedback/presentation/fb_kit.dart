import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The shell the Feedback pages sit in. The route builds it from the Settings
/// pane page, so these pages never import another feature's presentation.
///
/// [beta] adds the BETA mark to [title] (and the chat glyph on wide web).
/// [subline] is the grey line under the title. [heading] false leaves the
/// title out (the survey's sent state).
typedef FeedbackFrame = Widget Function({
  required String title,
  required List<Widget> children,
  required String backLabel,
  required VoidCallback onBack,
  bool beta,
  String? subline,
  double headingGap,
  bool heading,
});

/// Board colors for both layouts. The phone boards and the desktop boards use
/// one palette; `WebTokens` holds it with the board's tertiary gray (#8A8A8E).
extension FbContext on BuildContext {
  WebTokens get fbTokens => webTokens;
  PantasColors get fb => webTokens.colors;
  bool get fbWide => wideWeb;

  /// A board text style: Geist, [size] px, in the label color unless told.
  TextStyle fbText(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double spacing = 0,
  }) =>
      webTokens.style(
        size,
        weight: weight,
        color: color,
        height: height,
        spacing: spacing,
      );
}

// ---------------------------------------------------------------------------
// Dates. The beta runs on Philippine dates, so every date shown is read in
// UTC+8, whatever the device clock says.

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// The wall-clock fields of [instant] in the Philippines (a UTC `DateTime`
/// whose fields read as Philippine time).
DateTime phTime(DateTime instant) =>
    instant.toUtc().add(const Duration(hours: 8));

/// `2026-11-12`, the key the server counts days by.
String phKey(DateTime instant) {
  final p = phTime(instant);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${p.year}-${two(p.month)}-${two(p.day)}';
}

/// "Nov 11".
String monthDay(DateTime instant) {
  final p = phTime(instant);
  return '${_months[p.month - 1]} ${p.day}';
}

/// "Nov 20, 2027".
String monthDayYear(DateTime instant) =>
    '${monthDay(instant)}, ${phTime(instant).year}';

/// "Nov 11, 9:41 PM".
String stamp(DateTime instant) {
  final p = phTime(instant);
  final hour = p.hour % 12 == 0 ? 12 : p.hour % 12;
  final minute = p.minute.toString().padLeft(2, '0');
  return '${monthDay(instant)}, $hour:$minute ${p.hour < 12 ? 'AM' : 'PM'}';
}

/// "Mon" for a `YYYY-MM-DD` key.
String weekdayOf(String key) =>
    _weekdays[DateTime.parse('${key}T00:00:00Z').weekday - 1];

/// "Nov 9" for a `YYYY-MM-DD` key.
String monthDayOfKey(String key) {
  final d = DateTime.parse('${key}T00:00:00Z');
  return '${_months[d.month - 1]} ${d.day}';
}

String imageCount(int n) => n == 1 ? '1 image' : '$n images';

// ---------------------------------------------------------------------------
// Marks and glyphs.

/// The raised BETA mark after a title (9 px, w700, .08 em, 4 px after).
class BetaMark extends StatelessWidget {
  const BetaMark({this.top = 4, super.key});
  final double top;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.only(top: top, left: 4),
          child: Text(
            'BETA',
            style: context.fbText(
              9,
              weight: FontWeight.w700,
              spacing: .72,
              height: 1,
              color: context.fb.accent,
            ),
          ),
        ),
      );
}

/// A title with the BETA mark after it.
class BetaTitle extends StatelessWidget {
  const BetaTitle({
    required this.title,
    required this.style,
    this.markTop = 4,
    super.key,
  });
  final String title;
  final TextStyle style;
  final double markTop;

  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        label: '$title, beta',
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: style), BetaMark(top: markTop)],
        ),
      );
}

enum FbGlyphKind { check, plus, close, crown }

/// A board glyph on a 24 unit grid. [progress] draws a stroke part way, for
/// the checks that draw themselves in.
class FbGlyph extends StatelessWidget {
  const FbGlyph(
    this.kind, {
    required this.size,
    required this.color,
    this.stroke = 2,
    this.progress = 1,
    super.key,
  });
  final FbGlyphKind kind;
  final double size;
  final Color color;
  final double stroke;
  final double progress;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _GlyphPainter(kind, color, stroke, progress),
      );
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.kind, this.color, this.stroke, this.progress);
  final FbGlyphKind kind;
  final Color color;
  final double stroke;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    if (kind == FbGlyphKind.crown) {
      canvas.drawPath(
        Path()
          ..moveTo(3.5 * k, 8 * k)
          ..lineTo(8 * k, 11.5 * k)
          ..lineTo(12 * k, 5 * k)
          ..lineTo(16 * k, 11.5 * k)
          ..lineTo(20.5 * k, 8 * k)
          ..lineTo(19 * k, 17.5 * k)
          ..lineTo(5 * k, 17.5 * k)
          ..close(),
        Paint()..color = color,
      );
      return;
    }
    final path = Path();
    switch (kind) {
      case FbGlyphKind.check:
        path
          ..moveTo(5 * k, 12.5 * k)
          ..lineTo(9.5 * k, 17 * k)
          ..lineTo(19 * k, 7.5 * k);
      case FbGlyphKind.plus:
        path
          ..moveTo(12 * k, 5 * k)
          ..lineTo(12 * k, 19 * k)
          ..moveTo(5 * k, 12 * k)
          ..lineTo(19 * k, 12 * k);
      case FbGlyphKind.close:
        path
          ..moveTo(6 * k, 6 * k)
          ..lineTo(18 * k, 18 * k)
          ..moveTo(18 * k, 6 * k)
          ..lineTo(6 * k, 18 * k);
      case FbGlyphKind.crown:
        break;
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    if (progress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    // The stroke grows from its start, as `stroke-dashoffset` does.
    var total = 0.0;
    final metrics = path.computeMetrics().toList();
    for (final m in metrics) {
      total += m.length;
    }
    var left = total * progress.clamp(0, 1);
    for (final m in metrics) {
      if (left <= 0) break;
      canvas.drawPath(m.extractPath(0, math.min(left, m.length)), paint);
      left -= m.length;
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.kind != kind ||
      old.color != color ||
      old.stroke != stroke ||
      old.progress != progress;
}

// ---------------------------------------------------------------------------
// Motion. Every piece shows its final state at once under reduced motion.

/// Plays once when mounted. [builder] gets 0 to 1 across [duration] after
/// [delay]; before the delay it gets 0 (a CSS `both` fill). With reduced
/// motion it gets 1 and nothing ticks.
class FbTimeline extends StatefulWidget {
  const FbTimeline({
    required this.duration,
    required this.builder,
    this.delay = Duration.zero,
    this.child,
    super.key,
  });
  final Duration duration;
  final Duration delay;
  final Widget? child;
  final Widget Function(BuildContext context, double t, Widget? child) builder;

  @override
  State<FbTimeline> createState() => _FbTimelineState();
}

class _FbTimelineState extends State<FbTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.delay + widget.duration,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.builder(context, 1, widget.child);
    }
    final total = (widget.delay + widget.duration).inMicroseconds;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final elapsed = _c.value * total;
        final t = widget.duration.inMicroseconds == 0
            ? 1.0
            : ((elapsed - widget.delay.inMicroseconds) /
                    widget.duration.inMicroseconds)
                .clamp(0.0, 1.0);
        return widget.builder(context, t, child);
      },
    );
  }
}

/// `up` and `rise`: fades in while moving [dy] px up to its place.
class FbRise extends StatelessWidget {
  const FbRise({
    required this.child,
    this.dy = 10,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = PantasCurves.riseIn,
    super.key,
  });
  final Widget child;
  final double dy;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  Widget build(BuildContext context) => FbTimeline(
        duration: duration,
        delay: delay,
        child: child,
        builder: (context, t, child) {
          final e = curve.transform(t);
          return Opacity(
            opacity: e.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, dy * (1 - e)),
              child: child,
            ),
          );
        },
      );
}

/// `pop`: scale .4 to [peak] to 1 with the pop curve on each half, and a
/// fade in. The keyframes sit at 0, 60 and 100 percent.
class FbPop extends StatelessWidget {
  const FbPop({
    required this.child,
    this.peak = 1.08,
    this.duration = const Duration(milliseconds: 450),
    this.delay = Duration.zero,
    super.key,
  });
  final Widget child;
  final double peak;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) => FbTimeline(
        duration: duration,
        delay: delay,
        child: child,
        builder: (context, t, child) {
          final double scale;
          final double opacity;
          if (t < .6) {
            final e = PantasCurves.popC.transform(t / .6);
            scale = .4 + (peak - .4) * e;
            opacity = e.clamp(0.0, 1.0);
          } else {
            final e = PantasCurves.popC.transform((t - .6) / .4);
            scale = peak + (1 - peak) * e;
            opacity = 1;
          }
          return Opacity(
            opacity: opacity,
            child: Transform.scale(scale: scale, child: child),
          );
        },
      );
}

/// A stroked glyph that draws itself in (`checkDraw`).
class FbDrawnGlyph extends StatelessWidget {
  const FbDrawnGlyph(
    this.kind, {
    required this.size,
    required this.color,
    required this.stroke,
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    super.key,
  });
  final FbGlyphKind kind;
  final double size;
  final Color color;
  final double stroke;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) => FbTimeline(
        duration: duration,
        delay: delay,
        builder: (context, t, _) => FbGlyph(
          kind,
          size: size,
          color: color,
          stroke: stroke,
          progress: PantasCurves.checkDraw.transform(t),
        ),
      );
}

/// The button spinner: an 18 px ring, 2.4 px, a white arc turning every .9 s.
/// Under reduced motion it holds still.
class FbSpinner extends StatefulWidget {
  const FbSpinner({this.color = Colors.white, super.key});
  final Color color;

  @override
  State<FbSpinner> createState() => _FbSpinnerState();
}

class _FbSpinnerState extends State<FbSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _started = false;
    } else if (!_started) {
      _started = true;
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Sending',
        child: RotationTransition(
          turns: _c,
          child: CustomPaint(
            size: const Size.square(18),
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
    const width = 2.4;
    final rect = (Offset.zero & size).deflate(width / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color.withValues(alpha: .35);
    canvas.drawArc(rect, 0, math.pi * 2, false, paint);
    // The top quarter of the ring is solid, as `border-top-color` is.
    paint
      ..color = color
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -math.pi * .75, math.pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Pieces shared by the pages.

/// The white (dark: charcoal) rounded card of the boards.
class FbCard extends StatelessWidget {
  const FbCard({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final r = radius ?? (wide ? 16 : 14);
    if (wide) {
      return WebCard(radius: r, padding: padding, child: child);
    }
    final c = context.fb;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: dark ? Border.all(color: c.cardEdge) : null,
        borderRadius: BorderRadius.circular(r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The 13 px grey line under a card (7 px below it on the phone, 8 on wide).
class FbFootnote extends StatelessWidget {
  const FbFootnote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(16, context.fbWide ? 8 : 7, 16, 0),
        child: Text(
          text,
          style: context.fbText(
            13,
            height: 1.4,
            color: context.fb.secondaryLabel,
          ),
        ),
      );
}

/// "SEND FEEDBACK" and "SENT": 13 px, w600, .26 spacing, above a card.
class FbSectionHeader extends StatelessWidget {
  const FbSectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, context.fbWide ? 8 : 7),
        child: Semantics(
          header: true,
          child: Text(
            text,
            style: context.fbText(
              13,
              weight: FontWeight.w600,
              spacing: .26,
              color: context.fb.secondaryLabel,
            ),
          ),
        ),
      );
}

/// A board button: filled, tinted or disabled. 52 px on the phone and 44 px on
/// wide web, with the radius and label size of each board.
class FbButton extends StatelessWidget {
  const FbButton({
    required this.onPressed,
    required this.child,
    this.tint = false,
    this.busy = false,
    this.minWidth,
    this.compact = false,
    super.key,
  });

  /// Null draws the disabled button.
  final VoidCallback? onPressed;
  final Widget child;

  /// The tint button ("Back to Feedback").
  final bool tint;

  /// Looks pressed-in and enabled but ignores taps (a spinner is showing).
  final bool busy;
  final double? minWidth;

  /// The 44 px button at natural width on both layouts ("Back to Feedback").
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.fbTokens;
    final c = t.colors;
    final wide = context.fbWide;
    final small = wide || compact;
    final height = small ? 44.0 : 52.0;
    final radius = small ? 12.0 : 14.0;
    final enabled = onPressed != null || busy;
    final foreground = !enabled
        ? t.disabledText
        : tint
            ? c.accentTintText
            : Colors.white;
    Color background(Set<WidgetState> states) {
      if (!enabled) return t.disabledBackground;
      final hover = wide && states.contains(WidgetState.hovered);
      if (tint) return hover ? t.secondaryHover : c.accentTint;
      return hover ? t.accentHover : c.accentFill;
    }

    final motion = MediaQuery.disableAnimationsOf(context);
    final button = TextButton(
      onPressed: busy ? () {} : onPressed,
      style: ButtonStyle(
        animationDuration: motion ? Duration.zero : _quick,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        minimumSize: WidgetStatePropertyAll(
          Size(small ? (minWidth ?? 0) : double.infinity, height),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: small ? 20 : 16),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(background),
        foregroundColor: WidgetStatePropertyAll(foreground),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStateProperty.resolveWith(
          (s) => webKeyboardFocus(s)
              ? BorderSide(color: c.accent, width: 2)
              : BorderSide.none,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        textStyle: WidgetStatePropertyAll(
          context.fbText(
            small ? 16 : 17,
            weight: FontWeight.w600,
            spacing: small ? 0 : -.204,
          ),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: child,
      ),
    );
    final pressable = PressScale(
      scale: small ? .96 : .98,
      enabled: enabled && !busy,
      child: button,
    );
    if (!small) return pressable;
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: pressable,
    );
  }
}

const _quick = Duration(milliseconds: 160);

/// The app's toast: a snack bar over the page, one at a time.
void fbToast(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
