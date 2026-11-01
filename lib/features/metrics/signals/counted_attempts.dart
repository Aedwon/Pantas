import 'package:flutter/foundation.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';

/// One stored attempt, with the rule for which of its answers count toward the
/// exam being viewed.
@immutable
class CountedAttempt {
  const CountedAttempt(this.row, {Set<String>? carried}) : _carried = carried;

  final AttemptLocalRow row;

  /// Null for an attempt made under the viewed exam: every answer counts, as it
  /// always has. For an attempt made under another exam, the questions that
  /// the viewed exam also lists.
  final Set<String>? _carried;

  bool get isCarried => _carried != null;

  /// Whether the answer to [questionId] counts. Work on a question outside the
  /// viewed exam's pool never counts.
  bool counts(String questionId) =>
      _carried == null || _carried.contains(questionId);
}

/// The attempts that count toward [examId]'s figures. It is a filter over what
/// is stored: nothing is copied and nothing is deleted, so flipping
/// [carryOver] changes the figures at once and loses nothing.
///
/// - Attempts made under [examId] always count.
/// - With [carryOver] on, an attempt made under another exam also counts, for
///   the questions [examId] lists. A mock is one exam's paper and is not
///   carried, so a mirrored mock row from another exam never counts.
///
/// This is the figures only. Today's session and every due date read their own
/// tables and never come through here.
Future<List<CountedAttempt>> countedAttempts({
  required AppDatabase db,
  required ContentRepository content,
  required String examId,
  required bool carryOver,
  bool completedOnly = false,
}) async {
  final query = db.select(db.attemptsLocal);
  if (completedOnly) query.where((a) => a.completedAt.isNotNull());
  final rows = await query.get();

  final own = [
    for (final row in rows)
      if (row.examId == examId) CountedAttempt(row),
  ];
  if (!carryOver) return own;

  const reader = AttemptItemReader();
  final foreign = [
    for (final row in rows)
      if (row.examId != examId && !AttemptOrigins.mirrored.contains(row.origin))
        row,
  ];
  final answered = {
    for (final row in foreign)
      for (final item in reader.read(row.itemsJson)) item.questionId,
  };
  final listed = await content.questionIdsTaggedForExam(
    questionIds: answered,
    examId: examId,
  );
  final carried = <CountedAttempt>[];
  for (final row in foreign) {
    final kept = {
      for (final item in reader.read(row.itemsJson))
        if (listed.contains(item.questionId)) item.questionId,
    };
    if (kept.isNotEmpty) carried.add(CountedAttempt(row, carried: kept));
  }
  return [...own, ...carried];
}

/// The carry-over rule, packaged for the signals. Without a scope a signal
/// reads only the attempts made under the viewed exam, as it always did.
@immutable
class AttemptScope {
  const AttemptScope(this._content, {required this.carryOver});

  final ContentRepository _content;
  final bool carryOver;

  Future<List<CountedAttempt>> attempts(
    AppDatabase db,
    String examId, {
    bool completedOnly = true,
  }) =>
      countedAttempts(
        db: db,
        content: _content,
        examId: examId,
        carryOver: carryOver,
        completedOnly: completedOnly,
      );
}
