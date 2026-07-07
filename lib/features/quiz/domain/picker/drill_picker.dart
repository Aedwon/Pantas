import 'dart:math';

import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';

/// Shuffles the pool and prefers what the student has not just seen.
///
/// It used to filter through `SubtopicFilter`, which both callers fed
/// all-null subtopic ids, so it returned the pool in table order and took the
/// first N. The same ten questions came back in the same order forever, which
/// made "questions you haven't seen this week" untrue.
class DrillPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    final random = Random(context.shuffleSeed);
    final shuffled = [...context.allQuestions]..shuffle(random);

    final fresh = <Question>[];
    final seen = <Question>[];
    for (final question in shuffled) {
      if (context.excludedQuestionIds.contains(question.id)) {
        seen.add(question);
      } else {
        fresh.add(question);
      }
    }

    // Recently answered questions come back as a tail rather than being
    // dropped. A student who worked through a small topic this week should
    // still get a full session, just not the same one first.
    return [...fresh, ...seen].take(context.requestedLength).toList();
  }
}
