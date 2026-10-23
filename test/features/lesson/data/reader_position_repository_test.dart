import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';

import '../../../helpers/in_memory_database.dart';

class _Preferences extends AppPreferencesRepository {
  _Preferences(super.db);
  int writes = 0;
  Completer<void>? writeEntered;
  Completer<void>? releaseWrite;
  @override
  Future<void> setDeviceValue(String key, String value) async {
    writes++;
    writeEntered?.complete();
    await releaseWrite?.future;
    await super.setDeviceValue(key, value);
  }
}

void main() {
  late AppDatabase db;
  late _Preferences prefs;
  late ReaderPositionRepository positions;
  setUp(() {
    db = inMemoryDatabase();
    prefs = _Preferences(db);
    positions = ReaderPositionRepository(prefs, database: db);
  });
  tearDown(() => db.close());

  test('no saved fraction returns null, preserving the empty ring', () async {
    expect(await positions.readFraction('e', 'l'), isNull);
  });
  test('offset and fraction save together in one preference write', () async {
    await positions.write('e', 'l', 240, fraction: .25);
    expect(prefs.writes, 1);
    expect(await positions.read('e', 'l'), 240);
    expect(await positions.readFraction('e', 'l'), .25);
    final raw = await prefs.deviceValue('lesson_offset.e.l');
    expect(jsonDecode(raw!), {'offset': 240, 'fraction': .25});
  });
  test('fraction-only writes preserve the offset and remain scoped', () async {
    await positions.write('e', 'l', 120);
    await positions.writeFraction('e', 'l', .75);
    expect(await positions.read('e', 'l'), 120);
    expect(await positions.readFraction('e', 'l'), .75);
    expect(await positions.readFraction('other', 'l'), isNull);
    expect(await positions.readFraction('e', 'other'), isNull);
  });
  test('old scalar offsets still resume and have no fraction', () async {
    await prefs.setDeviceValue('lesson_offset.e.l', '360.0');
    expect(await positions.read('e', 'l'), 360);
    expect(await positions.readFraction('e', 'l'), isNull);
    await positions.writeFraction('e', 'l', .5);
    expect(await positions.read('e', 'l'), 360);
    expect(await positions.readFraction('e', 'l'), .5);
  });
  test('zero and one fractions round-trip', () async {
    for (final fraction in [0.0, 1.0]) {
      await positions.writeFraction('e', 'l', fraction);
      expect(await positions.readFraction('e', 'l'), fraction);
    }
  });
  test('invalid fraction writes fail before changing the saved position',
      () async {
    await positions.write('e', 'l', 120, fraction: .25);
    for (final fraction in [-.1, 1.1, double.nan, double.infinity]) {
      await expectLater(
        positions.writeFraction('e', 'l', fraction),
        throwsArgumentError,
      );
      expect(await positions.readFraction('e', 'l'), .25);
      await expectLater(
        positions.write('e', 'l', 200, fraction: fraction),
        throwsArgumentError,
      );
      expect(await positions.read('e', 'l'), 120);
    }
  });
  test('malformed or out-of-range saved values leave the ring empty', () async {
    for (final raw in [
      'broken',
      '{',
      '{"offset":20,"fraction":-1}',
      '{"offset":20,"fraction":2}',
      '{"offset":20,"fraction":"NaN"}',
    ]) {
      await prefs.setDeviceValue('lesson_offset.e.l', raw);
      expect(await positions.readFraction('e', 'l'), isNull);
    }
  });
  test('view capture enters database queue before actual empty wipe', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final blocking = db.transaction(() async {
      entered.complete();
      await release.future;
    });
    await entered.future;
    final token = positions.captureToken(isCurrent: () => true);
    final wipe = SyncLocalStateWiper(db).wipeAll();
    release.complete();
    await blocking;
    expect(await token, isNotNull);
    await wipe;
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    expect(
      await positions.isBoundaryCurrent(
        ReaderBoundary(examId: 'e', token: (await token)!),
        isCurrent: () => true,
      ),
      isFalse,
    );
    final fresh = await positions.captureToken(isCurrent: () => true);
    expect(fresh, isNotNull);
    expect(fresh, isNot(await token));
  });

  test('canceled queued initial capture never initializes after wipe',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final blocking = db.transaction(() async {
      entered.complete();
      await release.future;
    });
    await entered.future;
    var alive = true;
    final token = positions.captureToken(isCurrent: () => alive);
    alive = false;
    final wipe = SyncLocalStateWiper(db).wipeAll();
    release.complete();
    await blocking;
    expect(await token, isNull);
    await wipe;
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
  });

  test('initial token transaction rolls back cancellation after initialization',
      () async {
    var checks = 0;
    expect(await positions.captureToken(isCurrent: () => ++checks < 3), isNull);
    expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
  });

  test('early capture preserves recognized stable and anonymous snapshots',
      () async {
    final contexts = SyncActiveContextStore(db);
    for (final stable in [true, false]) {
      if (stable) {
        await contexts.publishStable(uid: 'u', generationId: 'g');
      } else {
        await contexts.clearStable();
      }
      final before = (await contexts.readSnapshot())!;
      expect(await positions.captureToken(isCurrent: () => true), before.token);
      expect((await contexts.readSnapshot())!.context, before.context);
    }
  });

  group('captured reader boundary', () {
    test('initial missing guest captures one reusable anonymous envelope',
        () async {
      final contexts = SyncActiveContextStore(db);
      final boundary =
          await positions.captureBoundary('e', isCurrent: () => true);
      expect(boundary, isNotNull);
      final captured = await contexts.readSnapshot();
      expect(captured!.context, isNull);
      expect(boundary!.token, captured.token);
      final again = await positions.captureBoundary('e', isCurrent: () => true);
      expect(again!.token, boundary.token);
    });

    test('recognized stable and anonymous snapshots keep their exact token',
        () async {
      final contexts = SyncActiveContextStore(db);
      for (final stable in [true, false]) {
        if (stable) {
          await contexts.publishStable(uid: 'u', generationId: 'g');
        } else {
          await contexts.clearStable();
        }
        final before = await contexts.readSnapshot();
        final boundary =
            await positions.captureBoundary('e', isCurrent: () => true);
        final after = await contexts.readSnapshot();
        expect(boundary!.token, before!.token);
        expect(after!.token, before.token);
        expect(after.context, before.context);
      }
    });

    test('ordinary guarded write keeps measured offset and fraction together',
        () async {
      final boundary =
          (await positions.captureBoundary('e', isCurrent: () => true))!;
      expect(
        await positions.writeGuarded(
          boundary,
          'l',
          120,
          fraction: .25,
          isCurrent: () => true,
        ),
        isTrue,
      );
      expect(await positions.read('e', 'l'), 120);
      expect(await positions.readFraction('e', 'l'), .25);
    });

    test('real wipe expires a held write without recreating its guest token',
        () async {
      final boundary =
          (await positions.captureBoundary('e', isCurrent: () => true))!;
      await SyncLocalStateWiper(db).wipeAll();
      expect(
        await positions.writeGuarded(
          boundary,
          'l',
          120,
          fraction: .25,
          isCurrent: () => true,
        ),
        isFalse,
      );
      expect(await prefs.deviceValue('lesson_offset.e.l'), isNull);
      expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    });

    test('same account reset and another account expire the held write',
        () async {
      final contexts = SyncActiveContextStore(db);
      await contexts.publishStable(uid: 'u', generationId: 'g');
      final boundary =
          (await positions.captureBoundary('e', isCurrent: () => true))!;
      for (final uid in ['u', 'other']) {
        await contexts.publishStable(uid: uid, generationId: 'g');
        expect(
          await positions.writeGuarded(
            boundary,
            'l',
            120,
            fraction: .25,
            isCurrent: () => true,
          ),
          isFalse,
        );
        expect(await prefs.deviceValue('lesson_offset.e.l'), isNull);
      }
    });

    test('changed exam rejects capture and a previously held write', () async {
      await prefs.setSelectedExamId('e');
      final boundary =
          (await positions.captureBoundary('e', isCurrent: () => true))!;
      await prefs.setSelectedExamId('other');
      expect(
        await positions.captureBoundary('e', isCurrent: () => true),
        isNull,
      );
      expect(
        await positions.writeGuarded(
          boundary,
          'l',
          120,
          fraction: .25,
          isCurrent: () => true,
        ),
        isFalse,
      );
    });

    test('canceled initial capture does not initialize a missing guest',
        () async {
      expect(
        await positions.captureBoundary('e', isCurrent: () => false),
        isNull,
      );
      expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    });

    test('cancellation during initial capture rolls back guest initialization',
        () async {
      var checks = 0;
      expect(
        await positions.captureBoundary('e', isCurrent: () => ++checks < 4),
        isNull,
      );
      expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    });

    test('queued writes check the boundary when they execute', () async {
      final boundary =
          (await positions.captureBoundary('e', isCurrent: () => true))!;
      final entered = Completer<void>();
      final release = Completer<void>();
      final blocker = positions.runGuarded(
        boundary,
        () async {
          entered.complete();
          await release.future;
        },
        isCurrent: () => true,
      );
      await entered.future;
      var current = true;
      final queued = positions.writeGuarded(
        boundary,
        'l',
        120,
        fraction: .25,
        isCurrent: () => current,
      );
      current = false;
      release.complete();
      expect(await blocker, isTrue);
      expect(await queued, isFalse);
      expect(await prefs.deviceValue('lesson_offset.e.l'), isNull);
    });

    test('a wipe between queued writes rejects the old captured token',
        () async {
      final boundary =
          (await positions.captureBoundary('e', isCurrent: () => true))!;
      prefs
        ..writeEntered = Completer<void>()
        ..releaseWrite = Completer<void>();
      final earlier = positions.write('e', 'other', 10);
      await prefs.writeEntered!.future;
      final stale = positions.writeGuarded(
        boundary,
        'l',
        120,
        fraction: .25,
        isCurrent: () => true,
      );
      await SyncLocalStateWiper(db).wipeAll();
      prefs.releaseWrite!.complete();
      await earlier;
      expect(await stale, isFalse);
      expect(await prefs.deviceValue('lesson_offset.e.l'), isNull);
      expect(await SyncActiveContextStore(db).readSnapshot(), isNull);
    });

    test('actor change inside a guarded transaction rolls back actual writes',
        () async {
      final boundary =
          (await positions.captureBoundary('e', isCurrent: () => true))!;
      var current = true;
      final saved = await positions.runGuarded(
        boundary,
        () async {
          await prefs.setDeviceValue('lesson_offset.e.l', '120');
          current = false;
        },
        isCurrent: () => current,
      );
      expect(saved, isFalse);
      expect(await prefs.deviceValue('lesson_offset.e.l'), isNull);
    });
  });
}
