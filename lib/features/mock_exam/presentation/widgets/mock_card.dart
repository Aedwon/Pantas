import 'package:flutter/material.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Board QZ_Free wording for the wait between Free mocks.
String freeMockIntervalLine(int days) =>
    'Free includes one mock every $days days.';

/// Days between Free mocks on the web, where the server owns the rule. The
/// phone keeps its own 14, so [MockCardModel.freeIntervalDays] defaults to it.
const freeMockIntervalDaysWeb = 30;

/// A server date arrives in UTC. The student reads their own calendar, so the
/// card converts before it prints (a mock taken at 01:50 on Nov 5 in Manila
/// is Nov 4 in UTC).
String mockNextOpensLine(DateTime opens) =>
    'Your next one opens ${PantasDates.withWeekday(opens.toLocal())}.';

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
    final titleStyle =
        PantasType.phoneTitle3.copyWith(color: context.colors.textPrimary);
    final duration = model.durationMinutes;
    final header = _TitleRow(
      name: model.name,
      duration: duration == null ? null : _duration(duration),
      titleStyle: titleStyle,
      durationStyle:
          type.subhead.copyWith(color: context.colors.secondaryLabel).tabular,
      gap: 8,
      maxLines: 1,
      forceStacked: MediaQuery.textScalerOf(context).scale(20) > 26,
    );
    final nextOpens =
        state == MockCardState.waiting && model.nextOpensAt != null
            ? ' ${mockNextOpensLine(model.nextOpensAt!)}'
            : '';
    final rule = model.pro
        ? "You're on Pro. Take as many mocks as you like."
        : '${freeMockIntervalLine(model.freeIntervalDays)}$nextOpens';
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
    if (context.wideWeb) {
      final t = context.webTokens;
      final (label, callback) = switch (state) {
        MockCardState.neverTaken ||
        MockCardState.ready ||
        MockCardState.customReady =>
          ('Take the Exam', onTake),
        MockCardState.waiting => ('View Last Results', onViewResults),
        MockCardState.inProgress => ('Resume', onResume),
        MockCardState.customUnset => ('Set One Up', onSetUp),
        _ => ('Take the Exam', null),
      };
      Widget history(String value, String caption, {String? unit}) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PantasSpace.s16,
                vertical: PantasSpace.s14,
              ),
              decoration: BoxDecoration(
                color: t.colors.background,
                borderRadius: BorderRadius.circular(PantasRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: PantasSpace.s32,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: PantasType.phoneLargeTitle.copyWith(
                            color: t.colors.textPrimary,
                            height: 1,
                          ),
                        ),
                        if (unit != null)
                          Text(
                            unit,
                            style: PantasType.webLead.copyWith(
                              color: t.colors.secondaryLabel,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s6),
                  Text(caption, style: t.sm),
                ],
              ),
            ),
          );
      return _rise(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WebText('Mock exam', kind: WebTextKind.eyebrow),
            WebCard(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s24,
                PantasSpace.s24,
                PantasSpace.s24,
                PantasSpace.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleRow(
                    name: model.name,
                    duration: duration == null ? null : _duration(duration),
                    titleStyle: PantasType.webH3Lg
                        .copyWith(color: t.colors.textPrimary),
                    durationStyle: t.sub,
                    gap: 12,
                  ),
                  if ((state == MockCardState.ready ||
                          state == MockCardState.waiting) &&
                      (model.lastPercent != null ||
                          model.lastAttemptAt != null)) ...[
                    const SizedBox(height: PantasSpace.s24),
                    Row(
                      children: [
                        if (model.lastPercent != null)
                          history(
                            '${model.lastPercent!.round()}',
                            'Last score',
                            unit: '%',
                          ),
                        if (model.lastPercent != null &&
                            model.lastAttemptAt != null)
                          const SizedBox(width: PantasSpace.s12),
                        if (model.lastAttemptAt != null)
                          history(
                            PantasDates.short(model.lastAttemptAt!.toLocal()),
                            'Last attempt',
                          ),
                      ],
                    ),
                  ],
                  if (body != null) ...[
                    const SizedBox(height: PantasSpace.s24),
                    Text(
                      body,
                      style: PantasType.webBody
                          .copyWith(color: t.colors.textPrimary, height: 1.45),
                    ),
                  ],
                  if (state != MockCardState.quizPaused &&
                      state != MockCardState.unavailable) ...[
                    const SizedBox(height: PantasSpace.s24),
                    if (model.proPaused)
                      const ProPausedLine()
                    else
                      Text(rule, style: t.sub),
                  ],
                  const SizedBox(height: PantasSpace.s24),
                  _MockActionButton(
                    label: label,
                    onPressed: callback,
                    outlined: state == MockCardState.waiting,
                  ),
                  if (state == MockCardState.customReady &&
                      onChangeSetup != null)
                    WebButton(
                      label: 'Change the Setup',
                      onPressed: onChangeSetup,
                      variant: WebButtonVariant.tertiary,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
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
          padding: const EdgeInsets.only(
            top: PantasSpace.s6,
            bottom: PantasSpace.s2,
          ),
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
            padding: const EdgeInsets.all(PantasSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: PantasSpace.s12),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
    return _rise(context, content);
  }
}

/// QZ_Tab/Free/Resume/First: hold to 190 ms, rise 12 px through 640 ms.
/// Phone and wide web share it.
Widget _rise(BuildContext context, Widget content) =>
    TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 640),
      child: content,
      builder: (context, value, child) {
        final progress = MediaQuery.disableAnimationsOf(context)
            ? 1.0
            : PantasCurves.house
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

/// Board `.btn2` / `.btnw` at card width: the system's large Button, the
/// secondary kind or the white one.
class _MockActionButton extends StatelessWidget {
  const _MockActionButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) => WebButton(
        label: label,
        onPressed: onPressed,
        kind: outlined ? PantasButtonKind.white : PantasButtonKind.secondary,
        size: PantasButtonSize.lg,
        expand: true,
      );
}

