import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';

import '../../../helpers/in_memory_database.dart';

class _Preferences extends AppPreferencesRepository {
  _Preferences(super.db);
  int writes = 0;
  @override
  Future<void> setDeviceValue(String key, String value) {
    writes++;
    return super.setDeviceValue(key, value);
  }
}

void main() {
  late AppDatabase db;
  late _Preferences prefs;
  late ReaderPositionRepository positions;
  setUp(() {
    db = inMemoryDatabase();
    prefs = _Preferences(db);
    positions = ReaderPositionRepository(prefs);
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
}
