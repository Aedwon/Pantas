import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/typeahead_buffer.dart';

void main() {
  const labels = ['Abra', 'Batangas', 'Bohol', 'Cebu', 'Davao'];

  test('one letter jumps to the first label that starts with it', () {
    final buffer = TypeaheadBuffer();
    expect(buffer.search('c', labels), 3);
    expect(
      buffer.search(
        'd',
        labels,
        now: DateTime.now().add(const Duration(seconds: 5)),
      ),
      4,
    );
  });

  test('letters typed within the window extend the buffer', () {
    final buffer = TypeaheadBuffer();
    final t = DateTime(2026, 11, 10, 9);
    expect(buffer.search('b', labels, now: t), 1);
    expect(
      buffer.search(
        'o',
        labels,
        now: t.add(const Duration(milliseconds: 400)),
      ),
      2,
    );
    expect(buffer.text, 'bo');
  });

  test('a pause longer than a second starts a new buffer', () {
    final buffer = TypeaheadBuffer();
    final t = DateTime(2026, 11, 10, 9);
    buffer.search('b', labels, now: t);
    expect(
      buffer.search(
        'c',
        labels,
        now: t.add(const Duration(milliseconds: 1500)),
      ),
      3,
    );
    expect(buffer.text, 'c');
  });

  test('matching ignores case and returns null when nothing matches', () {
    final buffer = TypeaheadBuffer();
    expect(buffer.search('B', labels), 1);
    final other = TypeaheadBuffer();
    expect(other.search('z', labels), isNull);
  });

  test('reset clears the buffer', () {
    final buffer = TypeaheadBuffer()
      ..search('b', labels)
      ..reset();
    expect(buffer.text, '');
  });
}
