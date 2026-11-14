// PROTOTYPE for the bite-sized lessons visual companion. Not for merge.
//
// The real build reads `part`, `partCount` and the quiz question count from
// the lesson. The prototype keeps them in this table so every surface that
// shows minutes today can show the proposed label from one place.

/// What the bite-sized label needs to know about one lesson.
class BitePart {
  const BitePart({
    required this.questions,
    this.part,
    this.partCount,
  });

  /// Position in the split lesson, 1 based. Null for a lesson not yet split.
  final int? part;
  final int? partCount;

  /// The real quiz question count (the number shown, never the number sized).
  final int questions;
}

/// Which wording the summed "minutes of material" line gets in the mockup.
enum BiteSumOption { countLeft, removed }

abstract final class BiteLabels {
  /// False renders today's label ("10 min"). True renders the proposal.
  static bool enabled = false;
  static BiteSumOption sumOption = BiteSumOption.countLeft;
  static Map<String, BitePart> lessons = {};

  static BitePart? _of(String lessonId) => lessons[lessonId];

  /// The question count a lesson quiz shows. An unsplit lesson keeps 5.
  static int questionsFor(String lessonId) => _of(lessonId)?.questions ?? 5;

  /// "Part 2 of 3 · 4 questions", or "5 questions" for a lesson not yet split.
  static String label(String lessonId, int minutes) {
    if (!enabled) return '$minutes min';
    final p = _of(lessonId);
    final count = p?.questions ?? 5;
    final noun = count == 1 ? 'question' : 'questions';
    if (p?.part == null) return '$count $noun';
    return 'Part ${p!.part} of ${p.partCount} · $count $noun';
  }

  /// The next-part action text for the lesson after [lessonId], or null.
  static String? nextPartAction(String lessonId) {
    final p = _of(lessonId);
    if (!enabled || p?.part == null || p!.part! >= p.partCount!) return null;
    return 'Next: Part ${p.part! + 1} of ${p.partCount}';
  }
}
