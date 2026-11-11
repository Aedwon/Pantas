/// A launch was refused because a different quiz is paused for this exam.
///
/// Starting never discards a paused quiz silently, so the student has to
/// resume it or discard it first. It is a [StateError] so callers that only
/// catch a failed launch keep working; callers that can offer Resume and
/// Discard catch this one first.
class PausedQuizConflict extends StateError {
  PausedQuizConflict() : super('Another quiz is paused');
}
