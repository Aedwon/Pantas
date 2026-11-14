import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';

/// Marks [lessonId] retired and points it at [replacedBy], as a split does.
Future<void> retireTestLesson(
  ContentDatabase db,
  String lessonId,
  List<String> replacedBy,
) async {
  await (db.update(db.contentLessons)..where((l) => l.id.equals(lessonId)))
      .write(
    ContentLessonsCompanion(
      status: const Value('retired'),
      replacedBy: Value(jsonEncode(replacedBy)),
    ),
  );
}
