import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/web_session_results.dart';

class SessionEndBody extends StatefulWidget {
  const SessionEndBody({
    required this.session,
    required this.attempt,
    required this.subjectNames,
    required this.proIsActive,
    required this.onDone,
    required this.onQuestion,
    required this.onAll,
    required this.onMistakes,
    required this.onNotes,
    this.sourceLine,
    this.debriefCards,
    this.proPaused = false,
    this.onNext,
    super.key,
  });
  final QuizSession session;
  final Attempt attempt;
  final Map<String, String> subjectNames;
  final bool proIsActive;
  final bool proPaused;
  final String? sourceLine;
  final Widget? debriefCards;
  final VoidCallback onDone;
  final ValueChanged<int> onQuestion;
  final VoidCallback onAll;
  final VoidCallback onMistakes;
  final VoidCallback onNotes;
  final Future<void> Function()? onNext;
  @override
  State<SessionEndBody> createState() => _SessionEndBodyState();
}

class _SessionEndBodyState extends State<SessionEndBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds:
          math.max(2600, 820 + (widget.attempt.items.length - 1) * 90),
    ),
  );
  bool _nextBusy = false;
  bool _nextFailed = false;
  bool? _still;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still == _still) return;
    _still = still;
    if (still) {
      _entry
        ..stop()
        ..value = 1;
    } else {
      _entry.forward();
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_nextBusy) return;
    setState(() {
      _nextBusy = true;
      _nextFailed = false;
    });
    try {
      await widget.onNext!();
    } on Object {
      if (mounted) setState(() => _nextFailed = true);
    } finally {
      if (mounted) setState(() => _nextBusy = false);
    }
  }

  Widget _appear(Widget child, int start, int duration, {double rise = 0}) =>
      AnimatedBuilder(
        animation: _entry,
        child: child,
        builder: (context, child) {
          final t = ((_entry.value * _entry.duration!.inMilliseconds - start) /
                  duration)
              .clamp(0.0, 1.0);
          final value = const Cubic(.3, .9, .3, 1).transform(t);
          return IgnorePointer(
            ignoring: t == 0,
            child: Transform.translate(
              offset: Offset(0, rise * (1 - value)),
              child: Opacity(opacity: value, child: child),
            ),
          );
        },
      );
  Widget _circle(int index) {
    final item = widget.attempt.items[index];
    final colors = context.colors;
    final circle = Semantics(
      label: 'Question ${index + 1}, ${item.isCorrect ? 'correct' : 'wrong'}',
      button: true,
      child: InkResponse(
        onTap: () => widget.onQuestion(index),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.isCorrect ? colors.accentTint : colors.wrongTint,
          ),
          child: Text(
            '${index + 1}',
            style: context.type.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: item.isCorrect ? colors.accent : colors.wrongText,
            ),
          ),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: _entry,
      child: circle,
      builder: (context, child) {
        final elapsed =
            _entry.value * _entry.duration!.inMilliseconds - 400 - index * 90;
        final before = elapsed < 0;
        final first = (elapsed / 260).clamp(0.0, 1.0);
        final last = ((elapsed - 260) / 160).clamp(0.0, 1.0);
        const curve = Cubic(.3, 1.4, .5, 1);
        final scale = elapsed <= 260
            ? .4 + .72 * curve.transform(first)
            : 1.12 - .12 * curve.transform(last);
        return IgnorePointer(
          ignoring: before,
          child: Opacity(
            opacity: before
                ? 0
                : elapsed <= 260
                    ? curve.transform(first).clamp(0.0, 1.0)
                    : 1,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final attempt = widget.attempt;
    final total = attempt.items.length;
    final (correct, _) = attempt.score;
    final misses = [
      for (var i = 0; i < total; i++)
        if (!attempt.items[i].isCorrect) i,
    ];
    final batch = widget.session.reviewBatch;
    final source = batch == null
        ? widget.sourceLine
        : 'Reviews · Session ${batch.ordinal} of ${batch.total}';
    final elapsed = attempt.completedAt?.difference(attempt.startedAt);
    final String? durationLine;
    if (elapsed == null || elapsed.isNegative) {
      durationLine = null;
    } else if (elapsed > Duration.zero && elapsed.inMinutes == 0) {
      durationLine = 'in under 1 minute';
    } else {
      final minutes = elapsed.inMinutes;
      durationLine = 'in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
    final next =
        widget.onNext != null && batch != null && batch.ordinal < batch.total;
    if (context.wideWeb) {
      return WebSessionResults(
        session: widget.session,
        attempt: attempt,
        subjectNames: widget.subjectNames,
        pro: widget.proIsActive,
        debriefCards: widget.debriefCards,
        proPaused: widget.proPaused,
        source: source,
        onDone: widget.onDone,
        onQuestion: widget.onQuestion,
        onAll: widget.onAll,
        onMistakes: widget.onMistakes,
        onNotes: widget.onNotes,
        onNext: next ? () => unawaited(_next()) : null,
        nextBusy: _nextBusy,
        failure: _nextFailed ? saveFailureLine(() => unawaited(_next())) : null,
      );
    }
    return SafeArea(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
            children: [
              _appear(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session finished.',
                      style: type.pageTitle.copyWith(fontSize: 30),
                    ),
                    if (source != null) Text(source, style: type.subhead),
                  ],
                ),
                100,
                380,
                rise: 6,
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Column(
                  children: [
                    HalfRingGauge.quizCount(correct: correct, total: total),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (var i = 0; i < total; i++) _circle(i)],
                    ),
                    if (durationLine != null) ...[
                      const SizedBox(height: 8),
                      _appear(
                        Text(durationLine, style: type.footnote),
                        1600,
                        300,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.debriefCards != null) ...[
                const SizedBox(height: 22),
                widget.debriefCards!,
              ],
              if (misses.isNotEmpty) ...[
                const SizedBox(height: 22),
                _appear(
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'YOUR MISTAKES',
                                style: type.sectionHeader,
                              ),
                            ),
                            Text('${misses.length}', style: type.sectionHeader),
                          ],
                        ),
                      ),
                      GroupedSection(
                        children: [
                          for (final (position, index)
                              in misses.take(3).indexed)
                            _appear(
                              ListRow(
                                title: widget
                                        .session.questions[index].shortLabel ??
                                    widget.session.questions[index].stem,
                                titleWidget: widget.session.questions[index]
                                            .shortLabel ==
                                        null
                                    ? DefaultTextStyle(
                                        style: type.body,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        child: MathText(
                                          widget.session.questions[index].stem,
                                        ),
                                      )
                                    : null,
                                subtitle: widget.subjectNames[
                                    widget.session.questions[index].topicId],
                                leading: Icon(
                                  PantasIcons.close,
                                  size: 22,
                                  color: colors.wrongText,
                                ),
                                divider: position < misses.take(3).length - 1 ||
                                    misses.length > 3,
                                onTap: () => widget.onQuestion(index),
                              ),
                              1700 + position * 90,
                              380,
                              rise: 6,
                            ),
                          if (misses.length > 3)
                            ListRow(
                              title: 'See all ${misses.length} mistakes',
                              titleColor: colors.accent,
                              onTap: widget.onMistakes,
                            ),
                        ],
                      ),
                    ],
                  ),
                  1620,
                  380,
                  rise: 8,
                ),
              ],
              const SizedBox(height: 22),
              _appear(
                GroupedSection(
                  children: [
                    ListRow(title: 'See all questions', onTap: widget.onAll),
                  ],
                ),
                2000,
                380,
                rise: 10,
              ),
              if (misses.isNotEmpty &&
                  (widget.proIsActive || widget.proPaused)) ...[
                const SizedBox(height: 22),
                _appear(
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: widget.proPaused
                        ? const ProPausedLine()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Tell Pantas why you got each one wrong. '
                                'The better your notes, the more every '
                                'review helps.',
                                style: type.subhead.copyWith(
                                  color: colors.label,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 12),
                              PantasButton(
                                label: 'Finish the Notes',
                                variant: PantasButtonVariant.secondary,
                                height: 44,
                                radius: 99,
                                fontSize: 15,
                                onPressed: widget.onNotes,
                              ),
                            ],
                          ),
                  ),
                  2260,
                  300,
                ),
              ],
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [
                    0,
                    .26,
                  ],
                  colors: [
                    colors.background.withValues(alpha: 0),
                    colors.background,
                  ],
                ),
              ),
              child: _appear(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_nextFailed) saveFailureLine(() => unawaited(_next())),
                    if (next) ...[
                      PantasButton(
                        label: 'Start Session ${batch.ordinal + 1}',
                        busy: _nextBusy,
                        onPressed: () => unawaited(_next()),
                      ),
                      const SizedBox(height: 4),
                    ],
                    PantasButton(
                      label: 'Done',
                      variant: next
                          ? PantasButtonVariant.tertiary
                          : PantasButtonVariant.primary,
                      height: next ? 44 : 52,
                      onPressed: _nextBusy ? null : widget.onDone,
                    ),
                  ],
                ),
                2200,
                300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
