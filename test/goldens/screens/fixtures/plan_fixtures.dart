// The plan the Plan and Plan day screens share.
import 'package:flutter/widgets.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';

/// The Plan page, with [webPane] open beside it on the wide layout.
Widget planFixture({Widget? webPane, String? selectedWeek}) => PlanPage(
      pro: true,
      paused: false,
      done: 2,
      total: 4,
      subtitle: '42 days until CSE-P',
      webPane: webPane,
      selectedWeek: selectedWeek,
      nodes: const [
        PlanNode(
          kind: PlanNodeKind.week,
          title: 'Nov 9 – 15',
          subtitle: 'Number Sense',
          date: 'This week',
          target: '2026-11-09',
        ),
        PlanNode(
          kind: PlanNodeKind.exam,
          title: 'CSE-P',
          subtitle: 'Exam day',
          date: 'Sun, Dec 20',
        ),
      ],
      history: const [
        PlanHistoryEntry(id: 'h1', date: 'Today', text: 'Moved a review'),
      ],
      onBack: () {},
      onToday: () {},
      onWeek: (_) {},
      onPro: () {},
    );
