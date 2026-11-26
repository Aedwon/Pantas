import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_emphasis_check.dart';

void main() {
  test('fails on bold nested inside italics (the Nov 26 modal line)', () {
    const md = 'Modals take the base verb '
        '(*She **must register***, not *must registers*).\n';
    final findings = checkWalkthroughEmphasis('bad', md);
    expect(findings, hasLength(1));
    expect(findings.single.where, 'bad:1');
  });

  test('fails on triple-star bold italics', () {
    expect(checkWalkthroughEmphasis('bad', 'Use ***always*** here.\n'),
        hasLength(1));
  });

  test('passes on one level of emphasis, math and bullets', () {
    const md = '* A bullet with *italic* and **bold**.\n'
        r'Math such as $2 * 3 = 6$ stays.'
        '\n'
        r'$$a * b$$'
        '\n'
        '(*She must register*, not *must registers*)\n';
    expect(checkWalkthroughEmphasis('good', md), isEmpty);
  });
}
