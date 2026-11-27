import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_slim_format_check.dart';
import '../../../tool/content/lesson_checks.dart';

void main() {
  // Trimmed copy of the Nov 27 `discounted-prices` lesson on the lesson
  // branch: four :::check blocks and two **Check:** lines (one under the
  // example, one inside the try's answer).
  const fiveChecks = '''
## Core Concept

### What a Percent Means

**Percent** means "out of \$100\$". So \$20\\%\$ means \$20\$ out of every \$100\$.

:::check
Write \$35\\%\$ as a decimal.
:::answer
The answer is \$0.35\$. Divide \$35\$ by \$100\$.
:::

### Finding the Discount

:::check
A shirt is listed at Php \$500\$ with a \$20\\%\$ discount. How much is the discount?
:::answer
The answer is Php \$100\$. Multiply the listed price by the rate.
:::

:::check
A jacket is listed at Php \$1,200\$ with a \$15\\%\$ discount. What do you pay?
:::answer
The answer is Php \$1,020\$.
:::

:::check
A Php \$2,000\$ watch gets successive discounts of \$10\\%\$ and \$20\\%\$. What is the final price?
:::answer
The answer is Php \$1,440\$.
:::

## Examples

### #1: Basic Discount

A pair of shoes originally priced at Php \$1,500\$ is on sale for \$20\\%\$ off.

**Check:** Use Way \$1\$. The discount is \$1,500\\times0.20=300\$.

### #2: Successive Discounts

:::try
Finish the last step: find \$85\\%\$ of Php \$24,000\$.
:::answer
The answer is Php \$20,400\$.

**Check:** The total discount is \$30,000-20,400=9,600\$.
:::
''';

  // The same lesson with one check and no Check lines.
  const slim = '''
## Core Concept

### What a Percent Means

:::check
A jacket is listed at Php \$1,200\$ with a \$15\\%\$ discount. What do you pay?
:::answer
The answer is Php \$1,020\$.
:::

## Examples

### #1: Basic Discount

A pair of shoes originally priced at Php \$1,500\$ is on sale for \$20\\%\$ off.

### #2: Successive Discounts

:::try
Finish the last step: find \$85\\%\$ of Php \$24,000\$.
:::answer
The answer is Php \$20,400\$. Multiply \$24,000\\times0.85\$.
:::
''';

  test('fails extra checks and every Check line, one violation each', () {
    final findings = checkWalkthroughSlimFormat('discounted', fiveChecks);
    expect(findings.map((v) => v.where), [
      'discounted:15',
      'discounted:21',
      'discounted:27',
      'discounted:39',
      'discounted:48',
    ]);
    for (final extra in findings.take(3)) {
      expect(extra.message, contains('more than one :::check'));
    }
    for (final line in findings.skip(3)) {
      expect(line.message, contains('**Check:**'));
    }
  });

  test('passes one check and no Check lines', () {
    expect(checkWalkthroughSlimFormat('slim', slim), isEmpty);
  });

  test('a lesson with no ::: block is skipped', () {
    const old = '## Examples\n\n### #1: Old\n\n**Check:** fine.\n';
    expect(checkWalkthroughSlimFormat('old', old), isEmpty);
  });

  test('a Check line inside an answer or after a comment still fails', () {
    const md = '''
:::check
Q
:::answer
The answer is 1.

**Check:** inside an answer.
:::

<!--
**Check:** in a comment is ignored.
-->
''';
    final findings = checkWalkthroughSlimFormat('x', md);
    expect(findings, hasLength(1));
    expect(findings.single.where, 'x:6');
  });

  test('all samples in docs/content/walkthrough-samples are listed', () {
    // The sample lessons predate the Nov 27 revision, so they are not
    // required to pass. They must still parse without error.
    final files = Directory('docs/content/walkthrough-samples')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'));
    for (final file in files) {
      expect(
        () => checkWalkthroughSlimFormat(file.path, file.readAsStringSync()),
        returnsNormally,
      );
    }
  });

  test('registered in run_checks.dart and lesson_checks.dart', () {
    expect(
      File('tool/checks/run_checks.dart').readAsStringSync(),
      contains('WalkthroughSlimFormatCheck(),'),
    );
    expect(
      File('tool/checks/run_checks.dart').readAsStringSync(),
      isNot(contains('WalkthroughExampleCheckLineCheck')),
    );
    final root = Directory.systemTemp.createTempSync('walkthrough-slim-');
    try {
      File('${root.path}/lessons/general/topic/part.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '---\n_id: lesson-topic-part\npart: 1\nkeyPoints: [One]\n---\n'
          '$fiveChecks',
        );
      final messages =
          runLessonChecks(root.path).map((v) => v.message).toList();
      expect(messages, contains(contains('more than one :::check')));
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}
