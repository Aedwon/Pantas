import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:meta/meta.dart';

/// One part of the paper, as the student described it.
@immutable
class CustomBlueprintSectionDraft {
  const CustomBlueprintSectionDraft({
    required this.name,
    required this.questions,
    required this.minutes,
    this.subjectId,
  });

  /// Null for a part the student named themselves rather than picking a
  /// subject. It then draws on every topic in the track.
  final SubjectId? subjectId;

  final String name;
  final int questions;
  final int minutes;

  @override
  bool operator ==(Object other) =>
      other is CustomBlueprintSectionDraft &&
      other.subjectId == subjectId &&
      other.name == name &&
      other.questions == questions &&
      other.minutes == minutes;

  @override
  int get hashCode => Object.hash(subjectId, name, questions, minutes);
}

/// The paper a student described for their own track.
///
/// The questions come from the corpus, which Pantas has. The structure is
/// what it does not have: items per part, minutes per part, and whether the
/// parts are timed separately. For a listed exam that is published by the
/// testing body. Here it is the student's own assertion, the same kind of
/// thing as their exam date, so it may be stored and shown back to them.
///
/// It carries no readiness verdict and no comparison against a real paper's
/// difficulty mix, because those still need something published.
@immutable
class CustomBlueprint {
  const CustomBlueprint({
    required this.examId,
    required this.totalQuestions,
    required this.totalMinutes,
    this.sections = const [],
    this.sectionsTimedSeparately = false,
  });

  final ExamId examId;
  final int totalQuestions;
  final int totalMinutes;

  /// Empty means one continuous paper.
  final List<CustomBlueprintSectionDraft> sections;

  final bool sectionsTimedSeparately;

  bool get hasBreakdown => sections.isNotEmpty;

  /// The sections win over the totals, because they are the more specific
  /// claim: a student who sets 120 at the top and enters parts adding to 100
  /// has told us two things, and nothing else can decide which is the paper.
  int get effectiveQuestions => hasBreakdown
      ? sections.fold(0, (sum, section) => sum + section.questions)
      : totalQuestions;

  int get effectiveMinutes => hasBreakdown
      ? sections.fold(0, (sum, section) => sum + section.minutes)
      : totalMinutes;

  /// Exactly what `BlueprintSection.parseList` reads, so the student's paper
  /// enters the existing sampler unchanged.
  ///
  /// Weights are omitted rather than written as equal ones: the sampler
  /// already distributes evenly when they are absent.
  String toSectionsJson(Map<SubjectId, List<TopicId>> topicsBySubject) {
    final everyTopic = [
      for (final topics in topicsBySubject.values) ...topics,
    ];

    if (!hasBreakdown) {
      return jsonEncode([
        {
          'id': 'section_all',
          'name': 'Whole exam',
          'questionCount': totalQuestions,
          'suggestedMinutes': totalMinutes,
          'topicIds': everyTopic,
        },
      ]);
    }

    return jsonEncode([
      for (var i = 0; i < sections.length; i += 1)
        {
          'id': 'section_$i',
          'name': sections[i].name,
          'questionCount': sections[i].questions,
          'suggestedMinutes': sections[i].minutes,
          'topicIds': sections[i].subjectId == null
              ? everyTopic
              : topicsBySubject[sections[i].subjectId] ?? const <TopicId>[],
        },
    ]);
  }
}
