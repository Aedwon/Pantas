import 'dart:math';

import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';

/// Picks a lesson's in-lesson quiz. The size is the context's requested
/// length (the lesson's quiz size). It takes one question per key point
/// first, then fills from the rest of the lesson's pool. Fresh questions come
/// before ones the student has seen, in both passes, and the choice within a
/// group is random.
class InlineLessonPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    final random = Random(context.shuffleSeed);
    final shuffled = [...context.allQuestions]..shuffle(random);
    final ordered = [
      ...shuffled.where((q) => !context.excludedQuestionIds.contains(q.id)),
      ...shuffled.where((q) => context.excludedQuestionIds.contains(q.id)),
    ];

    final picked = <Question>[];
    final keyPoints = {
      for (final q in ordered)
        if (q.keyPoint != null) q.keyPoint!,
    }.toList()
      ..sort();
    for (final keyPoint in keyPoints) {
      if (picked.length >= context.requestedLength) break;
      picked.add(ordered.firstWhere((q) => q.keyPoint == keyPoint));
    }
    final chosen = picked.map((q) => q.id).toSet();
    for (final question in ordered) {
      if (picked.length >= context.requestedLength) break;
      if (chosen.add(question.id)) picked.add(question);
    }
    return picked;
  }
}
