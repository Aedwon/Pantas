import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/repos/diagnostic_set_repo.dart';
import 'package:cse_cet_reviewer/core/content/repos/mock_blueprint_repo.dart';
import 'package:cse_cet_reviewer/core/content/repos/mock_exam_repo.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentDatabase db;
  final updatedAt = DateTime.utc(2026, 5, 17);

  setUp(() async {
    db = ContentDatabase(NativeDatabase.memory());
    await db.into(db.contentExams).insert(
          ContentExamsCompanion.insert(
            id: 'exam_cse',
            schemaVersion: 1,
            updatedAt: updatedAt,
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
            ordering: 1,
          ),
        );
  });

  tearDown(() => db.close());

  test('MockBlueprintRepo.byExam filters inactive blueprints', () async {
    await db.into(db.contentMockBlueprints).insert(
          ContentMockBlueprintsCompanion.insert(
            id: 'bp_active',
            schemaVersion: 1,
            updatedAt: updatedAt,
            examId: 'exam_cse',
            name: 'CSE Practice',
            durationMinutes: 90,
            sectionsJson: jsonEncode([
              {'subjectId': 'subject_verbal', 'questionCount': 10},
            ]),
          ),
        );
    await db.into(db.contentMockBlueprints).insert(
          ContentMockBlueprintsCompanion.insert(
            id: 'bp_retired',
            schemaVersion: 1,
            isActive: const Value(false),
            updatedAt: updatedAt,
            examId: 'exam_cse',
            name: 'Retired',
            durationMinutes: 90,
            sectionsJson: '[]',
          ),
        );

    final blueprints = await MockBlueprintRepo(db).byExam('exam_cse');

    expect(blueprints.map((blueprint) => blueprint.id), equals(['bp_active']));
    expect(blueprints.single.sectionsJson, contains('subject_verbal'));
  });

  test('MockExamRepo.byBlueprint filters inactive mock exams', () async {
    await db.into(db.contentMockBlueprints).insert(
          ContentMockBlueprintsCompanion.insert(
            id: 'bp_active',
            schemaVersion: 1,
            updatedAt: updatedAt,
            examId: 'exam_cse',
            name: 'CSE Practice',
            durationMinutes: 90,
            sectionsJson: '[]',
          ),
        );
    await db.into(db.contentMockExams).insert(
          ContentMockExamsCompanion.insert(
            id: 'mock_active',
            schemaVersion: 1,
            updatedAt: updatedAt,
            blueprintId: 'bp_active',
            name: 'Mock 1',
            publishedAt: updatedAt,
          ),
        );
    await db.into(db.contentMockExams).insert(
          ContentMockExamsCompanion.insert(
            id: 'mock_retired',
            schemaVersion: 1,
            isActive: const Value(false),
            updatedAt: updatedAt,
            blueprintId: 'bp_active',
            name: 'Old Mock',
            publishedAt: updatedAt,
          ),
        );

    final mockExams = await MockExamRepo(db).byBlueprint('bp_active');

    expect(mockExams.map((mock) => mock.id), equals(['mock_active']));
  });

  test('DiagnosticSetRepo.forExam returns ordered question ids', () async {
    await db.into(db.contentDiagnosticSets).insert(
          ContentDiagnosticSetsCompanion.insert(
            id: 'diag_cse',
            schemaVersion: 1,
            updatedAt: updatedAt,
            examId: 'exam_cse',
            name: 'CSE Diagnostic',
            questionIdsJson: jsonEncode(['q_2', 'q_1']),
          ),
        );

    final diagnosticSet = await DiagnosticSetRepo(db).forExam('exam_cse');

    expect(diagnosticSet, isNotNull);
    expect(diagnosticSet!.questionIds, equals(['q_2', 'q_1']));
  });

  test('future repos return empty results when no active content exists',
      () async {
    expect(await MockBlueprintRepo(db).byExam('exam_cse'), isEmpty);
    expect(await MockExamRepo(db).byBlueprint('missing'), isEmpty);
    expect(await DiagnosticSetRepo(db).forExam('exam_cse'), isNull);
  });
}
