import 'check.dart';
import 'lesson_size_check.dart';

/// A stem that shares this many consecutive words with earlier lesson text
/// repeats it. Measured over the corpus (see the test file and the Nov 26
/// report); shorter sentences are caught by the sentence rule below.
const _minRunWords = 7;

/// An earlier example sentence (list item, Right or Wrong line, quoted span)
/// of at least this many words must not sit inside a stem.
const _minSentenceWords = 4;

/// A repeated math expression must be at least this long, with a digit.
const _minMathChars = 9;

final _frontmatterPattern = RegExp(r'^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)');
final _commentPattern = RegExp(r'<!--[\s\S]*?-->');
final _walkthroughPattern =
    RegExp(r'^:::(?:check|try)(?:\s|$)', multiLine: true);
final _mathPattern = RegExp(r'\$\$([\s\S]+?)\$\$|\$([^$\n]+?)\$');
final _choiceGroupPattern = RegExp(r'\(([^()/]+(?:/[^()/]+)+)\)');
final _listMarkerPattern = RegExp(r'^(?:[-*+]\s+|\d+\.\s+)');
final _pairMarkerPattern = RegExp(r'^(?:Right|Wrong)\s*:\s*');
final _quotedPattern = RegExp('"([^"]+)"|“([^”]+)”');
final _nonWordPattern = RegExp(r'[^\p{L}\p{N}|]+', unicode: true);

/// Words of [text], lowercased. Math spans and choice-group slashes become the
/// break token `|`, so a run never crosses them.
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

String _normalizeMath(String math) => math
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(r'\dfrac', r'\frac')
    .replaceAll(r'\left', '')
    .replaceAll(r'\right', '')
    .replaceAll(r'\,', '')
    .replaceAll(r'\!', '');

Iterable<String> _mathSpans(String text) sync* {
  for (final match in _mathPattern.allMatches(text)) {
    final expr = _normalizeMath((match.group(1) ?? match.group(2))!);
    final bareNumber = expr
        .replaceAll(
          RegExp(
            r'\\%|%|\^\\circ|\\text\{[^}]*\}|\\mathrm\{[^}]*\}|'
            r'\\frac\{[\d,.]+\}\{[\d,.]+\}',
          ),
          '1',
        )
        .replaceAll(r'\$', '');
    // A single number, percent, angle or fraction is a given in many
    // questions, not an expression; only compound expressions count.
    if (expr.length >= _minMathChars &&
        RegExp(r'\d').hasMatch(expr) &&
        !RegExp(r'^[+-]?[\d.,]+$').hasMatch(bareNumber)) {
      yield expr;
    }
  }
}

/// Every way to read the stem's `(a / b)` choice groups, one option per group.
List<String> _choiceVariants(String stem) {
  final groups = _choiceGroupPattern.allMatches(stem).toList();
  if (groups.isEmpty) return [stem];
  var variants = <String>[''];
  var cursor = 0;
  for (final group in groups) {
    final before = stem.substring(cursor, group.start);
    final options = group.group(1)!.split('/');
    final next = <String>[];
    for (final variant in variants) {
      for (final option in options) {
        next.add('$variant$before$option');
      }
    }
    // Cap growth; a stem with many groups is read on its first few variants.
    variants = next.length > 32 ? next.sublist(0, 32) : next;
    cursor = group.end;
  }
  return [for (final variant in variants) '$variant${stem.substring(cursor)}'];
}

/// Keys seen so far, each with the `###` sections it appeared in.
class _Seen {
  final _sections = <String, Set<int>>{};

  Iterable<String> get keys => _sections.keys;

  void add(String key, int section) =>
      _sections.putIfAbsent(key, () => <int>{}).add(section);

  /// True when [key] was seen, and (for a try, which finishes the worked
  /// example in its own `###`) in some other section than [ignoring].
  bool has(String key, {int? ignoring}) {
    final seen = _sections[key];
    if (seen == null) return false;
    return ignoring == null || seen.any((s) => s != ignoring);
  }
}

class _Earlier {
  final _Seen sentences = _Seen();
  final _Seen runs = _Seen();
  final _Seen maths = _Seen();
  int section = 0;
  bool inExample = false;
  bool afterSolution = false;

  void add(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('#')) {
      if (trimmed.startsWith('### ') || trimmed.startsWith('## ')) {
        section++;
        inExample = RegExp(r'^###\s+#\d').hasMatch(trimmed);
        afterSolution = false;
      }
      return;
    }

    var body = trimmed;
    var isInstance = false;
    final pair = _pairMarkerPattern.firstMatch(body);
    if (pair != null) {
      body = body.substring(pair.end);
      isInstance = true;
    } else {
      final list = _listMarkerPattern.firstMatch(body);
      if (list != null) {
        // Numbered lines are solution steps (reasoning), not instances.
        isInstance = !RegExp(r'^\d').hasMatch(body);
        body = body.substring(list.end);
      }
    }

    for (final expr in _mathSpans(body)) {
      maths.add(expr, section);
    }

    // Question wording and rule statements repeat legitimately, so a word run
    // counts only inside an instance: a list item, Right or Wrong line,
    // quoted span, or a worked example's own problem text.
    void addRuns(String text) {
      final words = _tokens(text);
      for (var i = 0; i + _minRunWords <= words.length; i++) {
        final window = words.sublist(i, i + _minRunWords);
        if (!window.contains('|')) runs.add(window.join(' '), section);
      }
    }

