/// Walk-through fences in lesson Markdown, shared by the two converters.
///
/// Pure Dart, no Flutter import, so the content build tool can use it. A
/// lesson is a walk-through lesson when it has any line that starts with
/// `:::`. [planWalkthrough] finds every fence, checks the whole lesson against
/// the rules in `docs/superpowers/specs/2026-11-26-walkthrough-renderer-build.md`
/// and its sweep twin `tools/audit/sweep_structure.py`, and throws the first
/// problem. [walkBlock] then builds the Portable Text block for one fence.
///
/// The converters supply two callbacks, so spans and nested blocks come from
/// the same code as the rest of the lesson: [WalkConvert] converts the lines
/// inside a fence, and [WalkSpans] turns a line of text into inline spans.
library;

/// Builds the error a converter throws, with its own wording for the place
/// (`path:line` in the tool, `line n` in the app).
typedef WalkErrorBuilder = FormatException Function(int line, String message);

/// Converts lines to blocks with the converter's own rules. [firstLine] is the
/// number of the first line, so errors name the line in the whole lesson.
typedef WalkConvert = List<Map<String, Object?>> Function(
  List<String> lines,
  int firstLine,
);

/// Turns one line of text into the converter's inline spans.
typedef WalkSpans = List<Map<String, Object?>> Function(String text);

/// The five fences a walk-through lesson may use.
enum WalkKind {
  /// `:::check` with its `:::answer`.
  check('walkCheck', 'check'),

  /// `:::try` with its `:::answer`.
  tryIt('walkTry', 'try'),

  /// `:::why`.
  why('walkWhy', 'why'),

  /// `:::pair #slug`.
  pair('walkPair', 'pair'),

  /// `:::checklist`.
  checklist('walkChecklist', 'checklist');

  const WalkKind(this.portableType, this.word);

  /// The `_type` of the Portable Text block.
  final String portableType;

  /// The word after `:::`.
  final String word;
}

/// One line of a checklist, with the target slug taken off the end.
class WalkChecklistItem {
  /// Creates an item.
  const WalkChecklistItem({
    required this.cue,
    required this.move,
    required this.target,
  });

  /// The text up to and including the first colon outside `$...$`, or empty.
  final String cue;

  /// The text after the cue.
  final String move;

  /// The pair id or `###` slug the line points to.
  final String target;
}

/// One fence found in a lesson. Indexes are positions in the list of lines
/// given to [planWalkthrough].
class WalkFence {
  /// Creates a fence.
  const WalkFence({
    required this.kind,
    required this.start,
    required this.end,
    this.answer,
    this.id,
    this.right,
    this.wrong,
    this.noteStart,
    this.items = const [],
  });

  /// Which fence it is.
  final WalkKind kind;

  /// The index of the opening line.
  final int start;

  /// The index of the closing `:::` line.
  final int end;

  /// The index of `:::answer`, for check and try.
  final int? answer;

  /// The slug of a pair.
  final String? id;

  /// The text after `Right:`.
  final String? right;

  /// The text after `Wrong:`.
  final String? wrong;

  /// The index of the first line of a pair's note.
  final int? noteStart;

  /// The lines of a checklist.
  final List<WalkChecklistItem> items;
}

/// The fences of a lesson, by the index of their opening line.
class WalkPlan {
  /// Creates a plan.
  const WalkPlan({required this.isWalk, required this.fences});

  /// A lesson with no fence: no field is added to any block.
  static const none = WalkPlan(isWalk: false, fences: {});

  /// True when the lesson has any line that starts with `:::`.
  final bool isWalk;

  /// The fences, by the index of their opening line.
  final Map<int, WalkFence> fences;
}

/// The slug of a `###` title: lowercase, runs of anything but `a-z` and `0-9`
/// become one `-`, no `-` at either end. Same rule as the structure sweep.
String headingSlug(String title) => title
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

final _heading3 = RegExp(r'^###\s+(.+)$');
const _slug = '[a-z0-9]+(?:-[a-z0-9]+)*';
final _pairOpen = RegExp('^:::pair\\s+#($_slug)\$');
final _itemStart = RegExp(r'^\s*-\s+(.*)$');
final _itemTarget = RegExp('\\s*\\{#($_slug)\\}\\s*\$');
final _marker = RegExp(r'<!--\s*(?:FIGURE|ILLUSTRATION|IMAGE):');
final _inlineMath = RegExp(r'\$[^$]+\$');

