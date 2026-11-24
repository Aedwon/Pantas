/// A word of the text and the part of the figure it names light each other
/// (spec "Linked words"). Pointing at the word, putting keyboard focus on it,
/// or tapping it makes the part keep its color and thicken while the rest of
/// the figure dims to 35%, over 150 ms. Leaving restores it in 150 ms.
library;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';

/// Which part of which figure is lit, for one lesson.
class FigureHighlights extends ChangeNotifier {
  final _active = <int, String>{};

  /// The label core lit in figure [figure], or null.
  String? of(int figure) => _active[figure];

  void set(int figure, String? label) {
    if (label == null) {
      if (_active.remove(figure) != null) notifyListeners();
    } else if (_active[figure] != label) {
      _active[figure] = label;
      notifyListeners();
    }
  }
}

/// Holds the [FigureHighlights] of a lesson for the words and plates below.
class FigureHighlightScope extends InheritedNotifier<FigureHighlights> {
  const FigureHighlightScope({
    required FigureHighlights highlights,
    required super.child,
    super.key,
  }) : super(notifier: highlights);

  static FigureHighlights? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<FigureHighlightScope>()?.notifier;
}

/// What a figure painter is told: the label core to light, and how far the
/// 150 ms change has come (0 off, 1 fully on).
class LitLabel extends InheritedWidget {
  const LitLabel({
    required this.label,
    required this.amount,
    required super.child,
    this.figure = -1,
    this.plate = false,
    super.key,
  });

  final String? label;
  final double amount;

  /// Which figure of the lesson this is, and whether it sits in a plate of the
  /// figure column, where it is drawn at the board's size.
  final int figure;
  final bool plate;

  static LitLabel? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LitLabel>();

  @override
  bool updateShouldNotify(LitLabel oldWidget) =>
      label != oldWidget.label ||
      amount != oldWidget.amount ||
      figure != oldWidget.figure ||
      plate != oldWidget.plate;
}

/// Tells the figure inside it which of its parts is lit, animated.
class FigureHighlightFor extends StatefulWidget {
  const FigureHighlightFor({
    required this.figure,
    required this.child,
    super.key,
  });

  final int figure;
  final Widget child;

  @override
  State<FigureHighlightFor> createState() => _FigureHighlightForState();
}

class _FigureHighlightForState extends State<FigureHighlightFor> {
  String? _last;

  @override
  Widget build(BuildContext context) {
    // Listens: the plate redraws when its part is lit.
    final highlights = context
        .dependOnInheritedWidgetOfExactType<FigureHighlightScope>()
        ?.notifier;
    final label = highlights?.of(widget.figure);
    // The part stays named while it fades out.
    if (label != null) _last = label;
    final still = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: label == null ? 0 : 1),
      duration: still ? Duration.zero : PantasDurations.short2,
      curve: ease,
      builder: (context, amount, child) => LitLabel(
        label: amount == 0 ? null : _last,
        amount: amount,
        figure: widget.figure,
        plate: true,
        child: child!,
      ),
      child: widget.child,
    );
  }
}

/// The spec's ease-out for a linked word and for the section line: the CSS
/// ease-out, (0, 0, .58, 1). The design system has no ease-out token.
const ease = Cubic(0, 0, 0.58, 1); // ds-geometry: spec motion table, ease-out

/// When the new mark of a solution figure starts to draw, after the figure's
/// own 240 ms arrival, and how long it takes.
const markDrawDelay = Duration(milliseconds: 240);
const markDrawDuration = Duration(milliseconds: 240);

/// How far the new mark has drawn, [elapsed] after the solution opened. With
/// reduced motion the figure only fades in and the mark is simply there.
double markDrawProgress(Duration elapsed, {bool reduced = false}) {
  if (reduced) return 1;
  final t = (elapsed - markDrawDelay).inMicroseconds /
      markDrawDuration.inMicroseconds;
  return PantasCurves.move.transform(t.clamp(0.0, 1.0));
}

/// The labels a solution figure has that its problem figure did not, and how
/// far they have drawn in (0 hidden, 1 drawn).
class NewMarks extends InheritedWidget {
  const NewMarks({
    required this.labels,
    required this.amount,
    required super.child,
    super.key,
  });

  final Set<String> labels;
  final double amount;

  static NewMarks? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NewMarks>();

  @override
  bool updateShouldNotify(NewMarks oldWidget) =>
      amount != oldWidget.amount || labels != oldWidget.labels;
}

/// A word that names a part of the figure beside the text: a dotted underline
/// that turns solid, in the text's own color, when the part is lit.
class LinkedWord extends StatefulWidget {
  const LinkedWord({
    required this.figure,
    required this.label,
    this.text = '',
    this.style = const TextStyle(),
    this.child,
    super.key,
  });

  final int figure;
  final String label;
  final String text;
  final TextStyle style;

  /// A formula that names the part, in place of [text].
  final Widget? child;

  @override
  State<LinkedWord> createState() => _LinkedWordState();
}

class _LinkedWordState extends State<LinkedWord> {
  bool _hover = false;
  bool _focus = false;
  bool _tapped = false;
  FigureHighlights? _highlights;

  bool _external = false;

  bool get _own => _hover || _focus || _tapped;
  bool get _lit => _own || _external;

  void _sync() {
    _highlights?.set(widget.figure, _own ? widget.label : null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _highlights = FigureHighlightScope.maybeOf(context);
  }

  @override
  void dispose() {
    _hover = _focus = _tapped = false;
    _highlights?.set(widget.figure, null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Pointing at the label in the figure underlines its words too.
    final scope = context
        .dependOnInheritedWidgetOfExactType<FigureHighlightScope>()
        ?.notifier;
    _external =
        scope?.of(widget.figure)?.toLowerCase() == widget.label.toLowerCase();
    final still = MediaQuery.disableAnimationsOf(context);
    final duration = still ? Duration.zero : PantasDurations.short2;
    return TapRegion(
      onTapOutside: (_) {
        if (_tapped) {
          setState(() => _tapped = false);
          _sync();
        }
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _hover = true);
          _sync();
        },
        onExit: (_) {
          setState(() => _hover = false);
          _sync();
        },
        child: OffsetFocusRing(
          borderRadius: BorderRadius.circular(PantasRadius.xs),
          child: FocusableActionDetector(
            mouseCursor: SystemMouseCursors.basic,
            onShowFocusHighlight: (v) {
              setState(() => _focus = v);
              _sync();
            },
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  setState(() => _tapped = !_tapped);
                  _sync();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _tapped = !_tapped);
                _sync();
              },
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: _lit
                      ? c.readerStrong
                      : (widget.style.color ?? c.readerBody),
                ),
                duration: duration,
                curve: ease,
                builder: (context, color, _) => CustomPaint(
                  foregroundPainter: LinkUnderline(
                    color: _lit ? c.readerStrong : c.tertiaryLabel,
                    solid: _lit,
                  ),
                  child: widget.child ??
                      Text(
                        widget.text,
                        style: widget.style.copyWith(color: color),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1.5 px, dotted, a few px under the baseline; solid when lit.
@visibleForTesting
class LinkUnderline extends CustomPainter {
  const LinkUnderline({required this.color, required this.solid});
  final Color color;
  final bool solid;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final y = size.height - 1;
    if (solid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    for (var x = .75; x < size.width; x += 3) {
      canvas.drawCircle(Offset(x, y), .75, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(LinkUnderline old) =>
      old.color != color || old.solid != solid;
}
