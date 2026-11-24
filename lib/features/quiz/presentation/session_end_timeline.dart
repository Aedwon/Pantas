import 'dart:math' as math;

import 'package:pantas/core/ui/components/answer_track.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

/// When each part of the session end appears (core loops B2), in whole
/// milliseconds from the last Finish.
///
/// With a flight, the question screen fades out first. Then the marks fly
/// from the bar into the results row, 20 ms apart (the whole stagger stops at
/// 180 ms), and the ring and the count-up start as the last two land. The
/// title, "in 9 minutes" and Done come in around them. Over 20 questions
/// there are no marks to fly: the results row fades in with the ring.
///
/// Without a flight (a result opened later) the earlier, approved timeline
/// stays as it was.
class SessionEndTimeline {
  /// The earlier timeline of a result opened later.
  SessionEndTimeline.still({required this.count})
      : flight = false,
        flies = false,
        fade = 0,
        step = 0,
        titleStart = 100,
        titleDuration = 380,
        ringStart = _stillRingStart,
        rowStart = 0,
        detailStart = 1600,
        doneStart = 1700,
        phoneDoneStart = 2200,
        later = 0;

  /// The timeline that follows the last Finish.
  factory SessionEndTimeline.flight({required int count}) {
    final flies = count <= AnswerTrack.maxMarks;
    final fade = PantasDurations.short3.inMilliseconds;
    final cap = PantasDurations.trackStaggerMax.inMilliseconds;
    final unit = PantasDurations.trackStagger.inMilliseconds;
    final step = count < 2 ? 0 : math.min(unit, cap ~/ (count - 1));
    final fly = PantasDurations.trackFly.inMilliseconds;
    int land(int i) => fade + step * i + fly;
    final ring = flies ? land(math.max(count - 2, 0)) : fade;
    final lastLand = flies ? land(math.max(count - 1, 0)) : fade;
    return SessionEndTimeline._(
      count: count,
      flies: flies,
      fade: fade,
      step: step,
      titleStart: flies ? ring - _titleLead : fade,
      ringStart: ring,
      rowStart: ring,
      detailStart: flies ? lastLand : fade + _titleFade,
      later: ring - _stillRingStart,
    );
  }

  SessionEndTimeline._({
    required this.count,
    required this.flies,
    required this.fade,
    required this.step,
    required this.titleStart,
    required this.ringStart,
    required this.rowStart,
    required this.detailStart,
    required this.later,
  })  : flight = true,
        titleDuration = _titleFade,
        doneStart = detailStart,
        phoneDoneStart = detailStart;

  /// Where the ring started in the earlier timeline: its 400 ms lead.
  static const int _stillRingStart = 400;

  /// The title and the ring fade in over 120 ms, starting 70 ms before the
  /// ring does (board B2_WideEnd).
  static const int _titleFade = 120;
  static const int _titleLead = 70;

  /// The "in 9 minutes" line and Done fade in over 280 ms (board B2_WideEnd).
  static const int detailDuration = 280;

  /// How many questions the session had.
  final int count;

  /// Whether this is the sequence after the last Finish.
  final bool flight;

  /// Whether marks fly: 20 questions or fewer.
  final bool flies;

  /// How long the question screen takes to fade out.
  final int fade;

  /// The gap between two marks taking off.
  final int step;
  final int titleStart;
  final int titleDuration;

  /// When the ring and the count-up start.
  final int ringStart;

  /// When the results row fades in, over 20 questions.
  final int rowStart;

  /// When "in 9 minutes" appears.
  final int detailStart;

  /// When Done appears: the wide page, then the phone page.
  final int doneStart;
  final int phoneDoneStart;

  /// How far the rest of the page (the mistakes, the notes) moves later than
  /// the earlier timeline put it.
  final int later;

  /// When mark [i] takes off.
  int takeOff(int i) => fade + step * i;

  /// When mark [i] has landed.
  int land(int i) => takeOff(i) + PantasDurations.trackFly.inMilliseconds;

  /// When the last mark has landed.
  int get lastLand => flies ? land(count - 1) : fade;

  /// The whole sequence in milliseconds, with room for what follows the ring.
  int get length {
    final earlier = math.max(2600, 820 + (count - 1) * 90);
    // The notes prompt is the last to appear, 2260 ms in the earlier
    // timeline, and takes 300 ms.
    return flight ? math.max(earlier, 2560 + later + 40) : earlier;
  }
}
