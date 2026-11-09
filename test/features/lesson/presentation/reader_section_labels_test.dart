import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_tap.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

Map<String, Object?> _block(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'text': text},
      ],
    };

final _blocks = [
  _block('Core Concept', style: 'h2'),
  _block('Earth has several layers.'),
  _block('Examples', style: 'h2'),
  _block('Traps to Watch For', style: 'h2'),
];

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pumpAt(
    WidgetTester tester,
    Size size,
    Widget child, {
    List<Override> overrides = const [],
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
  }

  TextStyle styleOf(WidgetTester tester, String text) {
    final rich = tester.widget<RichText>(
      find
          .descendant(
            of: find.byType(ContentRenderer),
            matching: find.byWidgetPredicate(
              (w) => w is RichText && w.text.toPlainText() == text,
            ),
          )
          .first,
    );
    return rich.text.style!;
  }

  testWidgets('wide web draws Core Concept like the other section labels', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(1440, 900),
      SingleChildScrollView(
        child: ContentRenderer(blocks: _blocks, readerFigures: true),
      ),
    );
    expect(find.text('CORE CONCEPT'), findsNothing);
    final core = styleOf(tester, 'Core Concept');
    final examples = styleOf(tester, 'Examples');
    final traps = styleOf(tester, 'Traps to Watch For');
    expect(core.fontSize, 26);
    expect(core.fontWeight, FontWeight.w700);
    expect(core.letterSpacing, PantasType.webH2.letterSpacing);
    expect(core.height, 1.2);
    for (final other in [examples, traps]) {
      expect(core.fontSize, other.fontSize);
      expect(core.fontWeight, other.fontWeight);
      expect(core.letterSpacing, other.letterSpacing);
      expect(core.height, other.height);
      expect(core.color, other.color);
    }
  });

  testWidgets('phone draws its section headings 26 px', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(390, 844),
      SingleChildScrollView(
        child: ContentRenderer(blocks: _blocks, readerFigures: true),
      ),
    );
    expect(find.text('CORE CONCEPT'), findsNothing);
    for (final label in ['Core Concept', 'Examples', 'Traps to Watch For']) {
      final style = styleOf(tester, label);
      expect(style.fontSize, 26, reason: label);
      expect(style.height, 1.2, reason: label);
      expect(
        style.letterSpacing,
        PantasType.webH2.letterSpacing,
        reason: label,
      );
    }
  });

  testWidgets('the margin outline still lists and scrolls to Core Concept', (
    tester,
  ) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final scroll = ScrollController();
    final offset = ValueNotifier<double>(0);
    final progress = ValueNotifier<double>(0);
    addTearDown(scroll.dispose);
    addTearDown(offset.dispose);
    addTearDown(progress.dispose);
    final reader = ReaderContext(
      lesson: Lesson(
        id: 'l1',
        topicId: 't1',
        title: 'Layers',
        summary: '',
        estimatedMinutes: 11,
        bodyJson: [
          for (var i = 0; i < 3; i++) ...[
            _block(
              ['Core Concept', 'Examples', 'Traps to Watch For'][i],
              style: 'h2',
            ),
            for (var j = 0; j < 14; j++)
              _block('Paragraph $i.$j of the lesson text.'),
          ],
        ],
      ),
      topicId: 't1',
      topicName: 'Earth Science',
      next: null,
      positionInTopic: 1,
      lessonsInTopic: 1,
      topicLessons: const [],
      isRead: false,
      isBookmarked: false,
      examId: 'e',
    );
    await pumpAt(
      tester,
      const Size(1440, 900),
      WebReaderLayout(
        reader: reader,
        controller: scroll,
        scrollOffset: offset,
        progress: progress,
        onBack: () {},
        onBookmark: () {},
        onLesson: (_) {},
        footer: const SizedBox(),
      ),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();
    expect(find.text('IN THIS LESSON'), findsOneWidget);
    // One label in the outline, one heading in the lesson.
    expect(find.text('Core Concept'), findsNWidgets(2));
    expect(find.text('Traps to Watch For'), findsWidgets);
    // Sections are told apart by space alone: 104 px above a later heading.
    Finder rich(String text) => find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == text,
        );
    final last = tester.getBottomLeft(
      rich('Paragraph 0.13 of the lesson text.').last,
    );
    expect(tester.getTopLeft(rich('Examples').last).dy - last.dy, 40);
    final outlineEntry = find
        .ancestor(
          of: find.text('Traps to Watch For').first,
          matching: find.byType(ReaderTap),
        )
        .first;
    await tester.tap(outlineEntry);
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(100));
  });
}
