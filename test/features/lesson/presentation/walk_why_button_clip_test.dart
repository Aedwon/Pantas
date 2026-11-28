// The walk-through "Why?" button overhangs the text column by 14 px on the
// left (board: `.why .wtert{margin-left:-14px}`), so its label lines up with
// the text above. Nothing between the button and the screen may clip that
// overhang. Rendered through the real reader, phone and wide, light and dark.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';

import '../../../helpers/in_memory_database.dart';

Map<String, Object?> _p(
  String text, {
  String style = 'normal',
  String? list,
  int? number,
  bool strong = false,
}) =>
    {
      '_type': 'block',
      'style': style,
      'children': [
        {
          '_type': 'span',
          'text': text,
          'marks': [if (strong) 'strong'],
        },
      ],
      if (list != null) 'listItem': list,
      if (list != null) 'level': 1,
      if (number != null) 'listNumber': number,
    };

Map<String, Object?> _why(String text) => {
      '_type': 'walkWhy',
      'body': [_p(text)],
    };

/// A top-level paragraph with a Why? under it, and an example whose solution
/// has a Why? under the first step's work.
List<Map<String, Object?>> _lesson() => [
      _p('Core Concept', style: 'h2'),
      _p('Top paragraph.'),
      _why('Top reason.'),
      _p('Examples', style: 'h2'),
      _p('#1: One example', style: 'h3'),
      _p('Evaluate it.'),
      _p('Solution:', strong: true),
      _p('Step 1 text.', list: 'number', number: 1),
      _p('Work paragraph.'),
      _why('Example reason.'),
      _p('Step 2 text.', list: 'number', number: 2),
      _p('More work.'),
    ];

/// The clip each ancestor of [leaf] applies, in global coordinates.
List<(String, Rect)> _clips(RenderObject leaf) {
  final out = <(String, Rect)>[];
  var child = leaf;
  while (child.parent != null) {
    final parent = child.parent!;
    final clip = parent.describeApproximatePaintClip(child);
    if (clip != null) {
      final toGlobal = parent.getTransformTo(null);
      out.add(
        (
          '${parent.runtimeType} (${parent.debugCreator})',
          MatrixUtils.transformRect(toGlobal, clip),
        ),
      );
    }
    child = parent;
  }
  return out;
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'A walk-through',
      summary: 'Why test',
      bodyJson: jsonEncode(_lesson()),
    );
  });

  tearDown(() => db.close());

  for (final wide in [false, true]) {
    for (final dark in [false, true]) {
      final name = '${wide ? 'wide 1440' : 'phone 390'}, '
          '${dark ? 'dark' : 'light'}';
      testWidgets('no ancestor clips the Why? overhang, $name', (tester) async {
        debugWebPlatformOverride = wide;
        addTearDown(() => debugWebPlatformOverride = null);
        tester.view
          ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              contentDatabaseProvider.overrideWithValue(contentDb),
            ],
            child: MaterialApp(
              theme:
                  dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
              home: const LessonPage(lessonId: 'l1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final buttons = find.byKey(const ValueKey('walk-why-button'));
        expect(buttons, findsNWidgets(2));
        final paragraphs = {
          0: 'Top paragraph.',
          1: 'Work paragraph.',
        };
        for (var i = 0; i < 2; i++) {
          final button = buttons.at(i);
          await tester.ensureVisible(button);
          await tester.pumpAndSettle();
          final rect = tester.getRect(button);
          final text = tester.getRect(
            find.byWidgetPredicate(
              (w) => w is RichText && w.text.toPlainText() == paragraphs[i],
            ),
          );
          expect(
            text.left - rect.left,
            closeTo(14, 0.5),
            reason: 'the button overhangs the text by 14 px (${paragraphs[i]})',
          );
          for (final (who, clip) in _clips(tester.renderObject(button))) {
            expect(
              clip.left <= rect.left + 0.01 &&
                  clip.right >= rect.right - 0.01 &&
                  clip.top <= rect.top + 0.01 &&
                  clip.bottom >= rect.bottom - 0.01,
              isTrue,
              reason: 'Why? #$i button $rect is clipped by $who, which keeps '
                  'only $clip',
            );
          }
        }
      });
    }
  }
}
