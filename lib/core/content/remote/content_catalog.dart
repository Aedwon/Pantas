import 'package:meta/meta.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sanity/parser_exceptions.dart';
import 'package:pantas/core/content/sanity/parsers/diagnostic_set_parser.dart';
import 'package:pantas/core/content/sanity/parsers/exam_parser.dart';
import 'package:pantas/core/content/sanity/parsers/mock_blueprint_parser.dart';
import 'package:pantas/core/content/sanity/parsers/parser_utils.dart';
import 'package:pantas/core/content/sanity/parsers/passage_parser.dart';
import 'package:pantas/core/content/sanity/parsers/subject_parser.dart';
import 'package:pantas/core/content/sanity/parsers/topic_parser.dart';

/// The `getContent` kind `catalog` documents, as the web client reads them.
///
/// The format is written down in `web/README.md` ("Content catalog"). Exams,
/// subjects, topics, passages, diagnostic sets and mock blueprints use the
/// same documents `tools/build_content_export` writes, so one set of parsers
/// reads the bundled seed and the catalog. Lessons and questions use the
/// compact forms below, which carry no text.

/// Id of the catalog document that lists exams, subjects and topics.
const catalogIndexId = 'index';

/// `index`: every exam, subject and topic, and which exams have a catalog.
@immutable
class CatalogIndex {
  const CatalogIndex({
    required this.exams,
    required this.subjects,
    required this.topics,
    required this.catalogs,
  });

  final List<ContentExamsCompanion> exams;
  final List<ContentSubjectsCompanion> subjects;
  final List<ContentTopicsCompanion> topics;

  /// Ids to request next with kind `catalog`: one per exam that has content.
  final List<String> catalogs;
}

/// A lesson without its body.
@immutable
class CatalogLesson {
  const CatalogLesson({
    required this.id,
    required this.topicId,
    required this.subtopicId,
    required this.title,
    required this.summary,
    required this.estimatedMinutes,
    required this.ordering,
    required this.isActive,
  });

  final String id;
  final String topicId;
  final String? subtopicId;
  final String title;
  final String summary;
  final int estimatedMinutes;
  final int ordering;
  final bool isActive;
}

/// A question without its text.
@immutable
class CatalogQuestion {
  const CatalogQuestion({
    required this.id,
    required this.passageId,
    required this.hasFigure,
  });

  final String id;
  final String? passageId;

  /// Quiz planning reads this before the question is fetched.
  final bool hasFigure;
}

/// One question set (the unit `getContent` serves for kind `questions`) and
/// the questions in it. Everything but the ids is shared by all its questions.
@immutable
class CatalogSet {
  const CatalogSet({
    required this.id,
    required this.topicId,
    required this.subtopicId,
    required this.lessonId,
    required this.examIds,
    required this.language,
    required this.questions,
  });

  /// The id to request with kind `questions`.
  final String id;
  final String topicId;
  final String? subtopicId;
  final String? lessonId;
  final List<String> examIds;
  final String language;
  final List<CatalogQuestion> questions;
}

/// `<examId>` (and the part documents named in `parts`).
@immutable
class ExamCatalog {
  const ExamCatalog({
    required this.id,
    required this.subjects,
    required this.topics,
    required this.lessons,
    required this.sets,
    required this.passages,
    required this.diagnosticSets,
    required this.mockBlueprints,
    required this.parts,
  });

  final String id;
  final List<ContentSubjectsCompanion> subjects;
  final List<ContentTopicsCompanion> topics;
  final List<CatalogLesson> lessons;
  final List<CatalogSet> sets;
  final List<ContentPassagesCompanion> passages;
  final List<ContentDiagnosticSetsCompanion> diagnosticSets;
  final List<ContentMockBlueprintsCompanion> mockBlueprints;

  /// Ids of further catalog documents of the same shape. A large exam is
  /// split by subject to stay under the 1 MiB Firestore document limit.
  final List<String> parts;
}

