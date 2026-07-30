import 'dart:convert';

import 'package:pantas/core/content/content.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentDatabase db;
  final updatedAt = DateTime.utc(2026, 5, 19);

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

  test('mockBlueprintsForExamProvider returns parseable active blueprints',
      () async {
    await db.into(db.contentMockBlueprints).insert(
          ContentMockBlueprintsCompanion.insert(
            id: 'bp_cse',
            schemaVersion: 1,
            updatedAt: updatedAt,
            examId: 'exam_cse',
            name: 'CSE Practice',
            durationMinutes: 90,
            sectionsJson: jsonEncode([
              {
                'id': 'general',
                'name': 'General Information',
                'questionCount': 10,
                'suggestedMinutes': 12,
                'topicIds': ['constitution'],
              },
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

    final container = ProviderContainer(
      overrides: [contentDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      mockBlueprintsForExamProvider('exam_cse').future,
    );

    expect(result.blueprints.map((blueprint) => blueprint.blueprint.id), [
      'bp_cse',
    ]);
    expect(result.blueprints.single.sections.single.id, 'general');
    expect(result.invalidBlueprintIds, isEmpty);
  });

  test('provider reports invalid blueprint sections as a typed failure',
      () async {
    await db.into(db.contentMockBlueprints).insert(
          ContentMockBlueprintsCompanion.insert(
            id: 'bp_bad',
            schemaVersion: 1,
            updatedAt: updatedAt,
            examId: 'exam_cse',
            name: 'Broken',
            durationMinutes: 90,
            sectionsJson: '{bad-json',
          ),
        );

    final container = ProviderContainer(
      overrides: [contentDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      mockBlueprintsForExamProvider('exam_cse').future,
    );

    expect(result.blueprints, isEmpty);
    expect(result.invalidBlueprintIds, ['bp_bad']);
    expect(result.failures.single.error, isA<BlueprintParseException>());
  });
}
