import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/sync_mapper.dart';

class PreferencesMapper implements SyncMapper {
  const PreferencesMapper();

  @override
  String get name => 'preferences';

  Map<String, Object?> toFirestore(
    List<AccountPrefRow> accountPrefs, {
    List<DevicePrefRow> devicePrefs = const [],
  }) {
    return {
      'preferences': {
        for (final pref in accountPrefs) pref.key: pref.value,
      },
    };
  }

  List<AccountPrefRow> fromFirestore(Map<String, Object?> doc) {
    final raw = doc['preferences'];
    if (raw is! Map) return const [];

    return raw.entries
        .map(
          (entry) => AccountPrefRow(
            key: entry.key as String,
            value: entry.value as String,
          ),
        )
        .toList(growable: false);
  }
}
