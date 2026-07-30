import 'dart:math';

import 'package:pantas/core/storage/domain/choice.dart';

const _labels = ['A', 'B', 'C', 'D', 'E', 'F'];

/// Puts a question's choices in an order derived from its id.
///
/// Authored files overwhelmingly put the correct answer first: measured across
/// the corpus on 4 August 2026 it was first in 96% of 2,153 questions, and in
/// every single Science and Reasoning question. Served in that order the bank
/// is beatable by always picking A, which measures nothing.
///
/// Ordering by question id rather than at random keeps a question's choices in
/// the same places in the quiz, the reveal and the review, so nothing has to
/// carry the order between them. Scoring compares choice ids, never positions,
/// so reordering here cannot change whether an answer is right.
List<Choice> orderChoicesFor(String questionId, List<Choice> choices) {
  if (choices.isEmpty) return choices;

  final ordered = [...choices]..shuffle(Random(_seedFrom(questionId)));

  return [
    for (var i = 0; i < ordered.length; i++)
      ordered[i].copyWith(label: i < _labels.length ? _labels[i] : '${i + 1}'),
  ];
}

/// FNV-1a, so the order depends only on the id and never on how Dart happens
/// to hash a string in a given run.
int _seedFrom(String questionId) {
  var hash = 0x811c9dc5;
  for (final unit in questionId.codeUnits) {
    hash = (hash ^ unit) * 0x01000193;
    hash &= 0x7fffffff;
  }
  return hash;
}
