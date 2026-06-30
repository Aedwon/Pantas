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
