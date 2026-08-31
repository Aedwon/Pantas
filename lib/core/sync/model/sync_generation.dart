enum SyncGenerationStatus { staging, active, retired }

class SyncGeneration {
  const SyncGeneration({
    required this.id,
    required this.status,
    required this.schemaVersion,
    required this.createdAt,
    required this.createdByDeviceId,
    required this.preferences,
  });

  factory SyncGeneration.fromMap({
    required String id,
    required Map<String, Object?> data,
  }) {
    final rawStatus = data['status'];
    final schemaVersion = data['schemaVersion'];
    final createdAt = data['createdAt'];
    final createdByDeviceId = data['createdByDeviceId'];
    final rawPreferences = data['preferences'];

    final status = switch (rawStatus) {
      'staging' => SyncGenerationStatus.staging,
      'active' => SyncGenerationStatus.active,
      'retired' => SyncGenerationStatus.retired,
      _ => throw const FormatException('invalid Sync generation status'),
    };
    if (schemaVersion != 1) {
      throw const FormatException('unsupported Sync generation schema');
    }
    if (createdAt is! DateTime) {
      throw const FormatException('Sync generation createdAt missing');
    }
    if (createdByDeviceId is! String || createdByDeviceId.isEmpty) {
      throw const FormatException('Sync generation device identity missing');
    }
    if (rawPreferences is! Map) {
      throw const FormatException('Sync generation preferences missing');
    }

    return SyncGeneration(
      id: id,
      status: status,
      schemaVersion: 1,
      createdAt: createdAt.toUtc(),
      createdByDeviceId: createdByDeviceId,
      preferences: {
        for (final entry in rawPreferences.entries)
          entry.key.toString(): entry.value,
      },
    );
  }

  final String id;
  final SyncGenerationStatus status;
  final int schemaVersion;
  final DateTime createdAt;
  final String createdByDeviceId;
  final Map<String, Object?> preferences;
}
