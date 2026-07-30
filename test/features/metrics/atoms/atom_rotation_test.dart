import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/metrics/atoms/atom.dart';
import 'package:pantas/features/metrics/atoms/atom_rotation.dart';

void main() {
  test('returns the same atom for the same user and local date', () {
    const atoms = AtomKey.values;
    final date = DateTime(2026, 6, 10);
    const rotation = AtomRotation();

    final first = rotation.pick(
      userId: 'user_1',
      localDate: date,
      available: atoms,
    );
    final second = rotation.pick(
      userId: 'user_1',
      localDate: date,
      available: atoms,
    );

    expect(second, first);
  });

  test('does not repeat yesterday when alternatives are available', () {
    const atoms = [AtomKey.timeOfDay, AtomKey.sessionShape];
    final rotation = AtomRotation(
      hashOverride: (_, __) => 0,
    );

    final yesterday = rotation.pick(
      userId: 'user_1',
      localDate: DateTime(2026, 6, 9),
      available: atoms,
    );
    final today = rotation.pick(
      userId: 'user_1',
      localDate: DateTime(2026, 6, 10),
      available: atoms,
    );

    expect(today, isNot(yesterday));
  });

  test('returns null when no atom has data', () {
    final selected = const AtomRotation().pick(
      userId: 'user_1',
      localDate: DateTime(2026, 6, 10),
      available: const [],
    );

    expect(selected, isNull);
  });
}
