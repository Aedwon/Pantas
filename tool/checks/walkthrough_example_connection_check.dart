import 'dart:convert';

import 'check.dart';
import 'lesson_size_check.dart';

final _frontmatterPattern = RegExp(
  r'^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)',
);
final _commentPattern = RegExp(r'<!--[\s\S]*?-->');
final _walkthroughMarkerPattern = RegExp(
  r'^:::(?:pair|checklist|check|try)(?:\s|$)',
  multiLine: true,
);
final _headingPattern = RegExp(r'^#{1,6}(?:\s|$)');
final _numberedStepPattern = RegExp(r'^\d+\.\s');
final _bareLabelPattern = RegExp(
  r'^(?:solution|for\s+example|examples?(?:\s+#?\d+)?|formula|rule|'
  r'shortcut|speed\s+trick|method(?:\s+\d+)?|way\s+\d+|step\s+\d+|check)'
  r'\s*:?$',
  caseSensitive: false,
);
final _bareConditionPattern = RegExp(
  r'^(?:if|when)\b.*:\s*$',
  caseSensitive: false,
);
final _actionVerbPattern = RegExp(
  r'\b(?:substitut(?:e|es|ed|ing)|find(?:s|ing)?|evaluat(?:e|es|ed|ing)|'
  'compar(?:e|es|ed|ing)|solv(?:e|es|ed|ing)|check(?:s|ed|ing)?|'
  'multipl(?:y|ies|ied|ying)|divid(?:e|es|ed|ing)|add(?:s|ed|ing)?|'
  'subtract(?:s|ed|ing)?|put(?:s|ting)?|plug(?:s|ged|ging)?|'
  'test(?:s|ed|ing)?|appl(?:y|ies|ied|ying)|chang(?:e|es|ed|ing)|'
  r'us(?:e|es|ed|ing)|let(?:\x27s|s)|replac(?:e|es|ed|ing)|'
  'writ(?:e|es|ten|ing)|comput(?:e|es|ed|ing)|calculat(?:e|es|ed|ing)|'
  'simplif(?:y|ies|ied|ying)|expand(?:s|ed|ing)?|factor(?:s|ed|ing)?|'
  'combin(?:e|es|ed|ing)|convert(?:s|ed|ing)?|reduc(?:e|es|ed|ing)|'
  'set(?:s|ting)?|tr(?:y|ies|ied|ying)|get(?:s|ting)?|tak(?:e|es|en|ing)|'
  'count(?:s|ed|ing)?|keep(?:s|ing)?|mov(?:e|es|ed|ing)|'
  'shift(?:s|ed|ing)?|split(?:s|ting)?|read(?:s|ing)?|'
  'identif(?:y|ies|ied|ying)|cancel(?:s|ed|led|ing|ling)?|'
  'express(?:es|ed|ing)?|rewrit(?:e|es|ten|ing)|form(?:s|ed|ing)?|'
  'show(?:s|ed|n|ing)?|see(?:s|ing)?|watch(?:es|ed|ing)?|'
  r'look(?:s|ed|ing)?|work\s+out)\b',
  caseSensitive: false,
);
final _latexCommandPattern = RegExp(
  r'\\(?:dfrac|frac|times|div|cdot|sqrt|pi|pm|approx|left|right|quad|qquad|'
  r'text|mathrm)\b',
);
final _plainIntegerPattern = RegExp(
  r'^[+-]?(?:\d{1,3}(?:,\d{3})+|\d+)$',
);
final _simpleNumberPattern = RegExp(
  r'^[+-]?(?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?(?:\\%|%)?$',
);
final _simpleFractionPattern = RegExp(
  r'^[+-]?\\d?frac\{[+-]?(?:\d{1,3}(?:,\d{3})+|\d+)\}'
  r'\{[+-]?(?:\d{1,3}(?:,\d{3})+|\d+)\}$',
);
final _mixedNumberPattern = RegExp(
  r'^[+-]?\d+\\d?frac\{\d+\}\{\d+\}$',
);
final _simpleRadicalPattern = RegExp(
  r'^[+-]?(?:\d+)?\\sqrt\{\d+\}$|'
  r'^[+-]?\\d?frac\{(?:\d+)?\\sqrt\{\d+\}\}\{\d+\}$',
);
final _simplePiPattern = RegExp(
  r'^[+-]?(?:\d+(?:\.\d+)?|\\d?frac\{\d+\}\{\d+\})?\\pi$',
);
final _singlePowerPattern = RegExp(r'^\d+\^\d+$');

