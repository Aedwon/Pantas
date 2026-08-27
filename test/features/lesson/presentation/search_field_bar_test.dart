import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/ink_magnifier.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_field_bar.dart';

import '../../../helpers/pump_app.dart';

const _testMap = StudyMap(
  examShortName: 'CSE Pro',
  subjects: [
    StudySubject(
      id: 's1',
      name: 'Verbal',
      topics: [
        StudyTopic(
          id: 't1',
          name: 'Vocabulary',
          lessons: [
            StudyLesson(
              id: 'l1',
              title: 'Basics',
              estimatedMinutes: 5,
              isRead: false,
              isBookmarked: false,
            ),
          ],
          readCount: 0,
          hasBookmark: false,
        ),
      ],
    ),
  ],
  readCount: 0,
  totalCount: 1,
  minutesLeftToRead: 5,
);

void main() {
  testWidgets('the placeholder counts the corpus', (tester) async {
    await tester.pumpAppWithProviders(
      SearchFieldBar(onCancel: () {}),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Search 141 lessons'), findsOneWidget);
  });

  testWidgets('typing writes the query', (tester) async {
    late ProviderContainer container;

    await tester.pumpAppWithProviders(
      Consumer(
        builder: (context, ref, child) {
          container = ProviderScope.containerOf(context);
          return SearchFieldBar(onCancel: () {});
        },
      ),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'venn');
    expect(container.read(searchQueryProvider), 'venn');
  });

  testWidgets('cancel calls back and clears the query', (tester) async {
    var cancelled = false;
    late ProviderContainer container;

    await tester.pumpAppWithProviders(
      Consumer(
        builder: (context, ref, child) {
          container = ProviderScope.containerOf(context);
          return SearchFieldBar(
            onCancel: () {
              cancelled = true;
            },
          );
        },
      ),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'venn');
    expect(container.read(searchQueryProvider), 'venn');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(cancelled, isTrue);
    expect(container.read(searchQueryProvider), '');
  });

  testWidgets('cancel is labeled and at least 48dp', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpAppWithProviders(
      SearchFieldBar(onCancel: () {}),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    final action = find.semantics.byLabel('Cancel search');
    expect(action, findsOne);
    expect(action.evaluate().single.rect.size.width, greaterThanOrEqualTo(48));
    expect(action.evaluate().single.rect.size.height, greaterThanOrEqualTo(48));

    semantics.dispose();
  });

  testWidgets('the map bar shows one trailing element', (tester) async {
    await tester.pumpAppWithProviders(
      const StudyTabHome(),
      overrides: [
        studyMapProvider.overrideWith((ref) async => _testMap),
        lastOpenedLessonProvider.overrideWith((ref) async => null),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(InkMagnifier), findsOneWidget);
  });

  testWidgets('the map search action is labeled and at least 48dp',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpAppWithProviders(
      const StudyTabHome(),
      overrides: [
        studyMapProvider.overrideWith((ref) async => _testMap),
        lastOpenedLessonProvider.overrideWith((ref) async => null),
      ],
    );
    await tester.pumpAndSettle();

    final action = find.semantics.byLabel('Search lessons');
    expect(action, findsOne);
    expect(action.evaluate().single.rect.size.width, greaterThanOrEqualTo(48));
    expect(action.evaluate().single.rect.size.height, greaterThanOrEqualTo(48));

    semantics.dispose();
  });

  testWidgets('search and cancel fit at 360dp and 200% text', (tester) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpAppWithProviders(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: SearchFieldBar(onCancel: () {}),
      ),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
