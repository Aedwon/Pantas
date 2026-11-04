/// How a lesson's blocks are grouped for the reader, apart from drawing them.
///
/// The reader gives some content its own look: a note card in "Mnemonics" and
/// "Traps", an example card with a hidden solution in "Examples", and answer
/// choices as rows. Lessons are written by many hands, so every rule here
/// matches leniently and falls back to plain blocks when a lesson does not fit.
/// Nothing in this file throws on odd input.
library;

/// The kind of section a level-two heading opens.
enum ReaderSection { plain, mnemonics, traps, examples }

/// The text of a block's children, joined, with no math delimiters.
String readerBlockText(Map<String, Object?> block) {
  final children = block['children'];
  if (children is! List<Object?>) return '';
  return children
      .whereType<Map<String, Object?>>()
      .map((run) => run['text'] is String ? run['text']! as String : '')
      .join();
}

/// The section a heading opens, from its title.
///
/// Matches on words, not an exact title, so "Worked Examples" and "Traps to
/// Watch For" both count. An unknown title is [ReaderSection.plain].
ReaderSection readerSectionFor(String title) {
  final words = title.toLowerCase().replaceAll(RegExp('[^a-z ]'), ' ');
  if (words.contains('mnemonic') || words.contains('memory aid')) {
    return ReaderSection.mnemonics;
  }
  if (RegExp(r'\btraps?\b').hasMatch(words)) return ReaderSection.traps;
  if (RegExp(r'^\s*(worked\s+)?examples?\b').hasMatch(words)) {
    return ReaderSection.examples;
  }
  return ReaderSection.plain;
}

/// Whether [block] is a heading of exactly [level], as in `h3`.
bool isReaderHeading(Map<String, Object?> block, int level) =>
    block['_type'] == 'block' && block['style'] == 'h$level';

/// Whether [block] is the line that opens a worked solution: "Solution:".
bool isSolutionMarker(Map<String, Object?> block) =>
    block['_type'] == 'block' &&
    RegExp(r'^Solution\s*:?$', caseSensitive: false)
        .hasMatch(readerBlockText(block).trim());

/// Where a "Solution:" line opens a solution in an example, or null.
///
/// Most lessons put the word on a line of its own. Where the first step sits
/// on the next line with no blank between, the Markdown joins them into one
/// paragraph that starts with a bold "Solution:". That paragraph opens the
/// solution too, and `rest` is what is left of it once the word is cut off,
/// or null when nothing is.
({Map<String, Object?>? rest})? solutionStart(Map<String, Object?> block) {
  if (isSolutionMarker(block)) return (rest: null);
  final children = block['children'];
  if (block['_type'] != 'block' ||
      block['listItem'] is String &&
          (block['listItem']! as String).isNotEmpty ||
      children is! List<Object?> ||
      children.length < 2) {
    return null;
  }
  final runs = children.whereType<Map<String, Object?>>().toList();
  if (runs.length != children.length) return null;
  final marks = runs.first['marks'];
  final word = runs.first['text'];
  if (marks is! List<Object?> ||
      !marks.contains('strong') ||
      word is! String ||
      !RegExp(r'^Solution\s*:?$', caseSensitive: false).hasMatch(word.trim())) {
    return null;
  }
  final rest = runs.sublist(1);
  if (rest.first['text'] is String) {
    rest[0] = {
      ...rest.first,
      'text': (rest.first['text']! as String).trimLeft(),
    };
  }
  return (rest: {...block, 'children': rest});
}

/// One step of a lesson, ready to draw.
sealed class ReaderItem {
  const ReaderItem();
}

/// A block drawn on its own, with the section it sits in.
final class ReaderPlain extends ReaderItem {
  const ReaderPlain(this.block, this.section);
  final Map<String, Object?> block;
  final ReaderSection section;
}

/// One example under the Examples heading: its title, the question blocks,
/// and the solution blocks. [solution] is empty when the example has none.
final class ReaderExample extends ReaderItem {
  const ReaderExample({
    required this.number,
    required this.title,
    required this.stem,
    required this.solution,
  });

  /// Counted from 1 within its section, in the order shown.
  final int number;
  final Map<String, Object?> title;
  final List<Map<String, Object?>> stem;
  final List<Map<String, Object?>> solution;
}

/// Groups [blocks] for the reader.
///
/// Under an Examples heading, each level-three heading and the blocks up to
/// the next level-three or higher heading become one [ReaderExample]. A
/// "Solution:" line splits the example into question and solution. Everything
/// else stays a [ReaderPlain] block.
List<ReaderItem> planReaderBlocks(List<Map<String, Object?>> blocks) {
  final items = <ReaderItem>[];
  var section = ReaderSection.plain;
  var number = 0;
  var i = 0;
  while (i < blocks.length) {
    final block = blocks[i];
    if (isReaderHeading(block, 1) || isReaderHeading(block, 2)) {
      section = isReaderHeading(block, 2)
          ? readerSectionFor(readerBlockText(block))
          : ReaderSection.plain;
      number = 0;
      items.add(ReaderPlain(block, section));
      i++;
      continue;
    }
    if (section == ReaderSection.examples && isReaderHeading(block, 3)) {
      var end = i + 1;
      while (end < blocks.length &&
          !isReaderHeading(blocks[end], 1) &&
          !isReaderHeading(blocks[end], 2) &&
          !isReaderHeading(blocks[end], 3)) {
        end++;
      }
      final body = blocks.sublist(i + 1, end);
      final marker = body.indexWhere((b) => solutionStart(b) != null);
      final rest = marker < 0 ? null : solutionStart(body[marker])!.rest;
      number++;
      items.add(
        ReaderExample(
          number: number,
          title: block,
          stem: marker < 0 ? body : body.sublist(0, marker),
          solution: marker < 0
              ? const []
              : [if (rest != null) rest, ...body.sublist(marker + 1)],
        ),
      );
      i = end;
      continue;
    }
    items.add(ReaderPlain(block, section));
    i++;
  }
  return items;
}

