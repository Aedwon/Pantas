import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/settings/presentation/pages/appearance_page.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';

/// Text Size preview, board TS_A: the sample sits under the slider in the
/// same card, set at the lesson text scale, live.
const _sentence =
    'A synonym is a word that means nearly the same as another word.';
const _stem = 'Which word means the same as "rapid"?';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required double width,
  bool dark = false,
  double systemScale = 1,
  double lessonScale = 1,
}) async {
  final wide = width >= 1024;
  tester.view
    ..physicalSize = Size(width, 1000)
    ..devicePixelRatio = 1;
  debugWebPlatformOverride = wide;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
    debugWebPlatformOverride = null;
  });
  final db = inMemoryDatabase();
  addTearDown(db.close);
  await AppPreferencesRepository(db)
      .setDeviceValue('lesson_text_scale', lessonScale.toString());
  final container =
      ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 1000),
          textScaler: TextScaler.linear(systemScale),
        ),
        child: MaterialApp(
          theme: dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
          home: const AppearancePage(),
        ),
      ),
    ),
  );
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
  return container;
}

double _scaled(WidgetTester tester, String text, double size) => tester
    .renderObject<RenderParagraph>(find.text(text))
    .textScaler
    .scale(size);

void main() {
  setUpAll(loadDsFonts);

  for (final width in [390.0, 1440.0]) {
    final wide = width >= 1024;
    testWidgets('the sample sits under the slider in the same card at $width',
        (tester) async {
      await _pump(tester, width: width);
      expect(find.text('LESSON TEXT SIZE'), findsOneWidget);
      final sample = find.byKey(const ValueKey('text-size-sample'));
      final slider = find.byType(Slider);
      expect(sample, findsOneWidget);
      expect(
        tester.getTopLeft(sample).dy,
        greaterThan(tester.getBottomLeft(slider).dy),
      );
      final card = wide
          ? find.byType(WebCard)
          : find.byKey(const ValueKey('grouped-section-surface'));
      Finder cardOf(Finder f) => find.ancestor(of: f, matching: card).first;
      expect(
        tester.element(cardOf(sample)).widget,
        same(tester.element(cardOf(slider)).widget),
      );
      // The band is the system inset surface.
      expect(find.byKey(const ValueKey('text-size-band')), findsOneWidget);
    });

    testWidgets('the sample follows the slider live at $width', (tester) async {
      await _pump(tester, width: width);
      final sentence = wide ? 18.0 : 17.0;
      final stem = wide ? 27.0 : 21.0;
      for (final value in [1.0, 1.5, 2.0]) {
        tester.widget<Slider>(find.byType(Slider)).onChanged!(value);
        await tester.pumpAndSettle();
        expect(
          _scaled(tester, _sentence, sentence),
          closeTo(sentence * value, .01),
        );
        expect(_scaled(tester, _stem, stem), closeTo(stem * value, .01));
      }
    });

    testWidgets('the sample is hidden from screen readers at $width',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, width: width);
      expect(find.bySemanticsLabel(RegExp('synonym')), findsNothing);
      expect(find.bySemanticsLabel(RegExp('rapid')), findsNothing);
      expect(find.bySemanticsLabel(RegExp('Fast')), findsNothing);
      handle.dispose();
    });
  }

  for (final width in [390.0, 320.0, 1440.0]) {
    for (final dark in [false, true]) {
      for (final lesson in [1.0, 2.0]) {
        for (final system in [1.0, 2.0]) {
          testWidgets(
              'no overflow at $width dark=$dark lesson=$lesson system=$system',
              (tester) async {
            await _pump(
              tester,
              width: width,
              dark: dark,
              lessonScale: lesson,
              systemScale: system,
            );
            expect(tester.takeException(), isNull);
            expect(
              find.byKey(const ValueKey('text-size-sample')),
              findsOneWidget,
            );
          });
        }
      }
    }
  }
}
