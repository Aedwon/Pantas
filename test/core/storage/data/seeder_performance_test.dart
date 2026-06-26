import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('measure first-run seed execution time', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final seeder = Seeder(db, bundle: rootBundle);

    final stopwatch = Stopwatch()..start();
    await seeder.maybeSeed();
    stopwatch.stop();

    final elapsedMs = stopwatch.elapsedMilliseconds;
    // ignore: avoid_print
    print('FIRST-RUN SEED MEASUREMENT: ${elapsedMs}ms');
    expect(elapsedMs, greaterThan(0));
  });
}
