import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_hard_break_check.dart';

void main() {
  // The shape found in 45 lane lessons on Nov 26: options stacked with two
  // trailing spaces and no blank line between them.
  // Trailing spaces are written as escapes so editors cannot strip them.
  const runOn = '## Examples\n'
      '\n'
      '### #1: Spelling\n'
      '\n'
      'A) kwento\x20\x20\n'
      'B) kuwento\x20\x20\n'
      'C) kuwentu\x20\x20\n'
      'D) kwentu\n'
      '\n'
      '**Solution:**\n';

  const separated = '''
## Examples

### #1: Spelling

A) kwento

B) kuwento

C) kuwentu

D) kwentu

**Solution:**
''';

  test('fails on options stacked with two trailing spaces', () {
    final findings = checkWalkthroughHardBreaks('bad', runOn);
    expect(findings, hasLength(3));
    expect(findings.first.where, 'bad:5');
    expect(findings.first.message, contains('A) kwento'));
  });

  test('passes when options are separated by blank lines', () {
    expect(checkWalkthroughHardBreaks('good', separated), isEmpty);
  });

  test('ignores trailing spaces before a blank line or a fence', () {
    const md =
        'A plain line.  \n\n:::check  \nQuestion?\n:::answer\nYes.\n:::\n';
    expect(checkWalkthroughHardBreaks('ok', md), isEmpty);
  });
}
