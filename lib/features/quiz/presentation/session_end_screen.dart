import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_tooltip.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/quiz_tap_area.dart';
import 'package:pantas/features/quiz/presentation/session_entry_motion.dart';
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
    this.onMistake,
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

  /// A mistake row opens that mistake, among the mistakes only. Without it
  /// the row opens the question like any other.
  final ValueChanged<int>? onMistake;
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

  late final _motion = SessionEntryMotion(_entry);
  Widget _appear(Widget child, int start, int duration, {double rise = 0}) =>
      _motion.appear(child, start, duration, rise: rise);
  Widget _circle(int index) {
    final item = widget.attempt.items[index];
    final colors = context.colors;
    final circle = Semantics(
      label: 'Question ${index + 1}, ${item.isCorrect ? 'correct' : 'wrong'}',
      button: true,
      child: QuizTapArea(
        onTap: () => widget.onQuestion(index),
        borderRadius: BorderRadius.circular(PantasRadius.full),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.isCorrect ? colors.accentTint : colors.dangerTint,
          ),
          child: Text(
            '${index + 1}',
            style: PantasType.phoneCaption.copyWith(
              color: item.isCorrect ? colors.accent : colors.dangerText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    return _motion.pop(index, circle);
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
        onMistake: widget.onMistake,
        onAll: widget.onAll,
        onMistakes: widget.onMistakes,
        onNotes: widget.onNotes,
        onNext: next ? () => unawaited(_next()) : null,
        entry: _motion,
        nextBusy: _nextBusy,
        failure: _nextFailed ? saveFailureLine(() => unawaited(_next())) : null,
      );
    }
    return SafeArea(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s0,
              PantasSpace.s16,
              PantasLayout.reserveBar,
            ),
            children: [
              // QV_EndPro: an X at x 19, y 17 closes the page like Done; the
              // title then starts at y 58.
              SizedBox(
                height: PantasSize.btnBar,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: const Offset(-8, 4),
                    child: PantasIconButton(
                      tooltip: 'Done',
                      onPressed: _nextBusy ? null : widget.onDone,
                      glyph: PantasIcons.close,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PantasSpace.s10),
              _appear(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session finished.',
                      style: PantasType.phoneTitle1.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (source != null) ...[
                      const SizedBox(height: PantasSpace.s2),
                      Text(
                        source,
                        style:
                            type.subhead.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
                100,
                380,
                rise: 6,
              ),
              const SizedBox(height: PantasSpace.s20),
              Padding(
                padding: const EdgeInsets.only(
                  top: PantasSpace.s6,
                  bottom: PantasSpace.s2,
                ),
                child: Column(
                  children: [
                    HalfRingGauge.quizCount(correct: correct, total: total),
                    const SizedBox(height: PantasSpace.s18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (var i = 0; i < total; i++) _circle(i)],
                    ),
                    if (durationLine != null) ...[
                      const SizedBox(height: PantasSpace.s10),
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
                const SizedBox(height: PantasSpace.s20),
                widget.debriefCards!,
              ],
              if (misses.isNotEmpty) ...[
                const SizedBox(height: PantasSpace.s20),
                _appear(
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          PantasSpace.s16,
                          PantasSpace.s0,
                          PantasSpace.s16,
                          PantasSpace.s6,
                        ),
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
                                    ContentRenderer.plainText(
                                      widget.session.questions[index].stem,
                                    ),
                                titleWidget: widget.session.questions[index]
                                            .shortLabel ==
                                        null
                                    ? PantasTooltip(
                                        message: ContentRenderer.plainText(
                                          widget.session.questions[index].stem,
                                        ),
                                        child: DefaultTextStyle(
                                          style: type.body,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          child: MathText(
                                            ContentRenderer.plainText(
                                              widget.session.questions[index]
                                                  .stem,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                    : null,
                                subtitle: widget.subjectNames[
                                    widget.session.questions[index].topicId],
                                leading: Icon(
                                  PantasIcons.close,
                                  size: 22,
                                  color: colors.dangerText,
                                ),
                                divider: position < misses.take(3).length - 1 ||
                                    misses.length > 3,
                                onTap: () =>
                                    (widget.onMistake ?? widget.onQuestion)(
                                  index,
                                ),
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
              const SizedBox(height: PantasSpace.s20),
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
                const SizedBox(height: PantasSpace.s20),
                _appear(
                  Container(
                    padding: const EdgeInsets.all(PantasSpace.s16),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(PantasRadius.lg),
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
                                  color: colors.textPrimary,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: PantasSpace.s12),
                              PantasButton(
                                label: 'Finish the Notes',
                                variant: PantasButtonVariant.secondary,
                                height: PantasSize.btn,
                                radius: PantasRadius.full,
                                fontSize: PantasType.webLink.fontSize,
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
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s14,
                PantasSpace.s16,
                PantasSpace.s20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [
                    0,
                    .26,
                  ],
                  colors: [
                    colors.bgPage.withValues(alpha: 0),
                    colors.bgPage,
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
                      const SizedBox(height: PantasSpace.s4),
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