CatalogIndex parseCatalogIndex(Map<String, Object?> data) {
  return CatalogIndex(
    exams: _docs(data, 'exams', parseExam),
    subjects: _docs(data, 'subjects', parseSubject),
    topics: _docs(data, 'topics', parseTopic),
    catalogs: _strings(data['catalogs'], 'index', 'catalogs'),
  );
}

ExamCatalog parseExamCatalog(Map<String, Object?> data) {
  return ExamCatalog(
    id: stringField(data, 'examCatalog', 'id'),
    subjects: _docs(data, 'subjects', parseSubject),
    topics: _docs(data, 'topics', parseTopic),
    lessons: _docs(data, 'lessons', _lesson),
    sets: _docs(data, 'sets', _set),
    passages: _docs(data, 'passages', parsePassage),
    diagnosticSets: _docs(data, 'diagnosticSets', parseDiagnosticSet),
    mockBlueprints: _docs(data, 'mockBlueprints', parseMockBlueprint),
    parts: _strings(data['parts'], 'examCatalog', 'parts'),
  );
}

CatalogLesson _lesson(Map<String, Object?> doc) {
  const doctype = 'catalogLesson';
  return CatalogLesson(
    id: stringField(doc, doctype, 'id'),
    topicId: refField(doc, doctype, 'topic'),
    subtopicId: optionalRefField(doc, doctype, 'subtopic'),
    title: stringField(doc, doctype, 'title'),
    summary: stringField(doc, doctype, 'summary'),
    estimatedMinutes: intField(doc, doctype, 'estimatedMinutes'),
    ordering: doc['ordering'] is int ? doc['ordering']! as int : 0,
    isActive: boolField(doc, doctype, 'isActive'),
  );
}

CatalogSet _set(Map<String, Object?> doc) {
  const doctype = 'catalogSet';
  final questions = doc['questions'];
  if (questions is! List) {
    throw const ParseException(
      doctype: doctype,
      field: 'questions',
      message: 'expected list',
    );
  }
  return CatalogSet(
    id: stringField(doc, doctype, 'id'),
    topicId: refField(doc, doctype, 'topic'),
    subtopicId: optionalRefField(doc, doctype, 'subtopic'),
    lessonId: optionalRefField(doc, doctype, 'lesson'),
    examIds: _strings(doc['exams'], doctype, 'exams'),
    language: optionalStringField(doc, doctype, 'language') ?? 'en',
    questions: [
      for (final raw in questions)
        _question(_object(raw, doctype, 'questions')),
    ],
  );
}

CatalogQuestion _question(Map<String, Object?> doc) {
  const doctype = 'catalogQuestion';
  return CatalogQuestion(
    id: stringField(doc, doctype, 'id'),
    passageId: optionalRefField(doc, doctype, 'passage'),
    hasFigure: boolField(doc, doctype, 'figure', defaultValue: false),
  );
}

/// A missing list is an empty list; a list that holds anything but objects is
/// an error, so a malformed catalog is refused whole rather than half loaded.
List<T> _docs<T>(
  Map<String, Object?> data,
  String field,
  T Function(Map<String, Object?> doc) parse,
) {
  final raw = data[field];
  if (raw == null) return const [];
  if (raw is! List) {
    throw ParseException(
      doctype: 'catalog',
      field: field,
      message: 'expected list',
    );
  }
  return [for (final item in raw) parse(_object(item, 'catalog', field))];
}

Map<String, Object?> _object(Object? value, String doctype, String field) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  throw ParseException(
    doctype: doctype,
    field: field,
    message: 'expected object',
  );
}

List<String> _strings(Object? raw, String doctype, String field) {
  if (raw == null) return const [];
  if (raw is List && raw.every((item) => item is String && item.isNotEmpty)) {
    return raw.cast<String>();
  }
  throw ParseException(
    doctype: doctype,
    field: field,
    message: 'expected list of ids',
  );
}
