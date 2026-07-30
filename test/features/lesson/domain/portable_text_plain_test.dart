import 'package:pantas/features/lesson/domain/portable_text_plain.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> block(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

void main() {
  test('spans in a block join without a gap', () {
    final plain = portableTextToPlain([
      {
        '_type': 'block',
        'style': 'normal',
        'children': [
          {'_type': 'span', 'text': 'Less than means ', 'marks': <String>[]},
          {
            '_type': 'span',
            'text': 'swap',
            'marks': ['strong'],
          },
          {'_type': 'span', 'text': ' the plan.', 'marks': <String>[]},
        ],
      },
    ]);

    expect(plain, 'Less than means swap the plan.');
  });

  test('blocks are separated by a space', () {
    expect(
      portableTextToPlain([block('First block.'), block('Second block.')]),
      'First block. Second block.',
    );
  });

  test('headings are part of the searchable text', () {
    expect(
      portableTextToPlain([block('Core Concept', style: 'h2')]),
      'Core Concept',
    );
  });

  test('a block with no children contributes nothing', () {
    expect(
      portableTextToPlain([
        {'_type': 'block', 'style': 'normal'},
        block('Only this.'),
      ]),
      'Only this.',
    );
  });

  test('a non-block entry is skipped rather than throwing', () {
    expect(
      portableTextToPlain([
        {'_type': 'image', 'asset': 'whatever'},
        block('Only this.'),
      ]),
      'Only this.',
    );
  });

  test('an empty body is an empty string', () {
    expect(portableTextToPlain(const []), '');
  });
}
