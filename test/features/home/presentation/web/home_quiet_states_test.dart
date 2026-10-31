import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_day.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';

Widget _wide(Widget child) => MaterialApp(
      theme: buildLightTheme(web: true),
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1440, 900)),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  testWidgets('the done block sits under the Today card, not inside it',
      (tester) async {
    await tester.pumpWidget(
      _wide(
        HomeTodayChecklist(
          web: true,
          lessons: const [],
          reviewsDone: 18,
          reviewsTotal: 18,
          newDone: 0,
          newTotal: 0,
          canAdvance: true,
          isMockDay: false,
          onLesson: (_) {},
          onLessons: () {},
          onReviews: () {},
          onNew: () {},
          onAdvance: () {},
          onMock: () {},
        ),
      ),
    );

    final card = tester.getRect(find.byType(WebCard));
    final title = tester.getRect(find.text("That's all for today."));
    final button = tester.getRect(find.text('I Want to Advance'));
    expect(title.top, greaterThanOrEqualTo(card.bottom + 22));
    expect(button.right, greaterThan(title.right));
  });

  testWidgets('the review-week note has no button', (tester) async {
    await tester.pumpWidget(
      _wide(
        HomeTodayChecklist(
          web: true,
          lessons: const [],
          reviewsDone: 20,
          reviewsTotal: 20,
          newDone: 0,
          newTotal: 0,
          canAdvance: false,
          isMockDay: false,
          doneNote: HomeDoneNote.reviewWeek,
          onLesson: (_) {},
          onLessons: () {},
          onReviews: () {},
          onNew: () {},
          onAdvance: () {},
          onMock: () {},
        ),
      ),
    );

    expect(find.text('I Want to Advance'), findsNothing);
    expect(find.textContaining('reviews only'), findsOneWidget);
  });

  testWidgets('a quiet-day card has the 40 px icon and board padding',
      (tester) async {
    await tester.pumpWidget(
      _wide(
        HomeStateCard(
          web: true,
          state: HomeState.nothingDue,
          examName: 'Civil Service',
          examShortName: 'CSE',
          onPrimary: () {},
        ),
      ),
    );

    final card = tester.getRect(find.byType(WebCard));
    final title = tester.getRect(find.text('Nothing due today'));
    expect(title.left - card.left, 24 + 40 + 18);
    expect(title.top - card.top, closeTo(26, 4));
  });

  testWidgets('the exam day intro names the exam and the warm-up',
      (tester) async {
    await tester.pumpWidget(
      _wide(const HomeExamDayIntro(examShortName: 'CSE', reviewsTotal: 10)),
    );

    expect(find.text('CSE is today.'), findsOneWidget);
    expect(find.textContaining('10 easy reviews are here'), findsOneWidget);
  });
}