class _DisplayBlock {
  _DisplayBlock({
    required this.line,
    required this.math,
    required this.section,
    required this.inExampleNumberedSteps,
    required this.prevNonBlankLine,
    required this.isContinuationOfGroup,
  });

  final int line;
  final String math;
  final String section;
  final bool inExampleNumberedSteps;
  final String? prevNonBlankLine;
  final bool isContinuationOfGroup;
}

String _blankCommentsKeepLines(String text) => text.replaceAllMapped(
      _commentPattern,
      (match) => match.group(0)!.replaceAll(RegExp(r'[^\n]'), ' '),
    );

bool _isWalkthroughBody(String commentBlankedBody) =>
    _walkthroughMarkerPattern.hasMatch(commentBlankedBody);

List<_DisplayBlock> _extractDisplayBlocks(String commentBlankedBody) {
  final lines = const LineSplitter().convert(commentBlankedBody);
  final blocks = <_DisplayBlock>[];
  var section = '';
  var inExampleNumberedSteps = false;
  var inDirective = false;
  String? prevNonBlankLine;
  var prevWasDisplay = false;

  var i = 0;
  while (i < lines.length) {
    final trimmed = lines[i].trim();
    if (trimmed.isEmpty) {
      i++;
      continue;
    }

    if (trimmed.startsWith(':::')) {
      inDirective = trimmed != ':::';
      prevNonBlankLine = trimmed;
      prevWasDisplay = false;
      i++;
      continue;
    }

    if (inDirective) {
      i++;
      continue;
    }

    if (trimmed.startsWith('## ')) {
      section = trimmed.substring(3).trim().toLowerCase();
      inExampleNumberedSteps = false;
      prevNonBlankLine = trimmed;
      prevWasDisplay = false;
      i++;
      continue;
    }

    if (trimmed.startsWith('### ')) {
      inExampleNumberedSteps = false;
      prevNonBlankLine = trimmed;
      prevWasDisplay = false;
      i++;
      continue;
    }

    if (section == 'examples' && _numberedStepPattern.hasMatch(trimmed)) {
      inExampleNumberedSteps = true;
    }

    if (trimmed.startsWith(r'$$')) {
      final startLine = i + 1;
      String? math;
      if (trimmed.length > 4 && trimmed.endsWith(r'$$')) {
        final inner = trimmed.substring(2, trimmed.length - 2).trim();
        if (!inner.contains(r'$$')) {
          math = inner;
          i++;
        }
      }
      if (math == null) {
        final buffer = StringBuffer();
        final firstRest = trimmed.substring(2).trim();
        if (firstRest.isNotEmpty) buffer.writeln(firstRest);
        i++;
        while (i < lines.length) {
          final nextTrimmed = lines[i].trim();
          if (nextTrimmed.endsWith(r'$$')) {
            final beforeClose =
                nextTrimmed.substring(0, nextTrimmed.length - 2).trim();
            if (beforeClose.isNotEmpty) buffer.writeln(beforeClose);
            i++;
            break;
          }
          buffer.writeln(lines[i]);
          i++;
        }
        math = buffer.toString().trim();
      }
      if (math.isNotEmpty) {
        blocks.add(
          _DisplayBlock(
            line: startLine,
            math: math,
            section: section,
            inExampleNumberedSteps: inExampleNumberedSteps,
            prevNonBlankLine: prevNonBlankLine,
            isContinuationOfGroup: prevWasDisplay,
          ),
        );
      }
      prevNonBlankLine = trimmed;
      prevWasDisplay = true;
      continue;
    }

    prevNonBlankLine = trimmed;
    prevWasDisplay = false;
    i++;
  }
  return blocks;
}

String _stripFormatting(String line) =>
    line.replaceAll('**', '').replaceAll('__', '').trim();

