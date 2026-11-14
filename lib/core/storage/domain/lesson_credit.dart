/// Computes family credit without changing stored progress.
///
/// Direct credit wins. A split inherits its earliest qualifying parent; a merge
/// becomes read when its last required parent is read. [compare] orders read
/// times, or returns zero for exclusion flags. Retired ids remain in this map
/// for recursive lookup, so callers must count only active lessons.
Map<String, T> resolveLessonCredit<T extends Object>({
  required Map<String, List<String>> retiredReplacements,
  required Map<String, T> own,
  required int Function(T, T) compare,
}) {
  final split = <String, List<String>>{};
  final merge = <String, List<String>>{};
  for (final entry in retiredReplacements.entries) {
    final targets = entry.value.toSet();
    for (final id in targets) {
      final parents = targets.length >= 2 ? split : merge;
      (parents[id] ??= []).add(entry.key);
    }
  }
  T? resolve(String id, Set<String> visited) {
    if (own.containsKey(id)) return own[id];
    if (!visited.add(id)) return null;
    T? result;
    for (final parent in split[id] ?? const <String>[]) {
      final value = resolve(parent, {...visited});
      if (value != null && (result == null || compare(value, result) < 0)) {
        result = value;
      }
    }
    final parents = merge[id] ?? const <String>[];
    T? merged;
    var all = parents.isNotEmpty;
    for (final parent in parents) {
      final value = resolve(parent, {...visited});
      if (value == null) {
        all = false;
        break;
      }
      if (merged == null || compare(value, merged) > 0) merged = value;
    }
    if (all &&
        merged != null &&
        (result == null || compare(merged, result) < 0)) {
      result = merged;
    }
    return result;
  }

  return {
    for (final id in {...own.keys, ...split.keys, ...merge.keys})
      if (resolve(id, {}) case final T value) id: value,
  };
}
