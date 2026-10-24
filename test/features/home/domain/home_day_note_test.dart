import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';

HomeDayNote? note({
  required DateTime day,
  DateTime? prior,
  bool missed = false,
  bool mock = false,
  bool priorMock = false,
  StudyDays studyDays = StudyDays.all,
}) =>
    homeDayNoteFor(
      day: day,
      isMockDay: mock,
      priorDay: prior,
      priorWasMockDay: priorMock,
      missedWorkToday: missed,
      studyDays: studyDays,
    );

void main() {
  final today = DateTime(2026, 10, 28);

  test('no missed work and no skipped mock means no note', () {
    expect(note(day: today, prior: DateTime(2026, 10, 27)), isNull);
  });

  test('yesterday unfinished is carried into today', () {
    expect(
      note(day: today, prior: DateTime(2026, 10, 27), missed: true),
      HomeDayNote.carried,
    );
  });

  test('one unopened study day between is still a carry', () {
    expect(
      note(day: today, prior: DateTime(2026, 10, 26), missed: true),
      HomeDayNote.carried,
    );
  });

  test('two or more unopened study days read as coming back', () {
    expect(
      note(day: today, prior: DateTime(2026, 10, 25), missed: true),
      HomeDayNote.welcomeBack,
    );
  });

  test('rest days between do not count as missed', () {
    // Study days Monday to Friday; Oct 24 is Saturday, Oct 26 Monday.
    final weekdays = StudyDays.fromStorage('1,2,3,4,5');
    expect(
      note(
        day: DateTime(2026, 10, 27),
        prior: DateTime(2026, 10, 23),
        missed: true,
        studyDays: weekdays,
      ),
      HomeDayNote.carried,
    );
  });

  test('a mock due on the last stored day and again today has moved', () {
    expect(
      note(
        day: today,
        prior: DateTime(2026, 10, 27),
        mock: true,
        priorMock: true,
      ),
      HomeDayNote.mockMoved,
    );
  });

  test('a mock that is simply due today has not moved', () {
    expect(note(day: today, prior: DateTime(2026, 10, 27), mock: true), isNull);
  });

  test('a moved mock outranks the carry line', () {
    expect(
      note(
        day: today,
        prior: DateTime(2026, 10, 27),
        mock: true,
        priorMock: true,
        missed: true,
      ),
      HomeDayNote.mockMoved,
    );
  });
}
