import 'package:cse_cet_reviewer/core/storage/domain/question.dart';

/// Fills requested slots, taking passage sets whole or not at all.
///
/// Section 4 of the spec: a set is taken only while the remaining room is at
/// least the set's size. A session smaller than the smallest available set
/// contains no passage questions, and that is correct rather than a failure.
abstract final class PassageSetFiller {
  static List<Question> fill({
    required int size,
    required List<Question> freeStanding,
    required Map<String, List<Question>> setsByPassageId,
  }) {
    return fillGeneric<Question>(
      size: size,
      freeStanding: freeStanding,
      setsByPassageId: setsByPassageId,
    );
  }

  static List<T> fillGeneric<T>({
    required int size,
    required List<T> freeStanding,
    required Map<String, List<T>> setsByPassageId,
  }) {
    final result = <T>[];
    for (final set in setsByPassageId.values) {
      if (set.length <= (size - result.length)) {
        result.addAll(set);
      }
    }
    final remainingRoom = size - result.length;
    if (remainingRoom > 0) {
      result.addAll(freeStanding.take(remainingRoom));
    }
    return result;
  }
}

/// Puts every question that shares a passage next to its siblings.
///
/// A student reads a passage once and answers everything about it before
/// moving on, which is how the real papers ask them. Scattering a set
/// across a session makes them read the same passage three times.
///
/// Stable: the first appearance of a passage fixes where its whole set
/// sits, and free-standing questions keep their order around them.
List<Question> groupPassageSets(List<Question> questions) {
  final order = <String>[];
  final sets = <String, List<Question>>{};
  final result = <Question>[];

  for (final q in questions) {
    final passageId = q.passageId;
    if (passageId == null || passageId.isEmpty) continue;
    if (!sets.containsKey(passageId)) {
      sets[passageId] = [];
      order.add(passageId);
    }
    sets[passageId]!.add(q);
  }

  final emitted = <String>{};
  for (final q in questions) {
    final passageId = q.passageId;
    if (passageId == null || passageId.isEmpty) {
      result.add(q);
      continue;
    }
    if (emitted.add(passageId)) result.addAll(sets[passageId]!);
  }
  return result;
}