String? _leadInViolation(String? prev, {required bool isFormulaDefinition}) {
  if (prev == null || prev.isEmpty) {
    return 'display math has no connecting lead-in line before it';
  }
  if (_headingPattern.hasMatch(prev)) {
    return 'display math immediately follows heading "$prev" '
        'without a connecting lead-in';
  }
  if (prev.startsWith(':::')) {
    return 'display math immediately follows "$prev" '
        'without a connecting lead-in';
  }
  final plain = _stripFormatting(prev);
  if (_bareLabelPattern.hasMatch(plain)) {
    return 'display math follows bare label "$prev" '
        'without a connecting lead-in';
  }
  if (_bareConditionPattern.hasMatch(plain) &&
      !_actionVerbPattern.hasMatch(plain)) {
    // A prose definition sentence introducing a symbolic formula (e.g.
    // "When $|r|<1$, the infinite sum $S_\infty$ is:") has a main clause
    // after the condition rather than ending right after the condition.
    final hasDefinitionClause = isFormulaDefinition &&
        RegExp(
          r',\s+.*\b(?:is|are|equals|means|gives)\b',
          caseSensitive: false,
        ).hasMatch(plain);
    if (!hasDefinitionClause) {
      return 'display math follows bare condition "$prev" '
          'without an action or target lead-in';
    }
  }
  return null;
}

bool _isFormulaDefinition(String math) {
  final parts = _splitTopLevelEquals(math);
  if (parts.length != 2) return false;
  return _hasAlgebraicVariableOrText(parts.last.trim());
}

String _stripTrailingUnitOrNote(String segment) {
  final trimmed = segment.trim();
  final match = RegExp(
    r'^(.*?)(?:\\qquad|\\quad|\\,|\\ |\s)*\\(?:text|mathrm)\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}$',
  ).firstMatch(trimmed);
  if (match == null) return trimmed;
  final head = match.group(1)!.trim();
  if (head.isEmpty) return trimmed;
  final lastChar = head[head.length - 1];
  if (RegExp(r'[\d\}\%)]').hasMatch(lastChar)) {
    return head;
  }
  return trimmed;
}

bool _hasAlgebraicVariableOrText(String segment) {
  if (RegExp(r'\\(?:text|mathrm)\{').hasMatch(segment)) {
    return true;
  }
  final withoutCommands = segment.replaceAll(_latexCommandPattern, '');
  return RegExp('[a-zA-Z]').hasMatch(withoutCommands);
}

bool _isSimplifiedValue(String segment) {
  final compact = segment.replaceAll(RegExp(r'\s+'), '');
  return _simpleNumberPattern.hasMatch(compact) ||
      _simpleFractionPattern.hasMatch(compact) ||
      _mixedNumberPattern.hasMatch(compact) ||
      _simpleRadicalPattern.hasMatch(compact) ||
      _simplePiPattern.hasMatch(compact);
}

List<String> _splitTopLevelEquals(String expr) {
  final parts = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < expr.length; i++) {
    final ch = expr[i];
    if (ch == '{' || ch == '(' || ch == '[') {
      depth++;
    } else if (ch == '}' || ch == ')' || ch == ']') {
      if (depth > 0) depth--;
    } else if (ch == '=' && depth == 0) {
      parts.add(expr.substring(start, i));
      start = i + 1;
    }
  }
  parts.add(expr.substring(start));
  return parts;
}

bool _isContinuedLater(
  List<_DisplayBlock> blocks,
  int index,
  String lhs,
  bool lhsHasVar,
) {
  final currentSection = blocks[index].section;
  // Multi-step equation setup in a consecutive group (e.g. 0.30x+...=0.20(20)
  // followed by 0.30x+2-0.10x=4 ... x=10).
  if (lhsHasVar) {
    var solvedInGroup = false;
    for (var j = index + 1; j < blocks.length; j++) {
      final next = blocks[j];
      if (!next.isContinuationOfGroup || next.section != currentSection) {
        break;
      }
      final nextParts = _splitTopLevelEquals(next.math);
      if (nextParts.length != 2) {
        solvedInGroup = false;
        break;
      }
      final nextLhs = nextParts.first.trim();
      final nextRhs = _stripTrailingUnitOrNote(nextParts.last);
      if (RegExp(r'^[a-zA-Z]$').hasMatch(nextLhs) &&
          _isSimplifiedValue(nextRhs)) {
        solvedInGroup = true;
      }
    }
    if (solvedInGroup) return true;
  }

  for (var j = index + 1; j < blocks.length; j++) {
    final next = blocks[j];
    if (next.section != currentSection) break;
    final nextParts = _splitTopLevelEquals(next.math);
    if (nextParts.length >= 2 && nextParts.first.trim() == lhs) {
      final nextFinal = _stripTrailingUnitOrNote(nextParts.last);
      if (_isSimplifiedValue(nextFinal)) {
        return true;
      }
    }
    if (!next.isContinuationOfGroup) break;
  }
  return false;
}

