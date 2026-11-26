import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../content/question_hash.dart';
import '../content/shipping_questions.dart';
import 'check.dart';
import 'lesson_size_check.dart';

final _pairLinePattern = RegExp(r'^:::pair(?:\s|$)');
final _validPairPattern = RegExp(r'^:::pair\s+#([a-z0-9]+(?:-[a-z0-9]+)*)$');

String _normalize(String value) =>
    value.trim().replaceAll(RegExp(r'\s+', unicode: true), ' ');

String _resolveLessonId(Map<String, CheckLesson> byId, String initialId) {
  var id = initialId;
  final seen = <String>{};
  while (byId[id]?.active == false) {
    if (!seen.add(id)) {
      throw FormatException('replacedBy cycle at $id');
    }
    final replacements = byId[id]!.replacements;
    if (replacements.isEmpty) {
      throw FormatException('retired lesson $id replaces nothing');
    }
    id = replacements.first;
  }
  return id;
}

List<Map<String, dynamic>>? _parseCitations(Object? raw) {
  if (raw is Map<String, dynamic>) {
    return [raw];
  }
  if (raw is List<dynamic> && raw.isNotEmpty) {
    final items = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if (entry is! Map<String, dynamic>) return null;
      items.add(entry);
    }
    return items;
  }
  return null;
}

void _verifyCitation({
  required String lessonId,
  required String slug,
  required Map<String, dynamic> citation,
  required Map<String, ShippingQuestion> byQuestionId,
  required Map<String, CheckLesson> byLessonId,
  required List<Violation> found,
}) {
  final questionId = citation['questionId'];
  final wrongChoice = citation['wrongChoice'];
  if (questionId is! String || questionId.trim().isEmpty) {
    found.add(
      Violation(lessonId, 'citation for :::pair #$slug missing questionId'),
    );
    return;
  }
  if (wrongChoice is! String || wrongChoice.trim().isEmpty) {
    found.add(
      Violation(
        lessonId,
        'citation for :::pair #$slug missing wrongChoice on $questionId',
      ),
    );
    return;
  }
  final question = byQuestionId[questionId];
  if (question == null) {
    found.add(
      Violation(lessonId, 'unknown questionId $questionId for :::pair #$slug'),
    );
    return;
  }
  final resolved = _resolveLessonId(
    byLessonId,
    questionLesson(question.question, question.meta),
  );
  if (resolved != lessonId) {
    found.add(
      Violation(
        lessonId,
        'questionId $questionId resolves to $resolved, '
        'expected $lessonId for :::pair #$slug',
      ),
    );
    return;
  }
  final target = _normalize(wrongChoice);
  final choices = question.question['choices'] as YamlList? ?? YamlList();
  var matchedCorrect = false;
  var matchedWrong = false;
  for (final rawChoice in choices) {
    if (rawChoice is! Map) continue;
    final choiceText = _normalize('${rawChoice['text'] ?? ''}');
    if (choiceText != target) continue;
    if (rawChoice['correct'] == true) {
      matchedCorrect = true;
    } else {
      matchedWrong = true;
    }
  }
  if (matchedWrong) return;
  if (matchedCorrect) {
    found.add(
      Violation(
        lessonId,
        'cited choice "$wrongChoice" in $questionId '
        'is the correct answer for :::pair #$slug',
      ),
    );
    return;
  }
  found.add(
    Violation(
      lessonId,
      'cited wrongChoice "$wrongChoice" not found in '
      '$questionId choices for :::pair #$slug',
    ),
  );
}

/// Checks that every `:::pair #slug` in active lessons cites a wrong quiz
/// choice.
///
/// Evidence is read from `<contentRoot>/walkthrough-trap-evidence.json`, where
/// each `(lessonId, slug)` maps to either a single `{questionId, wrongChoice}`
/// object or a non-empty list of those objects.
List<Violation> runWalkthroughTrapPairCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    final lessons = readCheckLessons(contentRoot);
    final byLessonId = {for (final lesson in lessons) lesson.id: lesson};
    final activePairs = <CheckLesson, List<String>>{};

    for (final lesson in lessons.where((lesson) => lesson.active)) {
      final stripped = lesson.body.replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ');
      final slugs = <String>[];
      final seen = <String>{};
      for (final line in const LineSplitter().convert(stripped)) {
        final trimmed = line.trim();
        if (!_pairLinePattern.hasMatch(trimmed)) continue;
        final match = _validPairPattern.firstMatch(trimmed);
        if (match == null) {
          found.add(Violation(lesson.id, 'invalid :::pair header: $trimmed'));
          continue;
        }
        final slug = match.group(1)!;
        if (!seen.add(slug)) {
          found.add(Violation(lesson.id, 'duplicate :::pair #$slug'));
          continue;
        }
        slugs.add(slug);
      }
      if (slugs.isNotEmpty) {
        activePairs[lesson] = slugs;
      }
    }

    if (activePairs.isEmpty) return found;

    final evidenceFile =
        File(p.join(contentRoot, 'walkthrough-trap-evidence.json'));
    if (!evidenceFile.existsSync()) {
      for (final entry in activePairs.entries) {
        for (final slug in entry.value) {
          found.add(
            Violation(
              entry.key.id,
              'missing walkthrough-trap-evidence.json for :::pair #$slug',
            ),
          );
        }
      }
      return found;
    }

    final decoded = jsonDecode(evidenceFile.readAsStringSync());
    if (decoded is! Map<String, dynamic> ||
        decoded['lessons'] is! Map<String, dynamic>) {
      found.add(
        Violation(
          evidenceFile.path,
          'walkthrough-trap-evidence.json must contain a "lessons" object',
        ),
      );
      return found;
    }
    final lessonsEvidence = decoded['lessons'] as Map<String, dynamic>;
    final questions = allQuestionsForApproval(contentRoot);
    final byQuestionId = {for (final q in questions) q.id: q};

    for (final entry in activePairs.entries) {
      final lessonId = entry.key.id;
      final rawLessonMap = lessonsEvidence[lessonId];
      if (rawLessonMap is! Map<String, dynamic>) {
        for (final slug in entry.value) {
          found.add(
            Violation(
              lessonId,
              'missing walkthrough-trap-evidence.json entry for :::pair #$slug',
            ),
          );
        }
        continue;
      }
      for (final slug in entry.value) {
        final citations = _parseCitations(rawLessonMap[slug]);
        if (citations == null) {
          found.add(
            Violation(
              lessonId,
              'missing or invalid citation for :::pair #$slug',
            ),
          );
          continue;
        }
        for (final citation in citations) {
          _verifyCitation(
            lessonId: lessonId,
            slug: slug,
            citation: citation,
            byQuestionId: byQuestionId,
            byLessonId: byLessonId,
            found: found,
          );
        }
      }
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughTrapPairCheck extends Check {
  const WalkthroughTrapPairCheck();

  @override
  String get name => 'walkthrough-trap-pair';

  @override
  String get origin =>
      'Lesson walk-through standard: every :::pair cites a real wrong choice '
      'in the quiz bank';

  @override
  List<Violation> run(String root) =>
      runWalkthroughTrapPairCheck('$root/content');
}
