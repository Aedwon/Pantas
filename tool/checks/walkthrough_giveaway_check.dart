import 'dart:io';

import 'check.dart';
import 'lesson_size_check.dart';

// Giveaway check for walk-through `:::check` and `:::try` blocks.
//
// A giveaway is a question a student can answer by copying text the lesson
// already printed, without using the rule. Four rules (names in messages):
//
//   a  choice copy:   the correct choice, word for word, is printed above.
//   b  only listed:   one choice alone is printed above (or in the prompt).
//   c  key in stem:   the key is a number printed in the block's own stem.
//   d  printed key:   a non-trivial key is printed in the same `###` section
//                     above, or in any `Right:` pair line above.
//
// "Visible above" is the lesson text before the block, with HTML comments and
// every `:::answer` and `:::why` body removed (hidden until a tap). Pair lines
// are visible. Lines that are choice lines of a question (`(A) ...`, `A) ...`)
// are not counted as printed text: they are the question, not the teaching.
//
// A key that cannot be read is skipped, never guessed.
//
// Line numbers are relative to the text passed in. The lesson runner passes
// the lesson body, as the other walk-through checks do.

final _frontmatterPattern = RegExp(r'^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)');
final _commentPattern = RegExp(r'<!--[\s\S]*?-->');
final _mathPattern = RegExp(r'\$\$([\s\S]+?)\$\$|\$([^$\n]+?)\$');
final _walkthroughPattern =
    RegExp(r'^:::(?:check|try)(?:\s|$)', multiLine: true);
final _choiceLinePattern = RegExp(
  r'^\s*(?:[-*]\s+)?(?:\(([A-E])\)|([A-E])[.)])\s*(.+)$',
);
final _listItemPattern = RegExp(r'^\s*(?:[-*+]|\d+\.)\s+');
final _choiceGroupPattern = RegExp(r'\(([^()/]+(?:/[^()/]+)+)\)');
final _keyPrefixPattern = RegExp(
  r'(?:the\s+answer\s+is|ang\s+sagot\s+ay)\s*:?\s*',
  caseSensitive: false,
);
final _pairMarkerPattern = RegExp(r'^(Right|Wrong)\s*:\s*');
final _nonWordPattern = RegExp(r'[^\p{L}\p{N}|]+', unicode: true);

/// Word answers that count as non-trivial keys.
const _wordAnswers = [
  'undefined',
  'not defined',
  'no real number',
  'not a real number',
  'no solution',
];

/// A choice appears "word for word" only when it has at least this many words,
/// so a single word that the lesson uses everywhere is not a copy.
const _minCopyWords = 3;

/// Keys 0 and 1 appear in nearly every stem and say nothing for rule c.
const _trivialStemValues = {'0', '1'};

class _Line {
  _Line(this.line, this.text, this.section, {this.isRight = false});
  final int line;
  final String text;
  final int section;
  final bool isRight;
}

class _Block {
  _Block({
    required this.kind,
    required this.line,
    required this.section,
    required this.above,
    required this.stem,
    required this.answer,
  });
  final String kind;
  final int line;
  final int section;
  final List<_Line> above;
  final List<String> stem;
  final List<String> answer;
}

/// Text with every math span replaced by a break token, split into choices.
String _maskMath(String text, List<String> store) =>
    text.replaceAllMapped(_mathPattern, (m) {
      store.add(m.group(0)!);
      return '\u27E6${store.length - 1}\u27E7';
    });

String _unmask(String text, List<String> store) => text.replaceAllMapped(
      RegExp('\u27E6(\\d+)\u27E7'),
      (m) => store[int.parse(m.group(1)!)],
    );

String _plain(String text) => text
    .replaceAll('**', '')
    .replaceAll('*', '')
    .replaceAll('_', ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Words of [text], lowercased. A math span becomes the break token `|`.
List<String> _tokens(String text) {
  final plain = text
      .replaceAll(_mathPattern, ' | ')
      .replaceAll('’', '')
      .replaceAll("'", '')
      .toLowerCase()
      .replaceAll(_nonWordPattern, ' ')
      .trim();
  return plain.isEmpty ? const [] : plain.split(' ');
}

bool _hasRun(List<String> haystack, List<String> needle) {
  if (needle.isEmpty || needle.length > haystack.length) return false;
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    var ok = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        ok = false;
        break;
      }
    }
    if (ok) return true;
  }
  return false;
}

