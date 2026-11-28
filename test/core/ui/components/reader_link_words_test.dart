// The core of a figure label, which the geometry painter lights.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/reader_link_words.dart';

void main() {
  group('the core of a label', () {
    test('is the text before " = " or ":"', () {
      expect(labelCore('r = 7 cm'), 'r');
      expect(labelCore('Central: 80°'), 'Central');
      expect(labelCore('Arc = 80°'), 'Arc');
    });

    test('drops "Center " and "Point "', () {
      expect(labelCore('Center O'), 'O');
      expect(labelCore('Point T'), 'T');
    });

    test('keeps a plain label whole', () {
      expect(labelCore('Tangent'), 'Tangent');
      expect(labelCore('Diameter AB = 10'), 'Diameter AB');
    });
  });
}
