import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';

void main() {
  test('week day state rules cover day off, today, future, and past work', () {
    expect(
      classifyWeekDay(
        isToday: false,
        isStudyDay: false,
        isFuture: false,
        total: 3,
        left: 3,
      ),
      WeekDayState.dayOff,
    );
    expect(
      classifyWeekDay(
        isToday: true,
        isStudyDay: true,
        isFuture: false,
        total: 3,
        left: 2,
      ),
      WeekDayState.today,
    );
    expect(
      classifyWeekDay(
        isToday: false,
        isStudyDay: true,
        isFuture: true,
        total: null,
        left: null,
      ),
      WeekDayState.plain,
    );
    expect(
      classifyWeekDay(
        isToday: false,
        isStudyDay: true,
        isFuture: false,
        total: 3,
        left: 0,
      ),
      WeekDayState.done,
    );
    expect(
      classifyWeekDay(
        isToday: false,
        isStudyDay: true,
        isFuture: false,
        total: 3,
        left: 2,
      ),
      WeekDayState.partial,
    );
    expect(
      classifyWeekDay(
        isToday: false,
        isStudyDay: true,
        isFuture: false,
        total: 3,
        left: 3,
      ),
      WeekDayState.missed,
    );
    expect(
      classifyWeekDay(
        isToday: false,
        isStudyDay: true,
        isFuture: false,
        total: null,
        left: null,
      ),
      WeekDayState.missed,
    );
  });

  test('today fraction is completion over original work and clamps', () {
    expect(todayCompletionFraction(total: 4, left: 2), .5);
    expect(todayCompletionFraction(total: 0, left: 0), 0);
    expect(todayCompletionFraction(total: 4, left: -1), 1);
    expect(todayCompletionFraction(total: 4, left: 5), 0);
  });
}
