import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_block_spacing_check.dart';

void main() {
  const headingGlued = '''
## Examples

Read the rule first.
## Traps to Watch For

Text.
''';

  const listGlued = '''
## Steps

Do these in order:
- first
- second

Then stop.
''';

  const numberedGlued = '''
Do these in order:
1. first
2. second
''';

  const good = '''
## Examples

Read the rule first.

## Traps to Watch For

Do these in order:

- first
  wrapped line of the first item
- second

1. one
2. two

```
code line
# not a heading
- not a list
```

:::check
Question?

- option
:::answer
Yes.
:::
''';

  test('flags a heading glued under a paragraph line', () {
    final found = checkWalkthroughBlockSpacing('bad', headingGlued);
    expect(found, hasLength(1));
    expect(found.single.where, 'bad:4');
    expect(found.single.message, contains('## Traps to Watch For'));
  });

  test('flags a bullet list glued under a sentence', () {
    final found = checkWalkthroughBlockSpacing('bad', listGlued);
    expect(found, hasLength(1));
    expect(found.single.where, 'bad:4');
    expect(found.single.message, contains('- first'));
  });

  test('flags a numbered list glued under a sentence', () {
    final found = checkWalkthroughBlockSpacing('bad', numberedGlued);
    expect(found, hasLength(1));
    expect(found.single.where, 'bad:2');
  });

  test('passes a lesson with blank lines, wrapped items and code fences', () {
    expect(checkWalkthroughBlockSpacing('good', good), isEmpty);
  });

  test('the four walk-through samples pass', () {
    final dir = Directory('docs/content/walkthrough-samples');
    final files = dir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.md'),
        );
    expect(files, isNotEmpty);
    for (final file in files) {
      final source = file.readAsStringSync();
      final body = source.replaceFirst(
        RegExp(r'^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)'),
        '',
      );
      expect(
        checkWalkthroughBlockSpacing(file.path, body),
        isEmpty,
        reason: file.path,
      );
    }
  });
}
