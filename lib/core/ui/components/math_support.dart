import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Renders one mathematical expression as a coherent, responsive unit.
///
/// `flutter_math_fork` lays a TeX expression out as one unbroken `RenderLine`.
/// At large text sizes that line can be wider than a narrow lesson reader. A
/// scale-down fit gives the math an unbounded measurement pass, then scales
/// only expressions that actually exceed the available width. Expressions
/// that already fit keep their existing size.
///
/// The semantic node replaces the renderer's glyph-level descendants so a
/// screen reader encounters one useful expression instead of one token per
/// focus stop.
class MathExpression extends StatelessWidget {
  const MathExpression({
    required this.latex,
    this.mathStyle = MathStyle.display,
    this.textStyle,
    this.textScaleFactor,
    this.semanticsLabel,
    this.fitAlignment = Alignment.center,
    this.onErrorFallback,
    super.key,
  });

  final String latex;
  final MathStyle mathStyle;
  final TextStyle? textStyle;
  final double? textScaleFactor;
  final String? semanticsLabel;
  final AlignmentGeometry fitAlignment;
  final WidgetBuilder? onErrorFallback;

  @override
  Widget build(BuildContext context) {
    final math = Math.tex(
      groupedThousands(latex),
      mathStyle: mathStyle,
      // The package turns any weight other than normal into an upright serif
      // override of every letter, so a bold line or a callout set its math
      // upright. KaTeX math keeps the regular weight and its own italics.
      textStyle: textStyle?.copyWith(fontWeight: FontWeight.normal),
      textScaleFactor: textScaleFactor,
      onErrorFallback: (_) =>
          onErrorFallback?.call(context) ?? Text(latex, style: textStyle),
    );

    // Preserve the package's malformed-TeX fallback rather than giving an
    // invalid expression a derived spoken label.
    if (math.parseError != null) return _DryBaselineSafe(child: math);

    final authoredLabel = semanticsLabel?.trim();
    final label = authoredLabel == null || authoredLabel.isEmpty
        ? mathSemanticsLabel(latex)
        : authoredLabel;

    return _DryBaselineSafe(
      child: Semantics(
        container: true,
        label: label,
        excludeSemantics: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: fitAlignment,
          child: math,
        ),
      ),
    );
  }
}

