import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/home/presentation/performance_screen.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

PerformanceRow row(String id, int right, int total) => PerformanceRow(
      id: id,
      title: id,
      subtext: 'Mathematics',
      correct: right,
      answered: total,
      secondsPerQuestion: null,
    );

final view = PerformanceViewData(
  subjects: [row('Mathematics', 8, 10)],
  topics: [row('Geometry', 1, 4)],
  lessons: const [],
  subjectCounts: const {'Mathematics': 1},
  lessonLevelAvailable: false,
  parentSubjectIds: const {'Geometry': 'Mathematics'},
);

final saved = <String>[];

class _Order extends TableOrderNotifier {
  @override
  Future<TableOrder> build() async => TableOrder.defaults;
  @override
  Future<void> setLevel(TableLevel level) async =>
      saved.add('level:${level.name}');
  @override
  Future<void> setSortKey(TableSortKey key) async =>
      saved.add('key:${key.name}');
  @override
  Future<void> setDirection(TableSortDirection direction) async =>
      saved.add('direction:${direction.name}');
  @override
  Future<void> setSubjectId(String? subjectId) async =>
      saved.add('subject:$subjectId');
}

String? lastPush;

Future<void> pump(
  WidgetTester tester, {
  bool pro = true,
  bool paused = false,
  Future<PerformanceViewData> Function()? load,
}) async {
  lastPush = null;
  saved.clear();
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, __) => Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () => context.push('/performance'),
            child: const Text('open'),
          ),
        ),
      ),
      GoRoute(
        path: '/performance',
        builder: (_, __) => const PerformanceScreen(),
      ),
      GoRoute(
        path: '/performance/topic/:topicId',
        builder: (_, state) {
          lastPush = state.uri.path;
          return const Scaffold(body: Text('topic'));
        },
      ),
      GoRoute(
        path: '/settings/pro',
        builder: (_, state) {
          lastPush = state.uri.path;
          return const Scaffold(body: Text('pro'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        performanceViewProvider
            .overrideWith((ref) => (load ?? () async => view)()),
        tableOrderProvider.overrideWith(_Order.new),
        proForActiveExamProvider.overrideWith((ref) async => pro),
        entitlementProvider.overrideWith(
          (ref) => Stream.value(
            paused
                ? const Entitlement(
                    plan: EntitlementPlan.monthly,
                    state: EntitlementState.paused,
                  )
                : const Entitlement.free(),
          ),
        ),
        activeExamFocusProvider.overrideWith(
          (ref) async => const ActiveExamFocus.selected(
            Exam(
              id: 'e',
              code: 'UPCAT',
              name: 'UPCAT',
              shortName: 'UPCAT',
              language: 'en',
              isActive: true,
              subjects: [],
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the measured overall accuracy and subjects',
      (tester) async {
    await pump(tester);
    expect(find.text('Your performance'), findsWidgets);
    expect(find.text('Overall accuracy'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
  });

  testWidgets('Pro opens a topic on its own route', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Geometry'));
    await tester.pumpAndSettle();
    expect(lastPush, '/performance/topic/Geometry');
  });

  testWidgets('Unlock with Pro opens the Pro page for Free', (tester) async {
    await pump(tester, pro: false);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlock with Pro'));
    await tester.pumpAndSettle();
    expect(lastPush, '/settings/pro');
  });

  testWidgets('paused access shows the paused line, not the invitation',
      (tester) async {
    await pump(tester, pro: false, paused: true);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Connect once to keep using Pro.'), findsOneWidget);
    expect(find.text('Unlock with Pro'), findsNothing);
  });

  testWidgets('a failed read keeps the title and offers Try Again',
      (tester) async {
    var fail = true;
    await pump(
      tester,
      load: () async {
        if (fail) throw StateError('offline');
        return view;
      },
    );
    expect(find.text('Could not load your performance.'), findsOneWidget);
    expect(find.text('Your performance'), findsWidgets);
    fail = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Overall accuracy'), findsOneWidget);
  });

  testWidgets('level and sort changes go to the remembered table order',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(saved, contains('level:topic'));
    await tester.tap(find.bySemanticsLabel('Sort: Weakest first'));
    await tester.pumpAndSettle();
    expect(saved, contains('direction:descending'));
  });
}
