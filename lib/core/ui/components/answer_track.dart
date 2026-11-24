import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// The answer track in the session bar (core loops B2): one small mark per
/// question. A question not yet reached is gray, the one on screen is solid
/// ink, and a checked one is teal (right) or red (wrong), changing color in
/// 200 ms. Over [maxMarks] questions the marks give way to one thin line that
/// fills in proportion.
///
/// [answered] holds whether each checked question was right, in order, so
/// its length is how many have been checked. [current] is the question the
/// student is on. [status] is the word read once as a status when a result
/// lands ("Correct", "Not this one"); it is never drawn.
class AnswerTrack extends StatelessWidget {
  const AnswerTrack({
    required this.total,
    required this.answered,
    required this.current,
    this.phone = false,
    this.compact = false,
    this.status,
    super.key,
  });

  /// Above this many questions the track is a line.
  static const int maxMarks = 20;

  final int total;
  final List<bool> answered;
  final int current;
  final bool phone;

  /// A phone under 360 wide: marks 6 x 4, 2 px apart (T16 B2 ruling).
  final bool compact;
  final String? status;

  bool get _line => total > maxMarks;

  double get _markWidth => _width(phone: phone, compact: compact);
  double get _gap => _gapOf(phone: phone, compact: compact);
  static const double _markHeight = PantasSpace.s4;

  /// Marks per row on the phone: 11 to 20 questions make two rows.
  static const int perRow = 10;

  static double _width({required bool phone, required bool compact}) => !phone
      ? PantasSpace.s10
      : compact
          ? PantasSpace.s6
          : PantasSpace.s8;

  static double _gapOf({required bool phone, required bool compact}) =>
      compact ? PantasSpace.s2 : PantasSpace.s3;

  /// As wide as ten marks: the phone's rows and its line.
  static double _tenWidth({required bool compact}) =>
      perRow * _width(phone: true, compact: compact) +
      (perRow - 1) * _gapOf(phone: true, compact: compact);

  /// Where the marks are on screen, for the flight at the end of a session.
  /// [key] is the key this track was built with. Empty over [maxMarks]
  /// questions, which fly nothing.
  static List<Rect> markRects(
    GlobalKey key,
    int total, {
    required bool phone,
    bool compact = false,
  }) {
    final box = key.currentContext?.findRenderObject();
    if (total > maxMarks || box is! RenderBox || !box.attached) return const [];
    final width = _width(phone: phone, compact: compact);
    final gap = _gapOf(phone: phone, compact: compact);
    final origin = box.localToGlobal(Offset.zero);
    return [
      for (var i = 0; i < total; i++)
        Rect.fromLTWH(
          origin.dx + (phone ? i % perRow : i) * (width + gap),
          phone
              ? origin.dy + (i ~/ perRow) * (_markHeight + gap)
              : origin.dy + (box.size.height - _markHeight) / 2,
          width,
          _markHeight,
        ),
    ];
  }

  /// "1", "1 and 3", "1, 3 and 5".
  static String _numbers(List<int> list) => list.length < 2
      ? '${list.single}'
      : '${list.take(list.length - 1).join(', ')} and ${list.last}';

  String get _label {
    final head = 'Question ${current + 1} of $total.';
    final result = status == null ? '' : ' $status.';
    if (_line) return '$head$result';
    final right = [
      for (final (i, ok) in answered.indexed)
        if (ok) i + 1,
    ];
    final wrong = [
      for (final (i, ok) in answered.indexed)
        if (!ok) i + 1,
    ];
    String phrase(String noun, List<int> list, String verdict) =>
        '${list.length > 1 ? '${noun}s' : noun} ${_numbers(list)} $verdict';
    final parts = [
      if (right.isNotEmpty) phrase('Question', right, 'right'),
      if (wrong.isNotEmpty) phrase('question', wrong, 'wrong'),
    ];
    final detail = parts.isEmpty ? '' : ' ${parts.join(', ')}.';
    return '$head$result$detail';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final duration = still ? Duration.zero : PantasDurations.trackColor;
    final Widget body;
    if (_line) {
      final lineWidth =
          phone ? _tenWidth(compact: compact) : PantasLayout.trackLine;
      final fraction =
          total == 0 ? 0.0 : (answered.length / total).clamp(0.0, 1.0);
      body = Container(
        key: const ValueKey('answer-track-line'),
        width: lineWidth,
        height: _markHeight,
        decoration: BoxDecoration(
          color: colors.dividerStrong,
          borderRadius: BorderRadius.circular(PantasRadius.full),
        ),
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.antiAlias,
        child: AnimatedContainer(
          key: const ValueKey('answer-track-line-fill'),
          duration: duration,
          curve: PantasCurves.fade,
          width: lineWidth * fraction,
          height: _markHeight,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(PantasRadius.full),
          ),
        ),
      );
    } else {
      Color colorOf(int i) {
        if (i < answered.length) {
          return answered[i] ? colors.accent : colors.danger;
        }
        return i == current ? colors.textPrimary : colors.dividerStrong;
      }

      final marks = [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            key: ValueKey('answer-track-mark-$i'),
            duration: duration,
            curve: PantasCurves.fade,
            width: _markWidth,
            height: _markHeight,
            decoration: BoxDecoration(
              color: colorOf(i),
              borderRadius: BorderRadius.circular(PantasRadius.full),
            ),
          ),
      ];
      // The phone never goes wider than ten marks: the rest wrap, left
      // aligned, in reading order.
      body = phone
          ? SizedBox(
              width: _tenWidth(compact: compact),
              child: Wrap(spacing: _gap, runSpacing: _gap, children: marks),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: _gap,
              children: marks,
            );
    }
    return Semantics(
      label: _label,
      liveRegion: status != null,
      image: true,
      excludeSemantics: true,
      child: body,
    );
  }
}
