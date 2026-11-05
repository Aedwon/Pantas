import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/reader_blocks.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

Map<String, Object?> _run(String text, [List<String> marks = const []]) =>
    {'_type': 'span', 'text': text, 'marks': marks};

Map<String, Object?> _block(
  Object text, {
  String style = 'normal',
  String? list,
}) =>
    {
      '_type': 'block',
      'style': style,
      'children': text is String ? [_run(text)] : text,
      if (list != null) 'listItem': list,
    };

String _text(List<Map<String, Object?>> runs) =>
    runs.map((r) => r['text']! as String).join();

/// Every lesson body, as the app turns it into blocks.
Map<String, List<Map<String, Object?>>> _lessons() {
  final frontmatter = RegExp(r'^---\n(.*?)\n---\n', dotAll: true);
  final out = <String, List<Map<String, Object?>>>{};
  final files = Directory('content/lessons')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'));
  for (final file in files) {
    final source = file.readAsStringSync();
    final match = frontmatter.firstMatch(source);
    out[file.path] = lessonBlocksFromMarkdown(
      match == null ? source : source.substring(match.end),
    );
  }
  return out;
}

void main() {
  group('section titles', () {
    test('match by words, not by exact title', () {
      expect(
        readerSectionFor('Mnemonics & Memory Aids'),
        ReaderSection.mnemonics,
      );
      expect(readerSectionFor('Memory Aids'), ReaderSection.mnemonics);
      expect(readerSectionFor('Traps to Watch For'), ReaderSection.traps);
      expect(readerSectionFor('Common Traps'), ReaderSection.traps);
      expect(readerSectionFor('Examples'), ReaderSection.examples);
      expect(readerSectionFor('Worked Examples'), ReaderSection.examples);
      expect(readerSectionFor('  examples & practice'), ReaderSection.examples);
    });

    test('never label a section that only sounds close', () {
      for (final title in [
        'Core Concept',
        'Speed Tricks & Shortcuts',
        'When to List Multiples',
        'Counterexamples',
        'Strapless Dresses',
        'Trapezoids',
        '',
      ]) {
        expect(readerSectionFor(title), ReaderSection.plain, reason: title);
      }
    });
  });

  group('planReaderBlocks', () {
    test('turns each h3 under Examples into a card with its solution', () {
      final items = planReaderBlocks([
        _block('Core Concept', style: 'h2'),
        _block('Text.'),
        _block('Examples', style: 'h2'),
        _block('#1: First', style: 'h3'),
        _block('Question one.'),
        _block([
          _run('Solution:', ['strong']),
        ]),
        _block('Step.', list: 'number'),
        _block('#2: Second', style: 'h3'),
        _block('Question two.'),
        _block('Traps to Watch For', style: 'h2'),
        _block('#1: Trap', style: 'h3'),
        _block('Quote', style: 'blockquote'),
      ]);
      final cards = items.whereType<ReaderExample>().toList();
      expect(cards.map((c) => c.number), [1, 2]);
      expect(cards[0].stem, hasLength(1));
      expect(cards[0].solution, hasLength(1));
      expect(cards[1].solution, isEmpty);
      final trap = items.whereType<ReaderPlain>().last;
      expect(trap.section, ReaderSection.traps);
      expect(
        items.whereType<ReaderPlain>().where((p) => p.block['style'] == 'h3'),
        hasLength(1),
        reason: 'only the trap heading stays a plain heading',
      );
    });

    test(
        'numbers restart in each Examples section and nothing throws on odd '
        'input', () {
      final items = planReaderBlocks([
        {'_type': 'mystery'},
        _block('Examples', style: 'h2'),
        _block('A', style: 'h3'),
        _block('Examples', style: 'h2'),
        _block('B', style: 'h3'),
        {'_type': 'block'},
        {'_type': 'block', 'style': 'h3', 'children': 'oops'},
      ]);
      expect(
        items.whereType<ReaderExample>().map((c) => c.number),
        [1, 1, 2],
      );
    });

    test('a Solution word joined to its first step still opens the solution',
        () {
      final items = planReaderBlocks([
        _block('Examples', style: 'h2'),
        _block('#1: Joined', style: 'h3'),
        _block('Question.'),
        _block([
          _run('Solution:', ['strong']),
          _run(' Recall the outline.'),
        ]),
        _block('More.'),
      ]);
      final card = items.whereType<ReaderExample>().single;
      expect(card.stem, hasLength(1));
      expect(card.solution, hasLength(2));
      expect(readerBlockText(card.solution.first), 'Recall the outline.');
      // A bold word that merely starts a sentence is not a solution.
      expect(
        solutionStart(
          _block([
            _run('Solutions', ['strong']),
            _run(' are mixtures.'),
          ]),
        ),
        isNull,
      );
      expect(solutionStart(_block('Solution: plain text')), isNull);
    });

    test('an example without a Solution line has no solution', () {
      final items = planReaderBlocks([
        _block('Examples', style: 'h2'),
        _block('Only', style: 'h3'),
        _block('Text.'),
      ]);
      expect(items.whereType<ReaderExample>().single.solution, isEmpty);
    });
  });

  group('splitReaderChoices', () {
    ReaderChoices? split(
      Object text, {
      String? list,
      String style = 'normal',
    }) =>
        splitReaderChoices(_block(text, list: list, style: style));

    test('cuts A) to D) out of one paragraph', () {
      final result = split('Which is odd? A) one B) two C) three D) four')!;
      expect(_text(result.stem), 'Which is odd?');
      expect(result.choices.map((c) => c.letter), ['A', 'B', 'C', 'D']);
      expect(
        result.choices.map((c) => _text(c.runs)),
        ['one', 'two', 'three', 'four'],
      );
    });

    test('accepts the parenthesized form and a bare list of choices', () {
      final result = split('(A) sharp (B) cut (C) paper (D) blade')!;
      expect(result.stem, isEmpty);
      expect(result.choices.map((c) => _text(c.runs)), [
        'sharp',
        'cut',
        'paper',
        'blade',
      ]);
      expect(split('Which? (A) yes (B) no')!.choices, hasLength(2));
    });

    test('keeps math inside a choice, whole and in place', () {
      final result = split([
        _run('Find it. A) '),
        _run(r'2^2 \times 3', ['latex']),
        _run(' B) '),
        _run(r'\dfrac{1}{2}', ['latex']),
        _run(' and more'),
        _run(' C) none'),
      ])!;
      expect(result.choices, hasLength(3));
      expect(result.choices[0].runs[0]['marks'], ['latex']);
      expect(result.choices[0].runs[0]['text'], r'2^2 \times 3');
      expect(result.choices[1].runs[0]['text'], r'\dfrac{1}{2}');
      expect(_text(result.choices[1].runs), r'\dfrac{1}{2} and more');
      expect(_text(result.choices[2].runs), 'none');
    });

    test('a marker inside dollar math in a text run is not a marker', () {
      final result = split(r'Pick. A) $f(A) B) g$ B) two')!;
      expect(result.choices, hasLength(2));
      expect(_text(result.choices[0].runs), r'$f(A) B) g$');
    });

    test('leaves anything that does not truly match alone', () {
      for (final text in [
        'No choices here.',
        'Only A) one',
        'Out of order: B) two A) one',
        'Starts at B: B) two C) three',
        'Skips: A) one C) three',
        'Compare (A) and (B).',
        'A) one B)',
        'Prefix:A) one B) two',
        'word A)one B)two',
      ]) {
        expect(split(text), isNull, reason: text);
      }
      expect(split('A) one B) two', list: 'bullet'), isNull);
      expect(split('A) one B) two', style: 'h3'), isNull);
      expect(split('A) one B) two', style: 'blockquote'), isNull);
      expect(splitReaderChoices({'_type': 'latex', 'body': 'x'}), isNull);
      expect(splitReaderChoices({'_type': 'block', 'children': 5}), isNull);
    });
  });

  group('every lesson under content/lessons', () {
    late Map<String, List<Map<String, Object?>>> lessons;
    setUpAll(() => lessons = _lessons());

    // The only section titles in the corpus. A new one is not wrong, but it
    // must be looked at: this test names it so a person decides how it reads.
    const known = {
      'Core Concept': ReaderSection.plain,
      'Examples': ReaderSection.examples,
      'Traps to Watch For': ReaderSection.traps,
      'Speed Tricks & Shortcuts': ReaderSection.plain,
      'Mnemonics & Memory Aids': ReaderSection.mnemonics,
      'When to List Multiples': ReaderSection.plain,
    };

    test('has lessons to check', () {
      expect(lessons.length, greaterThan(100));
    });

    test('every section title reads as expected, and none is mislabeled', () {
      final unknown = <String>{};
      for (final entry in lessons.entries) {
        for (final block in entry.value) {
          if (!isReaderHeading(block, 2)) continue;
          final title = readerBlockText(block);
          if (!known.containsKey(title)) {
            unknown.add('$title (${entry.key})');
            continue;
          }
          expect(
            readerSectionFor(title),
            known[title],
            reason: '$title in ${entry.key}',
          );
        }
      }
      expect(unknown, isEmpty, reason: 'New section titles: $unknown');
    });

    test('plans without throwing and loses no block', () {
      var cards = 0;
      var withSolution = 0;
      var split = 0;
      for (final entry in lessons.entries) {
        final blocks = entry.value;
        final items = planReaderBlocks(blocks);
        var placed = 0;
        for (final item in items) {
          switch (item) {
            case ReaderPlain():
              placed++;
              expect(
                isSolutionMarker(item.block),
                isFalse,
                reason: 'a stray Solution line in ${entry.key}',
              );
            case ReaderExample():
              cards++;
              placed += 1 + item.stem.length + item.solution.length;
              if (item.solution.isNotEmpty) {
                withSolution++;
                // A "Solution:" line of its own is one block more. One joined
                // to its first step is a block that became the first step.
                if (blocks.any((b) => identical(b, item.solution.first))) {
                  placed++;
                }
              }
              expect(
                readerBlockText(item.title),
                startsWith('#'),
                reason: 'example title in ${entry.key}',
              );
              for (final block in item.stem) {
                final result = splitReaderChoices(block);
                if (result == null) continue;
                split++;
                expect(
                  result.choices.map((c) => c.letter).toList(),
                  [
                    for (var i = 0; i < result.choices.length; i++)
                      String.fromCharCode(65 + i),
                  ],
                  reason: entry.key,
                );
                // No words are lost: only each marker, "A)" or "(A)", goes.
                final before = readerBlockText(block).replaceAll(
                  RegExp(r'\s+'),
                  '',
                );
                final after = (_text(result.stem) +
                        result.choices.map((c) => _text(c.runs)).join())
                    .replaceAll(RegExp(r'\s+'), '');
                final n = result.choices.length;
                expect(
                  before.length - after.length,
                  inInclusiveRange(2 * n, 3 * n),
                  reason: entry.key,
                );
              }
          }
        }
        expect(placed, blocks.length, reason: entry.key);
      }
      expect(cards, greaterThan(600));
      expect(withSolution, greaterThan(570));
      expect(split, greaterThan(40));
    });
  });

  for (final wide in [true, false]) {
    testWidgets('real lessons draw without error, ${wide ? 'wide' : 'phone'}',
        (tester) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });
      final all = _lessons();
      for (final name in [
        'real-imaginary-numbers.md',
        'word-analogies.md',
        'divisibility-rules.md',
        'parallelism.md',
        'prime-factorization-gcf-lcm.md',
      ]) {
        final key = all.keys.firstWhere((path) => path.endsWith(name));
        await tester.pumpWidget(
          MaterialApp(
            theme: wide ? buildDarkTheme(web: true) : buildLightTheme(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: ContentRenderer(blocks: all[key], readerFigures: true),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: name);
      }
    });
  }
}
