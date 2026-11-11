import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';

/// The ordered lessons of a plan day, passed to the reader as route extra.
/// Home keeps `from=home` in the URL as the fallback for a deep link.
@immutable
final class LessonDayContext {
  LessonDayContext({
    required this.date,
    required List<LessonId> lessonIds,
    required this.index,
    this.moreToDo = false,
  }) : lessonIds = List.unmodifiable(lessonIds) {
    RangeError.checkValidIndex(index, this.lessonIds, 'index');
  }

  final DateTime date;
  final List<LessonId> lessonIds;
  final int index;

  /// New questions or reviews are still on the day's list. The reader then
  /// does not close the last lesson with "That's enough for today." (6U-7).
  final bool moreToDo;
}
