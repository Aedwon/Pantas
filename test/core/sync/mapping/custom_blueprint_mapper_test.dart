import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/custom_blueprint_mapper.dart';

void main() {
  test('custom blueprint mapper round-trips deterministic exam identity', () {
    const mapper = CustomBlueprintMapper();
    final row = CustomBlueprintRow(
      examId: 'exam:custom/a.b',
      totalQuestions: 60,
      totalMinutes: 75,
      sectionsJson: '[{"subjectId":"math"}]',
      sectionsTimedSeparately: true,
      updatedAt: DateTime.utc(2026, 8, 30),
    );

    final doc = mapper.toFirestore(
      row,
      updatedAt: DateTime.utc(2026, 8, 30, 2),
      originDeviceId: 'device-1',
    );
    final restored = mapper.fromFirestore(doc);

    expect(mapper.documentId(row), row.examId);
    expect(restored.examId, row.examId);
    expect(restored.totalQuestions, 60);
    expect(restored.totalMinutes, 75);
    expect(restored.sectionsJson, row.sectionsJson);
    expect(restored.sectionsTimedSeparately, isTrue);
    expect(restored.updatedAt, row.updatedAt);
    expect(doc['schemaVersion'], CustomBlueprintMapper.schemaVersion);
  });
}
