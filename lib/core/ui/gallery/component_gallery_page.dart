import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/placeholder_figure.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class ComponentGalleryPage extends StatefulWidget {
  const ComponentGalleryPage({super.key});
  // Also drives the visible section order, not just the verification inventory.
  static const contractNames = [
    'GroupedSection',
    'ListRow',
    'PantasButton',
    'ButtonPair',
    'PantasSwitch',
    'SegmentedSwitch',
    'PantasPage',
    'ProgressRing',
    'CheckMark',
    'HalfRingGauge',
    'AccuracyBar',
    'WeekStrip',
    'SortCycleButton',
    'PantasSheet',
    'CenteredDialog',
    'Toast',
    'NoticeStrip',
    'FloatingBar',
    'QuestionGridSheet',
    'ValueWheel',
    'MonthFirstDatePicker',
    'ScopePicker',
    'SearchField',
    'Avatar',
    'LoadingShapes',
    'StepsScreen',
    'StateView',
    'ProTag',
    'ProPausedLine',
    'PlaceholderFigure',
    'QuestionCard',
    'ChoiceRow',
    'AnswerReveal',
    'PassageCard',
    'ContentRenderer',
    'MathText',
  ];
  @override
  State<ComponentGalleryPage> createState() => _ComponentGalleryPageState();
}

