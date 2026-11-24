// T5 (borderless buttons): renders every changed sheet, dialog and the Pro page
// to PNG under build/render/t5/<phase>/ (not committed), at 390 and 1440, light
// and dark. T5_PHASE=before draws the sheets with the Close and Cancel buttons
// the old code gave them; the default phase is "after".
//
//   T5_PHASE=before flutter test --tags golden --run-skipped \
//     test/renders/t5_buttons_render_test.dart
//   flutter test --tags golden --run-skipped \
//     test/renders/t5_buttons_render_test.dart
@Tags(['golden'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_date_sheet.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../features/settings/presentation/pro_page_payments_test.dart'
    show SettingsGateway;
import '../goldens/golden_harness.dart';

final _phase = Platform.environment['T5_PHASE'] ?? 'after';
final _before = _phase == 'before';
final _out = 'build/render/t5/$_phase';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await loadGoldenFonts();
    // Without the font a Material icon draws as a hollow square.
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  tearDown(() => debugWebPlatformOverride = null);

  final boundary = GlobalKey();

  Future<void> shoot(
    WidgetTester tester,
    String name, {
    required double width,
    required bool dark,
    required Widget Function(BuildContext) home,
    double height = 844,
    List<Override> overrides = const [],
    Future<void> Function(WidgetTester)? drive,
  }) async {
    final web = width >= 1024;
    debugWebPlatformOverride = web;
    final size = Size(width, web ? 900 : height);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: overrides,
        child: MediaQuery(
          data: MediaQueryData(size: size, disableAnimations: true),
          child: RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme:
                  dark ? buildDarkTheme(web: web) : buildLightTheme(web: web),
              home: Builder(builder: home),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (drive != null) await drive(tester);
    final object =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(boundary));
    final image = (await tester.runAsync(object.toImage))!;
    final bytes = (await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.png),
    ))!;
    await tester.runAsync(() async {
      final file = File('$_out/$name-${width.toInt()}-'
          '${dark ? 'dark' : 'light'}.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes.buffer.asUint8List());
    });
  }

  // The old code gave each of these sheets a Close or Cancel button.
  String? close(String label) => _before ? label : null;

  Widget phoneSheet({
    required String label,
    required Widget child,
    String? closeLabel,
    bool readerContents = true,
  }) =>
      Scaffold(
        body: PantasSheet(
          page: const ColoredBox(color: Color(0xFFF5F5F7)),
          label: label,
          open: true,
          onDismiss: () {},
          closeLabel: closeLabel,
          readerContents: readerContents,
          child: child,
        ),
      );

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('home sheets $mode', (tester) async {
      Widget row(String title, int done, int total) => TodayQuestionRow(
            title: title,
            subtitle: 'Mathematics',
            done: done,
            total: total,
            onTap: () {},
            fillDelay: Duration.zero,
          );
      await shoot(
        tester,
        'home-new-questions',
        width: 390,
        dark: dark,
        home: (_) => phoneSheet(
          label: 'New questions',
          closeLabel: close('Close'),
          child: TodayQuestionsSheet(
            title: 'New questions',
            done: 3,
            total: 10,
            rows: [
              row('Fractions', 3, 5),
              row('Ratios', 0, 5),
              row('Percent', 0, 5),
            ],
            startLabel: 'Start New Questions',
            onStart: () {},
          ),
        ),
      );
      await shoot(
        tester,
        'home-exam-date',
        width: 390,
        dark: dark,
        home: (_) => phoneSheet(
          label: 'Exam date',
          closeLabel: close('Cancel'),
          readerContents: false,
          child: HomeExamDateSheet(
            today: DateTime(2026, 11, 24),
            examName: 'UPCAT',
            web: false,
            onSave: (ExamDate _) {},
          ),
        ),
      );
    });

    testWidgets('quiz sheets $mode', (tester) async {
      await shoot(
        tester,
        'quiz-passage',
        width: 390,
        dark: dark,
        home: (_) => phoneSheet(
          label: 'Passage',
          closeLabel: close('Close'),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              _before ? 16 : 34,
            ),
            child: const PassageCard(
              title: 'The Water Cycle',
              text: 'Water moves between the sea, the air and the land. '
                  'Heat from the sun lifts it as vapor.\n\n'
                  'The vapor cools, forms clouds and falls again as rain.',
            ),
          ),
        ),
      );
      await shoot(
        tester,
        'quiz-grid',
        width: 390,
        dark: dark,
        home: (_) => Scaffold(
          body: QuestionGridSheet(
            page: const ColoredBox(color: Color(0xFFF5F5F7)),
            open: true,
            onDismiss: () {},
            onSelected: (_) {},
            summary: '4 of 10 answered',
            parts: [
              QuestionGridPart(
                title: '',
                questions: [
                  for (var n = 1; n <= 10; n++)
                    GridQuestion(
                      number: n,
                      state: n <= 4
                          ? GridQuestionState.answered
                          : GridQuestionState.unreached,
                      current: n == 5,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });

    testWidgets('dialogs $mode', (tester) async {
      await shoot(
        tester,
        'dialog-wide',
        width: 1440,
        dark: dark,
        home: (_) => Scaffold(
          body: Center(
            child: CenteredDialog(
              title: 'Sign out?',
              message: 'Your progress stays on this device.',
              primaryLabel: 'Sign Out',
              secondaryLabel: 'Cancel',
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );
      await shoot(
        tester,
        'dialog-phone',
        width: 390,
        dark: dark,
        home: (_) => Scaffold(
          body: Center(
            child: CenteredDialog(
              title: 'Sign out?',
              message: 'Your progress stays on this device.',
              primaryLabel: 'Sign Out',
              secondaryLabel: 'Cancel',
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );
    });

    for (final (name, entitlement) in [
      ('free', const Entitlement.free()),
      (
        'pro',
        const Entitlement(
          plan: EntitlementPlan.monthly,
          productId: 'pantas_pro_monthly',
        ),
      ),
    ]) {
      for (final width in [390.0, 1440.0]) {
        testWidgets('pro $name ${width.toInt()} $mode', (tester) async {
          final gateway = SettingsGateway(initial: entitlement);
          await shoot(
            tester,
            'pro-$name',
            width: width,
            dark: dark,
            height: 1000,
            overrides: [revenueCatGatewayProvider.overrideWithValue(gateway)],
            home: (_) => const ProPage(),
          );
        });
      }
    }
  }
}