class _History extends StatelessWidget {
  const _History({required this.model});
  final MockCardModel model;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final figure = PantasType.phoneTitle1
        .copyWith(color: context.colors.textPrimary)
        .tabular;
    Widget column(Widget value, String label) => Column(
          children: [
            value,
            const SizedBox(height: PantasSpace.s2),
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
              const SizedBox(width: PantasSpace.s2),
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
          Text(
            PantasDates.short(model.lastAttemptAt!.toLocal()),
            style: figure,
          ),
          'Last attempt',
        ),
    ];
    return MediaQuery.textScalerOf(context).scale(28) > 36
        ? Column(
            children: [
              for (var i = 0; i < columns.length; i++) ...[
                if (i > 0) const SizedBox(height: PantasSpace.s12),
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

/// The mock's name with its length beside it. The length stays beside the name
/// while both fit on one line. When they do not, the length goes under the name
/// so the name keeps its single line instead of wrapping or being cut.
class _TitleRow extends StatelessWidget {
  const _TitleRow({
    required this.name,
    required this.duration,
    required this.titleStyle,
    required this.durationStyle,
    required this.gap,
    this.maxLines,
    this.forceStacked = false,
  });
  final String name;
  final String? duration;
  final TextStyle titleStyle;
  final TextStyle durationStyle;
  final double gap;
  final int? maxLines;
  final bool forceStacked;

  @override
  Widget build(BuildContext context) {
    final length = duration;
    Widget title() => Text(
          name,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          style: titleStyle,
        );
    if (length == null) return title();
    return LayoutBuilder(
      builder: (context, constraints) {
        final base = DefaultTextStyle.of(context).style;
        double width(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: base.merge(style)),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();
          final measured = painter.width;
          painter.dispose();
          return measured;
        }

        final fits = !forceStacked &&
            width(name, titleStyle) + gap + width(length, durationStyle) <=
                constraints.maxWidth;
        if (!fits) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title(), Text(length, style: durationStyle)],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: title()),
            SizedBox(width: gap),
            Text(length, style: durationStyle),
          ],
        );
      },
    );
  }
}

/// Board QuizMock "New": what the web's mock card says to a student with no
/// named account, since the server only runs mocks for a named account.
class MockSignUpCard extends StatelessWidget {
  const MockSignUpCard({required this.onCreateAccount, super.key});

  final VoidCallback onCreateAccount;

  static const _title = 'Take a timed mock';
  static const _message =
      'Create a free account to take a mock and keep your results.';

  @override
  Widget build(BuildContext context) {
    final note = freeMockIntervalLine(freeMockIntervalDaysWeb);
    final button = _CreateAccountButton(onPressed: onCreateAccount);
    if (context.wideWeb) {
      final t = context.webTokens;
      return _rise(
        context,
        Semantics(
          key: const ValueKey('mock-signup-card'),
          container: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WebText('Mock exam', kind: WebTextKind.eyebrow),
              WebCard(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s24,
                  PantasSpace.s24,
                  PantasSpace.s24,
                  PantasSpace.s24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _title,
                      style: PantasType.webH3Lg.copyWith(
                        color: t.colors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: PantasSpace.s24),
                    Text(
                      _message,
                      style: PantasType.webBody.copyWith(
                        color: t.colors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: PantasSpace.s24),
                    Text(note, style: t.sub),
                    const SizedBox(height: PantasSpace.s24),
                    button,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    final type = context.type;
    final secondary = context.colors.secondaryLabel;
    final lines = <Widget>[
      Text(
        _title,
        style: PantasType.phoneTitle3.copyWith(
          color: context.colors.textPrimary,
          height: 1.3,
        ),
      ),
      Text(
        _message,
        style: type.subhead.copyWith(color: secondary, height: 1.4),
      ),
      Text(note, style: type.footnote.copyWith(height: 1.4)),
      button,
    ];
    return _rise(
      context,
      Semantics(
        key: const ValueKey('mock-signup-card'),
        container: true,
        child: GroupedSection(
          header: 'MOCK EXAM',
          children: [
            Padding(
              padding: const EdgeInsets.all(PantasSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < lines.length; i++) ...[
                    if (i > 0) const SizedBox(height: PantasSpace.s12),
                    lines[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Board `.gb`: the sign-in button, the system's large primary Button.
class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => context.wideWeb
      // No full-width buttons on wide screens (HANDOFF hard rule, Button
      // README): the button keeps its natural width.
      ? Align(
          alignment: Alignment.centerLeft,
          child: WebButton(
            label: 'Create Free Account',
            onPressed: onPressed,
            size: PantasButtonSize.lg,
          ),
        )
      : PantasButton(
          label: 'Create Free Account',
          onPressed: onPressed,
          height: PantasSize.btnLg,
        );
}
