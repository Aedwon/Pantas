import 'package:flutter/material.dart';
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
      latex,
      mathStyle: mathStyle,
      textStyle: textStyle,
      textScaleFactor: textScaleFactor,
      onErrorFallback: (_) =>
          onErrorFallback?.call(context) ?? Text(latex, style: textStyle),
    );

    // Preserve the package's malformed-TeX fallback rather than giving an
    // invalid expression a derived spoken label.
    if (math.parseError != null) return math;

    final authoredLabel = semanticsLabel?.trim();
    final label = authoredLabel == null || authoredLabel.isEmpty
        ? mathSemanticsLabel(latex)
        : authoredLabel;

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: fitAlignment,
        child: math,
      ),
    );
  }
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
  return spans;
}

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
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Builder(
      builder: (context) {
        final inherited = DefaultTextStyle.of(context).style;
        final body = style ?? inherited;

        // Text.rich automatically scales every WidgetSpan child with its
        // active TextScaler. Keep the TeX source size unscaled here and disable
        // flutter_math_fork's legacy scalar so the outer paragraph applies
        // Android's nonlinear accessibility scale exactly once.
        return MathExpression(
          latex: displayFractions(latex),
          mathStyle: MathStyle.text,
          textStyle: body,
          textScaleFactor: 1,
          fitAlignment: Alignment.centerLeft,
          onErrorFallback: onErrorFallback,
        );
      },
    ),
  );
}

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