// ---------------------------------------------------------------- values ---

final _fracPattern = RegExp(
  r'((?<![\p{L}\d})\]])-)?\\frac\{\s*([\d.]+)\s*\}\{\s*([\d.]+)\s*\}|'
  r'(?<![\d.])(\d+)/(\d+)(?![\d.])',
  unicode: true,
);
final _numberPattern = RegExp(
  r'(?<![\p{L}\d.])(-?)(\d+(?:\.\d+)?)(\s?%)?',
  unicode: true,
);

String _canonicalNumber(String digits) {
  final value = double.tryParse(digits);
  if (value == null) return digits;
  if (value == value.truncateToDouble()) return value.toInt().toString();
  return value.toString();
}

/// Canonical value tokens in [raw]: `7200`, `-9`, `0.4`, `25%`, `7/20`.
/// Thousands commas and trailing zeros do not matter, and `\dfrac` equals
/// `\frac`, so `7,200` equals `7200` and `0.40` equals `0.4`.
List<String> _values(String raw) {
  var text = raw
      .replaceAll(r'\dfrac', r'\frac')
      .replaceAll(r'\tfrac', r'\frac')
      .replaceAll(r'\%', '%')
      .replaceAll('\u2212', '-')
      .replaceAll(RegExp(r'\\[,!;: ]'), ' ')
      .replaceAll(RegExp(r'\\(?:left|right)'), '')
      .replaceAll(RegExp(r'\\(?:times|div|cdot)'), ' ')
      .replaceAll(RegExp(r'\\text\{([^}]*)\}'), r' $1 ')
      .replaceAll(r'\$', ' ')
      .replaceAll(r'$', ' ')
      .replaceAll('*', '');
  text = text.replaceAllMapped(
    RegExp(r'(?<=\d),(?=\d{3}(?!\d))'),
    (m) => '',
  );
  final found = <String>[];
  text = text.replaceAllMapped(_fracPattern, (m) {
    final top = m.group(2) ?? m.group(4)!;
    final bottom = m.group(3) ?? m.group(5)!;
    final negative = m.group(1) != null ? '-' : '';
    found.add('$negative${_canonicalNumber(top)}/${_canonicalNumber(bottom)}');
    return ' ';
  });
  for (final m in _numberPattern.allMatches(text)) {
    var value = _canonicalNumber(m.group(2)!);
    if (m.group(1) == '-' && value != '0') value = '-$value';
    if (m.group(3) != null) value = '$value%';
    found.add(value);
  }
  return found;
}

/// A key value that is worth checking against printed text: a fraction, a
/// percent, a decimal, or a number of 4 or more characters.
bool _nonTrivial(String value) {
  if (value.contains('/') || value.endsWith('%') || value.contains('.')) {
    return true;
  }
  return value.replaceAll('-', '').length >= 4;
}

/// True when the key is a plain number answer: every math span in it is a
/// number, fraction or percent, with no variable or operator. An expression
/// key such as `3m^2+3m+4` or `0.20(4+x)` is built from the stem's numbers by
/// design, so a number match says nothing (narrowing found by tuning).
bool _isSimpleKey(String keyText) {
  for (final match in _mathPattern.allMatches(keyText)) {
    var span = (match.group(1) ?? match.group(2))!
        .replaceAll(RegExp(r'\\text\{[^}]*\}'), '')
        .replaceAll(RegExp(r'\\(?:dfrac|tfrac|frac|left|right|%)'), '')
        .replaceAll(RegExp(r'\\[,!;: ]'), '')
        .replaceAll(RegExp(r'[\s{}%]'), '');
    if (span.startsWith('-')) span = span.substring(1);
    if (!RegExp(r'^[\d.,/]+$').hasMatch(span)) return false;
  }
  return true;
}

