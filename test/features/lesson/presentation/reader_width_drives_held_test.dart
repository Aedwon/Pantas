// Aedwon, Nov 28: "the reason we added the 2 column layout was to make the
// toggle more useful". The full-width toggle shows on every lesson and turns
// the two-column (held) layout on. Default on. See docs/design/DECISIONS.md,
// "Full-width toggle drives the two-column reader (Nov 28)".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/held_reader.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/held_picture_fixtures.dart';
import '../../../helpers/in_memory_database.dart';

const _plate = ValueKey('reader-figure-plate');
const _column = ValueKey('web-reader-column');
const _control = ValueKey('web-reader-width-control');

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late AppDatabase db;
  late AppPreferencesRepository prefs;

  setUp(() {
    db = inMemoryDatabase();
    prefs = AppPreferencesRepository(db);
    addTearDown(db.close);
  });

  Future<void> pump(
    WidgetTester tester,
    double width,
    List<Map<String, Object?>> body, {
    String? saved,
  }) async {
    if (saved != null) await prefs.setDeviceValue('reader_full_width', saved);
    tester.view
      ..physicalSize = Size(width, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final scroll = ScrollController();
    final offset = ValueNotifier<double>(0);
    final progress = ValueNotifier<double>(0);
    addTearDown(scroll.dispose);
    addTearDown(offset.dispose);
    addTearDown(progress.dispose);
    scroll.addListener(() => offset.value = scroll.offset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          appPreferencesRepositoryProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: WebReaderLayout(
              reader: readerFor('w-$width', body),
              controller: scroll,
              scrollOffset: offset,
              progress: progress,
              onBack: () {},
              onBookmark: () {},
              onLesson: (_) {},
              footer: const SizedBox(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<Map<String, Object?>> withPicture() => [
        paragraph('Anna is twice as old as Ben.'),
        pictureBlock(pictureUri(360, 208)),
        paragraph('Their ages add up to 36 years.'),
      ];
  List<Map<String, Object?>> plain() => [paragraph('Earth has layers.')];

  final control = find.byKey(_control);
  final column = find.byKey(_column);
  final plate = find.byKey(_plate);

  for (final width in [1440.0, 1100.0]) {
    testWidgets('$width: the toggle shows on a lesson with figures', (
      tester,
    ) async {
      await pump(tester, width, withPicture());
      expect(control, findsOneWidget);
      expect(find.byTooltip('Standard width'), findsOneWidget);
    });
  }

  testWidgets('on with figures: the two-column layout, plate in the column', (
    tester,
  ) async {
    await pump(tester, 1440, withPicture(), saved: '1');
    expect(find.byType(HeldReader), findsOneWidget);
    expect(plate, findsOneWidget);
    expect(find.byKey(const ValueKey('web-reader-outline')), findsNothing);
  });

  testWidgets('off with figures: the 680 column, picture inline, no plate', (
    tester,
  ) async {
    await pump(tester, 1440, withPicture(), saved: '0');
    expect(find.byType(HeldReader), findsNothing);
    expect(plate, findsNothing);
    expect(tester.getSize(column).width, 680);
    expect(
      find.descendant(of: column, matching: find.byType(SvgPicture)),
      findsOneWidget,
    );
    expect(find.byTooltip('Full width'), findsOneWidget);
  });

  testWidgets('on with no figures: the 800 column', (tester) async {
    await pump(tester, 1440, plain(), saved: '1');
    expect(find.byType(HeldReader), findsNothing);
    expect(tester.getSize(column).width, 800);
    expect(find.byKey(const ValueKey('web-reader-outline')), findsNothing);
  });

  testWidgets('off with no figures: the 680 column', (tester) async {
    await pump(tester, 1440, plain(), saved: '0');
    expect(tester.getSize(column).width, 680);
  });

  testWidgets('with no saved choice the toggle starts on', (tester) async {
    await pump(tester, 1440, withPicture());
    expect(find.byType(HeldReader), findsOneWidget);
    expect(find.byTooltip('Standard width'), findsOneWidget);
  });

  testWidgets('a saved 0 stays off', (tester) async {
    await pump(tester, 1440, withPicture(), saved: '0');
    expect(find.byTooltip('Full width'), findsOneWidget);
    expect(find.byType(HeldReader), findsNothing);
  });

  testWidgets('toggling switches the layout and is saved', (tester) async {
    await pump(tester, 1440, withPicture());
    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(find.byType(HeldReader), findsNothing);
    expect(tester.getSize(column).width, 680);
    expect(await prefs.deviceValue('reader_full_width'), '0');
    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(find.byType(HeldReader), findsOneWidget);
    expect(await prefs.deviceValue('reader_full_width'), '1');
  });

  testWidgets('switching keeps the section being read in view', (
    tester,
  ) async {
    final body = [
      heading('First', 'h2'),
      for (var i = 0; i < 12; i++) paragraph('Filler paragraph $i. ' * 12),
      heading('Second', 'h2'),
      pictureBlock(pictureUri(360, 208)),
      for (var i = 0; i < 12; i++) paragraph('More paragraph $i. ' * 12),
    ];
    await pump(tester, 1440, body);
    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const ValueKey('web-reader-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    scrollable.position.jumpTo(
      scrollable.position.pixels + tester.getTopLeft(find.text('Second')).dy,
    );
    await tester.pumpAndSettle();
    await tester.tap(control);
    await tester.pumpAndSettle();
    final top = tester.getTopLeft(find.text('Second')).dy;
    expect(top, inInclusiveRange(0, 900));
  });

  testWidgets('at 1024, the narrowest width, held runs with the toggle', (
    tester,
  ) async {
    // Under 1024 the phone reader is used, not this layout, so it is
    // unchanged by this decision.
    await pump(tester, 1024, withPicture());
    expect(control, findsOneWidget);
    expect(find.byType(HeldReader), findsOneWidget);
  });
}
