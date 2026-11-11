import 'package:pantas/core/storage/domain/ids.dart';

/// Web only: makes sure the text of a lesson or question is in the in-memory
/// content database before a repository reads it.
///
/// The in-memory database holds the catalog (ids, titles, topics) from the
/// start, but lesson bodies and question text arrive from the server when
/// first needed. Native builds pass no hook and read the bundled database.
abstract interface class ContentFetchHook {
  /// Fetches [id] when its body is not present yet. True when the body is
  /// present afterwards.
  Future<bool> ensureLesson(LessonId id);

  /// Fetches the question set that carries passage [id] when the passage text
  /// is not present yet. True when the passage is present afterwards.
  Future<bool> ensurePassage(PassageId id);

  /// Fetches the question sets holding [ids] when their text is not present
  /// yet. Returns the ids whose text is present afterwards.
  Future<Set<QuestionId>> ensureQuestions(Iterable<QuestionId> ids);
}