void _checkDisplayChains(
  String sourceId,
  List<_DisplayBlock> blocks,
  int index,
  List<Violation> found,
) {
  final block = blocks[index];
  if (block.section == 'traps to watch for') return;
  if (block.section == 'examples' && block.inExampleNumberedSteps) return;
  if (_numberedStepPattern.hasMatch(block.prevNonBlankLine ?? '')) return;
  if (block.math.contains(r'\begin{')) return;

  final subEquations = block.math.split(RegExp(r',\\q?quad\s*'));
  for (final rawEq in subEquations) {
    final eq = rawEq.trim();
    final segments = _splitTopLevelEquals(eq);
    if (segments.length < 2) continue;

    final lhs = segments.first.trim();
    final finalRaw = segments.last.trim();
    final finalStripped = _stripTrailingUnitOrNote(finalRaw);

    if (_hasAlgebraicVariableOrText(finalStripped)) continue;
    if (_isSimplifiedValue(finalStripped)) continue;

    // Integer decomposition/factorization (e.g. 60 = 2^2 \times 3 \times 5)
    // starts from a plain integer, so there is nothing left to compute.
    if (_plainIntegerPattern.hasMatch(lhs.replaceAll(' ', ''))) continue;

    // Pattern recognition ending at an evaluated integer's square/power
    // (e.g. 3 - 2 = 1 = 1^2).
    if (segments.length >= 3) {
      final prevCompact =
          segments[segments.length - 2].trim().replaceAll(' ', '');
      final finalCompact = finalStripped.replaceAll(' ', '');
      if (_plainIntegerPattern.hasMatch(prevCompact) &&
          _singlePowerPattern.hasMatch(finalCompact)) {
        continue;
      }
    }

    // Multi-step equation setup or same-LHS simplification continued on the
    // following display block.
    if (segments.length == 2 &&
        _isContinuedLater(
          blocks,
          index,
          lhs,
          _hasAlgebraicVariableOrText(lhs),
        )) {
      continue;
    }

    found.add(
      Violation(
        '$sourceId:${block.line}',
        'display chain "$eq" does not end in a final value '
            '(ends in "$finalRaw")',
      ),
    );
  }
}

/// Checks one lesson's markdown (with optional YAML frontmatter) for
/// worked-example lead-in and display-chain value rules.
List<Violation> checkWalkthroughExampleConnections(
  String sourceId,
  String markdown, {
  bool onlyWalkthrough = true,
}) {
  final fm = _frontmatterPattern.firstMatch(markdown);
  final body = fm == null ? markdown : markdown.substring(fm.end);
  final commentBlanked = _blankCommentsKeepLines(body);
  if (onlyWalkthrough && !_isWalkthroughBody(commentBlanked)) {
    return const [];
  }

  final bodyLineOffset =
      fm == null ? 0 : '\n'.allMatches(markdown.substring(0, fm.end)).length;

  final blocks = _extractDisplayBlocks(commentBlanked);
  final found = <Violation>[];

  for (var i = 0; i < blocks.length; i++) {
    final block = blocks[i];
    final fileLine = block.line + bodyLineOffset;
    if (!block.isContinuationOfGroup && block.section != 'traps to watch for') {
      final reason = _leadInViolation(
        block.prevNonBlankLine,
        isFormulaDefinition: _isFormulaDefinition(block.math),
      );
      if (reason != null) {
        found.add(Violation('$sourceId:$fileLine', reason));
      }
    }
    final previousCount = found.length;
    _checkDisplayChains(sourceId, blocks, i, found);
    if (bodyLineOffset > 0 && found.length > previousCount) {
      for (var k = previousCount; k < found.length; k++) {
        found[k] = Violation(
          '$sourceId:$fileLine',
          found[k].message,
        );
      }
    }
  }

  return found;
}

/// Runs the worked-example connection and display-chain check across all
/// active walk-through lessons under [contentRoot].
List<Violation> runWalkthroughExampleConnectionCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    final lessons = readCheckLessons(contentRoot);
    for (final lesson in lessons.where((lesson) => lesson.active)) {
      found.addAll(
        checkWalkthroughExampleConnections(lesson.id, lesson.body),
      );
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughExampleConnectionCheck extends Check {
  const WalkthroughExampleConnectionCheck();

  @override
  String get name => 'walkthrough-example-connection';

  @override
  String get origin =>
      'Nov 26 walk-through feedback: worked examples need a connecting lead-in '
      'before display math and display chains must end in a final value';

  @override
  List<Violation> run(String root) =>
      runWalkthroughExampleConnectionCheck('$root/content');
}
