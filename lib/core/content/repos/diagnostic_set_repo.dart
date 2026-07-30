import 'dart:convert';

import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/domain/diagnostic_set.dart';
import 'package:drift/drift.dart';

class DiagnosticSetRepo {
  DiagnosticSetRepo(this._db);

  final ContentDatabase _db;
  ContentDatabase get database => _db;

  Future<DiagnosticSet?> forExam(String examId) async {
    final row = await (_db.select(_db.contentDiagnosticSets)
          ..where(
            (table) =>
                table.examId.equals(examId) & table.isActive.equals(true),
          ))
        .getSingleOrNull();
    if (row == null) return null;
    return DiagnosticSet(
      id: row.id,
      examId: row.examId,
      name: row.name,
      questionIds: (jsonDecode(row.questionIdsJson) as List).cast<String>(),
    );
  }
}
