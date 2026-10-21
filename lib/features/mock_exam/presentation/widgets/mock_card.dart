import 'package:flutter/material.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

enum MockCardState {
  neverTaken,
  ready,
  waiting,
  inProgress,
  quizPaused,
  customUnset,
  customReady,
  unavailable,
}

/// W4d supplies the active exam's availability and measured paper/history data.
@immutable
class MockCardModel {
  const MockCardModel({
    required this.state,
    required this.name,
    this.durationMinutes,
    this.pro = false,
    this.freeIntervalDays = 14,
    this.proPaused = false,
    this.lastPercent,
    this.lastAttemptAt,
    this.nextOpensAt,
    this.customQuestions,
  });

  final MockCardState state;

  /// Listed exam: "<exam> simulation". Custom track: the student's track name.
  final String name;
  final int? durationMinutes;
  final bool pro;
  final int freeIntervalDays;
  final bool proPaused;

  /// Score percentages use 0 to 100, including UPCAT's deduction.
  final double? lastPercent;
  final DateTime? lastAttemptAt;
  final DateTime? nextOpensAt;
  final int? customQuestions;
}

class MockCard extends StatelessWidget {
  const MockCard({
    required this.model,
    this.onTake,
    this.onResume,
    this.onViewResults,
    this.onSetUp,
    this.onChangeSetup,
    super.key,
  });

  final MockCardModel model;
  final VoidCallback? onTake;
  final VoidCallback? onResume;
  final VoidCallback? onViewResults;
  final VoidCallback? onSetUp;
  final VoidCallback? onChangeSetup;

  @override
  Widget build(BuildContext context) {
    final state = model.state;
    final type = context.type;
    final title = Text(
      model.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: type.body.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -.24,
      ),
    );
    final duration = model.durationMinutes;
    final durationLabel = duration == null
        ? null
        : Text(
            _duration(duration),
            style: type.subhead
                .copyWith(color: context.colors.secondaryLabel)
                .tabular,
          );
    final header = MediaQuery.textScalerOf(context).scale(20) > 26
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (durationLabel != null) durationLabel,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: title),
              if (durationLabel != null) ...[
                const SizedBox(width: 8),
                durationLabel,
              ],
            ],
          );
    final nextOpens =
        state == MockCardState.waiting && model.nextOpensAt != null
            ? ' Your next one opens '
                '${PantasDates.withWeekday(model.nextOpensAt!)}.'
            : '';
    final rule = model.pro
        ? "You're on Pro. Take as many mocks as you like."
        : 'Free includes one mock every '
            '${model.freeIntervalDays} days.$nextOpens';
    final body = switch (state) {
      MockCardState.neverTaken => 'The whole exam under real timing. '
          'Test yourself on how you do under time pressure.',
      MockCardState.quizPaused => 'Finish your quiz session first.',
      MockCardState.customUnset =>
        'You can build your own mock exam. Tell us how many questions '
            "and how long it runs, and we'll set it up for you.",
      MockCardState.customReady =>
        '${model.customQuestions} questions, ${_customDuration(duration!)}. '
            'You set this up.',
      MockCardState.unavailable => 'This exam has no mock paper ready yet.',
      _ => null,
    };
    Widget? action(String label, VoidCallback? callback) => callback == null
        ? null
        : PantasButton(
            label: label,
            onPressed: callback,
            variant: PantasButtonVariant.secondary,
            height: 48,
          );
    final primary = switch (state) {
      MockCardState.neverTaken ||
      MockCardState.ready ||
      MockCardState.customReady =>
        action('Take the Exam', onTake),
      MockCardState.waiting => action('View Last Results', onViewResults),
      MockCardState.inProgress => action('Resume', onResume),
      MockCardState.customUnset => action('Set one up', onSetUp),
      MockCardState.quizPaused || MockCardState.unavailable => null,
    };
    final children = <Widget>[
      header,
      if (body != null)
        Text(
          body,
          style: type.subhead
              .copyWith(color: context.colors.secondaryLabel, height: 1.4),
        ),
      if ((state == MockCardState.ready || state == MockCardState.waiting) &&
          (model.lastPercent != null || model.lastAttemptAt != null))
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: _History(model: model),
        ),
      if (state != MockCardState.quizPaused &&
          state != MockCardState.unavailable)
        if (model.proPaused)
          const ProPausedLine()
        else
          Text(rule, style: type.footnote.copyWith(height: 1.4)),
      if (state == MockCardState.customReady && onChangeSetup != null)
        PantasButton(
          label: 'Change the setup',
          onPressed: onChangeSetup,
          variant: PantasButtonVariant.tertiary,
          height: 44,
        ),
      if (primary != null) primary,
    ];
    final content = Semantics(
      key: const ValueKey('mock-card-state'),
      liveRegion: true,
      container: true,
      child: GroupedSection(
        header: 'MOCK EXAM',
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
    // QZ_Tab/Free/Resume/First: hold to 190 ms, rise 12 px through 640 ms.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 640),
      child: content,
      builder: (context, value, child) {
        final progress = MediaQuery.disableAnimationsOf(context)
            ? 1.0
            : PantasCurves.houseOut
                .transform(((value * 640 - 190) / 450).clamp(0.0, 1.0));
        return ExcludeFocus(
          excluding: progress == 0,
          child: Transform.translate(
            key: const ValueKey('mock-card-rise'),
            offset: Offset(0, 12 * (1 - progress)),
            child: Opacity(
              key: const ValueKey('mock-card-opacity'),
              opacity: progress,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.model});
  final MockCardModel model;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final figure = type.pageTitle
        .copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.12,
          letterSpacing: -.56,
        )
        .tabular;
    Widget column(Widget value, String label) => Column(
          children: [
            value,
            const SizedBox(height: 2),
            Text(label, style: type.footnote),
          ],
        );
    final columns = <Widget>[
      if (model.lastPercent != null)
        column(
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${model.lastPercent!.round()}', style: figure),
              const SizedBox(width: 1),
              Text(
                '%',
                style: type.subheadStrong
                    .copyWith(color: context.colors.secondaryLabel),
              ),
            ],
          ),
          'Last score',
        ),
      if (model.lastAttemptAt != null)
        column(
          Text(PantasDates.short(model.lastAttemptAt!), style: figure),
          'Last attempt',
        ),
    ];
    return MediaQuery.textScalerOf(context).scale(28) > 36
        ? Column(
            children: [
              for (var i = 0; i < columns.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                columns[i],
              ],
            ],
          )
        : Row(
            children: [for (final column in columns) Expanded(child: column)],
          );
  }
}

String _duration(int minutes) => minutes < 60
    ? '$minutes min'
    : minutes % 60 == 0
        ? '${minutes ~/ 60} hr'
        : '${minutes ~/ 60} hr ${minutes % 60} min';

String _customDuration(int minutes) => minutes < 60
    ? '$minutes minutes'
    : minutes % 60 == 0
        ? '${minutes ~/ 60} ${minutes == 60 ? 'hour' : 'hours'}'
        : '${minutes ~/ 60}h ${minutes % 60}m';