/// Numbers in [text], without sign, percent or fraction bars, as canonical
/// strings. Small whole numbers (10 or less) are left out: nearly every line
/// has one.
Set<String> _atoms(String text) {
  final cleaned = text
      .replaceAll(r'\%', ' ')
      .replaceAll(RegExp(r'(?<=\d),(?=\d{3}(?!\d))'), '');
  return {
    for (final m in RegExp(r'(?<![\p{L}\d.])\d+(?:\.\d+)?', unicode: true)
        .allMatches(cleaned))
      if (!_smallWhole(_canonicalNumber(m.group(0)!)))
        _canonicalNumber(m.group(0)!),
  };
}

/// A positive whole number of 10 or less is a coincidence as often as a
/// giveaway when it matches a stem number (narrowing found by tuning).
bool _smallWhole(String value) =>
    RegExp(r'^\d+$').hasMatch(value) && int.parse(value) <= 10;

/// A year (1900 to 2100) in a date is printed by design in date questions, so
/// matching one says nothing (narrowing found by tuning on the clerical
/// lessons).
bool _yearLike(String value) =>
    RegExp(r'^\d{4}$').hasMatch(value) &&
    int.parse(value) >= 1900 &&
    int.parse(value) <= 2100;

// ----------------------------------------------------------------- parse ---

/// Visible lines and blocks of one lesson, in order. [body] has its comments
/// blanked already.
({List<_Block> blocks}) _parse(String body, int lineOffset) {
  final lines = body.split('\n');
  final visible = <_Line>[];
  final blocks = <_Block>[];
  var section = 0;
  var hidden = false;
  var i = 0;
  while (i < lines.length) {
    final raw = lines[i].replaceAll('\r', '');
    final trimmed = raw.trim();
    final number = i + 1 + lineOffset;
    final opener = RegExp(r'^:::(check|try)(?:\s|$)').firstMatch(trimmed);
    if (opener != null) {
      final stem = <String>[];
      final answer = <String>[];
      var inAnswer = false;
      i++;
      while (i < lines.length && lines[i].trim() != ':::') {
        final inner = lines[i].replaceAll('\r', '');
        if (inner.trim() == ':::answer') {
          inAnswer = true;
        } else if (inAnswer) {
          answer.add(inner);
        } else {
          stem.add(inner);
        }
        i++;
      }
      blocks.add(
        _Block(
          kind: opener.group(1)!,
          line: number,
          section: section,
          above: List.of(visible),
          stem: stem,
          answer: answer,
        ),
      );
      for (var s = 0; s < stem.length; s++) {
        if (stem[s].trim().isNotEmpty) {
          visible.add(_Line(number + 1 + s, stem[s], section));
        }
      }
      i++;
      continue;
    }
    if (trimmed.startsWith(':::')) {
      hidden = RegExp(r'^:::(?:why|answer)(?:\s|$)').hasMatch(trimmed);
      i++;
      continue;
    }
    if (hidden) {
      i++;
      continue;
    }
    if (trimmed.startsWith('## ') || trimmed.startsWith('### ')) {
      section++;
      i++;
      continue;
    }
    if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
      final pair = _pairMarkerPattern.firstMatch(trimmed);
      visible.add(
        _Line(
          number,
          pair == null ? raw : trimmed.substring(pair.end),
          section,
          isRight: pair?.group(1) == 'Right',
        ),
      );
    }
    i++;
  }
  return (blocks: blocks);
}

// ------------------------------------------------------------------ keys ---

/// First sentence of [text]: ends at `.`, `!` or `?` outside math, followed
/// by optional closing quotes and a space or the end. A period inside a
/// number (`0.35`) does not end it.
String _firstSentence(String text) {
  final buffer = StringBuffer();
  var inMath = false;
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (ch == r'$') inMath = !inMath;
    buffer.write(ch);
    if (inMath || !'.!?'.contains(ch)) continue;
    var j = i + 1;
    while (j < text.length && '"\'\u201D\u2019)*'.contains(text[j])) {
      j++;
    }
    if (j >= text.length || text[j] == ' ' || text[j] == '\n') break;
  }
  return buffer.toString();
}

class _Key {
  _Key(this.text, {this.letter});

