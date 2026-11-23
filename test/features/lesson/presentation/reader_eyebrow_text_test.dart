// UX ruling (Fable 5.2, Nov 23): the phone reader eyebrow drops a parenthetical
// aside so the longest CSE topic fits one caps line on 360 px phones; the full
// name stays everywhere else and for screen readers. Never an ellipsis.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/lesson/presentation/reader_eyebrow_text.dart';

void main() {
  test('a parenthetical aside is dropped and the rest is upper case', () {
    expect(
      readerEyebrowText('Spatial & Abstract (Non-Verbal) Reasoning'),
      'SPATIAL & ABSTRACT REASONING',
    );
  });

  test('a name with no aside is only upper-cased', () {
    expect(readerEyebrowText('Philippine Constitution'),
        'PHILIPPINE CONSTITUTION');
  });

  test('a name that is only an aside keeps its text', () {
    expect(readerEyebrowText('(Reading)'), '(READING)');
  });
}
