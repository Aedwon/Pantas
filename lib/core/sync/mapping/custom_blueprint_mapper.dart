import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/sync_mapper.dart';

class CustomBlueprintMapper implements SyncMapper {
  const CustomBlueprintMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'custom_blueprints';

  String documentId(CustomBlueprintRow row) => row.examId;

  Map<String, Object?> toFirestore(
    CustomBlueprintRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'examId': row.examId,
      'totalQuestions': row.totalQuestions,
      'totalMinutes': row.totalMinutes,
      'sectionsJson': row.sectionsJson,
      'sectionsTimedSeparately': row.sectionsTimedSeparately,
      'blueprintUpdatedAt': row.updatedAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  CustomBlueprintRow fromFirestore(Map<String, Object?> doc) {
    final domainUpdatedAt =
        doc['blueprintUpdatedAt'] as String? ?? doc['updatedAt']! as String;
    return CustomBlueprintRow(
      examId: doc['examId']! as String,
      totalQuestions: doc['totalQuestions']! as int,
      totalMinutes: doc['totalMinutes']! as int,
      sectionsJson: doc['sectionsJson']! as String,
      sectionsTimedSeparately: doc['sectionsTimedSeparately'] as bool? ?? false,
      updatedAt: DateTime.parse(domainUpdatedAt),
    );
  }

  CustomBlueprintsLocalCompanion toCompanion(CustomBlueprintRow row) {
    return CustomBlueprintsLocalCompanion(
      examId: Value(row.examId),
      totalQuestions: Value(row.totalQuestions),
      totalMinutes: Value(row.totalMinutes),
      sectionsJson: Value(row.sectionsJson),
      sectionsTimedSeparately: Value(row.sectionsTimedSeparately),
      updatedAt: Value(row.updatedAt),
    );
  }
}