/// Lets a TeX box answer a dry baseline query.
///
/// `flutter_math_fork` does not implement `computeDryBaseline`. A paragraph
/// asks for it while it measures a cell for an intrinsic width, as a table
/// does, and a debug build then throws. The answer given here is used only for
/// that measuring pass. The real layout still reads the package's own
/// baseline, so inline maths keeps its place on the line.
class _DryBaselineSafe extends SingleChildRenderObjectWidget {
  const _DryBaselineSafe({required Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderDryBaselineSafe();
}

class _RenderDryBaselineSafe extends RenderProxyBox {
  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) =>
      // The box's bottom edge. Close enough for a measuring pass; it never
      // positions anything on screen.
      child?.getDryLayout(constraints).height ?? 0;
}

/// Produces a deterministic spoken fallback for the LaTeX used by Pantas.
///
/// This intentionally is not a general mathematical speech engine. It
/// removes common TeX syntax noise and verbalizes the operators and grouping
/// used by the current lesson and question corpus without changing the math.
String mathSemanticsLabel(String latex) {
  var text = latex.trim();
  text = text
      .replaceAll(r'\left', '')
      .replaceAll(r'\right', '')
      .replaceAll(r'\,', ' ')
      .replaceAll(r'\;', ' ')
      .replaceAll(r'\!', ' ');

  text = _fractionsForSpeech(text);
  text = _squareRootsForSpeech(text);
  text = _scriptsForSpeech(text, '^', 'to the power of');
  text = _scriptsForSpeech(text, '_', 'subscript');

  const commands = <String, String>{
    r'\times': ' times ',
    r'\cdot': ' times ',
    r'\div': ' divided by ',
    r'\pm': ' plus or minus ',
    r'\leq': ' less than or equal to ',
    r'\le': ' less than or equal to ',
    r'\geq': ' greater than or equal to ',
    r'\ge': ' greater than or equal to ',
    r'\neq': ' not equal to ',
    r'\approx': ' approximately ',
    r'\pi': ' pi ',
    r'\theta': ' theta ',
    r'\alpha': ' alpha ',
    r'\beta': ' beta ',
    r'\gamma': ' gamma ',
    r'\delta': ' delta ',
    r'\lambda': ' lambda ',
    r'\mu': ' mu ',
    r'\sigma': ' sigma ',
  };
  for (final entry in commands.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }

  // Unknown named commands remain more readable without the literal slash.
  text = text.replaceAllMapped(
    RegExp(r'\\([A-Za-z]+)'),
    (match) => ' ${match.group(1)} ',
  );
  text = text
      .replaceAll(r'\%', ' percent ')
      .replaceAll('=', ' equals ')
      .replaceAll('+', ' plus ')
      .replaceAll('-', ' minus ')
      .replaceAll('/', ' divided by ')
      .replaceAll('(', ' open parenthesis ')
      .replaceAll(')', ' close parenthesis ')
      .replaceAll('[', ' open bracket ')
      .replaceAll(']', ' close bracket ')
      .replaceAll(RegExp('[{}]'), ' ');

  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _fractionsForSpeech(String latex) {
  final out = StringBuffer();
  var i = 0;
  while (i < latex.length) {
    final command = _fractionCommandAt(latex, i);
    if (command == null) {
      out.write(latex[i]);
      i++;
      continue;
    }

    final numerator = _readLatexArgument(latex, i + command.length);
    if (numerator == null) {
      out.write(command);
      i += command.length;
      continue;
    }
    final denominator = _readLatexArgument(latex, numerator.next);
    if (denominator == null) {
      out.write(command);
      i += command.length;
      continue;
    }

    out
      ..write(' ')
      ..write(mathSemanticsLabel(numerator.value))
      ..write(' over ')
      ..write(mathSemanticsLabel(denominator.value))
      ..write(' ');
    i = denominator.next;
  }
  return out.toString();
}

String _squareRootsForSpeech(String latex) {
  const command = r'\sqrt';
  final out = StringBuffer();
  var i = 0;
  while (i < latex.length) {
    if (!latex.startsWith(command, i)) {
      out.write(latex[i]);
      i++;
      continue;
    }
    final argument = _readLatexArgument(latex, i + command.length);
    if (argument == null) {
      out.write(command);
      i += command.length;
      continue;
    }
    out
      ..write(' square root of ')
      ..write(mathSemanticsLabel(argument.value))
      ..write(' ');
    i = argument.next;
  }
  return out.toString();
}

String _scriptsForSpeech(String latex, String marker, String phrase) {
  final out = StringBuffer();
  var i = 0;
  while (i < latex.length) {
    if (latex[i] != marker) {
      out.write(latex[i]);
      i++;
      continue;
    }
    final argument = _readLatexArgument(latex, i + 1);
    if (argument == null) {
      out.write(marker);
      i++;
      continue;
    }
    out
      ..write(' ')
      ..write(phrase)
      ..write(' ')
      ..write(mathSemanticsLabel(argument.value))
      ..write(' ');
    i = argument.next;
  }
  return out.toString();
}

const _fractionCommands = <String>[r'\dfrac', r'\tfrac', r'\frac'];

String? _fractionCommandAt(String latex, int index) {
  for (final command in _fractionCommands) {
    if (latex.startsWith(command, index)) return command;
  }
  return null;
}

({String value, int next})? _readLatexArgument(String latex, int start) {
  var i = start;
  while (i < latex.length && latex[i] == ' ') {
    i++;
  }
  if (i >= latex.length) return null;

  if (latex[i] == '{') {
    final end = _matchingSpeechBrace(latex, i);
    if (end == null) return null;
    return (value: latex.substring(i + 1, end), next: end + 1);
  }

  if (latex[i] == r'\') {
    var end = i + 1;
    while (end < latex.length && _isAsciiLetter(latex[end])) {
      end++;
    }
    if (end == i + 1) end = (i + 2).clamp(0, latex.length);
    return (value: latex.substring(i, end), next: end);
  }

  return (value: latex[i], next: i + 1);
}

int? _matchingSpeechBrace(String latex, int open) {
  var depth = 0;
  for (var i = open; i < latex.length; i++) {
    if (latex[i] == '{') {
      depth++;
    } else if (latex[i] == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return null;
}

bool _isAsciiLetter(String char) {
  final code = char.codeUnitAt(0);
  return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
}

/// Builds the sentence-level accessibility text for a string containing
/// inline `$…$` maths.
///
/// A malformed expression returns `null` so callers keep the renderer's
/// existing fallback semantics instead of announcing a derived math label.
({String label, bool hasMath})? inlineMathSemantics(String text) {
  if (!text.contains(r'$')) return (label: text, hasMath: false);

  final matches = RegExp(r'\$([^$]+)\$').allMatches(text).toList();
  if (matches.isEmpty) return (label: text, hasMath: false);

  final label = StringBuffer();
  var lastEnd = 0;
  for (final match in matches) {
    label.write(text.substring(lastEnd, match.start));
    final mathLabel = inlineMathExpressionSemanticsLabel(match.group(1) ?? '');
    if (mathLabel == null) return null;
    label.write(mathLabel);
    lastEnd = match.end;
  }
  label.write(text.substring(lastEnd));
  return (label: label.toString(), hasMath: true);
}

/// Returns the existing Pantas math speech only when the inline TeX parses.
String? inlineMathExpressionSemanticsLabel(String latex) {
  final displayedLatex = displayFractions(latex);
  final math = Math.tex(displayedLatex, mathStyle: MathStyle.text);
  if (math.parseError != null) return null;
  return mathSemanticsLabel(displayedLatex);
}

/// Splits a plain string on `$…$` and sets each enclosed run as maths.
///
/// A string with no dollars comes back as one plain span, so this is safe to
/// use everywhere rather than only where maths is expected.
List<InlineSpan> inlineMathSpans(
  String text, {
  TextStyle? style,
  WidgetBuilder? onErrorFallback,
}) {
  if (!text.contains(r'$')) {
    return [TextSpan(text: text, style: style)];
  }

  final spans = <InlineSpan>[];
  var lastEnd = 0;
  for (final match in RegExp(r'\$([^$]+)\$').allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(
        TextSpan(text: text.substring(lastEnd, match.start), style: style),
      );
    }
    spans.add(
      inlineMathSpan(
        match.group(1) ?? '',
        style: style,
        onErrorFallback: onErrorFallback,
      ),
    );
    lastEnd = match.end;
  }
  if (spans.isEmpty) {
    return [TextSpan(text: text, style: style)];
  }
  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd), style: style));
  }
  return keepPunctuationWithMath(spans);
}