/// Splits checklist text at the first colon outside `$...$`. The cue keeps the
/// colon. With no colon the cue is empty and the move is the whole text.
({String cue, String move}) splitChecklistText(String text) {
  final math = _inlineMath.allMatches(text).toList();
  for (var i = 0; i < text.length; i++) {
    if (text[i] != ':') continue;
    if (math.any((m) => i >= m.start && i < m.end)) continue;
    return (
      cue: text.substring(0, i + 1).trim(),
      move: text.substring(i + 1).trim(),
    );
  }
  return (cue: '', move: text.trim());
}

/// Finds and checks every fence in [lines]. [firstLine] is the number of the
/// first line. Throws the first problem through [error].
WalkPlan planWalkthrough(
  List<String> lines, {
  required int firstLine,
  required WalkErrorBuilder error,
}) {
  final headingSlugs = <String>{};
  var any = false;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith(':::')) any = true;
    final heading = _heading3.firstMatch(trimmed);
    if (heading != null) headingSlugs.add(headingSlug(heading.group(1)!));
  }
  if (!any) return WalkPlan.none;

  final fences = <int, WalkFence>{};
  final pairIds = <String>{};
  final checklistTargets = <(int, String)>[];

  WalkKind? kind;
  var start = 0;
  String? pairId;
  int? answerAt;

  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();
    final lineNumber = firstLine + i;
    final open = kind;
    if (open != null && _marker.hasMatch(lines[i])) {
      throw error(
        lineNumber,
        'figure or illustration marker inside :::${open.word} block',
      );
    }
    if (!trimmed.startsWith(':::')) continue;

    if (open == null) {
      switch (trimmed) {
        case ':::':
          throw error(lineNumber, 'stray closing ::: with no open block');
        case ':::answer':
          throw error(
            lineNumber,
            ':::answer is only allowed inside :::check or :::try',
          );
        case ':::check':
          kind = WalkKind.check;
        case ':::try':
          kind = WalkKind.tryIt;
        case ':::why':
          kind = WalkKind.why;
        case ':::checklist':
          kind = WalkKind.checklist;
        default:
          if (trimmed == ':::pair' ||
              trimmed.startsWith(':::pair ') ||
              trimmed.startsWith(':::pair\t')) {
            final header = _pairOpen.firstMatch(trimmed);
            if (header == null) {
              throw error(
                lineNumber,
                'invalid :::pair header "$trimmed"; '
                'expected :::pair #kebab-slug',
              );
            }
            pairId = header.group(1);
            if (!pairIds.add(pairId!)) {
              throw error(lineNumber, 'duplicate :::pair #$pairId');
            }
            if (pairIds.length > 3) {
              throw error(
                lineNumber,
                'more than 3 :::pair blocks in one lesson',
              );
            }
            kind = WalkKind.pair;
          } else {
            throw error(lineNumber, 'unknown block "$trimmed"');
          }
      }
      start = i;
      answerAt = null;
    } else if (trimmed == ':::') {
      fences[start] = _close(
        open,
        lines,
        start,
        i,
        answerAt: answerAt,
        pairId: pairId,
        firstLine: firstLine,
        error: error,
        checklistTargets: checklistTargets,
      );
      kind = null;
    } else if (trimmed == ':::answer') {
      if (open != WalkKind.check && open != WalkKind.tryIt) {
        throw error(
          lineNumber,
          ':::answer is only allowed inside :::check or :::try',
        );
      }
      if (answerAt != null) {
        throw error(lineNumber, 'second :::answer in :::${open.word} block');
      }
      answerAt = i;
    } else {
      throw error(
        lineNumber,
        'nested block "$trimmed" inside :::${open.word}',
      );
    }
  }
  final unclosed = kind;
  if (unclosed != null) {
    throw error(firstLine + start, 'unclosed :::${unclosed.word} block');
  }

  final targets = {...pairIds, ...headingSlugs};
  for (final (lineNumber, target) in checklistTargets) {
    if (!targets.contains(target)) {
      throw error(
        firstLine + lineNumber,
        'checklist target #$target matches no :::pair id or ### heading',
      );
    }
  }
  return WalkPlan(isWalk: true, fences: fences);
}

WalkFence _close(
  WalkKind kind,
  List<String> lines,
  int start,
  int end, {
  required int? answerAt,
  required String? pairId,
  required int firstLine,
  required WalkErrorBuilder error,
  required List<(int, String)> checklistTargets,
}) {
  switch (kind) {
    case WalkKind.check:
    case WalkKind.tryIt:
      if (answerAt == null) {
        throw error(firstLine + start, ':::${kind.word} has no :::answer');
      }
      return WalkFence(kind: kind, start: start, end: end, answer: answerAt);
    case WalkKind.why:
      return WalkFence(kind: kind, start: start, end: end);
    case WalkKind.pair:
      return _closePair(lines, start, end, pairId!, firstLine, error);
    case WalkKind.checklist:
      return _closeChecklist(
        lines,
        start,
        end,
        firstLine,
        error,
        checklistTargets,
      );
  }
}

