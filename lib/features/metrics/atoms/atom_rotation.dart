import 'package:cse_cet_reviewer/features/metrics/atoms/atom.dart';

typedef AtomHash = int Function(String userId, DateTime localDate);

class AtomRotation {
  const AtomRotation({AtomHash? hashOverride}) : _hashOverride = hashOverride;

  final AtomHash? _hashOverride;

  AtomKey? pick({
    required String userId,
    required DateTime localDate,
    required List<AtomKey> available,
  }) {
    if (available.isEmpty) return null;
    if (available.length == 1) return available.single;

    final todayIndex = _indexFor(userId, localDate, available.length);
    final yesterday = localDate.subtract(const Duration(days: 1));
    final yesterdayIndex = _indexFor(userId, yesterday, available.length);
    if (todayIndex != yesterdayIndex) return available[todayIndex];
    return available[(todayIndex + 1) % available.length];
  }

  int _indexFor(String userId, DateTime localDate, int length) {
    final ordinal = DateTime(localDate.year, localDate.month, localDate.day)
        .difference(DateTime(1970))
        .inDays;
    return (_hash(userId, localDate).abs() + ordinal) % length;
  }

  int _hash(String userId, DateTime localDate) {
    final override = _hashOverride;
    if (override != null) return override(userId, localDate);
    return Object.hash(userId, localDate.year, localDate.month, localDate.day);
  }
}