final _hugging = RegExp(r'^[.,;:!?)\]]+');

/// Moves a period, comma or other closing mark that sits right after a
/// formula into the formula's own box, so a line never breaks between them
/// and leaves the mark alone at the start of the next line.
///
/// A formula is one box in the line, and the text after it is a separate run,
/// so the line may break between the two. Only marks that follow the formula
/// with no space move; "x^2 ." keeps its space.
List<InlineSpan> keepPunctuationWithMath(List<InlineSpan> spans) {
  final out = <InlineSpan>[];
  for (var i = 0; i < spans.length; i++) {
    final span = spans[i];
    final next = i + 1 < spans.length ? spans[i + 1] : null;
    final text = next is TextSpan && next.children == null ? next.text : null;
    final mark =
        span is WidgetSpan && text != null ? _hugging.firstMatch(text) : null;
    if (span is! WidgetSpan || mark == null || next is! TextSpan) {
      out.add(span);
      continue;
    }
    out.add(
      WidgetSpan(
        alignment: span.alignment,
        baseline: span.baseline,
        style: span.style,
        child: _MathWithMark(
          mark: mark.group(0)!,
          style: next.style,
          child: span.child,
        ),
      ),
    );
    final rest = text!.substring(mark.end);
    if (rest.isNotEmpty) {
      out.add(
        TextSpan(
          text: rest,
          style: next.style,
          recognizer: next.recognizer,
          semanticsLabel: next.semanticsLabel,
        ),
      );
    }
    i++;
  }
  return out;
}

