import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:pantas/core/ui/components/accessible_math.dart';

/// A line of text that may carry `$…$` maths.
///
/// The single place a plain string becomes maths. Answer choices, which are
/// plain strings rather than lesson blocks, went to the screen through `Text`
/// and printed their dollar signs: 645 of the 2,000 questions in the bank
/// carry maths in a choice.
class InlineMathText extends StatelessWidget {
  const InlineMathText(
    this.text, {
    this.style,
    this.textAlign,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: inlineMathSpans(text, style: style)),
      style: style,
      textAlign: textAlign,
    );
  }
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
        final body = style ??
            TextStyle(
              fontSize: inherited.fontSize,
              color: inherited.color,
              fontWeight: inherited.fontWeight,
            );
        return AccessibleMath(
          latex: displayFractions(latex),
          mathStyle: MathStyle.text,
          textStyle: body,
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
