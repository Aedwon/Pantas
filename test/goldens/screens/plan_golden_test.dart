// Route /plan.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';

import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'plan',
    (tester, width) => pumpScreen(
      tester,
      width,
      PlanPage(
        pro: true,
        paused: false,
        done: 2,
        total: 4,
        subtitle: '42 days until CSE-P',
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
      ),
    ),
  );
}
