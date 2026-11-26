import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_fence_line_check.dart';

void main() {
  test('fails on a closing fence glued to a text line', () {
    // The Nov 26 present-habits shape: the answer never closed.
    const md = ':::check\n'
        'Choose the verb.\n'
        ':::answer\n'
        '*Know* describes a state, not an action. :::\n'
        '\n'
        '## Examples\n';
    final findings = checkWalkthroughFenceLines('bad', md);
    expect(findings, hasLength(1));
    expect(findings.single.where, 'bad:4');
  });

  test('passes when every fence is on its own line', () {
    const md = ':::pair #slug\n'
        'Right: A.\n'
        'Wrong: B.\n'
        'A note.\n'
        ':::\n'
        '\n'
        ':::check\n'
        'Q?\n'
        ':::answer\n'
        'A.\n'
        ':::\n';
    expect(checkWalkthroughFenceLines('good', md), isEmpty);
  });
}