    if (trimmed.startsWith('**Solution')) afterSolution = true;
    if (isInstance || (inExample && !afterSolution)) addRuns(body);

    void addSentence(String sentence) {
      addRuns(sentence);
      final tokens = _tokens(sentence);
      if (tokens.length >= _minSentenceWords && !tokens.contains('|')) {
        sentences.add(tokens.join(' '), section);
      }
    }

    if (isInstance) {
      body.split(RegExp(r'(?<=[.!?;])\s+')).forEach(addSentence);
    }
    for (final quoted in _quotedPattern.allMatches(body)) {
      addSentence((quoted.group(1) ?? quoted.group(2))!);
    }
  }
}

/// Text of the earlier instance this stem repeats, or null.
String? _repeated(_Earlier earlier, String stem, {required bool isTry}) {
  final ignoring = isTry ? earlier.section : null;
  for (final expr in _mathSpans(stem)) {
    if (earlier.maths.has(expr, ignoring: ignoring)) return expr;
  }
  for (final variant in _choiceVariants(stem)) {
    final words = _tokens(variant);
    final joined = ' ${words.join(' ')} ';
    for (final sentence in earlier.sentences.keys) {
      if (joined.contains(' $sentence ') &&
          earlier.sentences.has(sentence, ignoring: ignoring)) {
        return sentence;
      }
    }
    for (var i = 0; i + _minRunWords <= words.length; i++) {
      final window = words.sublist(i, i + _minRunWords);
      if (window.contains('|') ||
          !earlier.runs.has(window.join(' '), ignoring: ignoring)) {
        continue;
      }
      var end = i + _minRunWords;
      while (end < words.length &&
          !words[end].contains('|') &&
          earlier.runs.has(
            words.sublist(end - _minRunWords + 1, end + 1).join(' '),
            ignoring: ignoring,
          )) {
        end++;
      }
      return words.sublist(i, end).join(' ');
    }
  }
  return null;
}

/// Checks one lesson (lane rule 5a): every `:::check` and `:::try` uses a
/// fresh instance, never a sentence or math expression shown earlier.
List<Violation> checkWalkthroughFreshInstances(
  String sourceId,
  String markdown,
) {
  final fm = _frontmatterPattern.firstMatch(markdown);
  final blanked = markdown.replaceAllMapped(
    _commentPattern,
    (m) => m.group(0)!.replaceAll(RegExp(r'[^\n]'), ' '),
  );
  final bodyStart = fm?.end ?? 0;
  final body = blanked.substring(bodyStart);
  if (!_walkthroughPattern.hasMatch(body)) return const [];

  final lineOffset = '\n'.allMatches(blanked.substring(0, bodyStart)).length;
  final lines = body.split('\n');
  final earlier = _Earlier();
  final found = <Violation>[];

  var i = 0;
  while (i < lines.length) {
    final trimmed = lines[i].trim();
    final opener = RegExp(r'^:::(check|try)(?:\s|$)').firstMatch(trimmed);
    if (opener != null) {
      final startLine = i + 1 + lineOffset;
      final stemLines = <String>[];
      var inAnswer = false;
      i++;
      while (i < lines.length && lines[i].trim() != ':::') {
        if (lines[i].trim() == ':::answer') {
          inAnswer = true;
        } else if (!inAnswer) {
          stemLines.add(lines[i]);
        }
        i++;
      }
      final stem = stemLines.join('\n');
      final repeat = _repeated(earlier, stem, isTry: opener.group(1) == 'try');
      if (repeat != null) {
        found.add(
          Violation(
            '$sourceId:$startLine',
            ':::${opener.group(1)} repeats earlier lesson text '
                '"$repeat"; use a fresh instance of the rule',
          ),
        );
      }
      stemLines.forEach(earlier.add);
      i++;
      continue;
    }
    if (trimmed.startsWith(':::')) {
      i++;
      continue;
    }
    if (trimmed.startsWith(r'$$') && !trimmed.endsWith(r'$$') ||
        trimmed == r'$$') {
      // Multi-line display math: join to its closing line.
      final buffer = StringBuffer(trimmed);
      i++;
      while (i < lines.length) {
        buffer.write(' ${lines[i].trim()}');
        if (lines[i].trim().endsWith(r'$$')) break;
        i++;
      }
      earlier.add(buffer.toString());
      i++;
      continue;
    }
    earlier.add(lines[i]);
    i++;
  }
  return found;
}

/// Runs the fresh-instance check across all active walk-through lessons.
List<Violation> runWalkthroughFreshInstanceCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    for (final lesson
        in readCheckLessons(contentRoot).where((lesson) => lesson.active)) {
      found.addAll(checkWalkthroughFreshInstances(lesson.id, lesson.body));
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughFreshInstanceCheck extends Check {
  const WalkthroughFreshInstanceCheck();

  @override
  String get name => 'walkthrough-fresh-instance';

  @override
  String get origin =>
      'Nov 26 walk-through lane rule 5a: a Quick Check or Try repeated an '
      'example sentence, number set or expression already worked in the lesson';

  @override
  List<Violation> run(String root) =>
      runWalkthroughFreshInstanceCheck('$root/content');
}
