// The end sequence (core loops B2): the question screen fades out in 180 ms,
// each mark flies for 360 ms, 20 ms after the one before (the whole stagger
// stops at 180 ms), and the marks have landed within about 0.75 s of Finish.
// The ring and the count-up start as the last two land.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/presentation/session_end_timeline.dart';

void main() {
  test('10 questions: 20 ms apart, landed by 720 ms', () {
    final t = SessionEndTimeline.flight(count: 10);
    expect(t.fade, 180);
    expect(t.step, 20);
    expect(t.takeOff(0), 180);
    expect(t.land(0), 540);
    expect(t.land(9), 720);
    expect(t.lastLand, 720);
    // The ring starts as the last two land.
    expect(t.ringStart, t.land(8));
    expect(t.ringStart, 700);
    expect(t.detailStart, t.lastLand);
    expect(t.flies, isTrue);
  });

  test('20 questions: the whole stagger stops at 180 ms', () {
    final t = SessionEndTimeline.flight(count: 20);
    expect(t.step, lessThan(20));
    expect(t.takeOff(19) - t.takeOff(0), lessThanOrEqualTo(180));
    expect(t.lastLand, lessThanOrEqualTo(750));
    expect(t.ringStart, t.land(18));
  });

  test('11 questions: the stagger is capped, not 20 ms a mark', () {
    final t = SessionEndTimeline.flight(count: 11);
    expect(t.takeOff(10) - t.takeOff(0), lessThanOrEqualTo(180));
    expect(t.lastLand, lessThanOrEqualTo(750));
  });

  test('25 questions: nothing flies, the row comes in with the ring', () {
    final t = SessionEndTimeline.flight(count: 25);
    expect(t.flies, isFalse);
    expect(t.lastLand, 180);
    expect(t.ringStart, 180);
    expect(t.rowStart, t.ringStart);
    expect(t.titleStart, 180);
  });

  test('one question lands its only mark and starts the ring with it', () {
    final t = SessionEndTimeline.flight(count: 1);
    expect(t.ringStart, t.land(0));
  });

  test('the rest of the page follows the ring', () {
    final ten = SessionEndTimeline.flight(count: 10);
    // The mistakes come in as the 1.4 s ring fills, as they did before.
    expect(ten.later, ten.ringStart + 1400 - 1600);
    expect(ten.length, greaterThanOrEqualTo(2560 + ten.later));
  });

  test('a result opened later keeps the earlier timeline', () {
    final t = SessionEndTimeline.still(count: 10);
    expect(t.flight, isFalse);
    expect(t.titleStart, 100);
    expect(t.ringStart, 400);
    expect(t.doneStart, 1700);
    expect(t.phoneDoneStart, 2200);
    expect(t.later, 0);
    expect(t.length, 2600);
  });
}
