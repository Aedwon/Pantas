import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/corpus_ceiling.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/value_wheel_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// What the screen needs to know about the student's track.
@immutable
class CustomMockSetupData {
  const CustomMockSetupData({
    required this.examId,
    required this.subjects,
    required this.topicsBySubject,
    required this.availableQuestions,
  });

  final ExamId examId;
  final List<Subject> subjects;
  final Map<SubjectId, List<Topic>> topicsBySubject;

  /// Counted from the scoped topics, so it follows the track rather than
  /// the whole corpus.
  final int availableQuestions;
}

/// Where a student says how long their own exam is and how it breaks down.
class CustomMockSetupPage extends StatefulWidget {
  const CustomMockSetupPage({
    required this.data,
    required this.onSave,
    super.key,
  });

  final CustomMockSetupData data;
  final Future<void> Function(CustomBlueprint blueprint) onSave;

  @override
  State<CustomMockSetupPage> createState() => _CustomMockSetupPageState();
}

class _CustomMockSetupPageState extends State<CustomMockSetupPage> {
  int _questions = 120;
  int _minutes = 120;
  bool _breakdownOpen = false;
  bool _timedSeparately = false;
  final _sections = <SubjectId, (int questions, int minutes)>{};

  bool get _hasBreakdown => _breakdownOpen && _sections.isNotEmpty;

  int get _effectiveQuestions => _hasBreakdown
      ? _sections.values.fold(0, (sum, part) => sum + part.$1)
      : _questions;

  int get _effectiveMinutes => _hasBreakdown
      ? _sections.values.fold(0, (sum, part) => sum + part.$2)
      : _minutes;

  CorpusFit get _fit => CheckCorpusFit.call(
        requested: _effectiveQuestions,
        available: widget.data.availableQuestions,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final fit = _fit;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Set up your mock', style: styles.headlineMedium),
          const SizedBox(height: 6),
          Text(
            "We'll build the mock exam based on what you tell us.",
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 16),
          _ValueRow(
            label: 'Questions',
            value: '$_effectiveQuestions',
            // Once parts exist the totals are their sum, so the top rows
            // stop being editable rather than disagreeing with them.
            onTap: _hasBreakdown ? null : _pickQuestions,
            isRefused: !fit.fits,
          ),
          _ValueRow(
            label: 'Time',
            value: formatDuration(_effectiveMinutes),
            onTap: _hasBreakdown ? null : _pickMinutes,
          ),
          _BreakdownToggle(
            isOpen: _breakdownOpen,
            onTap: () => setState(() => _breakdownOpen = !_breakdownOpen),
          ),
          if (_breakdownOpen) ...[
            for (final subject in widget.data.subjects)
              _ValueRow(
                label: subject.name,
                value: _sections[subject.id] == null
                    ? 'Set'
                    : '${_sections[subject.id]!.$1} · '
                        '${_sections[subject.id]!.$2}m',
                onTap: () => _pickSection(subject),
              ),
            SettingsValueRow(
              title: 'Time each part separately',
              control: SettingsSwitch(value: _timedSeparately),
              onTap: () => setState(() => _timedSeparately = !_timedSeparately),
            ),
          ],
          const SizedBox(height: 12),
          if (!fit.fits) ...[
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.rule,
                    // ignore: avoid_redundant_argument_values
                    width: AppDimensions.hairline,
                  ),
                ),
              ),
              child: Text(
                "You've ticked subjects with ${widget.data.availableQuestions} "
                'questions. A ${fit.requested} question paper needs more.',
                style: styles.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => context.push('/settings/exam/included'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tick more subjects',
                  style: styles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.board,
                  ),
                ),
              ),
            ),
          ] else
            Text(
              "You'll be timed here, and you'll get used to it before exam "
              'day.',
              style: styles.bodySmall.copyWith(color: colors.inkMuted),
            ),
          const SizedBox(height: 16),
          BoardButton(
            label: 'Save',
            onPressed: fit.fits ? _save : null,
          ),
        ],
      ),
    );
  }

  Future<void> _pickQuestions() async {
    final chosen = await showValueWheelSheet(
      context: context,
      title: 'How many questions?',
      values: questionValues,
      initial: _questions,
    );
    if (chosen != null) setState(() => _questions = chosen);
  }

  Future<void> _pickMinutes() async {
    final chosen = await showValueWheelSheet(
      context: context,
      title: 'How long is it?',
      values: minuteValues,
      initial: _minutes,
      format: formatDuration,
    );
    if (chosen != null) setState(() => _minutes = chosen);
  }

  Future<void> _pickSection(Subject subject) async {
    final held = _sections[subject.id];
    final chosen = await showTwoColumnWheelSheet(
      context: context,
      title: subject.name,
      initialQuestions: held?.$1 ?? 40,
      initialMinutes: held?.$2 ?? 30,
    );
    if (chosen != null) setState(() => _sections[subject.id] = chosen);
  }

  Future<void> _save() {
    return widget.onSave(
      CustomBlueprint(
        examId: widget.data.examId,
        totalQuestions: _questions,
        totalMinutes: _minutes,
        sectionsTimedSeparately: _hasBreakdown && _timedSeparately,
        sections: [
          if (_hasBreakdown)
            for (final subject in widget.data.subjects)
              if (_sections[subject.id] != null)
                CustomBlueprintSectionDraft(
                  subjectId: subject.id,
                  name: subject.name,
                  questions: _sections[subject.id]!.$1,
                  minutes: _sections[subject.id]!.$2,
                ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isRefused = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  /// The student's number stays on screen when it is refused, in rust.
  /// Clearing it would throw away the only thing they know for certain
  /// about their exam.
  final bool isRefused;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.ruleFaint,
              // ignore: avoid_redundant_argument_values
              width: AppDimensions.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: styles.bodyMedium)),
            Text(
              value,
              style: styles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isRefused ? colors.rust : colors.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Text(
                '›',
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreakdownToggle extends StatelessWidget {
  const _BreakdownToggle({required this.isOpen, required this.onTap});

  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.ruleFaint,
              // ignore: avoid_redundant_argument_values
              width: AppDimensions.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'I know the section breakdown',
                style: styles.bodyMedium,
              ),
            ),
            Text(
              isOpen ? '‹' : '›',
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
