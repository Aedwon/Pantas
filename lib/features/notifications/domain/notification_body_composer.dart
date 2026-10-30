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

  NotificationCopy examCountdown({
    required int daysLeft,
    required String examName,
    int flaggedCount = 0,
  }) {
    if (daysLeft == 0) {
      return const NotificationCopy(
        title: "Today's the day.",
        body: 'Good luck.',
      );
    }

    final body = flaggedCount > 0
        ? "You've got $flaggedCount questions flagged. Want to clear them?"
        : '';

    return NotificationCopy(
      title: '$daysLeft days to $examName',
      body: body,
    );
  }

  NotificationCopy? comeBack({
    required String? subjectName,
    required int? correctCount,
    required int? totalCount,
  }) {
    if (subjectName == null ||
        subjectName.isEmpty ||
        correctCount == null ||
        totalCount == null ||
        totalCount <= 0 ||
        correctCount < 0 ||
        correctCount > totalCount) {
      return null;
    }

    return NotificationCopy(
      title: 'Your $subjectName is waiting',
      body: 'You got $correctCount of $totalCount last time. One session '
          'picks it back up.',
    );
  }
}
