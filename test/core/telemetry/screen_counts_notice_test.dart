import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/screen_counts_notice.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppPreferencesRepository prefs;

  // One store is one visit: the record it keeps of what it showed this visit
  // is in memory, the rest is on the device.
  ScreenCountsNoticeStore visit() => ScreenCountsNoticeStore(prefs);

  setUp(() {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    prefs = AppPreferencesRepository(db);
  });

  test('before the notice was shown, nothing may be counted', () async {
    expect(await visit().countingAllowed('learner-a'), isFalse);
  });

  test('in the visit that showed it, nothing may be counted', () async {
    final now = visit();
    await now.markShown('learner-a');
    expect(await now.countingAllowed('learner-a'), isFalse);
  });

  test('on the next visit counting may start', () async {
    await visit().markShown('learner-a');
    expect(await visit().countingAllowed('learner-a'), isTrue);
  });

  test('showing it again in a later visit does not open the same visit',
      () async {
    await visit().markShown('learner-a');
    final later = visit();
    await later.markShown('learner-a');
    expect(await later.countingAllowed('learner-a'), isTrue);
  });

  test('another learner on the same device is not counted until shown',
      () async {
    await visit().markShown('learner-a');
    final next = visit();
    expect(await next.countingAllowed('learner-a'), isTrue);
    expect(await next.countingAllowed('learner-b'), isFalse);
    await next.markShown('learner-b');
    expect(await next.countingAllowed('learner-b'), isFalse);
    expect(await visit().countingAllowed('learner-b'), isTrue);
  });

  test('dismissing is a record that it was shown, not consent', () async {
    final now = visit();
    await now.markShown('learner-a');
    expect(await now.isDismissed('learner-a'), isFalse);
    await now.markDismissed('learner-a');
    expect(await now.isDismissed('learner-a'), isTrue);
    expect(await now.countingAllowed('learner-a'), isFalse);
    expect(await visit().countingAllowed('learner-a'), isTrue);
  });

  test('dismissing is for one learner only', () async {
    await visit().markDismissed('learner-a');
    expect(await visit().isDismissed('learner-b'), isFalse);
  });

  test('the record is device storage keyed by the account id', () async {
    await visit().markShown('learner-a');
    expect(
      await prefs.deviceValue(ScreenCountsNoticeStore.keyFor('learner-a')),
      isNotNull,
    );
    expect(
      await prefs.deviceValue(ScreenCountsNoticeStore.keyFor('learner-b')),
      isNull,
    );
  });
}
