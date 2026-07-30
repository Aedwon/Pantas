import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TableSortKey { score, time }

enum TableSortDirection { ascending, descending }

enum TableLevel { subject, topic, lesson }

@immutable
class TableOrder {
  const TableOrder({
    required this.sortKey,
    required this.direction,
    required this.level,
    this.subjectId,
  });

  final TableSortKey sortKey;
  final TableSortDirection direction;
  final TableLevel level;

  /// The subject the table is scoped to, or null for all subjects. It
  /// survives a level change and clears at Subject level, where filtering
  /// four rows down to one is not a thing anyone wants.
  final String? subjectId;

  /// Weakest first, which is the actionable direction. Sorting Score
  /// descending is the deliberate other case: it is the view a student
  /// screenshots.
  static const TableOrder defaults = TableOrder(
    sortKey: TableSortKey.score,
    direction: TableSortDirection.ascending,
    level: TableLevel.subject,
  );

  TableOrder copyWith({
    TableSortKey? sortKey,
    TableSortDirection? direction,
    TableLevel? level,
    String? subjectId,
    bool clearSubject = false,
  }) {
    return TableOrder(
      sortKey: sortKey ?? this.sortKey,
      direction: direction ?? this.direction,
      level: level ?? this.level,
      subjectId: clearSubject ? null : (subjectId ?? this.subjectId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableOrder &&
          runtimeType == other.runtimeType &&
          sortKey == other.sortKey &&
          direction == other.direction &&
          level == other.level &&
          subjectId == other.subjectId;

  @override
  int get hashCode => Object.hash(sortKey, direction, level, subjectId);
}

class TableOrderNotifier extends AsyncNotifier<TableOrder> {
  @override
  Future<TableOrder> build() async {
    return load();
  }

  Future<TableOrder> load() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final userSettings = await settingsRepo.readUserSettings();
    if (!userSettings.retainTableOrder) {
      return TableOrder.defaults;
    }

    final prefs = ref.read(appPreferencesRepositoryProvider);
    final sortStr = await prefs.deviceValue('progress_table_sort');
    final dirStr = await prefs.deviceValue('progress_table_direction');
    final levelStr = await prefs.deviceValue('progress_table_level');
    final storedSubject = await prefs.deviceValue('progress_table_subject');
    // The store holds an empty string for "no filter", because clearing a
    // device value and never having set one must read the same.
    final subjectId =
        (storedSubject == null || storedSubject.isEmpty) ? null : storedSubject;

    final sortKey = TableSortKey.values.firstWhere(
      (e) => e.name == sortStr,
      orElse: () => TableSortKey.score,
    );
    final direction = TableSortDirection.values.firstWhere(
      (e) => e.name == dirStr,
      orElse: () => TableSortDirection.ascending,
    );
    final level = TableLevel.values.firstWhere(
      (e) => e.name == levelStr,
      orElse: () => TableLevel.subject,
    );

    return TableOrder(
      sortKey: sortKey,
      direction: direction,
      level: level,
      // Subject level holds no filter, so a stored one is ignored rather
      // than restored into a control that cannot show it.
      subjectId: level == TableLevel.subject ? null : subjectId,
    );
  }

  Future<void> setSortKey(TableSortKey key) async {
    final current = await future;
    final next = current.copyWith(sortKey: key);
    state = AsyncData(next);

    final settingsRepo = ref.read(settingsRepositoryProvider);
    final userSettings = await settingsRepo.readUserSettings();
    if (userSettings.retainTableOrder) {
      final prefs = ref.read(appPreferencesRepositoryProvider);
      await prefs.setDeviceValue('progress_table_sort', key.name);
    }
  }

  Future<void> setDirection(TableSortDirection direction) async {
    final current = await future;
    final next = current.copyWith(direction: direction);
    state = AsyncData(next);

    final settingsRepo = ref.read(settingsRepositoryProvider);
    final userSettings = await settingsRepo.readUserSettings();
    if (userSettings.retainTableOrder) {
      final prefs = ref.read(appPreferencesRepositoryProvider);
      await prefs.setDeviceValue('progress_table_direction', direction.name);
    }
  }

  Future<void> setLevel(TableLevel level) async {
    final current = await future;
    final next = level == TableLevel.subject
        ? current.copyWith(level: level, clearSubject: true)
        : current.copyWith(level: level);
    state = AsyncData(next);

    final settingsRepo = ref.read(settingsRepositoryProvider);
    final userSettings = await settingsRepo.readUserSettings();
    if (userSettings.retainTableOrder) {
      final prefs = ref.read(appPreferencesRepositoryProvider);
      await prefs.setDeviceValue('progress_table_level', level.name);
      if (level == TableLevel.subject) {
        await prefs.setDeviceValue('progress_table_subject', '');
      }
    }
  }

  Future<void> setSubjectId(String? subjectId) async {
    final current = await future;
    final next = subjectId == null
        ? current.copyWith(clearSubject: true)
        : current.copyWith(subjectId: subjectId);
    state = AsyncData(next);

    final settingsRepo = ref.read(settingsRepositoryProvider);
    final userSettings = await settingsRepo.readUserSettings();
    if (userSettings.retainTableOrder) {
      final prefs = ref.read(appPreferencesRepositoryProvider);
      await prefs.setDeviceValue('progress_table_subject', subjectId ?? '');
    }
  }
}

final tableOrderProvider =
    AsyncNotifierProvider<TableOrderNotifier, TableOrder>(
  TableOrderNotifier.new,
);

final retainTableOrderProvider = FutureProvider<bool>((ref) async {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final settings = await settingsRepo.readUserSettings();
  return settings.retainTableOrder;
});
