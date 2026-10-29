// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/placeholder_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Mock exam')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Text(
              _simulationTitle(blueprint),
              style: type.pageTitleCompact,
            ),
            const SizedBox(height: 5),
            Text(
              '$plannedTotal total items · ${_duration(blueprint.durationMinutes)}',
              style: type.subhead.copyWith(color: colors.secondaryLabel),
            ),
            const SizedBox(height: 26),
            _SetupTable(
              sections: sections,
              isSectional: isSectional,
              total: plannedTotal,
              durationMinutes: blueprint.durationMinutes,
            ),
            const SizedBox(height: 24),
            Text(
              _paperRule(blueprint),
              style: type.subhead.copyWith(height: 1.5),
            ),
            if (blueprint.unscoredItems != null) ...[
              const SizedBox(height: 10),
              Text(
                'The real exam also has ${blueprint.unscoredItems} '
                'personal-information items. They are not scored, so this '
                'mock leaves them out.',
                style: type.subhead.copyWith(color: colors.secondaryLabel),
              ),
            ],
            if (actualTotal != null && actualTotal < plannedTotal) ...[
              const SizedBox(height: 10),
              Text(
                'This mock has $actualTotal questions instead of $plannedTotal.',
                style: type.subhead.copyWith(color: colors.secondaryLabel),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Strict mode', style: type.emphasized),
                      const SizedBox(height: 4),
                      Text(
                        'For this mock only',
                        style: type.footnote
                            .copyWith(color: colors.secondaryLabel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PantasSwitch(
                  value: _strictMode,
                  label: 'Strict mode for this mock',
                  onChanged: (value) => setState(() => _strictMode = value),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _strictMode
                  ? 'No pausing and no ending a section early. Leaving the app '
                      'instantly ends and submits your answers, finished or not '
                      'finished.'
                  : 'Closest to the real exam. Turn it on when you can take the '
                      'whole mock without interruptions.',
              style: type.subhead.copyWith(
                color: colors.secondaryLabel,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            PantasButton(
              label: 'Start the Mock Exam',
              onPressed: () => widget.onStart(_strictMode),
            ),
            const SizedBox(height: 8),
            Text(
              'The clock starts when you tap.',
              textAlign: TextAlign.center,
              style: type.footnote.copyWith(color: colors.secondaryLabel),
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
        WebCard(
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
        const SingleActivator(LogicalKeyboardKey.enter): () =>
            widget.onStart(_strictMode),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: ListView(
            key: const ValueKey('web-mock-setup'),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Quiz'),
                ),
              ),
              Text(_simulationTitle(blueprint), style: t.h1),
              const SizedBox(height: 6),
              Text(
                '$total total items · ${_duration(blueprint.durationMinutes)}',
                style: t.style(17, color: t.colors.secondaryLabel),
              ),
              const SizedBox(height: 28),
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
      switch (blueprint.examId) {
        'exam_upcat' => 'UPCAT simulation',
        'exam_dlsucet' => 'DCAT simulation',
        'exam_cse_pro' => 'CSE Professional simulation',
        'exam_cse_sub' => 'CSE Subprofessional simulation',
        'exam_acet' => 'ACET simulation',
        _ => '${blueprint.name.replaceAll(' Practice Paper', '')} simulation',
      };

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