/// One answer choice cut out of a paragraph: its letter and its text runs.
final class ReaderChoice {
  const ReaderChoice(this.letter, this.runs);
  final String letter;
  final List<Map<String, Object?>> runs;
}

/// A paragraph cut into the text before its choices and the choices.
final class ReaderChoices {
  const ReaderChoices(this.stem, this.choices);
  final List<Map<String, Object?>> stem;
  final List<ReaderChoice> choices;
}

final _choiceMarker = RegExp(r'(?:^|(?<=\s))\(?([A-J])\)(?=\s|$)');

/// Cuts "A) ... B) ... C) ..." out of a plain paragraph, or returns null.
///
/// The letters must run A, B, C in order, with at least A and B, each marker
/// at the start of the text or after a space, and each choice must hold text
/// or math. Markers inside math never count, because math is its own run. A
/// list item, a heading or a paragraph that fails any check is left alone.
ReaderChoices? splitReaderChoices(Map<String, Object?> block) {
  if (block['_type'] != 'block') return null;
  final style = block['style'];
  if ((style != null && style != 'normal') ||
      (block['listItem'] is String &&
          (block['listItem']! as String).isNotEmpty)) {
    return null;
  }
  final raw = block['children'];
  if (raw is! List<Object?>) return null;
  final runs = raw.whereType<Map<String, Object?>>().toList();

  bool isMath(Map<String, Object?> run) {
    final marks = run['marks'];
    return marks is List<Object?> && marks.contains('latex');
  }

  String text(Map<String, Object?> run) =>
      run['text'] is String ? run['text']! as String : '';

  // Accept markers in order: the first A, then the next B, and so on.
  final accepted = <({int run, int start, int end, String letter})>[];
  var expected = 'A'.codeUnitAt(0);
  for (var r = 0; r < runs.length; r++) {
    if (isMath(runs[r])) continue;
    // Dollar-delimited math inside a text run is hidden from the search.
    final searchable = text(runs[r]).replaceAllMapped(
      RegExp(r'\$[^$]*\$'),
      (m) => '_' * m.group(0)!.length,
    );
    for (final match in _choiceMarker.allMatches(searchable)) {
      if (match.group(1)!.codeUnitAt(0) == expected) {
        accepted.add(
          (run: r, start: match.start, end: match.end, letter: match.group(1)!),
        );
        expected++;
      }
    }
  }
  if (accepted.length < 2) return null;

  // The runs between two positions, cut at the exact characters.
  List<Map<String, Object?>> between(
    ({int run, int start, int end, String letter})? from,
    ({int run, int start, int end, String letter})? to,
  ) {
    final out = <Map<String, Object?>>[];
    final firstRun = from?.run ?? 0;
    final lastRun = to?.run ?? runs.length - 1;
    for (var r = firstRun; r <= lastRun; r++) {
      var piece = text(runs[r]);
      // A marker is never inside math, so only text runs are cut.
      if (!isMath(runs[r])) {
        final begin = r == from?.run ? from!.end : 0;
        final finish = r == to?.run ? to!.start : piece.length;
        piece = piece.substring(begin, finish);
      }
      if (piece.isNotEmpty) out.add({...runs[r], 'text': piece});
    }
    return out;
  }

  List<Map<String, Object?>> trimmed(List<Map<String, Object?>> pieces) {
    final out = [...pieces];
    while (out.isNotEmpty &&
        !isMath(out.first) &&
        text(out.first).trimLeft().isEmpty) {
      out.removeAt(0);
    }
    while (out.isNotEmpty &&
        !isMath(out.last) &&
        text(out.last).trimRight().isEmpty) {
      out.removeLast();
    }
    if (out.isNotEmpty && !isMath(out.first)) {
      out[0] = {...out.first, 'text': text(out.first).trimLeft()};
    }
    if (out.isNotEmpty && !isMath(out.last)) {
      out[out.length - 1] = {...out.last, 'text': text(out.last).trimRight()};
    }
    return out;
  }

  final choices = <ReaderChoice>[];
  for (var k = 0; k < accepted.length; k++) {
    final pieces = trimmed(
      between(accepted[k], k + 1 < accepted.length ? accepted[k + 1] : null),
    );
    final hasContent = pieces.any(
      (run) => isMath(run) || RegExp('[A-Za-z0-9]').hasMatch(text(run)),
    );
    if (!hasContent) return null;
    choices.add(ReaderChoice(accepted[k].letter, pieces));
  }
  return ReaderChoices(trimmed(between(null, accepted.first)), choices);
}
