import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_example_connection_check.dart';
import '../../../tool/content/lesson_checks.dart';

void main() {
  const walkthroughStub = '\n:::check\nFind 1 + 1.\n:::\n';

  test('fails on bare condition and unfinished chain from old Nov 26 sample',
      () {
    const oldSampleExcerpt = '''
## Core Concept

### Put a Negative Value in Parentheses

To **substitute** means to replace a letter with its number.

If \$x=-2\$:

\$\$3x=3(-2)=-6\$\$

\$\$x^2=(-2)^2\$\$

\$\$\\dfrac{12}{x}=\\dfrac{12}{-2}=-6\$\$
$walkthroughStub
''';
    final findings = checkWalkthroughExampleConnections(
      'old-sample',
      oldSampleExcerpt,
    );
    expect(findings, hasLength(2));
    expect(findings[0].message, contains(r'If $x=-2$:'));
    expect(findings[1].message, contains('(-2)^2'));
  });

  test('passes on Aedwon-approved lead-in and complete display chains', () {
    const approvedExcerpt = '''
## Core Concept

### Put a Negative Value in Parentheses

Let's substitute \$x = -2\$ into \$3x\$, \$x^2\$ and \$\\dfrac{12}{x}\$:

\$\$3x = 3(-2) = -6\$\$

\$\$x^2 = (-2)^2 = 4\$\$

\$\$\\dfrac{12}{x} = \\dfrac{12}{(-2)} = -6\$\$
$walkthroughStub
''';
    expect(
      checkWalkthroughExampleConnections('approved', approvedExcerpt),
      isEmpty,
    );
  });

  group('Rule 1: connecting lead-in before display math', () {
    test('fails when display math immediately follows a heading', () {
      const md = '''
## Core Concept

### Discount Formula

\$\$800\\times 0.25 = 200\$\$
$walkthroughStub
''';
      final findings = checkWalkthroughExampleConnections('heading', md);
      expect(findings, hasLength(1));
      expect(findings.single.message, contains('heading'));
    });

    test('fails on bare labels (**Solution:**, For example:, Example:)', () {
      for (final label in ['**Solution:**', 'For example:', 'Example:']) {
        final md = '''
## Examples

### #1: Try One

$label

\$\$2+3=5\$\$
$walkthroughStub
''';
        final findings = checkWalkthroughExampleConnections('label', md);
        expect(findings, hasLength(1), reason: label);
        expect(findings.single.message, contains('bare label'));
      }
    });

    test('fails on bare When condition without an action verb', () {
      const md = '''
## Core Concept

When \$a=3\$:

\$\$2a+1=7\$\$
$walkthroughStub
''';
      final findings = checkWalkthroughExampleConnections('when', md);
      expect(findings, hasLength(1));
      expect(findings.single.message, contains('bare condition'));
    });

    test('allows prose When sentence with action verb before formula', () {
      const md = '''
## Core Concept

When two workers work together, add their rates:

\$\$r_{\\text{together}}=r_1+r_2\$\$
$walkthroughStub
''';
      expect(checkWalkthroughExampleConnections('prose-when', md), isEmpty);
    });

    test('allows formula definition preceded by prose sentence', () {
      const md = '''
## Core Concept

When \$|r|<1\$, the infinite sum \$S_\\infty\$ is:

\$\$S_\\infty=\\dfrac{a_1}{1-r}\$\$
$walkthroughStub
''';
      expect(checkWalkthroughExampleConnections('formula', md), isEmpty);
    });

    test('skips HTML comments when locating the preceding lead-in', () {
      const md = '''
## Core Concept

Compare \$(-3)^2\$ and \$-3^2\$:

<!-- ILLUSTRATION: two panels -->

\$\$(-3)^2=(-3)\\times(-3)=9\$\$

\$\$-3^2=-(3\\times3)=-9\$\$
$walkthroughStub
''';
      expect(checkWalkthroughExampleConnections('comment', md), isEmpty);
    });
  });

  group('Rule 2: display chain ends in a final value', () {
    test('fails on unfinished arithmetic chains in Core Concept', () {
      const cases = [
        r'$$3x=3(-2)$$',
        r'$$\dfrac{12}{x}=\dfrac{12}{(-2)}$$',
        r'$$2+3\times 4=2+12$$',
        r'$$(-3)^2=(-3)\times(-3)$$',
      ];
      for (final expr in cases) {
        final md = '''
## Core Concept

Evaluate the expression:

$expr
$walkthroughStub
''';
        final findings = checkWalkthroughExampleConnections('unfinished', md);
        expect(findings, hasLength(1), reason: expr);
        expect(
          findings.single.message,
          contains('does not end in a final value'),
        );
      }
    });

    test('allows simplified values, fractions, complex numbers, radicals', () {
      const valid = [
        r'$$3x=3(-2)=-6$$',
        r'$$x^2=(-2)^2=4$$',
        r'$$\dfrac{10}{40}=0.25$$',
        r'$$20+10-\dfrac{20\times 10}{100}=28\%$$',
        r'$$S_\infty=16\div\dfrac{3}{2}=16\times\dfrac{2}{3}=\dfrac{32}{3}$$',
        r'$$6+20+7i=26+7i$$',
        r'$$\dfrac{-1+5i}{2}=-\dfrac{1}{2}+\dfrac{5}{2}i$$',
        r'$$\sqrt{12}=2\sqrt{3}$$',
        r'$$S_\infty=\dfrac{a_1}{1-r}$$',
        r'$$60=2^2\times 3\times 5$$',
      ];
      for (final expr in valid) {
        final md = '''
## Core Concept

Check this value:

$expr
$walkthroughStub
''';
        expect(
          checkWalkthroughExampleConnections('valid', md),
          isEmpty,
          reason: expr,
        );
      }
    });

    test('allows intermediate expressions inside numbered ## Examples steps',
        () {
      const md = '''
## Examples

### #1: Multi-Step

Evaluate \$21\\div 7\$.

**Solution:**

1. Check whether \$21\$ is a multiple of \$7\$.

\$\$21=7\\times 3\$\$
$walkthroughStub
''';
      expect(checkWalkthroughExampleConnections('numbered', md), isEmpty);
    });
  });

  test('skips non-walkthrough lessons without ::: blocks', () {
    const legacy = r'''
## Core Concept

If $x=-2$:

$$x^2=(-2)^2$$
''';
    expect(checkWalkthroughExampleConnections('legacy', legacy), isEmpty);
  });

  test('all samples in docs/content/walkthrough-samples pass', () {
    final samplesDir = Directory('docs/content/walkthrough-samples');
    final files = samplesDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    expect(files, isNotEmpty);
    final violations = [
      for (final file in files)
        ...checkWalkthroughExampleConnections(
          file.path,
          file.readAsStringSync(),
        ),
    ];
    expect(violations, isEmpty);
  });

  test('registered in run_checks.dart and lesson_checks.dart', () {
    expect(
      File('tool/checks/run_checks.dart').readAsStringSync(),
      contains('WalkthroughExampleConnectionCheck(),'),
    );
    final root = Directory.systemTemp.createTempSync('walkthrough-conn-');
    try {
      File('${root.path}/lessons/general/topic/part.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '---\n_id: lesson-topic-part\npart: 1\nkeyPoints: [One]\n---\n'
          '## Core Concept\n\nIf \$x=-2\$:\n\n\$\$x^2=(-2)^2\$\$\n'
          '$walkthroughStub',
        );
      final messages =
          runLessonChecks(root.path).map((v) => v.message).toList();
      expect(messages, contains(contains(r'If $x=-2$:')));
      expect(messages, contains(contains('(-2)^2')));
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}
