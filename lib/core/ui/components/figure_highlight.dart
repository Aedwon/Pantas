/// Lighting one part of a figure while the rest dims to 35%, over 150 ms. The
/// linked words of the old two-column reader that drove it are gone (Nov 29,
/// Immersion); the figure side stays for the geometry painter.
library;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

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