class _ComponentGalleryPageState extends State<ComponentGalleryPage> {
  bool _dark = false;
  bool _switch = true;
  int _segment = 0;
  SortCycleOrder _order = SortCycleOrder.weakest;
  bool _sheet = false;
  bool _bookmarks = false;
  bool _grid = false;
  bool _mock = false;
  bool _notice = false;
  int _wheel = 1;
  MonthFirstDate _date = const MonthFirstDate(year: 2026, month: 10);
  Set<String> _scope = {'equations'};
  DateTime? _day;
  ChoiceRowState _choice = ChoiceRowState.plain;
  String _toast = 'Flagged. Find it in the Quiz tab.';
  void noop() {}
  void dialog(BuildContext context, {required bool destructive}) {
    showDialog<void>(
      context: context,
      builder: (context) => CenteredDialog(
        title: destructive ? 'Discard this mock?' : 'Leave the quiz?',
        message: 'Your answers stay here.',
        primaryLabel: destructive ? 'Discard' : 'Keep going',
        secondaryLabel: 'Cancel',
        destructive: destructive,
        onConfirm: () => Navigator.of(context).pop(),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  Map<String, List<Widget>> samples(BuildContext context) {
    final photo = MemoryImage(
      base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
          'AAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg=='),
    );
    return {
      'GroupedSection': [
        GroupedSection(
          header: 'Practice',
          footer: 'Footer explanations stay below the rows.',
          children: [
            ListRow(
              title: 'Session length',
              value: '10 questions',
              variant: ListRowVariant.value,
              onTap: noop,
            ),
          ],
        ),
      ],
      'ListRow': [
        GroupedSection(
          children: [
            for (final variant in ListRowVariant.values)
              ListRow(
                title: variant.name,
                value: 'November 2026',
                variant: variant,
                selected: true,
                expanded: variant == ListRowVariant.inlineEditor,
                onTap: noop,
                divider: true,
                editor: ValueWheel(
                  values: const ['2026', '2027', '2028'],
                  selectedIndex: 0,
                  label: 'Year',
                  onSelected: (_) {},
                ),
              ),
          ],
        ),
      ],
      'PantasButton': [
        for (final variant in PantasButtonVariant.values) ...[
          PantasButton(label: variant.name, variant: variant, onPressed: noop),
          PantasButton(label: 'Disabled', variant: variant),
          PantasButton(
            label: 'Saving',
            variant: variant,
            busy: true,
            onPressed: noop,
          ),
        ],
      ],
      'ButtonPair': [
        for (final stacked in [true, false])
          ButtonPair(
            stacked: stacked,
            primary: PantasButton(label: 'Save', onPressed: noop),
            secondary: PantasButton(
              label: 'Later',
              variant: PantasButtonVariant.secondary,
              onPressed: noop,
            ),
          ),
      ],
      'PantasSwitch': [
        Wrap(
          spacing: 24,
          children: [
            PantasSwitch(
              value: _switch,
              label: 'Enabled switch',
              onChanged: (v) => setState(() => _switch = v),
            ),
            PantasSwitch(
              value: !_switch,
              label: 'Other switch',
              onChanged: (v) => setState(() => _switch = !v),
            ),
          ],
        ),
      ],
      'SegmentedSwitch': [
        SegmentedSwitch(
          labels: const ['Subjects', 'Topics', 'Lessons'],
          selected: _segment,
          onChanged: (v) => setState(() => _segment = v),
        ),
      ],
      'PantasPage': [
        SizedBox(
          height: 260,
          child: PantasPage(
            title: 'Settings',
            backLabel: 'Home',
            onBack: noop,
            children: List.generate(
              10,
              (i) => ListRow(title: 'Row ${i + 1}', onTap: noop),
            ),
          ),
        ),
      ],
      'ProgressRing': [
        const Wrap(
          spacing: 24,
          children: [
            ProgressRing(fraction: 0),
            ProgressRing(fraction: .5),
            ProgressRing(fraction: 1),
          ],
        ),
      ],
      'CheckMark': [
        const Align(alignment: Alignment.centerLeft, child: CheckMark()),
      ],
      'HalfRingGauge': [
        const HalfRingGauge(fraction: .61, label: 'Overall accuracy'),
        const HalfRingGauge(
          fraction: .694,
          label: 'Mock score',
          decimalPlaces: 1,
        ),
      ],
      'AccuracyBar': [
        for (final value in [.3, .4, .54, .58, .6, .61, .7, .8, .95])
          AccuracyBar(accuracy: value),
        const AccuracyBar.topicRows(accuracy: .6),
      ],
      'WeekStrip': [
        WeekStrip(
          today: DateTime(2026, 10, 7),
          states: const [
            WeekDayState.dayOff,
            WeekDayState.done,
            WeekDayState.partial,
            WeekDayState.today,
            WeekDayState.missed,
            WeekDayState.plain,
            WeekDayState.plain,
          ],
          todayFraction: .5,
          selectedDate: _day,
          onSelected: (v) => setState(() => _day = v),
        ),
      ],
      'SortCycleButton': [
        Align(
          alignment: Alignment.centerLeft,
          child: SortCycleButton(
            value: _order,
            onChanged: (v) => setState(() => _order = v),
          ),
        ),
      ],
      'PantasSheet': [
        for (final bookmarks in [false, true])
          PantasButton(
            label: bookmarks ? 'Open bookmarks sheet' : 'Open standard sheet',
            variant: PantasButtonVariant.secondary,
            onPressed: () => setState(() {
              _bookmarks = bookmarks;
              _sheet = true;
            }),
          ),
      ],
      'CenteredDialog': [
        for (final destructive in [false, true])
          PantasButton(
            label: destructive ? 'Destructive confirmation' : 'Confirmation',
            variant: PantasButtonVariant.secondary,
            onPressed: () => dialog(context, destructive: destructive),
          ),
      ],
      'Toast': [
        Toast(
          message: _toast,
          onUndo: () => setState(() => _toast = 'Undone.'),
        ),
        const Toast(message: 'Saved.'),
      ],
      'NoticeStrip': [
        NoticeStrip(
          title: 'Add your exam date',
          detail: 'Your plan paces each day to it.',
          expanded: _notice,
          onToggle: () => setState(() => _notice = !_notice),
          onClose: () => setState(() => _notice = false),
          primaryLabel: 'Add date',
          onPrimary: noop,
          secondaryLabel: 'Later',
          onSecondary: noop,
        ),
        NoticeStrip(title: 'Service message', onClose: noop),
      ],
      'FloatingBar': [
        for (final state in FloatingBarState.values)
          FloatingBar(
            state: state,
            left: TextButton(onPressed: noop, child: const Text('Back')),
            counter: '4 of 10',
            right: TextButton(onPressed: noop, child: const Text('Next')),
          ),
      ],
      'QuestionGridSheet': [
        for (final mock in [false, true])
          PantasButton(
            label: mock ? 'Open mock grid' : 'Open quiz grid',
            variant: PantasButtonVariant.secondary,
            onPressed: () => setState(() {
              _mock = mock;
              _grid = true;
            }),
          ),
      ],
      'ValueWheel': [
        ValueWheel.horizontal(
          values: const ['5', '10', '15', '20', '25'],
          selectedIndex: _wheel,
          label: 'Questions',
          invalidIndices: const {0, 4},
          onSelected: (v) => setState(() => _wheel = v),
        ),
        ValueWheel(
          values: const ['5', '10', '15', '20', '25'],
          selectedIndex: _wheel,
          label: 'Questions',
          invalidIndices: const {0, 4},
          onSelected: (v) => setState(() => _wheel = v),
        ),
      ],
      'MonthFirstDatePicker': [
        MonthFirstDatePicker(
          value: _date,
          today: DateTime(2026, 10, 3),
          onChanged: (v) => setState(() => _date = v),
        ),
      ],
      'ScopePicker': [
        ScopePicker(
          subjects: const [
            ScopeSubject(
              title: 'Mathematics',
              topics: [
                ScopeTopic(
                  id: 'algebra',
                  title: 'Algebra',
                  lessons: [
                    ScopeLesson(id: 'equations', title: 'Equations'),
                    ScopeLesson(
                      id: 'polynomials',
                      title: 'Polynomials',
                      unread: true,
                    ),
                  ],
                ),
                ScopeTopic(
                  id: 'geometry',
                  title: 'Geometry',
                  hasQuestions: false,
                ),
              ],
            ),
          ],
          selectedIds: _scope,
          onChanged: (v) => setState(() => _scope = v),
        ),
      ],
      'SearchField': [
        SearchField(title: 'Study', hint: 'Lessons, topics', onChanged: (_) {}),
      ],
      'Avatar': [
        Wrap(
          spacing: 14,
          children: [
            Avatar(name: 'Photo', photo: photo),
            const Avatar(name: 'Ada'),
            const Avatar(name: '👩🏽‍🔬 Scientist'),
            const Avatar(),
          ],
        ),
      ],
      'LoadingShapes': [
        const LoadingShapes(),
        const LoadingShapes(proGate: true),
      ],
      'StepsScreen': [
        const SizedBox(
          height: 360,
          child: StepsScreen(
            title: 'Restoring purchases',
            subtitle: 'This may take a moment.',
            steps: [
              WorkStep(label: 'Find purchases', state: WorkStepState.done),
              WorkStep(label: 'Restore Pro', state: WorkStepState.active),
              WorkStep(label: 'Finish', state: WorkStepState.pending),
            ],
          ),
        ),
      ],
      'StateView': [
        StateView(message: 'Could not load your progress.', onRetry: noop),
        const StateView(message: 'No questions yet.'),
        SizedBox(
          height: 420,
          child: StateView.fullScreen(
            onRetry: noop,
            error: Exception('Not rendered'),
          ),
        ),
      ],
      'ProTag': [const Align(alignment: Alignment.centerLeft, child: ProTag())],
      'ProPausedLine': [const ProPausedLine()],
      'PlaceholderFigure': [
        const PlaceholderFigure(
          12,
          reason: 'Debug gallery fixture, not a student metric.',
        ),
      ],
      'QuestionCard': [
        const QuestionCard(
          subject: 'Math',
          stem: r'What is $\frac{1}{2}$ of six?',
        ),
        const QuestionCard(
          subject: 'Math',
          stem: 'Use the figure.',
          figure: SizedBox(
            height: 80,
            child: Center(child: Text('Figure backing stays white.')),
          ),
        ),
      ],
      'ChoiceRow': [
        ChoiceRow(
          letter: 'A',
          text: 'Tap to pick this answer.',
          state: _choice,
          onTap: () => setState(
            () => _choice = _choice == ChoiceRowState.picked
                ? ChoiceRowState.plain
                : ChoiceRowState.picked,
          ),
        ),
        for (final state in ChoiceRowState.values)
          ChoiceRow(letter: 'B', text: state.name, state: state, onTap: noop),
      ],
      'AnswerReveal': [
        const AnswerReveal(
          correctLetter: 'B',
          explanation: 'The crust is the outer layer.',
        ),
        const AnswerReveal(
          correctLetter: 'B',
          explanation: 'The crust is the outer layer.',
          pickedLetter: 'A',
          wrongPick: 'The mantle is below the crust.',
        ),
      ],
      'PassageCard': [
        const PassageCard(
          title: 'Read the passage',
          text: 'The river rose after the rain. '
              'A reader can scroll this passage with the question.',
        ),
      ],
      'ContentRenderer': [
        const ContentRenderer(
          blocks: [
            {
              '_type': 'block',
              'style': 'h2',
              'children': [
                {'text': 'A lesson heading'},
              ],
            },
            {
              '_type': 'block',
              'children': [
                {'text': r'A paragraph with $x^2$.'},
              ],
            },
            {
              '_type': 'example',
              'title': 'Example 1',
              'body': 'Add one and one.',
              'solution': 'The answer is two.',
            },
            {
              '_type': 'block',
              'style': 'blockquote',
              'children': [
                {'text': 'A quoted line.'},
              ],
            },
            {
              '_type': 'block',
              'listItem': 'number',
              'children': [
                {'text': 'First step'},
              ],
            },
            {
              '_type': 'block',
              'listItem': 'number',
              'children': [
                {'text': 'Second step'},
              ],
            },
            {
              '_type': 'table',
              'rows': [
                ['Name', 'Value'],
                ['One', '1'],
              ],
            },
            {
              '_type': 'figureSpec',
              'spec': {
                'kind': 'gear-train',
                'gears': 3,
                'firstTurns': 'clockwise',
              },
              'semanticsLabel': 'Three meshed gears.',
              'credit': 'Code-drawn figure',
            },
            {'_type': 'image'},
            {'_type': 'unknown'},
          ],
        ),
      ],
      'MathText': [
        const MathText(r'Inline $\frac{1}{2}$ keeps one spoken sentence.'),
        const MathText(r'\frac{1}{\frac{2}{3}}', display: true),
        const MathText(r'\badcommand{{{', display: true),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Theme(
      data: _dark ? buildDarkTheme() : buildLightTheme(),
      child: Builder(
        builder: (context) {
          final demos = samples(context);
          final page = Scaffold(
            key: const ValueKey('component-gallery'),
            backgroundColor: context.colors.background,
            appBar: AppBar(
              title: const Text('Component gallery'),
              actions: [
                IconButton(
                  tooltip: 'Switch theme',
                  onPressed: () => setState(() => _dark = !_dark),
                  icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final name in ComponentGalleryPage.contractNames)
                  Padding(
                    key: ValueKey('gallery-$name'),
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(name, style: context.type.emphasized),
                        const SizedBox(height: 12),
                        for (final sample in demos[name]!) ...[
                          sample,
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
          final sheet = PantasSheet(
            page: page,
            open: _sheet,
            bookmarks: _bookmarks,
            label: 'Gallery sheet',
            onDismiss: () => setState(() => _sheet = false),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _bookmarks ? 'Bookmarks' : 'Sheet',
                    style: context.type.sectionHero,
                  ),
                  for (var i = 0; i < (_bookmarks ? 30 : 4); i++)
                    ListRow(title: 'Item ${i + 1}', onTap: noop),
                ],
              ),
            ),
          );
          return QuestionGridSheet(
            page: sheet,
            open: _grid,
            onDismiss: () => setState(() => _grid = false),
            mock: _mock,
            parts: [
              QuestionGridPart(
                title: 'Part 1',
                questions: List.generate(
                  15,
                  (i) => GridQuestion(
                    number: i + 1,
                    state: GridQuestionState.values[i % 4],
                    current: i == 3,
                    flagged: i == 1,
                  ),
                ),
              ),
              QuestionGridPart(
                title: 'Next part',
                enabled: false,
                questions: List.generate(
                  6,
                  (i) => GridQuestion(
                    number: i + 16,
                    state: GridQuestionState.unreached,
                  ),
                ),
              ),
            ],
            onSelected: (_) => setState(() => _grid = false),
          );
        },
      ),
    );
  }
}
