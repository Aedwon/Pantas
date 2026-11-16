import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_review_note.dart';

class MockReviewView extends StatefulWidget {
  const MockReviewView({
    required this.entries, required this.markedIds, required this.offerHandled,
    required this.pro, required this.reasons, required this.onToggleFlag,
    required this.onSaveFlags, required this.onDismissFlags, required this.onSaveNote,
    required this.onBack, super.key,
  });
  final List<ReviewEntry> entries;
  final Set<String> markedIds;
  final bool offerHandled;
  final bool pro;
  final Map<String, MockAnswer> reasons;
  final Future<void> Function(String) onToggleFlag;
  final Future<void> Function() onSaveFlags;
  final Future<void> Function() onDismissFlags;
  final Future<void> Function(String, MockReviewNoteValue) onSaveNote;
  final VoidCallback onBack;
  @override
  State<MockReviewView> createState() => _MockReviewViewState();
}

class _MockReviewViewState extends State<MockReviewView> {
  ReviewFilter _filter = ReviewFilter.wrong;
  List<ReviewEntry>? _viewing;
  int _index = 0;
  bool _note = false;
  bool _flagBusy = false;
  bool _flagFailed = false;
  List<ReviewEntry> get _filtered => switch (_filter) {
    ReviewFilter.all => widget.entries,
    ReviewFilter.wrong => widget.entries.where((e) => !e.isCorrect).toList(),
    ReviewFilter.flagged => widget.entries.where((e) => widget.markedIds.contains(e.question.id)).toList(),
  };
  void _open(List<ReviewEntry> entries, int index, {bool note = false}) => setState(() {
    _viewing = List.unmodifiable(entries); _index = index; _note = note && widget.pro;
  });
  Future<void> _flags(Future<void> Function() action) async {
    if (_flagBusy) return;
    setState(() { _flagBusy = true; _flagFailed = false; });
    try { await action(); }
    catch (_) { if (mounted) setState(() => _flagFailed = true); }
    finally { if (mounted) setState(() => _flagBusy = false); }
  }
  @override
  Widget build(BuildContext context) {
    if (_viewing != null) return _viewer(context);
    final filtered = _filtered;
    final groups = FilterReviewEntries.groupBySubject(filtered);
    final wrong = widget.entries.where((e) => !e.isCorrect).length;
    final marked = widget.entries.where((e) => widget.markedIds.contains(e.question.id)).length;
    return PantasPage(title: 'All questions', backLabel: 'Results', onBack: widget.onBack, children: [
      SegmentedSwitch(labels: ['All ${widget.entries.length}', 'Wrong $wrong', 'Flagged $marked'], selected: _filter.index,
        onChanged: (i) => setState(() => _filter = ReviewFilter.values[i])),
      if (_filter == ReviewFilter.wrong && widget.pro) ...[
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tell Pantas why you got each one wrong. The better your notes, the more every review helps.', style: context.type.subhead.copyWith(height: 1.5)),
            TextButton(onPressed: filtered.isEmpty ? null : () {
              final first = filtered.indexWhere((e) {
                final note = widget.reasons[e.question.id];
                return e.isAnswered ? note?.missReason == null : note?.blankReason == null;
              });
              _open(filtered, first < 0 ? 0 : first, note: true);
            }, child: const Text('Finish the Notes')),
          ])),
      ],
      if (_filter == ReviewFilter.flagged && !widget.offerHandled && marked > 0) ...[
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('You flagged $marked questions while the clock was running. Do you want to save them?', style: context.type.subhead.copyWith(height: 1.5)),
            const SizedBox(height: 12),
            ButtonPair(primary: PantasButton(label: 'Save All $marked', height: 44, radius: 99, fontSize: 15,
              busy: _flagBusy, onPressed: () => _flags(widget.onSaveFlags)),
              secondary: PantasButton(label: 'No Thanks', height: 44, radius: 99, fontSize: 15,
                variant: PantasButtonVariant.secondary, onPressed: _flagBusy ? null : () => _flags(widget.onDismissFlags))),
            if (_flagFailed) TextButton(onPressed: () => _flags(widget.onSaveFlags), child: const Text('Try Again')),
          ])),
      ],
      for (final group in groups.entries) ...[
        const SizedBox(height: 22),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 7), child: Row(children: [
          Expanded(child: Text(group.key.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: context.type.sectionHeader)),
          const SizedBox(width: 8),
          Text(_filter == ReviewFilter.all ? '${group.value.where((e) => e.isCorrect).length} of ${group.value.length}' : '${group.value.length}', style: context.type.sectionHeader),
        ])),
        GroupedSection(children: [for (var i = 0; i < group.value.length; i++) ...[
          ListRow(key: ValueKey('mock-review-row-${group.value[i].question.id}'),
            title: group.value[i].label, subtitle: group.value[i].isAnswered ? null : 'Left blank',
            leading: SizedBox(width: 30, child: Text('${group.value[i].number}', style: context.type.subheadStrong.copyWith(
              color: group.value[i].isCorrect ? context.colors.accent : context.colors.wrongText, fontWeight: FontWeight.w700))),
            onTap: () => _open(filtered, filtered.indexOf(group.value[i]))),
          if (i < group.value.length - 1) Padding(padding: const EdgeInsets.only(left: 58), child: Divider(height: .5, thickness: .5, color: context.colors.separator)),
        ]]),
      ],
    ]);
  }
  Widget _viewer(BuildContext context) {
    final entry = _viewing![_index];
    final current = widget.entries.where((e) => e.question.id == entry.question.id).firstOrNull ?? entry;
    final q = entry.question;
    final picked = q.choices.where((c) => c.id == entry.chosenChoiceId).firstOrNull;
    final note = widget.reasons[q.id];
    final hasNote = entry.isAnswered ? note?.missReason != null : note?.blankReason != null;
    final state = !entry.isAnswered ? FloatingBarState.neutral : entry.isCorrect ? FloatingBarState.right : FloatingBarState.wrong;
    Widget arrow(bool next) => IconButton(tooltip: next ? 'Next' : 'Previous',
      onPressed: next ? (_index + 1 < _viewing!.length ? () => setState(() { _index++; _note = false; }) : null)
        : (_index > 0 ? () => setState(() { _index--; _note = false; }) : null),
      icon: Icon(next ? PantasIcons.next : PantasIcons.back, size: 22));
    final counter = '${_index + 1} of ${_viewing!.length}';
    return PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) {
      if (!didPop) setState(() { _viewing = null; _note = false; });
    }, child: Scaffold(backgroundColor: context.colors.background,
      body: SafeArea(child: Stack(children: [
        Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(4, 0, 8, 0), child: Row(children: [
            TextButton.icon(onPressed: () => setState(() { _viewing = null; _note = false; }),
              icon: Icon(PantasIcons.back, size: 24), label: Text('All questions', style: context.type.body.copyWith(color: context.colors.accent))),
            const Spacer(), IconButton(tooltip: current.isFlagged ? 'Unflag' : 'Flag', onPressed: () => _flags(() => widget.onToggleFlag(q.id)),
              icon: Icon(PantasIcons.flag, color: current.isFlagged ? context.colors.accent : context.colors.label, size: 22)),
          ])),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 140), child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              QuestionCard(subject: entry.subjectName, stem: q.stem,
                passage: entry.passage == null ? null : PassageCard(text: entry.passage!.body, title: entry.passage!.title),
                figure: q.figureSpecJson == null ? null : QuestionFigure(specJson: q.figureSpecJson),
                choices: [for (final choice in q.choices) ChoiceRow(letter: choice.label, text: choice.text,
                  state: choice.isCorrect ? ChoiceRowState.right : choice.id == picked?.id ? ChoiceRowState.wrong : ChoiceRowState.dimmed)]),
              const SizedBox(height: 20),
              AnswerReveal(correctLetter: q.correctChoice.label, explanation: q.explanation,
                pickedLetter: picked?.label, wrongPick: widget.pro && !entry.isCorrect ? picked?.rationale : null),
            ]))),
        ]),
        Positioned(left: 16, right: 16, bottom: 26, child: _note && widget.pro
          ? MockReviewNote(key: ValueKey(q.id), blank: !entry.isAnswered, initial: note,
              onCancel: () => setState(() => _note = false), onSave: (value) async {
                await widget.onSaveNote(q.id, value);
                if (mounted) setState(() => _note = false);
              })
          : widget.pro ? FloatingBar.content(state: state, child: Row(children: [arrow(false),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text(counter, style: context.type.subheadStrong)),
              const Spacer(), if (!entry.isCorrect) IconButton(tooltip: hasNote ? 'Edit Note' : 'Add Note',
                onPressed: () => setState(() => _note = true), icon: Icon(hasNote ? PantasIcons.noted : PantasIcons.addNote, size: 22)), arrow(true)]))
            : FloatingBar(state: state, left: arrow(false), counter: counter, right: arrow(true))),
      ])),
    ));
  }
}
