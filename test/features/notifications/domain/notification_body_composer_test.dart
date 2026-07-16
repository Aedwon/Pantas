import 'package:cse_cet_reviewer/features/notifications/notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('daily reminder copy', () {
    test('standard daily reminder includes review count', () {
      final copy = const NotificationBodyComposer().dailyReminder(
        const DailyReminderInput(
          planState: DailyReminderPlanState.standard,
          reviewCount: 14,
        ),
      );

      expect(copy.title, "Today's session is ready");
      expect(copy.body, "14 questions to review. You've got this.");
    });

    test('mock daily reminder uses mock day copy', () {
      final copy = const NotificationBodyComposer().dailyReminder(
        const DailyReminderInput(
          planState: DailyReminderPlanState.mock,
          reviewCount: 0,
        ),
      );

      expect(copy.title, 'Mock exam day');
      expect(
        copy.body,
        'Take your time and treat it like the real thing. '
        "You've prepped for this.",
      );
    });

    test('behind daily reminder uses welcome back copy', () {
      final copy = const NotificationBodyComposer().dailyReminder(
        const DailyReminderInput(
          planState: DailyReminderPlanState.behind,
          reviewCount: 8,
        ),
      );

      expect(copy.title, 'Welcome back');
      expect(copy.body, "Let's ease in. 8 reviews today, no rush.");
    });

    test('calm daily reminder uses quick check in copy', () {
      final copy = const NotificationBodyComposer().dailyReminder(
        const DailyReminderInput(
          planState: DailyReminderPlanState.calm,
          reviewCount: 3,
        ),
      );

      expect(copy.title, 'Quick check-in');
      expect(copy.body, 'Short session today keeps you sharp.');
    });

    test('first post diagnostic daily reminder uses plan set copy', () {
      final copy = const NotificationBodyComposer().dailyReminder(
        const DailyReminderInput(
          planState: DailyReminderPlanState.firstPostDiagnostic,
          reviewCount: 5,
        ),
      );

      expect(copy.title, 'Your plan is set');
      expect(copy.body, "Let's start with 5 questions. Easy first session.");
    });

    test('daily reminder falls back when plan is unavailable', () {
      final copy = const NotificationBodyComposer().fallbackDailyReminder();

      expect(copy.title, "Time for today's session");
      expect(copy.body, "You've got this.");
    });
  });

  group('streak save copy', () {
    test('streak save copy covers key tiers', () {
      const composer = NotificationBodyComposer();

      expect(
        composer.streakSave(streakLength: 1).title,
        "Don't lose your streak",
      );
      expect(
        composer.streakSave(streakLength: 2).title,
        'Five more minutes?',
      );
      expect(
        composer.streakSave(streakLength: 6).title,
        'Five more minutes?',
      );
      expect(
        composer.streakSave(streakLength: 7).title,
        "Your 7-day streak's still alive",
      );
      expect(
        composer.streakSave(streakLength: 29).title,
        "Your 29-day streak's still alive",
      );
      expect(composer.streakSave(streakLength: 30).title, '30 days strong');
      expect(composer.streakSave(streakLength: 100).title, '100 days strong');
    });

    test('streak save freeze copy surfaces remaining freezes', () {
      final copy = const NotificationBodyComposer().streakSave(
        streakLength: 5,
        freezesRemaining: 1,
      );

      expect(copy.title, "Your 5-day streak's safe tonight");
      expect(
        copy.body,
        "If you skip, your streak's freeze will save it "
        '(1 left this month). Want to keep the freeze and study anyway?',
      );
    });
  });

  group('exam countdown copy', () {
    test('countdown at 7 days with flagged questions includes count', () {
      final copy = const NotificationBodyComposer().examCountdown(
        daysLeft: 7,
        examName: 'UPCAT',
        flaggedCount: 42,
      );

      expect(copy.title, '7 days to UPCAT');
      expect(copy.body, "You've got 42 questions flagged. Want to clear them?");
    });

    test('day of exam contains no count and no call to action', () {
      final copy = const NotificationBodyComposer().examCountdown(
        daysLeft: 0,
        examName: 'UPCAT',
        flaggedCount: 10,
      );

      expect(copy.title, "Today's the day.");
      expect(copy.body, 'Good luck.');
      expect(copy.body.contains(RegExp(r'\d+')), isFalse);
      expect(copy.body.toLowerCase().contains('want to'), isFalse);
    });

    test('countdown with no flagged questions sends title with no second line', () {
      final copy = const NotificationBodyComposer().examCountdown(
        daysLeft: 14,
        examName: 'UPCAT',
        flaggedCount: 0,
      );

      expect(copy.title, '14 days to UPCAT');
      expect(copy.body, isEmpty);
    });
  });

  group('lapse comeBack copy', () {
    test('lapse composer with attempt data names subject and past score', () {
      final copy = const NotificationBodyComposer().comeBack(
        subjectName: 'Chemistry',
        correctCount: 12,
        totalCount: 20,
      );

      expect(copy, isNotNull);
      expect(copy!.title, 'Your Chemistry is waiting');
      expect(
        copy.body,
        'You got 12 of 20 last time. One session picks it back up.',
      );
    });

    test('lapse composer with no attempts returns null', () {
      final copy = const NotificationBodyComposer().comeBack(
        subjectName: null,
        correctCount: null,
        totalCount: null,
      );

      expect(copy, isNull);
    });
  });

  group('spec compliance checks across all notification copy', () {
    test('no body contains an em dash, marks, or banned words', () {
      const composer = NotificationBodyComposer();
      final copies = <NotificationCopy>[
        composer.examCountdown(daysLeft: 7, examName: 'UPCAT', flaggedCount: 42),
        composer.examCountdown(daysLeft: 0, examName: 'UPCAT'),
        composer.examCountdown(daysLeft: 14, examName: 'UPCAT'),
        composer.comeBack(subjectName: 'Chemistry', correctCount: 12, totalCount: 20)!,
      ];

      for (final copy in copies) {
        final fullText = '${copy.title} ${copy.body}';
        expect(fullText.contains('—'), isFalse, reason: 'Contains em dash');
        expect(fullText.toLowerCase().contains('marks'), isFalse, reason: 'Contains marks');
        expect(fullText.toLowerCase().contains('falling behind'), isFalse);
        expect(fullText.toLowerCase().contains('last chance'), isFalse);
        expect(fullText.toLowerCase().contains('progress will be lost'), isFalse);
        expect(fullText.toLowerCase().contains('we miss you'), isFalse);
        expect(fullText.toLowerCase().contains('on track'), isFalse);
      }
    });
  });
}
