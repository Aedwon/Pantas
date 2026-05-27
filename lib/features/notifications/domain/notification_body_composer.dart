enum DailyReminderPlanState {
  standard,
  mock,
  behind,
  calm,
  firstPostDiagnostic,
}

class NotificationCopy {
  const NotificationCopy({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class DailyReminderInput {
  const DailyReminderInput({
    required this.planState,
    required this.reviewCount,
  });

  final DailyReminderPlanState planState;
  final int reviewCount;
}

class NotificationBodyComposer {
  const NotificationBodyComposer();

  NotificationCopy dailyReminder(DailyReminderInput input) {
    return switch (input.planState) {
      DailyReminderPlanState.standard => NotificationCopy(
          title: "Today's session is ready",
          body: "${input.reviewCount} questions to review. You've got this.",
        ),
      DailyReminderPlanState.mock => const NotificationCopy(
          title: 'Mock exam day',
          body: 'Take your time and treat it like the real thing. '
              "You've prepped for this.",
        ),
      DailyReminderPlanState.behind => NotificationCopy(
          title: 'Welcome back',
          body: "Let's ease in. ${input.reviewCount} reviews today, no rush.",
        ),
      DailyReminderPlanState.calm => const NotificationCopy(
          title: 'Quick check-in',
          body: 'Short session today keeps you sharp.',
        ),
      DailyReminderPlanState.firstPostDiagnostic => NotificationCopy(
          title: 'Your plan is set',
          body: "Let's start with ${input.reviewCount} questions. "
              'Easy first session.',
        ),
    };
  }

  NotificationCopy fallbackDailyReminder() {
    return const NotificationCopy(
      title: "Time for today's session",
      body: "You've got this.",
    );
  }

  NotificationCopy streakSave({
    required int streakLength,
    int freezesRemaining = 0,
  }) {
    if (freezesRemaining > 0) {
      return NotificationCopy(
        title: "Your $streakLength-day streak's safe tonight",
        body: "If you skip, your streak's freeze will save it "
            '($freezesRemaining left this month). Want to keep the freeze '
            'and study anyway?',
      );
    }

    if (streakLength == 1) {
      return const NotificationCopy(
        title: "Don't lose your streak",
        body: 'Your 1-day streak is on the line. One more quick session '
            "and you'll have 2.",
      );
    }
    if (streakLength < 7) {
      return NotificationCopy(
        title: 'Five more minutes?',
        body: 'Your $streakLength-day streak is still going. Quick session, '
            "then you're done.",
      );
    }
    if (streakLength < 30) {
      return NotificationCopy(
        title: "Your $streakLength-day streak's still alive",
        body: 'One quick session before midnight keeps it going.',
      );
    }
    return NotificationCopy(
      title: '$streakLength days strong',
      body: "Don't let tonight be the one that breaks your $streakLength-day "
          'streak - a few minutes is all it takes.',
    );
  }
}
