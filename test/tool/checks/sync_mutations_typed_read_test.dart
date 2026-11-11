import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/sync_mutations_typed_read.dart';

void main() {
  test('typed reads and watches fail', () {
    for (final bad in [
      '_db.select(_db.syncLocalMutations).watch();',
      'db.select(\n  db.syncLocalMutations,\n).get();',
      'q.join([leftOuterJoin(db.syncLocalMutations, on)]);',
      'db.syncLocalMutations.map(row.data);',
      'db.managers.syncLocalMutations.get();',
    ]) {
      expect(findTypedReads('lib/a.dart', bad), hasLength(1), reason: bad);
    }
  });

  test('raw reads, writes and table references pass', () {
    expect(
      findTypedReads('lib/a.dart', """
_db.customSelect('select 1', readsFrom: {_db.syncLocalMutations}).watch();
_db.delete(_db.syncLocalMutations);
_db.into(_db.syncLocalMutations).insert(row);
_db.notifyUpdates({TableUpdate.onTable(_db.syncLocalMutations)});
// _db.select(_db.syncLocalMutations) is what must not come back.
"""),
      isEmpty,
    );
  });
}
