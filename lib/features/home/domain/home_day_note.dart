import 'package:pantas/core/time/study_days.dart';

/// The one calm line Home may print above Today.
enum HomeDayNote { carried, welcomeBack, mockMoved }

/// Derives the note from what the stored plan and its change log recorded.
///
/// [priorDay] is the most recent stored plan before [day]. A mock due on that
/// day and again today was skipped, because a submitted mock is never placed
/// again. Coming back means two or more whole study days passed with no plan
/// stored (the same two-day threshold the reminders use).
HomeDayNote? homeDayNoteFor({
  required DateTime day,
  required bool isMockDay,
  required DateTime? priorDay,
  required bool priorWasMockDay,
  required bool missedWorkToday,
  required StudyDays studyDays,
}) {
  if (isMockDay && priorWasMockDay && priorDay != null) {
    return HomeDayNote.mockMoved;
  }
  if (!missedWorkToday || priorDay == null) return null;
  return studyDays.missedBetween(priorDay, day) >= 2
      ? HomeDayNote.welcomeBack
      : HomeDayNote.carried;
}
