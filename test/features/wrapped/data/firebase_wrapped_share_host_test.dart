import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/wrapped/data/firebase_wrapped_share_host.dart';

void main() {
  test('a share record carries purgeAt inside the 90 days the rules allow', () {
    final now = DateTime.utc(2026, 11, 20, 8);
    final record = FirebaseWrappedShareHost.shareRecord(
      uid: 'owner',
      shareId: 'a' * 32,
      archetypeId: 'night_owl',
      now: now,
    );
    final purgeAt = (record['purgeAt']! as Timestamp).toDate().toUtc();
    expect(purgeAt.isAfter(now), isTrue);
    // The server clock may run ahead of this device, so the value keeps a
    // margin under the 90-day limit.
    expect(purgeAt.isBefore(now.add(const Duration(days: 90))), isTrue);
    expect(purgeAt.isAfter(now.add(const Duration(days: 80))), isTrue);
    expect(record['ownerUid'], 'owner');
    expect(record['storagePath'], 'wrapped/owner/${'a' * 32}.png');
    expect(record['revoked'], false);
  });
}