WalkFence _closePair(
  List<String> lines,
  int start,
  int end,
  String id,
  int firstLine,
  WalkErrorBuilder error,
) {
  FormatException bad() => error(
        firstLine + start,
        ':::pair #$id needs one Right: line, then one Wrong: line',
      );

  var next = start + 1;
  while (next < end && lines[next].trim().isEmpty) {
    next++;
  }
  if (next >= end || !lines[next].trim().startsWith('Right:')) throw bad();
  final right = lines[next].trim().substring('Right:'.length).trim();
  next++;
  while (next < end && lines[next].trim().isEmpty) {
    next++;
  }
  if (next >= end || !lines[next].trim().startsWith('Wrong:')) throw bad();
  final wrong = lines[next].trim().substring('Wrong:'.length).trim();
  next++;
  for (var i = next; i < end; i++) {
    final text = lines[i].trim();
    if (text.startsWith('Right:') || text.startsWith('Wrong:')) throw bad();
  }
  return WalkFence(
    kind: WalkKind.pair,
    start: start,
    end: end,
    id: id,
    right: right,
    wrong: wrong,
    noteStart: next,
  );
}

WalkFence _closeChecklist(
  List<String> lines,
  int start,
  int end,
  int firstLine,
  WalkErrorBuilder error,
  List<(int, String)> targets,
) {
  final items = <WalkChecklistItem>[];
  for (var i = start + 1; i < end; i++) {
    final text = lines[i].trim();
    if (text.isEmpty) continue;
    final lineNumber = firstLine + i;
    final item = _itemStart.firstMatch(lines[i]);
    if (item == null) {
      throw error(lineNumber, 'checklist line is not a "- " item: "$text"');
    }
    final body = item.group(1)!;
    final target = _itemTarget.firstMatch(body);
    if (target == null) {
      throw error(lineNumber, 'checklist item needs a trailing {#slug}');
    }
    if (items.length == 3) {
      throw error(lineNumber, ':::checklist has more than 3 items');
    }
    final parts = splitChecklistText(body.substring(0, target.start));
    items.add(
      WalkChecklistItem(
        cue: parts.cue,
        move: parts.move,
        target: target.group(1)!,
      ),
    );
    targets.add((i, target.group(1)!));
  }
  if (items.isEmpty) {
    throw error(firstLine + start, ':::checklist has no items');
  }
  return WalkFence(
    kind: WalkKind.checklist,
    start: start,
    end: end,
    items: items,
  );
}

/// Builds the Portable Text block for [fence]. [lines] and [firstLine] are the
/// ones given to [planWalkthrough].
Map<String, Object?> walkBlock(
  WalkFence fence,
  List<String> lines,
  int firstLine, {
  required WalkConvert convert,
  required WalkSpans spans,
}) {
  List<Map<String, Object?>> inner(int from, int to) =>
      convert(lines.sublist(from, to), firstLine + from);
  List<Map<String, Object?>> spansOrEmpty(String text) =>
      text.isEmpty ? const [] : spans(text);

  final type = fence.kind.portableType;
  switch (fence.kind) {
    case WalkKind.check:
      return {
        '_type': type,
        'question': inner(fence.start + 1, fence.answer!),
        'answer': inner(fence.answer! + 1, fence.end),
      };
    case WalkKind.tryIt:
      return {
        '_type': type,
        'prompt': inner(fence.start + 1, fence.answer!),
        'answer': inner(fence.answer! + 1, fence.end),
      };
    case WalkKind.why:
      return {'_type': type, 'body': inner(fence.start + 1, fence.end)};
    case WalkKind.pair:
      return {
        '_type': type,
        'id': fence.id,
        'right': spansOrEmpty(fence.right!),
        'wrong': spansOrEmpty(fence.wrong!),
        'note': inner(fence.noteStart!, fence.end),
      };
    case WalkKind.checklist:
      return {
        '_type': type,
        'items': [
          for (final item in fence.items)
            {
              'cue': spansOrEmpty(item.cue),
              'move': spansOrEmpty(item.move),
              'target': item.target,
            },
        ],
      };
  }
}
