import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/data_row_tile.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:cse_cet_reviewer/features/progress/application/performance_provider.dart';
import 'package:cse_cet_reviewer/features/progress/application/table_order_prefs.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/performance_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/in_memory_database.dart';

final mixedRows = [
  const PerformanceRow(
    id: 'chem',
    title: 'Chemistry',
    subtext: 'Science',
    correct: 3,
    answered: 10,
    secondsPerQuestion: 40,
  ),
  const PerformanceRow(
    id: 'alg',
    title: 'Algebra',
    subtext: 'Mathematics',
    correct: 8,
    answered: 10,
    secondsPerQuestion: 25,
  ),
  const PerformanceRow(
    id: 'phys',
    title: 'Physics',
    subtext: 'Science',
    correct: 6,
    answered: 10,
    secondsPerQuestion: 60,
  ),
];

final rowsWithNullSubtext = [
  const PerformanceRow(
    id: 'sci',
    title: 'Science',
    subtext: null,
    correct: 3,
    answered: 10,
    secondsPerQuestion: null,
  ),
  const PerformanceRow(
    id: 'math',
    title: 'Mathematics',
    subtext: null,
    correct: 8,
    answered: 10,
    secondsPerQuestion: null,
  ),
];

final lessonRows = [
  const PerformanceRow(
    id: 'chem-04',
    title: 'Balancing equations',
    subtext: 'Chemistry',
    correct: 2,
    answered: 10,
    secondsPerQuestion: null,
  ),
];

/// The level the section opens on, so a test can pick one without going
/// through the stored preference.
final testInitialOrderProvider = Provider<TableOrder>(
  (ref) => TableOrder.defaults,
);

void main() {
  late AppDatabase db;
  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  String firstRowTitle(WidgetTester tester) =>
      tester.widgetList<DataRowTile>(find.byType(DataRowTile)).first.title;

  Color? colourOfRow(WidgetTester tester, String title) => tester
      .widgetList<DataRowTile>(find.byType(DataRowTile))
      .firstWhere((t) => t.title == title)
      .primaryColor;

  Widget harness({
    List<PerformanceRow>? rows,
    bool timeMeasurable = true,
    bool isPro = true,
    TableLevel level = TableLevel.topic,
    List<({String id, String name, int rowCount})> subjects = const [
      (id: 'sci', name: 'Science', rowCount: 2),
      (id: 'math', name: 'Mathematics', rowCount: 1),
    ],
  }) {
    final table = PerformanceTable(
      rows: rows ?? mixedRows,
      timeIsMeasurable: timeMeasurable,
      lessonLevelAvailable: true,
      subjects: subjects,
    );

    final router = GoRouter(
      initialLocation: '/progress',
      routes: [
        GoRoute(
          path: '/progress',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(child: PerformanceSection()),
          ),
        ),
        GoRoute(
          path: '/lesson/:id',
          builder: (_, __) => const Scaffold(body: Text('reader')),
        ),
        GoRoute(
          path: '/paywall',
          builder: (_, __) => const Scaffold(body: Text('paywall')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        entitlementProvider.overrideWith(
          (ref) => Stream.value(
            isPro
                ? Entitlement(
                    plan: EntitlementPlan.monthly,
                    expiresAt: DateTime.now().add(const Duration(days: 30)),
                  )
                : const Entitlement.free(),
          ),
        ),
        testInitialOrderProvider.overrideWithValue(
          TableOrder.defaults.copyWith(level: level),
        ),
        tableOrderProvider.overrideWith(_FixedOrder.new),
        performanceProvider.overrideWith((ref, query) async => table),
      ],
      child: MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
      ),
    );
  }

  testWidgets('opens on Score ascending, weakest first', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(firstRowTitle(tester), 'Chemistry');
  });

  testWidgets('no rule between the header and the table head', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('section-header-rule')), findsNothing);
  });

  testWidgets('re-sorting never changes a row colour', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    final before = colourOfRow(tester, 'Chemistry');

    await tester.tap(find.text('SCORE'));
    await tester.pumpAndSettle();

    expect(colourOfRow(tester, 'Chemistry'), before);
    expect(firstRowTitle(tester), 'Algebra');
  });

  testWidgets('with no mock, the column is absent and the line explains it',
      (tester) async {
    await tester.pumpWidget(harness(timeMeasurable: false));
    await tester.pumpAndSettle();

    expect(find.text('TIME'), findsNothing);
    expect(
      find.textContaining('after your first full length mock'),
      findsOneWidget,
    );
  });

  testWidgets('with no blueprint the size clause drops and the table renders',
      (tester) async {
    await tester.pumpWidget(harness(rows: rowsWithNullSubtext));
    await tester.pumpAndSettle();

    expect(find.textContaining('of 180 questions'), findsNothing);
    expect(
      find.byType(DataRowTile),
      findsNWidgets(rowsWithNullSubtext.length),
    );
  });

  testWidgets('a lesson row opens the reader', (tester) async {
    await tester.pumpWidget(
      harness(rows: lessonRows, level: TableLevel.lesson),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Balancing equations'));
    await tester.pumpAndSettle();

    expect(find.text('reader'), findsOneWidget);
  });

  testWidgets('a topic row is not a launcher', (tester) async {
    // The table is a reading surface and Home owns starting a session.
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chemistry'));
    await tester.pumpAndSettle();

    expect(find.text('reader'), findsNothing);
    expect(find.byType(DataRowTile), findsNWidgets(mixedRows.length));
  });

  testWidgets('no board green anywhere in the table', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    for (final t in tester.widgetList<Text>(
      find.descendant(
        of: find.byType(PerformanceSection),
        matching: find.byType(Text),
      ),
    )) {
      expect(t.style?.color, isNot(AppColors.light.board));
    }
  });

  testWidgets('no ordering explanation is printed', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.textContaining('sorted by'), findsNothing);
    expect(find.textContaining('Showing'), findsNothing);
  });

  testWidgets('Free reads the table at subject level', (tester) async {
    await tester.pumpWidget(harness(isPro: false, level: TableLevel.lesson));
    await tester.pumpAndSettle();

    expect(find.text('SUBJECT'), findsOneWidget);
  });

  testWidgets('a dimmed level label opens the paywall', (tester) async {
    await tester.pumpWidget(harness(isPro: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Topic'));
    await tester.pumpAndSettle();

    expect(find.text('paywall'), findsOneWidget);
  });
}

/// The order notifier with its storage taken out: these tests are about
/// the section, and the round trip is covered where it lives.
class _FixedOrder extends TableOrderNotifier {
  @override
  Future<TableOrder> build() async => ref.read(testInitialOrderProvider);

  @override
  Future<void> setSortKey(TableSortKey key) async {
    state = AsyncData(
      (state.value ?? TableOrder.defaults).copyWith(
        sortKey: key,
      ),
    );
  }

  @override
  Future<void> setDirection(TableSortDirection direction) async {
    state = AsyncData(
      (state.value ?? TableOrder.defaults).copyWith(
        direction: direction,
      ),
    );
  }

  @override
  Future<void> setLevel(TableLevel level) async {
    state = AsyncData(
      (state.value ?? TableOrder.defaults).copyWith(
        level: level,
      ),
    );
  }

  @override
  Future<void> setSubjectId(String? subjectId) async {
    state = AsyncData(
      subjectId == null
          ? (state.value ?? TableOrder.defaults).copyWith(clearSubject: true)
          : (state.value ?? TableOrder.defaults).copyWith(
              subjectId: subjectId,
            ),
    );
  }
}
