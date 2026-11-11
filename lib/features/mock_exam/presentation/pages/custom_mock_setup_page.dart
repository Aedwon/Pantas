import 'dart:math' as math;

import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/domain/corpus_ceiling.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/presentation/pages/web_custom_mock_setup.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_tap.dart';

/// The width of one value wheel (board width; the system sets no token).
const _wheelWidth = 120.0;

/// What the screen needs to know about the student's track.
@immutable
class CustomMockSetupData {
  const CustomMockSetupData({
    required this.examId,
    required this.subjects,
    required this.topicsBySubject,
    required this.availableQuestions,
    this.availableBySubject = const {},
    this.saved,
  });

  final ExamId examId;
  final List<Subject> subjects;
  final Map<SubjectId, List<Topic>> topicsBySubject;

  /// Counted from the scoped topics, so it follows the track rather than
  /// the whole corpus.
  final int availableQuestions;

  /// What each subject's scoped topics hold. A section asks for questions from
  /// one subject, so it cannot be larger than this. A subject missing here
  /// holds none.
  final Map<SubjectId, int> availableBySubject;

  /// The setup the student saved before, shown back with its own values.
  final CustomBlueprint? saved;
}

/// Questions the wheel offers, in fives up to the ceiling.
final List<int> customQuestionValues = [
  for (var i = 10; i <= questionWheelCeiling; i += 5) i,
];

/// The most questions one mock can hold. The server refuses a longer paper.
const int customMockQuestionLimit = 300;

/// Fifteen minutes to six hours, in fives.
final List<int> customMinuteValues = [for (var i = 15; i <= 360; i += 5) i];

/// `2h 00m`.
String formatCustomDuration(int minutes) =>
    '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m';

/// Where a student says how long their own exam is and how it breaks down
/// (CM_Setup, CM_Wheel, CM_Breakdown, CM_Ceiling). Questions and Time open
/// their wheel in place.
class CustomMockSetupPage extends StatefulWidget {
  const CustomMockSetupPage({
    required this.data,
    required this.onSave,
    this.onBack,
    this.onTickMoreSubjects,
    super.key,
  });

  final CustomMockSetupData data;
  final Future<void> Function(CustomBlueprint blueprint) onSave;
  final VoidCallback? onBack;
  final VoidCallback? onTickMoreSubjects;

  @override
  State<CustomMockSetupPage> createState() => _CustomMockSetupPageState();
}

/// Which value has its wheel open under it.
enum _Field { questions, time }

