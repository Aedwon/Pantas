import 'dart:convert';

import 'package:pantas/core/content/sanity/parser_exceptions.dart';
import 'package:pantas/core/content/sanity/parsers/portable_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('portableTextToJson accepts blocks with span children', () {
    final json = portableTextToJson([
      {
        '_type': 'block',
        'style': 'normal',
        'children': [
          {'_type': 'span', 'text': 'Hello', 'marks': <String>[]},
        ],
      },
    ]);

    final decoded = jsonDecode(json) as List;
    expect(decoded.single, isA<Map<String, Object?>>());
  });

  test('portableTextToJson preserves image and math blocks', () {
    final json = portableTextToJson([
      {
        '_type': 'image',
        'asset': {'_ref': 'image-abc'},
        'alt': 'Diagram',
      },
      {'_type': 'math', 'body': 'x^2 + y^2'},
    ]);

    final decoded = jsonDecode(json) as List;
    expect(decoded.map((block) => (block as Map)['_type']), ['image', 'math']);
  });

  test('portableTextToJson rejects non-list values', () {
    expect(
      () => portableTextToJson({'_type': 'block'}),
      throwsA(isA<ParseException>()),
    );
  });

  test('portableTextToJson rejects span children without text', () {
    expect(
      () => portableTextToJson([
        {
          '_type': 'block',
          'children': [
            {'_type': 'span', 'marks': <String>[]},
          ],
        },
      ]),
      throwsA(isA<ParseException>()),
    );
  });
}
