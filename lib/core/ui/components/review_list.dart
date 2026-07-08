import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';

enum ReviewFilter { all, wrong, flagged }

/// One question as the review lists it.
class ReviewEntry {
  const ReviewEntry({
    required this.number,
    required this.question,
    required this.isFlagged,
    required this.subjectName,
    required this.label,
    required this.labelIsStem,
    this.chosenChoiceId,
  });

  final int number;
  final Question question;

  /// Null where the question was left blank, which a mock allows and a
  /// practice session does not.
  final ChoiceId? chosenChoiceId;

  final bool isFlagged;
  final String subjectName;

  /// The authored short label, or the stem when the content pass has not
  /// reached this question.
  final String label;
  final bool labelIsStem;

  bool get isAnswered => chosenChoiceId != null;

  bool get isCorrect =>
      chosenChoiceId != null && chosenChoiceId == question.correctChoice.id;
}

class ReviewCounts {
  const ReviewCounts({
    required this.all,
    required this.wrong,
    required this.flagged,
  });

  final int all;
  final int wrong;
  final int flagged;
}

abstract final class FilterReviewEntries {
  /// A blank counts as wrong.
  ///
  /// Not because it is graded the same, but because the student opening this
  /// filter is looking for what they did not get, and a question they never
  /// answered is one of those. The opposite reading is defensible; this one is
  /// chosen and stated so a later reader does not have to guess.
  static bool _isMiss(ReviewEntry entry) => !entry.isCorrect;

  static List<ReviewEntry> call(
    List<ReviewEntry> entries,
    ReviewFilter filter,
  ) =>
      switch (filter) {
        ReviewFilter.all => entries,
        ReviewFilter.wrong => entries.where(_isMiss).toList(),
        ReviewFilter.flagged =>
          entries.where((entry) => entry.isFlagged).toList(),
      };

  static ReviewCounts count(List<ReviewEntry> entries) => ReviewCounts(
        all: entries.length,
        wrong: entries.where(_isMiss).length,
        flagged: entries.where((entry) => entry.isFlagged).length,
      );

  /// First-seen order, so the groups follow the paper rather than the
  /// alphabet.
  static Map<String, List<ReviewEntry>> groupBySubject(
    List<ReviewEntry> entries,
  ) {
    final grouped = <String, List<ReviewEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.subjectName, () => []).add(entry);
    }
    return grouped;
  }
}