  /// Cleaned text of the key (no `$`, `*`, closing period).
  final String text;

  /// Choice letter when the answer names one.
  final String? letter;
}

_Key? _readKey(List<String> answer) {
  final all = answer.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (all.isEmpty) return null;
  final prefix = _keyPrefixPattern.firstMatch(all);
  var sentence = prefix == null
      ? _firstSentence(all)
      : _firstSentence(all.substring(prefix.end));
  if (prefix == null && sentence.split(' ').length > 8) return null;
  sentence = sentence.replaceAll('**', '').replaceAll('*', '').trim();
  String? letter;
  final choice =
      RegExp(r'^\(?([A-E])\)?(?=$|[\s,:.)])\s*[:,.)]?\s*').firstMatch(sentence);
  if (choice != null) {
    letter = choice.group(1);
    sentence = sentence.substring(choice.end);
  }
  sentence = sentence
      .replaceAll(RegExp(r'^[\s"\u201C\u2018]+|[\s"\u201D\u2019.!?]+$'), '')
      .trim();
  if (sentence.isEmpty && letter == null) return null;
  return _Key(sentence, letter: letter);
}

// --------------------------------------------------------------- choices ---

/// Choice texts a stem offers, as written, plus its prompt (everything else).
({List<String> choices, String prompt, bool offers}) _stemChoices(
  List<String> stem,
  _Key key,
) {
  final choices = <String>[];
  final prompt = <String>[];
  for (final line in stem) {
    final match = _choiceLinePattern.firstMatch(line);
    if (match != null) {
      choices.add(match.group(3)!.trim());
    } else {
      prompt.add(line);
    }
  }
  var promptText = prompt.join('\n');
  if (choices.isNotEmpty) {
    return (choices: choices, prompt: promptText, offers: true);
  }
  // Inline `(x / y / z)` groups: use the one holding the key.
  final store = <String>[];
  final masked = _maskMath(promptText, store);
  final groups = _choiceGroupPattern.allMatches(masked).toList();
  if (groups.isEmpty) {
    return (choices: const [], prompt: promptText, offers: false);
  }
  List<String>? best;
  for (final group in groups) {
    final options = [
      for (final option in group.group(1)!.split('/'))
        _plain(_unmask(option, store)),
    ];
    if (key.letter != null) {
      best = options;
      break;
    }
    if (_matchChoice(options, key.text) != null) {
      best = options;
      break;
    }
  }
  promptText = _unmask(masked.replaceAll(_choiceGroupPattern, ' '), store);
  return (choices: best ?? const [], prompt: promptText, offers: true);
}

/// Index of the choice the key text names, or null.
int? _matchChoice(List<String> choices, String keyText) {
  final keyTokens = _tokens(keyText);
  if (keyTokens.isEmpty) return null;
  int? best;
  var bestLength = 0;
  var tie = false;
  for (var i = 0; i < choices.length; i++) {
    final tokens = _tokens(_plain(choices[i]));
    if (tokens.isEmpty || tokens.length > keyTokens.length) continue;
    var ok = true;
    for (var j = 0; j < tokens.length; j++) {
      if (tokens[j] != keyTokens[j]) {
        ok = false;
        break;
      }
    }
    if (!ok) continue;
    if (tokens.length > bestLength) {
      best = i;
      bestLength = tokens.length;
      tie = false;
    } else if (tokens.length == bestLength) {
      tie = true;
    }
  }
  return tie ? null : best;
}

// ----------------------------------------------------------------- rules ---

String _clip(String text) {
  final plain = _plain(text);
  return plain.length <= 70 ? plain : '${plain.substring(0, 67)}...';
}

bool _isChoiceLine(String line) => _choiceLinePattern.hasMatch(line);

/// Printed lines a rule may match: not the question's own choice lines.
List<_Line> _printed(List<_Line> lines) => [
      for (final l in lines)
        if (!_isChoiceLine(l.text)) l,
    ];

String _withoutGroups(String text) {
  final store = <String>[];
  return _unmask(
    _maskMath(text, store).replaceAll(_choiceGroupPattern, ' '),
    store,
  );
}

