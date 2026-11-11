// ignore_for_file: lines_longer_than_80_chars

import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/data_table.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/placeholder_figure.dart';
import 'package:pantas/core/ui/components/row_tap_target.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/domain/mock_title.dart';

class MockSetupPage extends StatefulWidget {
  const MockSetupPage({
    required this.parsedBlueprint,
    required this.onStart,
    this.initialStrictMode = false,
    this.actualQuestionCount,
    super.key,
  });

  final ParsedMockBlueprint parsedBlueprint;
  final bool initialStrictMode;
  final int? actualQuestionCount;
  final ValueChanged<bool> onStart;

  @override
  State<MockSetupPage> createState() => _MockSetupPageState();
}

class _MockSetupPageState extends State<MockSetupPage> {
  late bool _strictMode;

  @override
  void initState() {
    super.initState();
    _strictMode = widget.initialStrictMode;
  }

  @override
  Widget build(BuildContext context) {
    final blueprint = widget.parsedBlueprint.blueprint;
    final sections = widget.parsedBlueprint.sections;
    final isSectional = blueprint.sectionalTiming == SectionalTiming.sectional;
    final plannedTotal = blueprint.totalPublishedItems ??
        sections.fold<int>(0, (sum, section) => sum + section.questionCount);
    final actualTotal = widget.actualQuestionCount;
    final type = context.type;
    final colors = context.colors;

    if (context.wideWeb) return _wide(context, plannedTotal, isSectional);

    // MK_SetupCSE and MK_SetupStrict: a green "< Quiz" link, a white table
    // card, a white strict-mode card and a Start button pinned to the bottom.
    final table = _SetupTable(sections: sections, sectional: isSectional);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // MK_SetupCSE: the link row is 44 px under 6 px of padding, so
                // its text sits 6 px lower than a bare 44 px row.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s4,
                    PantasSpace.s6,
                    PantasSpace.s8,
                    PantasSpace.s0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => leavePage(context, fallback: '/quiz'),
                      child: Semantics(
                        button: true,
                        label: 'Quiz',
                        excludeSemantics: true,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PantasIcons.back,
                                size: 24,
                                color: colors.accent,
                              ),
                              const SizedBox(width: PantasSpace.s2),
                              Text(
                                'Quiz',
                                style: type.body.copyWith(color: colors.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      PantasSpace.s16,
                      PantasSpace.s8,
                      PantasSpace.s16,
                      PantasLayout.reserveBar,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PantasSpace.s4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _simulationTitle(blueprint),
                              style: type.pageTitle,
                            ),
                            const SizedBox(height: PantasSpace.s4),
                            Text(
                              '$plannedTotal total items · ${_duration(blueprint.durationMinutes)}',
                              style: PantasType.phoneCallout.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: PantasSpace.s24),
                      table,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          PantasSpace.s16,
                          PantasSpace.s8,
                          PantasSpace.s16,
                          PantasSpace.s0,
                        ),
                        child: Text(
                          _paperRule(blueprint),
                          style: type.footnote.copyWith(
                            color: colors.secondaryLabel,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (blueprint.unscoredItems != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            PantasSpace.s16,
                            PantasSpace.s6,
                            PantasSpace.s16,
                            PantasSpace.s0,
                          ),
                          child: Text(
                            'The real exam also has ${blueprint.unscoredItems} '
                            'personal-information items. They are not scored, so this '
                            'mock leaves them out.',
                            style: type.footnote.copyWith(
                              color: colors.secondaryLabel,
                              height: 1.4,
                            ),
                          ),
                        ),
                      if (actualTotal != null && actualTotal < plannedTotal)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            PantasSpace.s16,
                            PantasSpace.s6,
                            PantasSpace.s16,
                            PantasSpace.s0,
                          ),
                          child: Text(
                            'This mock has $actualTotal questions instead of $plannedTotal.',
                            style: type.footnote.copyWith(
                              color: colors.secondaryLabel,
                              height: 1.4,
                            ),
                          ),
                        ),
                      const SizedBox(height: PantasSpace.s24),
                      RowTapTarget(
                        onTap: () => setState(() => _strictMode = !_strictMode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PantasSpace.s16,
                            vertical: PantasSpace.s12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius:
                                BorderRadius.circular(PantasRadius.lg),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Strict mode', style: type.body),
                                    const SizedBox(height: PantasSpace.s2),
                                    Text(
                                      _strictMode
                                          ? 'No pausing and no ending a section early. Leaving the app '
                                              'instantly ends and submits your answers, finished or not '
                                              'finished.'
                                          : 'Closest to the real exam. Turn it on when you can take the '
                                              'whole mock without interruptions.',
                                      style: type.footnote.copyWith(
                                        color: colors.secondaryLabel,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: PantasSpace.s12),
                              PantasSwitch(
                                value: _strictMode,
                                label: 'Strict mode for this mock',
                                onChanged: (value) =>
                                    setState(() => _strictMode = value),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  PantasSpace.s32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, .26],
                    colors: [
                      colors.background.withValues(alpha: 0),
                      colors.background,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PantasButton(
                      label: 'Start the Mock Exam',
                      onPressed: () => widget.onStart(_strictMode),
                    ),
                    const SizedBox(height: PantasSpace.s8),
                    Text(
                      'The clock starts when you tap.',
                      textAlign: TextAlign.center,
                      style:
                          type.footnote.copyWith(color: colors.secondaryLabel),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wide(BuildContext context, int total, bool sectional) {
    final t = context.webTokens;
    final blueprint = widget.parsedBlueprint.blueprint;
    final table = _SetupTable(
      sections: widget.parsedBlueprint.sections,
      sectional: sectional,
    );
    final rules = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        table,
        const SizedBox(height: PantasSpace.s16),
        Text(_paperRule(blueprint), style: t.sub),
        if (blueprint.unscoredItems != null)
          Padding(
            padding: const EdgeInsets.only(top: PantasSpace.s10),
            child: Text(
              'The real exam also has ${blueprint.unscoredItems} personal-information items. They are not scored, so this mock leaves them out.',
              style: t.sub,
            ),
          ),
        if (widget.actualQuestionCount != null &&
            widget.actualQuestionCount! < total)
          Padding(
            padding: const EdgeInsets.only(top: PantasSpace.s10),
            child: Text(
              'This mock has ${widget.actualQuestionCount} questions instead of $total.',
              style: t.sub,
            ),
          ),
      ],
    );
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RowTapTarget(
          onTap: () => setState(() => _strictMode = !_strictMode),
          child: WebCard(
            padding: const EdgeInsets.all(PantasSpace.s20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strict mode',
                        style: PantasType.webLead.copyWith(
                          color: t.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: PantasSpace.s4),
                      Text(
                        _strictMode
                            ? 'No pausing and no ending a section early. Leaving the app instantly ends and submits your answers, finished or not finished.'
                            : 'Closest to the real exam. Turn it on when you can take the whole mock without interruptions.',
                        style: t.sub,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PantasSpace.s16),
                PantasSwitch(
                  value: _strictMode,
                  label: 'Strict mode for this mock',
                  onChanged: (value) => setState(() => _strictMode = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PantasSpace.s16),
        // MK_SetupCSE: the button fills the right column and the line under
        // it is centered.
        WebButton(
          label: 'Start the Mock Exam',
          large: true,
          expand: true,
          keyHint: 'Enter',
          onPressed: () => widget.onStart(_strictMode),
        ),
        const SizedBox(height: PantasSpace.s8),
        Center(
          child: Text(
            'The clock starts when you click.',
            textAlign: TextAlign.center,
            style: t.sm,
          ),
        ),
      ],
    );
    return Focus(
      onKeyEvent: enterKeyHandler(() => widget.onStart(_strictMode)),
      autofocus: true,
      child: Scaffold(
        body: ListView(
          key: const ValueKey('web-mock-setup'),
          padding: EdgeInsets.only(bottom: context.webPageBottomInset),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: const Offset(-6, 0),
                child: WebBackLink(
                  label: 'Quiz',
                  onPressed: () => leavePage(context, fallback: '/quiz'),
                  nudge: false,
                ),
              ),
            ),
            const SizedBox(height: PantasSpace.s6),
            Text(_simulationTitle(blueprint), style: t.h1),
            const SizedBox(height: PantasSpace.s6),
            Text(
              '$total total items · ${_duration(blueprint.durationMinutes)}',
              style:
                  PantasType.webLead.copyWith(color: t.colors.secondaryLabel),
            ),
            const SizedBox(height: PantasSpace.s28),
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth < 820
                  ? Column(
                      children: [
                        rules,
                        const SizedBox(height: PantasSpace.s24),
                        controls,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 14, child: rules),
                        const SizedBox(width: PantasSpace.s24),
                        Expanded(flex: 10, child: controls),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _simulationTitle(MockBlueprint blueprint) =>
      mockSimulationTitle(blueprint.examId, blueprint.name);

  String _paperRule(MockBlueprint blueprint) {
    final base = switch (blueprint.sectionalTiming) {
      SectionalTiming.sectional =>
        "This paper runs part by part. Once a part ends, you can't go back to it.",
      SectionalTiming.roamable =>
        "This paper runs as one block. You can move around the whole paper and submit when you're done.",
      null =>
        'We do not know yet whether this exam runs part by part. This mock lets you move around the whole paper.',
    };
    return switch (blueprint.examId) {
      'exam_dlsucet' =>
        '$base Not included: the essay and the personality test. This mock covers the multiple-choice parts only.',
      'exam_acet' =>
        '$base Not included: the essay. This mock covers the multiple-choice parts only.',
      _ => base,
    };
  }

  String _duration(int minutes) {
    if (minutes <= 0) return 'Untimed';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder min';
    if (remainder == 0) return '$hours hr';
    return '$hours hr $remainder min';
  }
}

/// The section table: Section, Items and (for a sectional paper) Time, on the
/// system DataTable. A figure that is still a development placeholder keeps
/// its [PlaceholderFigure] and prints its bare value, as it did before.
class _SetupTable extends StatelessWidget {
  const _SetupTable({required this.sections, required this.sectional});
  final List<BlueprintSection> sections;
  final bool sectional;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    Object? figure(BlueprintValue? figure, int? value, {String suffix = ''}) {
      if (value == null) return null;
      if (figure?.isPlaceholder ?? false) {
        final painter = TextPainter(
          text: TextSpan(text: '$value', style: PantasType.webBody),
          textDirection: direction,
          textScaler: scaler,
        )..layout();
        final width = painter.width;
        painter.dispose();
        return PantasTableCell.widget(
          PlaceholderFigure(value, reason: figure!.placeholderNote!),
          width: width,
          semanticLabel: '$value',
        );
      }
      return '$value$suffix';
    }

    return PantasDataTable(
      columns: [
        const PantasTableColumn('Section'),
        const PantasTableColumn('Items', numeric: true),
        if (sectional) const PantasTableColumn('Time', numeric: true),
      ],
      rows: [
        for (final section in sections)
          [
            section.name,
            figure(section.questionCountFigure, section.questionCount),
            if (sectional)
              figure(
                section.sectionalMinutesFigure,
                section.sectionalMinutes,
                suffix: ' min',
              ),
          ],
      ],
    );
  }
}

class MockSetupPlaceholderPage extends StatelessWidget {
  const MockSetupPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock exam')),
      body: Center(
        child: Text(
          'Choose a mock blueprint',
          style: context.type.subhead
              .copyWith(color: context.colors.secondaryLabel),
        ),
      ),
    );
  }
}
