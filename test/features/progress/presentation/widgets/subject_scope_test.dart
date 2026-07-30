import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/progress/application/table_order_prefs.dart';
import 'package:pantas/features/progress/presentation/widgets/subject_scope_sheet.dart';
import 'package:pantas/features/progress/presentation/widgets/table_head.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef ScopeSubject = ({String id, String name, int rowCount});

const twoSubjects = <ScopeSubject>[
  (id: 'sci', name: 'Science', rowCount: 18),
  (id: 'math', name: 'Mathematics', rowCount: 5),
];

void main() {
  /// The head as the section builds it: the left cell is a plain label at
  /// Subject level and the scope control below it.
  Widget harness({
    required TableLevel level,
    String? subjectId,
    List<ScopeSubject> subjects = twoSubjects,
  }) {
    final selected = ValueNotifier<String?>(subjectId);

    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: ValueListenableBuilder<String?>(
          valueListenable: selected,
          builder: (context, value, _) {
            final showScope =
                level != TableLevel.subject && subjects.length >= 2;
            return TableHead(
              rowNoun: level.name,
              showTime: false,
              sortKey: TableSortKey.score,
              direction: TableSortDirection.ascending,
              onSort: (_) {},
              scopeLabel: showScope
                  ? scopeLabelFor(
                      level: level,
                      subjectName: subjects
                          .where((s) => s.id == value)
                          .map((s) => s.name)
                          .firstOrNull,
                    )
                  : null,
              onScope: showScope
                  ? () async {
                      final choice = await showSubjectScopeSheet(
                        context,
                        subjects: subjects,
                        selectedId: value,
                      );
                      if (choice != null) selected.value = choice.subjectId;
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }

  testWidgets('at Subject level the cell is a plain label with no tap',
      (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.subject));

    expect(find.text('SUBJECT'), findsOneWidget);
    expect(find.byKey(const ValueKey('scope-underline')), findsNothing);
    await tester.tap(find.text('SUBJECT'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(SubjectScopeSheet), findsNothing);
  });

  testWidgets('at Topic level it reads All topics and is underlined',
      (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.topic));

    expect(find.text('All topics'), findsOneWidget);
    expect(find.byKey(const ValueKey('scope-underline')), findsOneWidget);
  });

  testWidgets('filtered, it states the filter', (tester) async {
    await tester.pumpWidget(
      harness(level: TableLevel.topic, subjectId: 'sci'),
    );

    expect(find.text('Science topics'), findsOneWidget);
    expect(find.textContaining('Filtered by'), findsNothing);
  });

  testWidgets('lesson level mirrors topic', (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.lesson));

    expect(find.text('All lessons'), findsOneWidget);
  });

  testWidgets('with one subject the control does not render', (tester) async {
    await tester.pumpWidget(
      harness(level: TableLevel.topic, subjects: [twoSubjects.first]),
    );

    expect(find.text('All topics'), findsNothing);
    expect(find.text('TOPIC'), findsOneWidget);
  });

  testWidgets('the sheet lists All first, then subjects with counts',
      (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.topic));

    await tester.tap(find.text('All topics'));
    await tester.pumpAndSettle();

    expect(find.text('Show which topics'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('dismissing leaves the filter alone, choosing All clears it',
      (tester) async {
    await tester.pumpWidget(
      harness(level: TableLevel.topic, subjectId: 'sci'),
    );

    await tester.tap(find.text('Science topics'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // the wash
    await tester.pumpAndSettle();
    expect(find.text('Science topics'), findsOneWidget);

    await tester.tap(find.text('Science topics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All topics').last);
    await tester.pumpAndSettle();
    expect(find.text('All topics'), findsOneWidget);
  });

  testWidgets('choosing a subject filters to it', (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.topic));

    await tester.tap(find.text('All topics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics topics'), findsOneWidget);
  });
}
