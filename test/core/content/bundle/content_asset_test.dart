import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the content database ships in the asset bundle', () async {
    final data = await rootBundle.load('assets/seed/content.db');

    expect(data.lengthInBytes, greaterThan(0));
  });

  test('the bundled file is a SQLite database', () async {
    final data = await rootBundle.load('assets/seed/content.db');
    final header = data.buffer
        .asUint8List(data.offsetInBytes, 16)
        .map(String.fromCharCode)
        .join();

    // Every SQLite file begins with this 16-byte magic string. The
    // sixteenth byte is a NUL, not a space, so it is written as an
    // escape: a literal NUL pasted into source is silently lossy.
    expect(header, 'SQLite format 3\x00');
  });
}
