import 'package:pantas/features/metrics/domain/signal_outputs.dart';

enum SubjectKind { numbers, words }

// IDs and names from tools/lesson_author/outline.json and the CSE rows kept
// by tools/build_content_export/build_content_export.dart. Reasoning and
// General Information have no numbers/words classification.
const subjectKinds = <String, SubjectKind>{
  'subj_upcat_mathematics': SubjectKind.numbers,
  'subj_upcat_science': SubjectKind.numbers,
  'subj_upcat_language_proficiency': SubjectKind.words,
  'subj_upcat_reading_comprehension': SubjectKind.words,
  'subj_cse_verbal': SubjectKind.words,
};

// SubjectAffinitySignal currently keys its output by the content's name.
const _subjectIdsByName = <String, String>{
  'Mathematics': 'subj_upcat_mathematics',
  'Science': 'subj_upcat_science',
  'Language Proficiency (English & Filipino)':
      'subj_upcat_language_proficiency',
  'Reading Comprehension (English & Filipino)':
      'subj_upcat_reading_comprehension',
  'Verbal Ability': 'subj_cse_verbal',
};

SubjectKind? strongestSubjectKind(SubjectAccuracySpeed signal) {
  if (signal.subjects.isEmpty) return null;
  final subjects = signal.subjects.entries.toList()
    ..sort((a, b) => b.value.accuracy.compareTo(a.value.accuracy));
  final key = subjects.first.key;
  return subjectKinds[_subjectIdsByName[key] ?? key];
}
