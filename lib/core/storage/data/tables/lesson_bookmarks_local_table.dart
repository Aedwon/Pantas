// coverage:ignore-file
import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/tables/lessons_table.dart';

/// A lesson the student marked to come back to. Separate from
/// `lesson_progress_local` on purpose: a row there means "read", and its
/// `readAt` is non-nullable, so bookmarking an unread lesson would change what
/// every existing progress row means.
@DataClassName('LessonBookmarkLocalRow')
class LessonBookmarksLocal extends Table {
  TextColumn get lessonId => text().references(Lessons, #id)();
  DateTimeColumn get markedAt => dateTime()();

  /// The student's hand ordering. Null until someone drags, which is why the
  /// default Recent order needs no writes at all.
  IntColumn get sortIndex => integer().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {lessonId};
}
