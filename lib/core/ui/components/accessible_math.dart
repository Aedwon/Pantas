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
class AccessibleMath extends StatelessWidget {
  const AccessibleMath({
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
    final end = _matchingBrace(latex, i);
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

int? _matchingBrace(String latex, int open) {
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
