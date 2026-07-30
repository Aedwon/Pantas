import 'package:pantas/features/settings/domain/session_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the default is the interleaved tail, and it is the recommended one',
      () {
    expect(SessionOrdering.fromStorage(null), SessionOrdering.interleavedTail);
    expect(SessionOrdering.interleavedTail.isRecommended, isTrue);
    expect(SessionOrdering.blocked.isRecommended, isFalse);
    expect(SessionOrdering.fullyMixed.isRecommended, isFalse);
  });

  test('an unrecognized stored value falls back to the default', () {
    expect(
      SessionOrdering.fromStorage('nonsense'),
      SessionOrdering.interleavedTail,
    );
  });

  test('storage keeps the spec vocabulary and labels are plain', () {
    expect(SessionOrdering.blocked.storageValue, 'blocked');
    expect(SessionOrdering.blocked.label, 'One topic only');

    expect(SessionOrdering.interleavedTail.storageValue, 'interleavedTail');
    expect(SessionOrdering.interleavedTail.label, 'Interleaved tail');

    expect(SessionOrdering.fullyMixed.storageValue, 'fullyMixed');
    expect(SessionOrdering.fullyMixed.label, 'All mixed up');
  });

  test('every ordering round trips through storage', () {
    for (final ordering in SessionOrdering.values) {
      expect(SessionOrdering.fromStorage(ordering.storageValue), ordering);
    }
  });

  test('no reason uses an em dash', () {
    for (final ordering in SessionOrdering.values) {
      expect(ordering.reason.contains('—'), isFalse);
      expect(ordering.label.contains('—'), isFalse);
    }
  });
}