/// A formula followed by the mark that closes its sentence or clause.
class _MathWithMark extends StatelessWidget {
  const _MathWithMark({
    required this.mark,
    required this.style,
    required this.child,
  });
  final String mark;
  final TextStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // The formula may still scale down to fit a narrow line, so it takes
          // what the mark leaves.
          Flexible(child: child),
          // The paragraph that holds this box scales it once, so the mark must
          // not scale itself a second time.
          Text(mark, style: style, textScaler: TextScaler.noScaling),
        ],
      );
}

/// Inline maths is set this much larger than the sentence around it, to match
/// the optical size of Geist. See [inlineMathSpan].
const inlineMathSizeFactor = 1.1;

/// Maths set on the surrounding line rather than under it.
///
/// A `WidgetSpan` sits on the bottom of the line by default, which drops a
/// formula below the words beside it, and `Math.tex` with no style of its own
/// renders at the package's size rather than the body's. Both were visible in
/// one glance: the number sat low and small.
InlineSpan inlineMathSpan(
  String latex, {
  TextStyle? style,
  WidgetBuilder? onErrorFallback,
}) {
  // A bare number such as 1987 or 22 has nothing to typeset. Set in KaTeX it
  // switches to a serif face in the middle of a sans sentence, so it stays text
  // in the body font. Any real expression keeps the math face.
  final numeral = latex.trim();
  if (_bareNumeral.hasMatch(numeral)) {
    return TextSpan(text: numeral, style: style);
  }
  // A plain counting list reads with the numbers around it in the sentence.
  if (_numberList.hasMatch(numeral)) {
    return TextSpan(
      text: numeral
          .replaceAll(RegExp(r'\\[lc]?dots|\\ldots'), '...')
          .replaceAll(RegExp(r'\s*,\s*'), ', '),
      style: style,
    );
  }
  // A section number such as 5(1) or 3(b) reads as words in the sentence
  // around it, so it stays in the body font. One citation then does not mix
  // two faces.
  if (_citation.hasMatch(numeral)) {
    return TextSpan(text: numeral, style: style);
  }
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Builder(
      builder: (context) {
        final inherited = DefaultTextStyle.of(context).style;
        final body = style ?? inherited;
        // KaTeX figures stand 0.666 em tall and its x-height is 0.431 em.
        // Geist figures stand 0.71 em and its x-height is 0.53 em. At the same
        // font size the maths reads smaller and sits low against the words,
        // although both share one baseline. Sizing it up evens the two.
        final sized = body.copyWith(
          fontSize: (body.fontSize ?? inherited.fontSize ?? 14) *
              inlineMathSizeFactor,
        );

        // Text.rich automatically scales every WidgetSpan child with its
        // active TextScaler. Keep the TeX source size unscaled here and disable
        // flutter_math_fork's legacy scalar so the outer paragraph applies
        // Android's nonlinear accessibility scale exactly once.
        return MathExpression(
          latex: displayFractions(latex),
          mathStyle: MathStyle.text,
          textStyle: sized,
          textScaleFactor: 1,
          fitAlignment: Alignment.centerLeft,
          onErrorFallback: onErrorFallback,
        );
      },
    ),
  );
}

