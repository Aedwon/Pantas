import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/icons/own/own_icons.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

void main() {
  final icons = <String, Object>{
    'homeTab': PantasIcons.homeTab,
    'studyTab': PantasIcons.studyTab,
    'quizTab': PantasIcons.quizTab,
    'settingsTab': PantasIcons.settingsTab,
    'back': PantasIcons.back,
    'next': PantasIcons.next,
    'close': PantasIcons.close,
    'counter': PantasIcons.counter,
    'toTop': PantasIcons.toTop,
    'expandFigure': PantasIcons.expandFigure,
    'sort': PantasIcons.sort,
    'contents': PantasIcons.contents,
    'flag': PantasIcons.flag,
    'report': PantasIcons.report,
    'questionsSheet': PantasIcons.questionsSheet,
    'addNote': PantasIcons.addNote,
    'noted': PantasIcons.noted,
    'check': PantasIcons.check,
    'pause': PantasIcons.pause,
    'paused': PantasIcons.paused,
    'timer': PantasIcons.timer,
    'pendingSend': PantasIcons.pendingSend,
    'nextMonth': PantasIcons.nextMonth,
    'streak': PantasIcons.streak,
    'restDay': PantasIcons.restDay,
    'addDate': PantasIcons.addDate,
    'pro': PantasIcons.pro,
    'progressError': PantasIcons.progressError,
    'tendencies': PantasIcons.tendencies,
    'answerStreak': PantasIcons.answerStreak,
    'search': PantasIcons.search,
    'bookmark': PantasIcons.bookmark,
    'reorder': PantasIcons.reorder,
    'imageFailed': PantasIcons.imageFailed,
    'edit': PantasIcons.edit,
    'share': PantasIcons.share,
    'exam': PantasIcons.exam,
    'practice': PantasIcons.practice,
    'reminders': PantasIcons.reminders,
    'appearance': PantasIcons.appearance,
    'backup': PantasIcons.backup,
    'feedback': PantasIcons.feedback,
    'about': PantasIcons.about,
    'proSettings': PantasIcons.proSettings,
    'profile': PantasIcons.profile,
  };
  test('exactly the 45 approved getters resolve without a lock', () {
    final source =
        File('lib/core/ui/icons/pantas_icons.dart').readAsStringSync();
    final names = RegExp(r'static (?:Widget|IconData) get (\w+)')
        .allMatches(source)
        .map((match) => match.group(1));
    expect(icons, hasLength(45));
    expect(names, unorderedEquals(icons.keys));
    expect(names, isNot(contains('locked')));
    expect(names, isNot(contains('lock')));
  });
  testWidgets('questionsSheet light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['questionsSheet']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/questionsSheet_light.png'),
    );
  });
  testWidgets('questionsSheet dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['questionsSheet']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/questionsSheet_dark.png'),
    );
  });
  testWidgets('report light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['report']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/report_light.png'),
    );
  });
  testWidgets('report dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['report']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/report_dark.png'),
    );
  });
  testWidgets('paused light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['paused']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/paused_light.png'),
    );
  });
  testWidgets('paused dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['paused']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/paused_dark.png'),
    );
  });
  testWidgets('streak light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['streak']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/streak_light.png'),
    );
  });
  testWidgets('streak dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['streak']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/streak_dark.png'),
    );
  });
  testWidgets('progressError light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['progressError']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/progressError_light.png'),
    );
  });
  testWidgets('progressError dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['progressError']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/progressError_dark.png'),
    );
  });
  testWidgets('reorder light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['reorder']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/reorder_light.png'),
    );
  });
  testWidgets('reorder dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['reorder']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/reorder_dark.png'),
    );
  });
  testWidgets('appearance light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['appearance']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/appearance_light.png'),
    );
  });
  testWidgets('appearance dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['appearance']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/appearance_dark.png'),
    );
  });
  testWidgets('backup light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['backup']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/backup_light.png'),
    );
  });
  testWidgets('backup dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['backup']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/backup_dark.png'),
    );
  });
  testWidgets('about light preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.light.label,
                    ),
                    child: icons['about']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/about_light.png'),
    );
  });
  testWidgets('about dark preserves the approved 24-point shape',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      size: 24,
                      color: PantasColors.dark.label,
                    ),
                    child: icons['about']! as Widget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final paint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    final painter = paint.painter! as OwnIconPainter;
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
    expect(painter.strokeWidth, 1.5);
    expect(painter.strokeCap, StrokeCap.round);
    expect(painter.strokeJoin, StrokeJoin.round);
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/about_dark.png'),
    );
  });
  test('regular glyphs keep their pinned 2.1.0 codepoints', () {
    const codepoints = <String, int>{
      'homeTab': 0xe2c2,
      'studyTab': 0xe0e6,
      'quizTab': 0xe184,
      'settingsTab': 0xe272,
      'back': 0xe138,
      'next': 0xe13a,
      'close': 0xe4f6,
      'counter': 0xe136,
      'toTop': 0xe08e,
      'expandFigure': 0xe0a6,
      'sort': 0xe140,
      'contents': 0xe2f0,
      'flag': 0xe244,
      'addNote': 0xe34a,
      'noted': 0xe348,
      'check': 0xe182,
      'pause': 0xe39e,
      'timer': 0xe492,
      'pendingSend': 0xe19a,
      'nextMonth': 0xe13a,
      'restDay': 0xe330,
      'addDate': 0xe10a,
      'pro': 0xe6a2,
      'tendencies': 0xe2dc,
      'answerStreak': 0xe2de,
      'search': 0xe30c,
      'bookmark': 0xe0ea,
      'imageFailed': 0xe2ca,
      'edit': 0xe3b4,
      'share': 0xeaf0,
      'exam': 0xe47c,
      'practice': 0xe74e,
      'reminders': 0xe0ce,
      'feedback': 0xe218,
      'proSettings': 0xe6a2,
      'profile': 0xe4c2,
    };
    expect(codepoints, hasLength(36));
    for (final entry in codepoints.entries) {
      final icon = icons[entry.key]! as IconData;
      expect(icon.codePoint, entry.value, reason: entry.key);
      expect(icon.fontFamily, 'Phosphor');
      expect(icon.fontPackage, isNull);
    }
  });
}
