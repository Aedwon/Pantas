import 'package:cse_cet_reviewer/features/lesson/domain/models/bookmark_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every order round-trips through storage', () {
    for (final order in BookmarkOrder.values) {
      expect(BookmarkOrder.fromStorage(order.storageValue), order);
    }
  });

  test('an absent or unrecognised value falls back to recent', () {
    expect(BookmarkOrder.fromStorage(null), BookmarkOrder.recent);
    expect(BookmarkOrder.fromStorage(''), BookmarkOrder.recent);
    expect(BookmarkOrder.fromStorage('alphabetical'), BookmarkOrder.recent);
  });

  test('recent is the default', () {
    expect(BookmarkOrder.defaultOrder, BookmarkOrder.recent);
  });

  test('each order has the label the control prints', () {
    expect(BookmarkOrder.recent.label, 'Recent');
    expect(BookmarkOrder.bySubject.label, 'By subject');
    expect(BookmarkOrder.oldest.label, 'Oldest');
    expect(BookmarkOrder.custom.label, 'Custom');
  });
}
