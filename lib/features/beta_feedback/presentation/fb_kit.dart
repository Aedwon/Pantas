import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
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
import 'package:pantas/core/ui/web/web_layout.dart';

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

/// The page's roles and width tier for the Feedback pieces. One palette
/// serves both layouts (design system 4.0).
extension FbContext on BuildContext {
  PantasColors get fb => colors;
  bool get fbWide => wideWeb;

  /// Body text: `web-body` on wide, `phone-body` on the phone.
  TextStyle get fbBody => (fbWide ? PantasType.webBody : PantasType.phoneBody)
      .copyWith(color: fb.textPrimary);

  /// A title in a row or a card: `web-title-sm` on wide, `phone-headline` on
  /// the phone.
  TextStyle get fbTitle =>
      (fbWide ? PantasType.webTitleSm : PantasType.phoneHeadline)
          .copyWith(color: fb.textPrimary);

  /// A line of detail: `web-sub` on wide, `phone-explanation` on the phone.
  TextStyle get fbSub =>
      (fbWide ? PantasType.webSub : PantasType.phoneExplanation)
          .copyWith(color: fb.textSecondary);

  /// Fine print: `web-small` on wide, `phone-footnote` on the phone.
  TextStyle get fbSmall =>
      (fbWide ? PantasType.webSmall : PantasType.phoneFootnote)
          .copyWith(color: fb.textSecondary);
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

/// "Nov" for a month number, 1 to 12.
String monthAbbr(int month) => _months[(month - 1) % 12];

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

/// The raised BETA mark after a title (`web-pro` type, 4 after).
class BetaMark extends StatelessWidget {
  const BetaMark({this.top = PantasSpace.s4, super.key});
  final double top;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.only(top: top, left: PantasSpace.s4),
          child: Text(
            'BETA',
            style: PantasType.webPro.copyWith(color: context.fb.accent),
          ),
        ),
      );
}

/// A title with the BETA mark after it.
class BetaTitle extends StatelessWidget {
  const BetaTitle({
    required this.title,
    required this.style,
    this.markTop = PantasSpace.s4,
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
    this.dy = PantasSpace.s10,
    this.duration = PantasDurations.flip,
    this.delay = Duration.zero,
    this.curve = PantasCurves.enter,
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
    this.duration = PantasDurations.long1,
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
            final e = PantasCurves.spring.transform(t / .6);
            scale = .4 + (peak - .4) * e;
            opacity = e.clamp(0.0, 1.0);
          } else {
            final e = PantasCurves.spring.transform((t - .6) / .4);
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
    this.duration = PantasDurations.switchDuration,
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
          progress: PantasCurves.draw.transform(t),
        ),
      );
}

/// The button spinner: an 18 ring, 2.4 thick (`size-ring-stroke`), an
/// `on-accent` arc turning every `dur-long-3`. Under reduced motion it holds
/// still.
class FbSpinner extends StatefulWidget {
  const FbSpinner({this.color, super.key});

  /// Null draws the arc in `on-accent`.
  final Color? color;

  @override
  State<FbSpinner> createState() => _FbSpinnerState();
}

class _FbSpinnerState extends State<FbSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: PantasDurations.long3,
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
            size: const Size.square(PantasSpace.s18),
            painter: _SpinnerPainter(widget.color ?? context.fb.onAccent),
          ),
        ),
      );
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const width = PantasSize.ringStroke;
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
    final r = radius ?? PantasRadius.xl;
    if (wide) {
      return WebCard(radius: r, padding: padding, child: child);
    }
    final c = context.fb;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        border: dark ? Border.all(color: c.edgeCard) : null,
        borderRadius: BorderRadius.circular(r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The Field well of the design system: `surface-card`, `radius-md`, a 1
/// `border-control` ring, and a 2 `accent` ring when [lit] (focus, or an
/// answer with text). The ring is drawn over the well and takes up no room.
class FbFieldWell extends StatelessWidget {
  const FbFieldWell({
    required this.child,
    required this.lit,
    this.padding = const EdgeInsets.symmetric(
      vertical: PantasSpace.s12,
      horizontal: PantasSpace.s14,
    ),
    this.boxKey,
    super.key,
  });
  final Widget child;
  final bool lit;
  final EdgeInsetsGeometry padding;

  /// The key of the animated box, for tests.
  final Key? boxKey;

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    final radius = BorderRadius.circular(PantasRadius.md);
    return AnimatedContainer(
      key: boxKey,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : PantasDurations.short2,
      curve: PantasCurves.fade,
      padding: padding,
      decoration: BoxDecoration(color: c.surfaceCard, borderRadius: radius),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: lit ? c.accent : c.borderControl,
          width: lit ? PantasBorder.ringSelected : PantasBorder.ring,
        ),
      ),
      child: child,
    );
  }
}

