const _cscProfessionalExamId = 'exam_cse_pro';

/// A topic's measured answers, before grouping them into exam areas.
typedef TopicAccuracyCount = ({String topicId, int correct, int answered});

/// Null means there are no answers in the exam's rated areas.
class OverallAccuracy {
  const OverallAccuracy(this.value);

  factory OverallAccuracy.ratio({
    required int correct,
    required int answered,
  }) =>
      OverallAccuracy(answered == 0 ? null : correct / answered);

  /// A legacy server summary has no area counts for a weighted exam.
  factory OverallAccuracy.fromLegacySummary({
    required String examId,
    required int correct,
    required int answered,
  }) =>
      examId == _cscProfessionalExamId
          ? const OverallAccuracy(null)
          : OverallAccuracy.ratio(correct: correct, answered: answered);

  factory OverallAccuracy.fromTopics({
    required String examId,
    required Iterable<TopicAccuracyCount> topics,
  }) {
    final counts = topics.toList();
    if (examId != _cscProfessionalExamId) {
      return OverallAccuracy.ratio(
        correct: counts.fold(0, (sum, row) => sum + row.correct),
        answered: counts.fold(0, (sum, row) => sum + row.answered),
      );
    }
    var weighted = 0.0;
    var weights = 0;
    for (final area in _cscAreas) {
      var correct = 0;
      var answered = 0;
      for (final row in counts) {
        if (!area.topics.contains(row.topicId)) continue;
        correct += row.correct;
        answered += row.answered;
      }
      if (answered == 0) continue;
      weighted += area.weight * correct / answered;
      weights += area.weight;
    }
    return OverallAccuracy(weights == 0 ? null : weighted / weights);
  }

  final double? value;
}

// CSC Professional rating areas. These differ from the app's subjects.
// Both the current CSE topics and shared legacy topics use this scope.
final _cscAreas = [
  (
    weight: 30,
    topics: _topicIds([
      'vocabulary',
      'grammar_and_structure',
      'language_application',
      'text_types',
      'comprehension_skills',
    ]),
  ),
  (
    weight: 35,
    topics: _topicIds([
      'logical_verbal_reasoning',
      'verbal_logic',
      'spatial_abstract_reasoning',
      'data_interpretation',
    ]),
  ),
  (
    weight: 30,
    topics: _topicIds(['arithmetic_number_sense', 'algebra']),
  ),
  (
    weight: 5,
    topics: _topicIds([
      'philippine_constitution',
      'code_of_conduct_ra_6713',
      'peace_and_human_rights',
      'environment_management',
    ]),
  ),
];

Set<String> _topicIds(List<String> slugs) => {
      for (final prefix in ['topic_cse_pro_', 'topic_upcat_'])
        for (final slug in slugs) '$prefix$slug',
    };