/// A number with lettered or numbered parts in parentheses, as in a legal
/// citation: `5(1)`, `261(a)`, `1(a)(2)`.
final _citation = RegExp(r'^\d+(?:\([0-9]{1,2}\)|\([a-z]\))+$');

/// Plain non-negative numbers separated by commas, which may end in dots:
/// `1,2,3,\dots`.
final _numberList = RegExp(
  r'^\d+(?:\s*,\s*\d+)+(?:\s*,\s*\\[lc]?dots)?$',
);

final _bareNumeral = RegExp(
  r'^(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$',
);

final _thousandsRun = RegExp(r'(?<![\d,])\d{1,3}(?:,\d{3})+(?!\d)');

/// Binds the commas of a number written with thousands separators, so TeX does
/// not add the space it puts after a punctuation comma ("27, 000").
///
/// Only a run of one to three digits followed by comma groups of exactly three
/// counts, so a list such as `20,22,25,26,300` keeps its list spacing.
String groupedThousands(String latex) => latex.contains(',')
    ? latex.replaceAllMapped(
        _thousandsRun,
        (match) => match.group(0)!.replaceAll(',', '{,}'),
      )
    : latex;

const _fracCommands = <String>[r'\dfrac', r'\tfrac', r'\frac'];

/// Promotes a top level `\frac` to `\dfrac`.
///
/// Inline, `\frac` sets its numerator and denominator at script size, which
/// on a phone is too small to read. `\dfrac` keeps them at full size.
///
/// **Only at the top level.** A fraction nested inside another is meant to be
/// smaller, and the bank holds 21 of those with 7 more in the lessons, so
/// rewriting every `\frac` would break the ones that are correct. An argument
/// of a fraction is therefore copied through untouched.
String displayFractions(String latex) {
  if (!latex.contains(r'\frac')) return latex;

  final out = StringBuffer();
  var i = 0;
  while (i < latex.length) {
    final command = _commandAt(latex, i);
    if (command == null) {
      out.write(latex[i]);
      i++;
      continue;
    }
    out.write(command == r'\frac' ? r'\dfrac' : command);
    i = _copyArguments(latex, i + command.length, 2, out);
  }
  return out.toString();
}

String? _commandAt(String latex, int i) {
  for (final command in _fracCommands) {
    if (latex.startsWith(command, i)) return command;
  }
  return null;
}

/// Copies [count] LaTeX arguments verbatim, so anything nested inside them
/// keeps the size its author chose. Returns the index just past the last one.
int _copyArguments(String latex, int start, int count, StringBuffer out) {
  var i = start;
  var copied = 0;
  while (copied < count && i < latex.length) {
    final char = latex[i];
    if (char == ' ') {
      out.write(char);
      i++;
    } else if (char == '{') {
      final end = _matchingBrace(latex, i);
      out.write(latex.substring(i, end + 1));
      i = end + 1;
      copied++;
    } else if (char == r'\') {
      // A command as an argument, `\frac\alpha\beta`.
      var end = i + 1;
      while (end < latex.length && _isLetter(latex[end])) {
        end++;
      }
      if (end == i + 1) end = i + 2;
      out.write(latex.substring(i, end));
      i = end;
      copied++;
    } else {
      // A single token, `\frac12`.
      out.write(char);
      i++;
      copied++;
    }
  }
  return i;
}

/// The index of the `}` closing the `{` at [open], or the end of the string
/// when the maths is malformed, which `Math.tex` reports for itself.
int _matchingBrace(String latex, int open) {
  var depth = 0;
  for (var i = open; i < latex.length; i++) {
    if (latex[i] == '{') {
      depth++;
    } else if (latex[i] == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return latex.length - 1;
}

bool _isLetter(String char) {
  final code = char.codeUnitAt(0);
  return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
}
