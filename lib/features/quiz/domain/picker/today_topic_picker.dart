import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';

class TodayTopicPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    final filtered = PickContext(
      allQuestions: _withinTopic(context.allQuestions, context),
      dueQuestions: _withinTopic(context.dueQuestions, context),
      weaknessQuestions: _withinTopic(context.weaknessQuestions, context),
      newQuestions: _withinTopic(context.newQuestions, context),
      requestedLength: context.requestedLength,
      topicId: context.topicId,
    );
    return _compose(filtered);
  }
}

List<Question> _withinTopic(List<Question> questions, PickContext context) {
  if (context.topicId == null) return questions;
  return questions
      .where((question) => question.topicId == context.topicId)
      .toList();
}

List<Question> _compose(PickContext context) {
  final requested = context.requestedLength;
  if (requested <= 0) return const [];
  final hasDue = context.dueQuestions.isNotEmpty;
  final dueTarget = hasDue ? (requested * 0.6).floor() : 0;
  final weaknessTarget =
      hasDue ? (requested * 0.3).floor() : (requested * 0.7).floor();
  final newTarget = requested - dueTarget - weaknessTarget;

  final picked = <Question>[];
  final used = <String>{};
  void addFrom(List<Question> source, int target) {
    var remaining = target;
    for (final question in source) {
      if (picked.length >= requested || remaining <= 0) break;
      if (used.add(question.id)) {
        picked.add(question);
        remaining--;
      }
    }
  }

  addFrom(context.dueQuestions, dueTarget);
  addFrom(context.weaknessQuestions, weaknessTarget);
  addFrom(context.newQuestions, newTarget);
  addFrom(context.dueQuestions, requested);
  addFrom(context.weaknessQuestions, requested);
  addFrom(context.newQuestions, requested);
  addFrom(context.allQuestions, requested);
  return picked.take(requested).toList();
}