class _CustomMockSetupPageState extends State<CustomMockSetupPage> {
  late int _questions;
  late int _minutes;
  late bool _breakdownOpen;
  late bool _timedSeparately;
  final _sections = <SubjectId, (int? questions, int? minutes)>{};
  _Field? _openField;
  (SubjectId, bool)? _openSection;
  bool _saving = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final saved = widget.data.saved;
    _questions = saved?.totalQuestions ?? 120;
    _minutes = saved?.totalMinutes ?? 120;
    _breakdownOpen = saved?.hasBreakdown ?? false;
    _timedSeparately = saved?.sectionsTimedSeparately ?? false;
    for (final section
        in saved?.sections ?? const <CustomBlueprintSectionDraft>[]) {
      final id = section.subjectId;
      if (id != null) _sections[id] = (section.questions, section.minutes);
    }
  }

  bool get _hasBreakdown => _breakdownOpen && _sections.isNotEmpty;

  /// A breakdown with a row still unset cannot be saved: it would silently
  /// drop that subject from the paper.
  bool get _hasUnsetRow =>
      _breakdownOpen &&
      widget.data.subjects.any((subject) {
        final part = _sections[subject.id];
        return part?.$1 == null || part?.$2 == null;
      });

  int get _effectiveQuestions => _breakdownOpen
      ? _sections.values.fold(0, (sum, part) => sum + (part.$1 ?? 0))
      : _questions;

  int get _effectiveMinutes => _breakdownOpen
      ? _sections.values.fold(0, (sum, part) => sum + (part.$2 ?? 0))
      : _minutes;

  CorpusFit get _fit => CheckCorpusFit.call(
        requested: _effectiveQuestions,
        available: widget.data.availableQuestions,
      );

  int _heldBy(SubjectId id) => widget.data.availableBySubject[id] ?? 0;

  bool _sectionIsOver(SubjectId id) =>
      _breakdownOpen && (_sections[id]?.$1 ?? 0) > _heldBy(id);

  /// Sections asking for more than their subject holds, in subject order.
  List<Subject> get _overSections => [
        for (final subject in widget.data.subjects)
          if (_sectionIsOver(subject.id)) subject,
      ];

  bool get _overLimit => _effectiveQuestions > customMockQuestionLimit;

  /// The total passes what the subjects hold. When a section is over, its own
  /// line says so and this one stays quiet.
  bool get _showCeiling => !_fit.fits && _overSections.isEmpty;

  /// Fewer than two parts run as one clock, so the part by part line would
  /// promise what the server does not do.
  bool get _runsByPart =>
      _breakdownOpen && _timedSeparately && widget.data.subjects.length >= 2;

  bool get _canSave =>
      _fit.fits &&
      !_hasUnsetRow &&
      _effectiveQuestions > 0 &&
      !_overLimit &&
      _overSections.isEmpty &&
      !_saving;

  Widget _pill(
    BuildContext context,
    String text, {
    required bool open,
    bool refused = false,
    Key? key,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    final c = context.colors;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: MockTap(
        key: key,
        onTap: onTap,
        radius: PantasRadius.sm,
        restFill: c.fill,
        child: Container(
          constraints: const BoxConstraints(minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s12),
          alignment: Alignment.center,
          child: Text(
            text,
            style: context.type.body.copyWith(
              color: refused
                  ? c.wrongText
                  : open
                      ? c.accent
                      : c.label,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wheel({
    required String label,
    required List<int> values,
    required int? current,
    required String Function(int) format,
    required ValueChanged<int> onChanged,
  }) {
    final index = current == null ? 0 : math.max(0, values.indexOf(current));
    return Center(
      child: SizedBox(
        width: _wheelWidth,
        child: ValueWheel(
          key: ValueKey('wheel-$label'),
          values: [for (final value in values) format(value)],
          selectedIndex: index,
          label: label,
          onSelected: (i) => onChanged(values[i]),
        ),
      ),
    );
  }

  Widget _editor(bool open, Widget Function() wheel) {
    final child = open ? wheel() : const SizedBox(width: double.infinity);
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }

  void _toggleField(_Field field) => setState(() {
        _openSection = null;
        _openField = _openField == field ? null : field;
      });

  void _toggleSection(SubjectId id, {required bool minutes}) => setState(() {
        _openField = null;
        _openSection = _openSection == (id, minutes) ? null : (id, minutes);
      });

  Widget _totalsRow(
    BuildContext context, {
    required String title,
    required String value,
    required _Field field,
    bool refused = false,
    bool divider = false,
  }) {
    final editable = !_breakdownOpen;
    final open = _openField == field;
    return ListRow(
      title: title,
      variant: ListRowVariant.value,
      divider: divider,
      onTap: editable ? () => _toggleField(field) : null,
      valueWidget: editable
          ? _pill(
              context,
              value,
              open: open,
              refused: refused,
              key: ValueKey('custom-${field.name}'),
              semanticLabel: '$title, $value',
              onTap: () => _toggleField(field),
            )
          : Text(
              value,
              style: context.type.body.copyWith(
                color:
                    refused ? context.colors.wrongText : context.colors.label,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
    );
  }

  Widget _sectionRow(BuildContext context, Subject subject) {
    final c = context.colors;
    final part = _sections[subject.id];
    String show(int? value, String Function(int) format) =>
        value == null ? 'Set' : format(value);
    final stack = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final label = Text(
      subject.name,
      style: context.type.body,
    );
    final unit = context.type.footnote.copyWith(color: c.secondaryLabel);
    final items = _pill(
      context,
      show(part?.$1, (v) => '$v'),
      open: _openSection == (subject.id, false),
      refused: _sectionIsOver(subject.id),
      key: ValueKey('custom-items-${subject.id}'),
      semanticLabel: '${subject.name} items, ${show(part?.$1, (v) => '$v')}',
      onTap: () => _toggleSection(subject.id, minutes: false),
    );
    final minutes = _pill(
      context,
      show(part?.$2, (v) => '$v'),
      open: _openSection == (subject.id, true),
      key: ValueKey('custom-minutes-${subject.id}'),
      semanticLabel: '${subject.name} minutes, ${show(part?.$2, (v) => '$v')}',
      onTap: () => _toggleSection(subject.id, minutes: true),
    );
    final values = [
      items,
      Text('items', style: unit),
      minutes,
      Text('min', style: unit),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s16,
            vertical: PantasSpace.s10,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.separator, width: .5)),
          ),
          child: stack
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label,
                    const SizedBox(height: PantasSpace.s8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: values,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: label),
                    for (final value in values) ...[
                      const SizedBox(width: PantasSpace.s8),
                      value,
                    ],
                  ],
                ),
        ),
        _editor(
          _openSection?.$1 == subject.id,
          () {
            final isMinutes = _openSection!.$2;
            return _wheel(
              label: '${subject.name} ${isMinutes ? 'minutes' : 'items'}',
              values: isMinutes ? customMinuteValues : customQuestionValues,
              current: isMinutes ? part?.$2 : part?.$1,
              format: isMinutes ? (v) => '$v' : (v) => '$v',
              onChanged: (value) {
                final held = _sections[subject.id];
                if ((isMinutes ? held?.$2 : held?.$1) == value) return;
                setState(() {
                  _sections[subject.id] =
                      isMinutes ? (held?.$1, value) : (value, held?.$2);
                });
              },
            );
          },
        ),
      ],
    );
  }

  /// A line under a card, in the footnote style.
  Widget _note(BuildContext context, String text, {Color? color}) => Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s16,
          PantasSpace.s4,
          PantasSpace.s16,
          PantasSpace.s0,
        ),
        child: Text(
          text,
          style: context.type.footnote.copyWith(
            color: color ?? context.colors.textSecondary,
            // ds-board: custom mock setup board, footnote lines at 1.4.
            height: 1.4,
          ),
        ),
      );

  /// A red line with the way to correct it: tick more subjects.
  Widget _limitLine(BuildContext context, String text, {double top = 0}) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        PantasSpace.s16,
        top,
        PantasSpace.s16,
        PantasSpace.s0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: context.type.footnote.copyWith(
              color: c.wrongText,
              // ds-board: custom mock setup board, footnote lines at 1.4.
              height: 1.4,
            ),
          ),
          const SizedBox(height: PantasSpace.s4),
          Semantics(
            button: true,
            label: 'Tick More Subjects',
            excludeSemantics: true,
            child: WebTextLink(
              label: 'Tick More Subjects',
              arrow: false,
              onPressed: widget.onTickMoreSubjects,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fit = _fit;
    final canSave = _canSave;
    final back = widget.onBack;
    final overSections = _overSections;

    if (context.wideWeb) {
      return WebCustomMockSetup(
        questions: _effectiveQuestions,
        minutes: _effectiveMinutes,
        available: widget.data.availableQuestions,
        fits: !_showCeiling,
        overLimit: _overLimit,
        failed: _failed,
        breakdown: _breakdownOpen,
        timedSeparately: _timedSeparately,
        unset: _hasUnsetRow,
        questionValues: customQuestionValues,
        minuteValues: customMinuteValues,
        sections: [
          for (final subject in widget.data.subjects)
            (
              id: subject.id,
              name: subject.name,
              questions: _sections[subject.id]?.$1,
              minutes: _sections[subject.id]?.$2,
              held: _heldBy(subject.id),
              over: _sectionIsOver(subject.id),
            ),
        ],
        onQuestions: (value) => setState(() => _questions = value),
        onMinutes: (value) => setState(() => _minutes = value),
        onBreakdown: (value) => setState(() => _breakdownOpen = value),
        onTiming: (value) => setState(() => _timedSeparately = value),
        onSection: (id, value, {required minutes}) => setState(() {
          final held = _sections[id];
          _sections[id] = minutes ? (held?.$1, value) : (value, held?.$2);
        }),
        onSave: canSave ? _save : null,
        onBack: back,
        onTickMoreSubjects: widget.onTickMoreSubjects,
      );
    }

    final totals = GroupedSection(
      children: [
        _totalsRow(
          context,
          title: 'Questions',
          value: '$_effectiveQuestions',
          field: _Field.questions,
          refused: _showCeiling || _overLimit,
          divider: true,
        ),
        _editor(
          _openField == _Field.questions,
          () => _wheel(
            label: 'Questions',
            values: customQuestionValues,
            current: _questions,
            format: (v) => '$v',
            onChanged: (value) {
              // The wheel reports its own jumps while it rebuilds.
              if (value != _questions) setState(() => _questions = value);
            },
          ),
        ),
        _totalsRow(
          context,
          title: 'Time',
          value: formatCustomDuration(_effectiveMinutes),
          field: _Field.time,
        ),
        _editor(
          _openField == _Field.time,
          () => _wheel(
            label: 'Time',
            values: customMinuteValues,
            current: _minutes,
            format: formatCustomDuration,
            onChanged: (value) {
              if (value != _minutes) setState(() => _minutes = value);
            },
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: c.background,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.background.withValues(alpha: 0), c.background],
            stops: const [0, .26],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s16,
            PantasSpace.s14,
            PantasSpace.s16,
            PantasSpace.s32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_hasUnsetRow) ...[
                Text(
                  'Choose questions and minutes for every subject.',
                  style: context.type.footnote
                      .copyWith(color: c.secondaryLabel, height: 1.4),
                ),
                const SizedBox(height: PantasSpace.s8),
              ],
              if (_failed) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Could not save. Please try again.',
                    // ds-board: custom mock setup board, footnote lines at 1.4.
                    style: context.type.footnote
                        .copyWith(color: c.secondaryLabel, height: 1.4),
                  ),
                ),
                const SizedBox(height: PantasSpace.s8),
              ],
              PantasButton(label: 'Save', onPressed: canSave ? _save : null),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: PantasSpace.s16),
                child: WebBackLink(
                  label: 'Quiz',
                  onPressed: back ?? () {},
                  nudge: false,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s8,
                  PantasSpace.s16,
                  PantasSpace.s24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set up your mock',
                            style: PantasType.phoneTitle1
                                .copyWith(color: c.textPrimary),
                          ),
                          const SizedBox(height: PantasSpace.s6),
                          Text(
                            "We'll build it from what you tell us.",
                            style: PantasType.phoneCallout.copyWith(
                              height: 1.45,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PantasSpace.s24),
                    if (!_showCeiling)
                      totals
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          totals,
                          const SizedBox(height: PantasSpace.s8),
                          _limitLine(
                            context,
                            'Your subjects have '
                            '${widget.data.availableQuestions} '
                            'questions. A ${fit.requested}-question '
                            'mock needs more.',
                          ),
                        ],
                      ),
                    const SizedBox(height: PantasSpace.s24),
                    GroupedSection(
                      footer: _breakdownOpen
                          ? null
                          : "You'll be timed, so exam day feels familiar.",
                      children: [
                        ListRow(
                          title: 'I know the section breakdown',
                          trailingWidget: _breakdownOpen
                              ? Transform.rotate(
                                  angle: -math.pi / 2,
                                  child: Icon(
                                    PantasIcons.next,
                                    size: 16,
                                    color: c.chevron,
                                  ),
                                )
                              : null,
                          onTap: () => setState(() {
                            _breakdownOpen = !_breakdownOpen;
                            _openField = null;
                            _openSection = null;
                          }),
                        ),
                      ],
                    ),
                    if (_breakdownOpen) ...[
                      const SizedBox(height: PantasSpace.s24),
                      GroupedSection(
                        header: 'Section breakdown',
                        footer: 'The totals above now add these up.',
                        children: [
                          for (final subject in widget.data.subjects)
                            _sectionRow(context, subject),
                          ListRow(
                            title: 'Time each section separately',
                            variant: ListRowVariant.switchControl,
                            selected: _timedSeparately,
                            onTap: () => setState(
                              () => _timedSeparately = !_timedSeparately,
                            ),
                          ),
                        ],
                      ),
                      if (_runsByPart) _note(context, customPartByPartRule),
                      if (_overLimit)
                        _note(
                          context,
                          'Mocks go up to $customMockQuestionLimit questions. '
                          'This one adds up to $_effectiveQuestions.',
                          color: c.wrongText,
                        ),
                      for (final subject in overSections)
                        _limitLine(
                          context,
                          'Your ${subject.name} topics have '
                          '${_heldBy(subject.id)} questions. '
                          'A ${_sections[subject.id]!.$1}-question section '
                          'needs more.',
                          top: 8,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onSave(_blueprint());
    } on Object {
      // The route records the cause. The page stays, with the row kept.
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  CustomBlueprint _blueprint() {
    return CustomBlueprint(
      examId: widget.data.examId,
      totalQuestions: _questions,
      totalMinutes: _minutes,
      sectionsTimedSeparately: _hasBreakdown && _timedSeparately,
      sections: [
        if (_breakdownOpen)
          for (final subject in widget.data.subjects)
            if (_sections[subject.id]?.$1 != null &&
                _sections[subject.id]?.$2 != null)
              CustomBlueprintSectionDraft(
                subjectId: subject.id,
                name: subject.name,
                questions: _sections[subject.id]!.$1!,
                minutes: _sections[subject.id]!.$2!,
              ),
      ],
    );
  }
}
