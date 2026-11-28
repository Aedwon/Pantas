import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/content/broad_rule_list.dart';

void main() {
  // Real lines from history, trimmed. The lines are the ones that the outside
  // audit flagged as rules stated more broadly than the lesson shows.

  // 033329008 past-time-checks.md lines 56 and 127 (Language Application
  // audit round 3 Blocker: "the shortcut makes the past perfect
  // compulsory whenever order is asked"). Line 20 of the same file (the
  // passive rule) is kept too: it reads "When the subject receives the
  // action", with no listed word, so the list cannot catch it.
  const pastTime = '''
## Core Concept

### Time Clues and Who Acts

Check who does the action. When the subject receives the action instead of doing it, use passive *was* or *were* plus a verb form that usually ends in *-ed*: "The parcels **were collected** by the driver last week." Parcels cannot collect themselves, and *last week* keeps the verb in the past.

:::check
Choose the correct form: In May, the new benches *(were painted / have painted)* by volunteers.
:::answer
*Were painted*: "In May, the new benches were painted by volunteers." *In May* marks a finished past time, and the benches receive the action.
:::

Do not add *had* to every past action. When *before* or *after* already makes the order clear, simple past can be enough unless a question specifically asks for past perfect to mark earlier completion. Do not put *had* on the later event instead of the earlier one.

## Speed Tricks & Shortcuts

Look for time clues first, check every *had + verb* pair for a participle, and when order is asked, put *had* on the earlier event.
''';

  // 033329008 clause-punctuation-checks.md. Line 66 (the comma rule stated for
  // all opening dependent clauses, the round 3 Blocker) has no listed word, so
  // it is not listed. Line 57, in the same lesson, states "only the seven
  // coordinating words" and is.
  const clause = '''
## Core Concept

### Other Linking Words and Clauses

:::why
Why does a comma before *however* fail when a comma before *but* works? In standard writing, only the seven coordinating words (*for, and, nor, but, or, yet, so*) can join two independent clauses after a comma.
:::

A **dependent clause** (*because the office closed*) joins an independent clause differently. Add a comma when the dependent clause comes first ("Because the office closed, we left"), and usually skip the comma when it comes second ("We left because the office closed").
''';

  // ecc329dd1 aspekto-at-paksa-sa-filipino.md. Line 84 (the Check that treats
  // simultaneity as proof of ongoing aspect, a round 8 Blocker) has no listed
  // word. Line 46 (Major: the claim about number is not limited) holds
  // "lamang". The front matter also holds "lamang" and is not teaching text.
  const aspekto = '''
---
_id: "lesson-grammar-and-structure-aspekto-at-paksa-sa-filipino"
title: "Aspekto at Paksa sa Filipino"
keyPoints:
  - "Karaniwang panatilihin ang anyo ng pandiwa kung bilang lamang ng paksa ang nagbago."
---
## Core Concept

### Bilang ng Paksa at Anyo ng Pandiwa

Sa ibang wika tulad ng Ingles, nagbabago ang pandiwa kapag naging maramihan ang paksa. Sa Filipino, karaniwang hindi nagbabago ang aspekto ng pandiwa dahil lamang dumami ang paksa:

## Examples

### #1: Pagpili ng Aspekto Ayon sa Pangyayari

Nasa mesa si Rico at hindi pa tapos sa pagtahi ng kurtina. Aling anyo ng *tahi* ang angkop: *(tumahi / tumatahi / tatahi)* sa "___ pa si Rico ng kurtina habang tumatawag ang kapatid niya"?

**Solution:**

1. Ang pahiwatig ay "hindi pa tapos": nagpapatuloy pa ang pagtahi.

**Check:** Ang *habang tumatawag* ay sabay sa pagtahi, kaya hindi ito tapos o hindi pa nagsisimula.
''';

  // Constructed: every place a listed word may appear without being teaching.
  const notTeaching = r'''
---
_id: "lesson-x"
keyPoints:
  - "Always check only the verb."
---
## Core Concept

### Rule

:::check
Choose the sentence that has only one comma. Which is never wrong?

(A) Only one comma is used here.

(B) All of the commas are used here.
:::answer
The answer is A.
:::

:::pair #only-one
Right: Use only the base form after *can*.
Wrong: Use any form after *can*.
The base form follows *can*.
:::

$$a+b = c \text{ for all } x$$

Use the base form after *can*.
''';

  List<String> lines(String markdown) => [
        for (final hit in broadRuleHits('lesson.md', markdown))
          '${hit.line}|${hit.word}',
      ];

  test('lists the past-time shortcut and its "every past action" rule', () {
    expect(lines(pastTime), ['13|every', '17|every']);
  });

  test('does not list a rule that carries no listed word (passive rule)', () {
    final text = broadRuleHits('lesson.md', pastTime).map((h) => h.sentence);
    expect(text, isNot(contains(contains('receives the action'))));
  });

  test('lists "only the seven coordinating words", not the line 66 rule', () {
    expect(lines(clause), ['6|only']);
  });

  test('lists "lamang" in the aspect claim, not front matter or the Check', () {
    expect(lines(aspekto), ['11|lamang']);
  });

  test('does not list quiz stems, choices, Right and Wrong, math or keys', () {
    expect(lines(notTeaching), isEmpty);
  });

  test('a hit carries the path, line, word and sentence', () {
    final hit = broadRuleHits('math/lesson.md', pastTime).first;
    expect(
      hit.toString(),
      'math/lesson.md:13 | every | Do not add *had* to every past action.',
    );
  });

  test('"X means Y" and plain no are listed', () {
    const md = '''
## Core Concept

### Terms

A **term** means a number or a variable.

There is no common factor here.
''';
    expect(lines(md), ['5|means', '7|no']);
    expect(lines('not a lesson'), isEmpty);
  });

  test('the command lists active walk-through lessons, or the named ones', () {
    final root = Directory.systemTemp.createTempSync('broad-rule-list-');
    try {
      File('${root.path}/lessons/language/a/one.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '---\n_id: one\nkeyPoints: [One]\n---\n$pastTime',
        );
      File('${root.path}/lessons/language/a/two.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '---\n_id: two\nkeyPoints: [One]\n---\n$clause',
        );
      File('${root.path}/lessons/language/a/old.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('---\n_id: old\nkeyPoints: [One]\n---\n'
            'Always do this.\n');
      File('${root.path}/lessons/language/a/retired.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '---\n_id: ret\nstatus: retired\nkeyPoints: [One]\n---\n$clause',
        );

      final all = StringBuffer();
      expect(
        runBroadRuleList(['--root', root.path], all, StringBuffer()),
        0,
      );
      expect(
        all.toString().trim().split('\n').map((l) => l.split(' | ').first),
        [
          'language/a/one.md:17',
          'language/a/one.md:21',
          'language/a/two.md:10',
        ],
      );

      final one = StringBuffer();
      expect(
        runBroadRuleList(
          ['--root', root.path, '--lesson', 'language/a/two.md'],
          one,
          StringBuffer(),
        ),
        0,
      );
      expect(one.toString(), contains('language/a/two.md:10 | only | '));
      expect(one.toString(), isNot(contains('one.md')));

      final err = StringBuffer();
      expect(runBroadRuleList(['--bad'], StringBuffer(), err), 2);
      expect(err.toString(), contains('Usage'));
      expect(
        runBroadRuleList(
          ['--root', root.path, '--lesson', 'nope.md'],
          StringBuffer(),
          err,
        ),
        2,
      );
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}