/// The grey line under a card (`web-small` on wide, `phone-footnote` on the
/// phone), 8 below the card on wide and 6 on the phone.
class FbFootnote extends StatelessWidget {
  const FbFootnote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
          PantasSpace.s16,
          context.fbWide ? PantasSpace.s8 : PantasSpace.s6,
          PantasSpace.s16,
          PantasSpace.s0,
        ),
        child: Text(
          text,
          style:
              (context.fbWide ? PantasType.webSmall : PantasType.phoneFootnote)
                  .copyWith(color: context.fb.textSecondary),
        ),
      );
}

/// "SEND FEEDBACK" and "SENT": the section header type (`web-eyebrow` on
/// wide, `phone-section-header` on the phone) above a card.
class FbSectionHeader extends StatelessWidget {
  const FbSectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
          PantasSpace.s16,
          PantasSpace.s0,
          PantasSpace.s16,
          context.fbWide ? PantasSpace.s8 : PantasSpace.s6,
        ),
        child: Semantics(
          header: true,
          child: Text(
            text,
            style: (context.fbWide
                    ? PantasType.webEyebrow
                    : PantasType.phoneSectionHeader)
                .copyWith(color: context.fb.textSecondary),
          ),
        ),
      );
}

/// The Feedback button: primary, or the secondary tint. It takes the height,
/// radius, padding and label type of the Button measurements: the standard
/// 44 on wide web (and for [compact]), the 52 phone button on the phone.
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

  /// The secondary (tint) button ("Back to Feedback").
  final bool tint;

  /// Looks pressed-in and enabled but ignores taps (a spinner is showing).
  final bool busy;
  final double? minWidth;

  /// The 44 button at natural width on both layouts ("Back to Feedback").
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    final wide = context.fbWide;
    final small = wide || compact;
    final metrics = pantasButtonMetrics(
      small ? PantasButtonSize.standard : PantasButtonSize.phone,
      tint ? PantasButtonKind.secondary : PantasButtonKind.primary,
    );
    final enabled = onPressed != null || busy;
    final foreground = !enabled
        ? c.textDisabled
        : tint
            ? c.accentTintText
            : c.onAccent;
    Color background(Set<WidgetState> states) {
      if (!enabled) return c.fill;
      final hover = wide && states.contains(WidgetState.hovered);
      if (tint) return hover ? c.accentTintHover : c.accentTint;
      return hover ? c.accentFillHover : c.accentFill;
    }

    final motion = MediaQuery.disableAnimationsOf(context);
    final button = TextButton(
      onPressed: busy ? () {} : onPressed,
      style: ButtonStyle(
        animationDuration: motion ? Duration.zero : PantasDurations.short2,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        minimumSize: WidgetStatePropertyAll(
          Size(small ? (minWidth ?? 0) : double.infinity, metrics.height),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.only(left: metrics.padLeft, right: metrics.padRight),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(background),
        foregroundColor: WidgetStatePropertyAll(foreground),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStateProperty.resolveWith(
          (s) => webKeyboardFocus(s)
              ? BorderSide(color: c.accent, width: PantasBorder.focus)
              : BorderSide.none,
        ),
        shape: WidgetStatePropertyAll(metrics.shape()),
        textStyle: WidgetStatePropertyAll(metrics.style),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: child,
      ),
    );
    final pressable = PressScale(
      scale: pantasPressScale,
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

/// The app's toast: a snack bar over the page, one at a time, drawn as the
/// design system Toast (`toast-bg`, `toast-text`, `radius-lg`).
void fbToast(BuildContext context, String message) {
  final c = context.fb;
  final wide = context.fbWide;
  ScaffoldMessenger.maybeOf(context)
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: (wide ? PantasType.webRowValue : PantasType.phoneSubhead)
              .copyWith(color: c.toastText),
        ),
        backgroundColor: c.toastBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PantasRadius.lg),
        ),
      ),
    );
}