List<Violation> _checkBlock(String sourceId, _Block block) {
  final key = _readKey(block.answer);
  if (key == null) return const [];
  final stem = _stemChoices(block.stem, key);
  final found = <Violation>[];
  void add(String rule, String message) => found.add(
        Violation(
          '$sourceId:${block.line}',
          ':::${block.kind} giveaway (rule $rule): $message',
        ),
      );

  // The key as text: the named choice's own text when the stem offers it.
  var keyText = key.text;
  String? choiceText;
  int? choiceIndex;
  if (stem.choices.isNotEmpty) {
    if (key.letter != null) {
      choiceIndex = key.letter!.codeUnitAt(0) - 'A'.codeUnitAt(0);
    } else {
      choiceIndex = _matchChoice(stem.choices, key.text);
    }
    if (choiceIndex != null &&
        choiceIndex >= 0 &&
        choiceIndex < stem.choices.length) {
      choiceText = stem.choices[choiceIndex];
      keyText = choiceText;
    } else {
      choiceIndex = null;
    }
  }
  if (key.letter != null && choiceText == null && key.text.isEmpty) {
    return const []; // a letter alone, with no choice text to read
  }

  final printed = _printed(block.above);
  final promptValues = _values(_withoutGroups(stem.prompt));

  // Rule c: the key is a number printed in the block's own stem. A stem that
  // offers the key as one of its choices (or asks to pick from numbers it
  // prints) is a choice question, not a giveaway of this kind.
  // A yes or no answer repeats the stem's numbers in its sentence ("yes, 203
  // is divisible by 7"); the number is not the key.
  final yesNo = RegExp(
    r'^(?:yes|no|oo|hindi)\b',
    caseSensitive: false,
  ).hasMatch(keyText);
  final simple = !yesNo && _isSimpleKey(keyText);
  final keyValues = simple ? _values(keyText) : const <String>[];
  final stemIsPick = stem.offers ||
      RegExp(r'\b(?:which|alin|piliin)\b', caseSensitive: false)
          .hasMatch(stem.prompt);
  if (!stemIsPick && keyValues.length <= 2) {
    for (final value in keyValues) {
      if (_trivialStemValues.contains(value) ||
          _smallWhole(value) ||
          _yearLike(value)) {
        continue;
      }
      if (promptValues.contains(value)) {
        add('c', 'key "$value" is printed in its own stem');
        break;
      }
    }
  }

  // Rule a: the correct choice, word for word, is printed above.
  final textual = stem.choices
      .where((c) => _tokens(_plain(c)).any((t) => t != '|'))
      .toList();
  if (choiceText != null && textual.length == stem.choices.length) {
    final tokens = _tokens(_plain(choiceText));
    if (tokens.length >= _minCopyWords && !tokens.contains('|')) {
      for (final l in printed) {
        if (_hasRun(_tokens(_withoutGroups(l.text)), tokens)) {
          add(
              'a',
              'choice "${_clip(choiceText)}" is printed above: '
                  '"${_clip(l.text)}"');
          break;
        }
      }
    }
  }

  // Rule b: exactly one choice has its distinguishing words printed above (or
  // in the stem's own prompt), and it is the key.
  if (choiceIndex != null &&
      stem.choices.length >= 2 &&
      textual.length == stem.choices.length) {
    final choiceTokens = [
      for (final c in stem.choices) _tokens(_plain(c)),
    ];
    final common =
        choiceTokens.map((t) => t.toSet()).reduce((a, b) => a.intersection(b));
    // Printed lists and series only: list items, Right lines and the stem's
    // own prompt. Ordinary prose uses nearly every word, so counting it would
    // alarm on any choice (narrowing found by tuning).
    final haystack = <String>{
      for (final l in printed)
        if (l.isRight || _listItemPattern.hasMatch(l.text))
          ..._tokens(_withoutGroups(l.text)),
      ..._tokens(_withoutGroups(stem.prompt)),
    };
    final appearing = <int>[];
    var testable = true;
    for (var i = 0; i < choiceTokens.length; i++) {
      final distinct = choiceTokens[i]
          .where((t) => !common.contains(t) && t != '|')
          .toList();
      if (distinct.isEmpty) {
        testable = false;
        break;
      }
      if (distinct.every(haystack.contains)) appearing.add(i);
    }
    if (testable && appearing.length == 1 && appearing.single == choiceIndex) {
      add(
        'b',
        'only the correct choice "${_clip(choiceText!)}" has its own '
            'words printed above; the other choices do not',
      );
    }
  }

  // Rule d: a non-trivial key is printed in the same ### section above, or in
  // any Right: line above.
  //
  // Narrowing found by tuning: a line of the same section counts only when it
  // is the same instance as the stem, meaning it shares a number (above 10)
  // with the stem. The same value printed in an unrelated worked example of
  // the section (a different set of numbers) is a coincidence, not a copy.
  // A `Right:` line counts without that test, because a pair is always open.
  final stemAtoms = _atoms(_withoutGroups(stem.prompt));
  final inScope = [
    for (final l in printed)
      if (l.isRight ||
          (l.section == block.section &&
              _atoms(l.text).any(stemAtoms.contains)))
        l,
  ];
  final keyLower = keyText.toLowerCase();
  for (final word in _wordAnswers) {
    if (!keyLower.contains(word)) continue;
    for (final l in inScope) {
      if (RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false)
          .hasMatch(_withoutGroups(l.text))) {
        add('d', 'key "$word" is printed above: "${_clip(l.text)}"');
        return found;
      }
    }
  }
  // An answer with three or more numbers is an arrangement of printed values
  // (an order, a list), so a match says nothing.
  // 100% is not checked: every percent formula prints "x 100%".
  for (final value in keyValues
      .where((v) => _nonTrivial(v) && !_yearLike(v) && v != '100%')) {
    if (keyValues.length > 2) break;
    for (final l in inScope) {
      if (_values(_withoutGroups(l.text)).contains(value)) {
        add('d', 'key "$value" is printed above: "${_clip(l.text)}"');
        return found;
      }
    }
  }
  return found;
}

