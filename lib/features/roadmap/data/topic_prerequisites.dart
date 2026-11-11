/// Topic id to the topic ids that must be covered first.
///
/// Only links where a topic cannot be understood without the other.
/// Authored order within a subject is not a reason.
///
/// Approved 1 October 2026; see the decision log
/// `2026-10-01-release-first-cuts-log.md`.
const Map<String, List<String>> topicPrerequisites = {
  'topic_upcat_algebra': ['topic_upcat_arithmetic_number_sense'],
  'topic_upcat_trigonometry': ['topic_upcat_geometry'],
  'topic_upcat_precalculus_basic_calculus': ['topic_upcat_algebra'],
  'topic_upcat_language_application': ['topic_upcat_grammar_and_structure'],
};
