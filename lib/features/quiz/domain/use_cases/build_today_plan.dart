import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/picker/today_interleaved_picker.dart';
import 'package:pantas/features/quiz/domain/picker/today_topic_picker.dart';

/// The session today's panel describes and the Start button creates.
///
/// The three counts describe **this plan**, not the backlog behind it, which
/// is why they sum to [length]. The panel prints them as
/// "6 due · 3 weak spots · 1 new", so they have to be the makeup of the
/// questions the student is about to be asked.
class TodaySessionPlan {
  const TodaySessionPlan({
    required this.questions,
    required this.dueCount,
    required this.weaknessCount,
    required this.freshCount,
    this.topicId,
    this.topicName,
  });

  static const empty = TodaySessionPlan(
    questions: [],
    dueCount: 0,
    weaknessCount: 0,
    freshCount: 0,
  );

  final List<Question> questions;
  final int dueCount;
  final int weaknessCount;
  final int freshCount;

  /// The topic the session is named after, even when the ordering interleaves
  /// other topics into it.
  final TopicId? topicId;
  final String? topicName;

  bool get isEmpty => questions.isEmpty;

  int get length => questions.length;
}

/// Builds today's session from the three buckets and counts what it built.
///
/// One function so the panel's composition line and the session the Start
/// button creates cannot drift apart. Before this existed,
/// `StartTodaySession` passed every question as `newQuestions` and left
/// `dueQuestions` and `weaknessQuestions` empty, so today's session was the
/// first N questions of the exam in seed order.
abstract final class BuildTodayPlan {
  static TodaySessionPlan call({
    required List<Question> due,
    required List<Question> weakness,
    required List<Question> fresh,
    required List<Question> allQuestions,
    required QuizPreferences preferences,
    TopicId? topicId,
    String? topicName,
    QuestionPicker? topicPicker,
    QuestionPicker? interleavedPicker,
  }) {
    final isBlocked = preferences.ordering == QuizOrdering.blocked;
    final requested =
        preferences.sessionLength == QuizPreferences.allDueSessionLength
            ? allQuestions.length
            : preferences.sessionLength;

    final context = PickContext(
      allQuestions: allQuestions,
      dueQuestions: due,
      weaknessQuestions: weakness,
      newQuestions: fresh,
      requestedLength: requested,
      // Only the blocked ordering confines the pick to one topic. The other
      // two still name the session after `topicId`; they just draw the tail
      // from elsewhere, which is Section 5's whole point.
      topicId: isBlocked ? topicId : null,
    );

    final picked = isBlocked
        ? (topicPicker ?? TodayTopicPicker()).pick(context)
        : (interleavedPicker ?? TodayInterleavedPicker()).pick(context);

    final dueIds = {for (final question in due) question.id};
    final weaknessIds = {for (final question in weakness) question.id};
    final freshIds = {for (final question in fresh) question.id};

    var dueCount = 0;
    var weaknessCount = 0;
    var freshCount = 0;
    for (final question in picked) {
      if (dueIds.contains(question.id)) {
        dueCount++;
      } else if (weaknessIds.contains(question.id)) {
        weaknessCount++;
      } else if (freshIds.contains(question.id)) {
        freshCount++;
      }
    }

    return TodaySessionPlan(
      questions: picked,
      dueCount: dueCount,
      weaknessCount: weaknessCount,
      freshCount: freshCount,
      topicId: topicId,
      topicName: topicName,
    );
  }
}
