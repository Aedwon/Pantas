import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpGap(
    WidgetTester tester, {
    bool isRead = false,
    ExamId? examId = 'e1',
    LessonId lessonId = 'l1',
  }) async {
    await tester.pumpApp(
      ReaderGap(
        isRead: isRead,
        examId: examId,
        lessonId: lessonId,
      ),
    );
  }

  testWidgets('an unread lesson shows no read line', (tester) async {
    await pumpGap(tester);

    expect(find.text('Read'), findsNothing);
    expect(find.text('marked automatically'), findsNothing);
  });

  testWidgets('a read lesson says so, and says how', (tester) async {
    await pumpGap(tester, isRead: true);

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('marked automatically'), findsOneWidget);
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('there is no mark as read button anywhere', (tester) async {
    await pumpGap(tester);

    expect(find.text('Mark as read'), findsNothing);
  });

  testWidgets('the coda names its length', (tester) async {
    await pumpGap(tester);

    expect(find.text('Quiz yourself, 5 questions'), findsOneWidget);
  });

  testWidgets('no exam means no coda rather than a broken route',
      (tester) async {
    await pumpGap(tester, examId: null);

    expect(find.text('Quiz yourself, 5 questions'), findsNothing);
  });

  testWidgets('the gap never prints the estimated minutes', (tester) async {
    await pumpGap(tester, isRead: true);

    expect(find.textContaining('min'), findsNothing);
  });
}
