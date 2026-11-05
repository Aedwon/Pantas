import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_layout_theme.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';

/// 2G-12 and 2G-16: a long name wraps or gives way, and is never cut off in
/// the middle of a word or pushed past the screen edge.
void main() {
  const subject = PerformanceRow(
    id: 'lang',
    title: 'Language Proficiency (English & Filipino)',
    subtext: null,
    correct: 6,
    answered: 10,
    secondsPerQuestion: null,
  );
  const topic = PerformanceRow(
    id: 'ops',
    title: 'Order of Operations (PEMDAS) and Signed Number Arithmetic',
    subtext: 'Language Proficiency (English & Filipino)',
    correct: 2,
    answered: 5,
    secondsPerQuestion: null,
  );
  const data = PerformanceViewData(
    subjects: [subject],
    topics: [topic],
    lessons: [topic],
    subjectCounts: {'lang': 1},
    lessonLevelAvailable: true,
    parentSubjectIds: {'ops': 'lang'},
  );
  Widget page({required bool web}) => MaterialApp(
        theme: buildLightTheme(web: web),
        home: WebLayoutTheme(
          web: web,
          child: PerformancePage(
            data: data,
            pro: true,
            paused: false,
            onTopic: (_) {},
            onPro: () {},
            onBack: () {},
          ),
        ),
      );

  testWidgets('wide Lessons view wraps a long title and its subject line',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(page(web: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lessons'));
    await tester.pumpAndSettle();
    for (final line in [topic.title, topic.subtext!]) {
      final text = tester.widget<Text>(find.text(line));
      expect(text.overflow, isNot(TextOverflow.ellipsis), reason: line);
      expect(text.maxLines, isNull, reason: line);
    }
    expect(
      tester.getSize(find.text(topic.title)).height,
      greaterThan(24),
      reason: 'the title wrapped onto a second line',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone Topics header keeps the order label on screen',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(page(web: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Language Proficiency (English & Filipino)'));
    await tester.pumpAndSettle();
    final subjectLabel = find.text('LANGUAGE PROFICIENCY (ENGLISH & FILIPINO)');
    expect(subjectLabel, findsOneWidget);
    expect(find.text('WEAKEST FIRST'), findsOneWidget);
    expect(tester.getRect(find.text('WEAKEST FIRST')).right, lessThan(390));
    expect(
      tester.getRect(subjectLabel).right,
      lessThanOrEqualTo(tester.getRect(find.text('WEAKEST FIRST')).left),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a topic row stays tinted while its panel is open (2G-11)',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final panel = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebLayoutTheme(
          web: true,
          child: PerformancePage(
            data: data,
            pro: true,
            paused: false,
            initialLevel: 1,
            onTopic: (_) => panel.future,
            onPro: () {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    bool tinted() => tester
        .widget<WebRow>(
          find.ancestor(
            of: find.text(topic.title),
            matching: find.byType(WebRow),
          ),
        )
        .selected;
    expect(tinted(), isFalse);
    await tester.tap(find.text(topic.title));
    await tester.pumpAndSettle();
    expect(tinted(), isTrue);
    panel.complete();
    await tester.pumpAndSettle();
    expect(tinted(), isFalse);
  });
}
