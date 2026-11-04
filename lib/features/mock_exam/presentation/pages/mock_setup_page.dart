// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/placeholder_figure.dart';
import 'package:pantas/core/ui/components/row_tap_target.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
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
    final table = _SetupTable(
      sections: sections,
      isSectional: isSectional,
      total: plannedTotal,
      durationMinutes: blueprint.durationMinutes,
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // MK_SetupCSE: the link row is 44 px under 6 px of padding, so
                // its text sits 6 px lower than a bare 44 px row.
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 8, 0),
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
                                const SizedBox(width: 2),
                                Text(
                                  'Quiz',
                                  style:
                                      type.body.copyWith(color: colors.accent),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _simulationTitle(blueprint),
                              style: type.pageTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$plannedTotal total items · ${_duration(blueprint.durationMinutes)}',
                              style: type.body.copyWith(
                                fontSize: 16,
                                color: colors.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: table.card(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
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
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
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
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                          child: Text(
                            'This mock has $actualTotal questions instead of $plannedTotal.',
                            style: type.footnote.copyWith(
                              color: colors.secondaryLabel,
                              height: 1.4,
                            ),
                          ),
                        ),
                      const SizedBox(height: 22),
                      RowTapTarget(
                        onTap: () => setState(() => _strictMode = !_strictMode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Strict mode', style: type.body),
                                    const SizedBox(height: 2),
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
                              const SizedBox(width: 12),
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
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
                    const SizedBox(height: 8),
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
    final table = WebCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text('SECTION', style: t.eb)),
                SizedBox(
                  width: 90,
                  child: Text('ITEMS', textAlign: TextAlign.right, style: t.eb),
                ),
                if (sectional)
                  SizedBox(
                    width: 90,
                    child:
                        Text('TIME', textAlign: TextAlign.right, style: t.eb),
                  ),
              ],
            ),
          ),
          for (final section in widget.parsedBlueprint.sections)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: t.colors.separator, width: .5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(section.name, style: t.style(17))),
                  SizedBox(
                    width: 90,
                    child: _SetupTable(
                      sections: const [],
                      isSectional: sectional,
                      total: total,
                      durationMinutes: blueprint.durationMinutes,
                    )._figure(
                      context,
                      section.questionCountFigure,
                      section.questionCount,
                    ),
                  ),
                  if (sectional)
                    SizedBox(
                      width: 90,
                      child: _SetupTable(
                        sections: const [],
                        isSectional: sectional,
                        total: total,
                        durationMinutes: blueprint.durationMinutes,
                      )._figure(
                        context,
                        section.sectionalMinutesFigure,
                        section.sectionalMinutes,
                        suffix: ' min',
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
    final rules = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        table,
        const SizedBox(height: 16),
        Text(_paperRule(blueprint), style: t.sub),
        if (blueprint.unscoredItems != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'The real exam also has ${blueprint.unscoredItems} personal-information items. They are not scored, so this mock leaves them out.',
              style: t.sub,
            ),
          ),
        if (widget.actualQuestionCount != null &&
            widget.actualQuestionCount! < total)
          Padding(
            padding: const EdgeInsets.only(top: 10),
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
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strict mode',
                        style: t.style(17, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _strictMode
                            ? 'No pausing and no ending a section early. Leaving the app instantly ends and submits your answers, finished or not finished.'
                            : 'Closest to the real exam. Turn it on when you can take the whole mock without interruptions.',
                        style: t.sub,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                PantasSwitch(
                  value: _strictMode,
                  label: 'Strict mode for this mock',
                  onChanged: (value) => setState(() => _strictMode = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        WebButton(
          label: 'Start the Mock Exam',
          large: true,
          keyHint: 'Enter',
          onPressed: () => widget.onStart(_strictMode),
        ),
        const SizedBox(height: 8),
        Text('The clock starts when you click.', style: t.sm),
      ],
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.enter,
          includeRepeats: false,
        ): () => widget.onStart(_strictMode),
      },
      child: Focus(
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
                  child: TextButton.icon(
                    onPressed: () => leavePage(context, fallback: '/quiz'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: EdgeInsets.zero,
                      foregroundColor: t.colors.accent,
                      overlayColor: Colors.transparent,
                      visualDensity: VisualDensity.standard,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: t.style(17),
                    ),
                    icon: const Icon(Icons.chevron_left, size: 20),
                    label: const Text('Quiz'),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(_simulationTitle(blueprint), style: t.h1),
              const SizedBox(height: 6),
              Text(
                '$total total items · ${_duration(blueprint.durationMinutes)}',
                style: t.style(17, color: t.colors.secondaryLabel),
              ),
              const SizedBox(height: 26),
              LayoutBuilder(
                builder: (context, constraints) => constraints.maxWidth < 820
                    ? Column(
                        children: [
                          rules,
                          const SizedBox(height: 24),
                          controls,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 14, child: rules),
                          const SizedBox(width: 24),
                          Expanded(flex: 10, child: controls),
                        ],
                      ),
              ),
            ],
          ),
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

class _SetupTable extends StatelessWidget {
  const _SetupTable({
    required this.sections,
    required this.isSectional,
    required this.total,
    required this.durationMinutes,
  });

  final List<BlueprintSection> sections;
  final bool isSectional;
  final int total;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    return Column(
      children: [
        _TableRow(
          section: Text(
            'SECTION',
            style: type.sectionHeader.copyWith(color: colors.secondaryLabel),
          ),
          items: Text(
            'ITEMS',
            textAlign: TextAlign.end,
            style: type.sectionHeader.copyWith(color: colors.secondaryLabel),
          ),
          time: isSectional
              ? Text(
                  'TIME',
                  textAlign: TextAlign.end,
                  style:
                      type.sectionHeader.copyWith(color: colors.secondaryLabel),
                )
              : null,
        ),
        Divider(color: colors.separator, height: 16),
        for (final section in sections) ...[
          _TableRow(
            section: Text(section.name, style: type.subhead),
            items: _figure(
              context,
              section.questionCountFigure,
              section.questionCount,
            ),
            time: isSectional
                ? _figure(
                    context,
                    section.sectionalMinutesFigure,
                    section.sectionalMinutes,
                    suffix: ' min',
                  )
                : null,
          ),
          Divider(color: colors.separator, height: 16),
        ],
        _TableRow(
          section: Text('Total', style: type.subheadStrong),
          items: Text(
            '$total',
            textAlign: TextAlign.end,
            style: type.subheadStrong.tabular,
          ),
          time: isSectional
              ? Text(
                  _shortDuration(durationMinutes),
                  textAlign: TextAlign.end,
                  style: type.subheadStrong.tabular,
                )
              : null,
        ),
      ],
    );
  }

  /// The phone card: no Total row, 12 px caps header, 16 px rows (boards).
  Widget card(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    Widget row(
      Widget section,
      Widget items,
      Widget? time,
      EdgeInsets pad, {
      required bool line,
    }) {
      return Container(
        padding: pad,
        decoration: BoxDecoration(
          border: line
              ? Border(bottom: BorderSide(color: colors.separator, width: .5))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: section),
            SizedBox(width: 56, child: items),
            if (time != null) ...[
              const SizedBox(width: 8),
              SizedBox(width: 56, child: time),
            ],
          ],
        ),
      );
    }

    final caps = type.sectionHeader.copyWith(
      color: colors.secondaryLabel,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: .36,
    );
    final rowText = type.body.copyWith(fontSize: 16);
    return Column(
      children: [
        row(
          Text('SECTION', style: caps),
          Text('ITEMS', textAlign: TextAlign.end, style: caps),
          isSectional
              ? Text('TIME', textAlign: TextAlign.end, style: caps)
              : null,
          const EdgeInsets.fromLTRB(16, 10, 16, 8),
          line: true,
        ),
        for (var i = 0; i < sections.length; i++)
          row(
            Text(
              sections[i].name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: rowText,
            ),
            _phoneFigure(
              context,
              sections[i].questionCountFigure,
              sections[i].questionCount,
              rowText.copyWith(color: colors.secondaryLabel).tabular,
            ),
            isSectional
                ? _phoneFigure(
                    context,
                    sections[i].sectionalMinutesFigure,
                    sections[i].sectionalMinutes,
                    rowText.copyWith(color: colors.secondaryLabel).tabular,
                    suffix: ' min',
                  )
                : null,
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            line: i < sections.length - 1,
          ),
      ],
    );
  }

  Widget _phoneFigure(
    BuildContext context,
    BlueprintValue? figure,
    int? value,
    TextStyle style, {
    String suffix = '',
  }) {
    if (value == null) return const SizedBox.shrink();
    if (figure?.isPlaceholder ?? false) {
      return Align(
        alignment: Alignment.centerRight,
        child: PlaceholderFigure(value, reason: figure!.placeholderNote!),
      );
    }
    return Text('$value$suffix', textAlign: TextAlign.end, style: style);
  }

  Widget _figure(
    BuildContext context,
    BlueprintValue? figure,
    int? value, {
    String suffix = '',
  }) {
    if (value == null) return const SizedBox.shrink();
    if (figure?.isPlaceholder ?? false) {
      return Align(
        alignment: Alignment.centerRight,
        child: PlaceholderFigure(
          value,
          reason: figure!.placeholderNote!,
        ),
      );
    }
    return Text(
      '$value$suffix',
      textAlign: TextAlign.end,
      style: context.type.subhead.tabular,
    );
  }

  String _shortDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder min';
    if (remainder == 0) return '${hours}h';
    return '${hours}h ${remainder}m';
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.section,
    required this.items,
    this.time,
  });

  final Widget section;
  final Widget items;
  final Widget? time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: section),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: items),
        if (time != null) ...[
          const SizedBox(width: 10),
          Expanded(flex: 2, child: time!),
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
