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
      final topicIds = area.topicIds;
      for (final row in counts) {
        if (!topicIds.contains(row.topicId)) continue;
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

/// A display part. These keys group rows only and never replace stored ids.
class CseExamPart {
  const CseExamPart({
    required this.key,
    required this.name,
    required this.topicNames,
    required this.slugs,
    this.weight = 0,
  });

  final String key;
  final String name;
  final List<String> topicNames;
  final List<String> slugs;
  final int weight;

  // Preserve Professional's rated scope, including its legacy Text Types topic.
  Set<String> get topicIds => {
        for (final prefix in ['topic_cse_pro_', 'topic_upcat_'])
          for (final slug in slugs) '$prefix$slug',
      };
}

const _general = CseExamPart(
  key: 'general_information',
  name: 'General Information',
  weight: 5,
  topicNames: [
    'Philippine Constitution',
    'Code of Conduct (RA 6713)',
    'Peace and Human Rights',
    'Environment Management',
  ],
  slugs: [
    'philippine_constitution',
    'code_of_conduct_ra_6713',
    'peace_and_human_rights',
    'environment_management',
  ],
);
const _verbal = CseExamPart(
  key: 'verbal_ability',
  name: 'Verbal Ability',
  weight: 30,
  topicNames: [
    'Vocabulary',
    'Grammar and Structure',
    'Application',
    'Comprehension Skills',
  ],
  slugs: [
    'vocabulary',
    'grammar_and_structure',
    'language_application',
    'text_types',
    'comprehension_skills',
  ],
);
const _analytical = CseExamPart(
  key: 'analytical_ability',
  name: 'Analytical Ability',
  weight: 35,
  topicNames: [
    'Logical & Verbal Reasoning',
    'Spatial & Abstract (Non-Verbal) Reasoning',
    'Verbal Logic',
    'Data Interpretation',
  ],
  slugs: [
    'logical_verbal_reasoning',
    'verbal_logic',
    'spatial_abstract_reasoning',
    'data_interpretation',
  ],
);
const _numerical = CseExamPart(
  key: 'numerical_ability',
  name: 'Numerical Ability',
  weight: 30,
  topicNames: ['Arithmetic & Number Sense', 'Algebra'],
  slugs: ['arithmetic_number_sense', 'algebra'],
);
const _clerical = CseExamPart(
  key: 'clerical_ability',
  name: 'Clerical Ability',
  topicNames: ['Clerical Ability'],
  slugs: ['clerical_ability'],
);

// Keep the rating order and weights unchanged.
const _cscAreas = [_verbal, _analytical, _numerical, _general];

List<CseExamPart> csePartsForExam(String examId) => switch (examId) {
      'exam_cse_pro' => const [_general, _verbal, _analytical, _numerical],
      'exam_cse_sub' => const [_general, _verbal, _numerical, _clerical],
      _ => const [],
    };

CseExamPart? csePartForTopic(String examId, String topicName) {
  for (final part in csePartsForExam(examId)) {
    if (part.topicNames.contains(topicName)) return part;
  }
  return null;
}

/// Null for a CSE topic outside its parts. Other exams keep their own heading.
String? examSubjectName(String examId, String topicName, String? subjectName) =>
    csePartsForExam(examId).isEmpty
        ? subjectName
        : csePartForTopic(examId, topicName)?.name;

/// The part a topic counts under, known by its name or by its id.
CseExamPart? csePartForTopicRow(String examId, String topicId, String name) {
  for (final part in csePartsForExam(examId)) {
    if (part.topicNames.contains(name) || part.topicIds.contains(topicId)) {
      return part;
    }
  }
  return null;
}
