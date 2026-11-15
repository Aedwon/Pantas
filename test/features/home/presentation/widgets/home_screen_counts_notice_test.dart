import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/screen_counts_providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/screen_counts_notice.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/presentation/widgets/home_notice_strip.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import '../../../../helpers/ds_matrix.dart';
import '../../../../helpers/in_memory_database.dart';

const _notice = HomeNotice(
  kind: HomeNoticeKind.screenCounts,
  title: screenCountsNoticeTitle,
  detail: screenCountsNoticeText,
  dismissalToken: 'learner-a',
  primaryLabel: 'Got It',
  secondaryLabel: 'Learn More',
  route: '/legal/privacy',
);

void main() {
  late AppDatabase db;
  late AppPreferencesRepository prefs;
  late ScreenCountsNoticeStore store;
  final routes = <String>[];

  setUp(() {
    db = inMemoryDatabase();
    prefs = AppPreferencesRepository(db);
    store = ScreenCountsNoticeStore(prefs);
    routes.clear();
  });
  tearDown(() => db.close());

  Widget strip() => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          nowProvider.overrideWithValue(() => DateTime(2026, 11, 15)),
          appPreferencesRepositoryProvider.overrideWithValue(prefs),
          screenCountsNoticeStoreProvider.overrideWithValue(store),
          homeNoticeProvider.overrideWith(
            (ref) async => await ref
                    .read(screenCountsNoticeStoreProvider)
                    .isDismissed('learner-a')
                ? null
                : _notice,
          ),
        ],
        child: HomeNoticeStrip(onDate: (_) {}, onRoute: routes.add),
      );

  Future<void> show(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(body: strip()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens with its text and both buttons showing', (tester) async {
    await show(tester);
    expect(find.text(screenCountsNoticeTitle), findsOneWidget);
    expect(find.text(screenCountsNoticeText), findsOneWidget);
    expect(find.text('Learn More'), findsOneWidget);
    expect(find.text('Got It'), findsOneWidget);
    expect(
      tester.widget<NoticeStrip>(find.byType(NoticeStrip)).icon,
      PantasIcons.info,
    );
  });

  testWidgets('Learn More is secondary on the left, Got It main on the right',
      (tester) async {
    await show(tester);
    final learn = tester.widget<PantasButton>(
      find.widgetWithText(PantasButton, 'Learn More'),
    );
    final got = tester.widget<PantasButton>(
      find.widgetWithText(PantasButton, 'Got It'),
    );
    expect(learn.variant, PantasButtonVariant.secondary);
    expect(got.variant, PantasButtonVariant.primary);
    expect(
      tester.getTopLeft(find.text('Learn More')).dx,
      lessThan(tester.getTopLeft(find.text('Got It')).dx),
    );
  });

  testWidgets('wide: the same roles and order', (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(body: strip()),
      ),
    );
    await tester.pumpAndSettle();
    final learn = tester.widget<WebButton>(
      find.widgetWithText(WebButton, 'Learn More'),
    );
    final got = tester.widget<WebButton>(
      find.widgetWithText(WebButton, 'Got It'),
    );
    expect(learn.variant, WebButtonVariant.secondary);
    expect(got.variant, WebButtonVariant.primary);
    expect(
      tester.getTopLeft(find.text('Learn More')).dx,
      lessThan(tester.getTopLeft(find.text('Got It')).dx),
    );
    await tester.tap(find.text('Learn More'));
    await tester.pumpAndSettle();
    expect(routes, ['/legal/privacy']);
  });

  testWidgets('showing it records it for this learner, same visit not counted',
      (tester) async {
    await show(tester);
    expect(
      await prefs.deviceValue(ScreenCountsNoticeStore.keyFor('learner-a')),
      isNotNull,
    );
    expect(await store.countingAllowed('learner-a'), isFalse);
    expect(
      await ScreenCountsNoticeStore(prefs).countingAllowed('learner-a'),
      isTrue,
    );
  });

  testWidgets('Learn More opens the page and keeps the notice', (tester) async {
    await show(tester);
    await tester.tap(find.text('Learn More'));
    await tester.pumpAndSettle();
    expect(routes, ['/legal/privacy']);
    expect(find.byType(NoticeStrip), findsOneWidget);
    expect(await store.isDismissed('learner-a'), isFalse);
  });

  testWidgets('Got It closes it for this learner only', (tester) async {
    await show(tester);
    await tester.tap(find.text('Got It'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeStrip), findsNothing);
    expect(await store.isDismissed('learner-a'), isTrue);
    expect(await store.isDismissed('learner-b'), isFalse);
    expect(
      await prefs.deviceValue('home_notice_dismissed_screenCounts'),
      isNull,
    );
  });

  testWidgets('the close button does the same', (tester) async {
    await show(tester);
    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeStrip), findsNothing);
    expect(await store.isDismissed('learner-a'), isTrue);
  });

  final cells = <DsCell>[
    ...dsCells,
    const DsCell(320, 1, dark: false),
    const DsCell(320, 2, dark: false),
    const DsCell(320, 2, dark: true),
  ];

  dsMatrix(
    'screen counts notice fits',
    (_) => strip(),
    cells: cells,
    check: (tester, cell) async {
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Learn More'), findsOneWidget);
      expect(find.text('Got It'), findsOneWidget);
    },
  );
}