/// Checks one lesson. [sourceId] is the lesson id or path.
List<Violation> checkWalkthroughGiveaways(String sourceId, String markdown) {
  final fm = _frontmatterPattern.firstMatch(markdown);
  final blanked = markdown.replaceAllMapped(
    _commentPattern,
    (m) => m.group(0)!.replaceAll(RegExp(r'[^\n]'), ' '),
  );
  final bodyStart = fm?.end ?? 0;
  final body = blanked.substring(bodyStart);
  if (!_walkthroughPattern.hasMatch(body)) return const [];
  final lineOffset = '\n'.allMatches(blanked.substring(0, bodyStart)).length;
  final parsed = _parse(body, lineOffset);
  return [
    for (final block in parsed.blocks) ..._checkBlock(sourceId, block),
  ];
}

/// Runs the giveaway check across all active walk-through lessons.
List<Violation> runWalkthroughGiveawayCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    for (final lesson
        in readCheckLessons(contentRoot).where((lesson) => lesson.active)) {
      found.addAll(checkWalkthroughGiveaways(lesson.id, lesson.body));
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughGiveawayCheck extends Check {
  const WalkthroughGiveawayCheck();

  @override
  String get name => 'walkthrough-giveaway';

  @override
  String get origin =>
      'Nov 27 process entry "Grammar walk-through lessons fail every '
      'outside audit round": a Quick Check or try whose key is printed above '
      'it, sits in its own stem, or is the only choice matching printed text '
      'passed every in-lane check and failed the outside audit read';

  @override
  List<Violation> run(String root) =>
      runWalkthroughGiveawayCheck('$root/content');
}

void main(List<String> args) {
  if (args.length != 2 ||
      args.first != '--root' ||
      !Directory(args[1]).existsSync()) {
    stderr.writeln(
      'Usage: dart run tool/checks/walkthrough_giveaway_check.dart '
      '--root <content dir>',
    );
    exitCode = 2;
    return;
  }
  final findings = runWalkthroughGiveawayCheck(args[1]);
  for (final finding in findings) {
    stdout.writeln(finding);
  }
  exitCode = findings.isEmpty ? 0 : 1;
}
