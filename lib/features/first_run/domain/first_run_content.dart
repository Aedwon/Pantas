/// The fixed lesson and questions a new learner tries after setup ("Try
/// Pantas first", first-run board E-176, plan
/// `docs/superpowers/plans/2026-11-25-first-run-build.md`, ruling 3).
///
/// One lesson for every exam it is tagged for. The questions are 0001 and 0003
/// (both drawn on the board) and 0002, the remaining approved easy question.
/// An exam missing from [firstRunContentFor] gets no run: setup goes to Home.
class FirstRunContent {
  const FirstRunContent({required this.lessonId, required this.questionIds});

  final String lessonId;

  /// In the order the learner answers them.
  final List<String> questionIds;
}

const _lessonId =
    'lesson-arithmetic-number-sense-fractions-decimals-percentages';
const _question = 'q-arithmetic-number-sense-fractions-decimals-percentages';

const _fractions = FirstRunContent(
  lessonId: _lessonId,
  questionIds: ['$_question-0001', '$_question-0003', '$_question-0002'],
);

/// The exams the lesson and all three questions are tagged for.
const firstRunExamIds = <String>{
  'exam_upcat',
  'exam_acet',
  'exam_dlsucet',
  'exam_ustet',
  'exam_pupcet',
  'exam_cse_pro',
  'exam_cse_sub',
};

/// The run for [examId], or null when the exam has no fixed lesson.
FirstRunContent? firstRunContentFor(String examId) =>
    firstRunExamIds.contains(examId) ? _fractions : null;
