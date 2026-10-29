import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart'
    as passage_ui;
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_editor.dart';
import 'package:pantas/features/quiz/presentation/web_quiz_question.dart';

class QuizQuestionViewer extends StatefulWidget {
  const QuizQuestionViewer({
    required this.questions,
    required this.items,
    required this.pro,
    required this.onBack,
    required this.onNote,
    required this.onReport,
    this.subjectNames = const {},
    this.passages = const {},
    this.onReload,
    this.proPaused = false,
    this.openNotes = false,
    this.initialIndex = 0,
    this.backLabel = 'All questions',
    super.key,
  });
  final List<Question> questions;
  final List<AttemptItem> items;
  final Map<String, String> subjectNames;
  final Map<String, Passage> passages;
  final bool pro;
  final bool proPaused;
  final bool openNotes;
  final VoidCallback onBack;
  final VoidCallback? onReload;
  final Future<void> Function(String id, MistakeTag? tag, String? note) onNote;
  final Future<bool?> Function(String id) onReport;
  final int initialIndex;
  final String backLabel;
  @override
  State<QuizQuestionViewer> createState() => _QuizQuestionViewerState();
}

class _QuizQuestionViewerState extends State<QuizQuestionViewer> {
  late int _index = widget.initialIndex.clamp(0, widget.questions.length - 1);
  late bool _notes = widget.openNotes && widget.pro;
  final Map<String, AttemptItem> _updates = {};
  final Set<String> _reported = {};
  String? _reportStatus;
  Timer? _reportTimer;
  final Set<String> _dismissedNotes = {};
  final FocusNode _webFocus = FocusNode();
  @override
  void dispose() {
    _reportTimer?.cancel();
    _webFocus.dispose();
    super.dispose();
  }

  int _editorEpoch = 0;
  int _saveSerial = 0;
  String? _savedQuestion;
  late AttemptItem? _editingItem = widget.items
      .where((item) => item.questionId == widget.questions[_index].id)
      .firstOrNull;

  @override
  void didUpdateWidget(QuizQuestionViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pro && !widget.pro) {
      _notes = false;
      _editorEpoch++;
    }
  }

  void _move(int index) {
    setState(() {
      _index = index;
      _savedQuestion = null;
      _notes = false;
    });
  }

  Future<void> _save(String questionId, MistakeTag? tag, String? note) async {
    await widget.onNote(questionId, tag, note);
    if (!mounted) return;
    final item = _updates[questionId] ??
        widget.items.firstWhere((i) => i.questionId == questionId);
    setState(() {
      _updates[questionId] = item.copyWith(mistakeTag: tag, mistakeNote: note);
      _saveSerial++;
      _savedQuestion = tag != null || note != null ? questionId : null;
      _notes = false;
      _webFocus.requestFocus();
    });
  }

  Future<void> _report(String id) async {
    final saved = await widget.onReport(id);
    if (mounted && (saved ?? false)) {
      _reportTimer?.cancel();
      setState(() {
        _reported.add(id);
        _reportStatus = id;
      });
      _reportTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _reportStatus = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_index];
    final original =
        widget.items.where((i) => i.questionId == question.id).firstOrNull;
    final item = _updates[question.id] ?? original;
    final correctId = item?.correctChoiceId ?? question.correctChoice.id;
    final correct = question.choices.firstWhere((c) => c.id == correctId);
    final picked =
        question.choices.where((c) => c.id == item?.chosenChoiceId).firstOrNull;
    final wrong = !(item?.isCorrect ?? true);
    final canNote = wrong && widget.pro;
    final notes = _notes && canNote;
    final passage = widget.passages[question.passageId];
    if (context.wideWeb) {
      final t = context.webTokens;
      final editor = canNote
          ? QuizNoteEditor(
              key: ValueKey(
                'web-note-${question.id}-$_saveSerial-$_editorEpoch',
              ),
              tag: item?.mistakeTag,
              note: item?.mistakeNote,
              framed: false,
              onCancel: () => setState(() {
                _notes = false;
                _dismissedNotes.add(question.id);
                _webFocus.requestFocus();
              }),
              onSave: (tag, note) => _save(question.id, tag, note),
            )
          : null;
      void previous() {
        if (_index > 0) _move(_index - 1);
      }

      void next() {
        if (_index + 1 < widget.questions.length) _move(_index + 1);
      }

      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): widget.onBack,
          const SingleActivator(LogicalKeyboardKey.arrowLeft): previous,
          const SingleActivator(LogicalKeyboardKey.arrowRight): next,
        },
        child: Focus(
          focusNode: _webFocus,
          autofocus: true,
          child: Scaffold(
            backgroundColor: t.colors.background,
            body: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: widget.onBack,
                          icon: Icon(PantasIcons.back, size: 20),
                          label: Text(widget.backLabel),
                        ),
                        const SizedBox(width: 10),
                        const WebKeyHint('Esc'),
                        const Spacer(),
                        if (_reportStatus == question.id)
                          Text(
                            "Saved. It sends when you're back online.",
                            style: t.sm,
                          ),
                        IconButton(
                          tooltip: 'Report a question',
                          onPressed: () => unawaited(_report(question.id)),
                          icon: IconTheme(
                            data: IconThemeData(
                              color: _reported.contains(question.id)
                                  ? t.colors.accent
                                  : t.colors.secondaryLabel,
                            ),
                            child: PantasIcons.report,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(40, 56, 40, 140),
                          child: question.passageId != null && passage == null
                              ? errorFor(
                                  'question',
                                  widget.onReload ?? widget.onBack,
                                )
                              : WebQuizQuestion(
                                  question: question,
                                  subject:
                                      widget.subjectNames[question.topicId] ??
                                          '',
                                  chosenId: item?.chosenChoiceId,
                                  checked: true,
                                  pro: widget.pro,
                                  proPaused: widget.proPaused,
                                  passage: passage,
                                  passagePosition: passage == null
                                      ? null
                                      : (
                                          ordinal: widget.questions
                                              .take(_index + 1)
                                              .where(
                                                (q) =>
                                                    q.passageId ==
                                                    question.passageId,
                                              )
                                              .length,
                                          total: widget.questions
                                              .where(
                                                (q) =>
                                                    q.passageId ==
                                                    question.passageId,
                                              )
                                              .length,
                                        ),
                                  notes: canNote &&
                                          (_notes ||
                                              (_savedQuestion != question.id &&
                                                  !_dismissedNotes
                                                      .contains(question.id)))
                                      ? editor
                                      : null,
                                ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 28,
                        child: Center(
                          child: IntrinsicWidth(
                            child: WebBottomBar(
                              compact: true,
                              counter:
                                  '${_index + 1} of ${widget.questions.length}',
                              state:
                                  wrong ? WebBarState.wrong : WebBarState.right,
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Previous question',
                                    onPressed: _index > 0 ? previous : null,
                                    icon: Icon(
                                      PantasIcons.back,
                                      size: 18,
                                    ),
                                  ),
                                  const WebKeyHint('←'),
                                ],
                              ),
                              action: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const WebKeyHint('→'),
                                  if (canNote &&
                                      (_savedQuestion == question.id ||
                                          _dismissedNotes
                                              .contains(question.id)))
                                    IconButton(
                                      tooltip: 'Edit Note',
                                      onPressed: () => setState(() {
                                        _notes = true;
                                        _editorEpoch++;
                                      }),
                                      icon: Icon(PantasIcons.addNote),
                                    ),
                                  IconButton(
                                    tooltip: 'Next question',
                                    onPressed:
                                        _index + 1 < widget.questions.length
                                            ? next
                                            : null,
                                    icon: Icon(
                                      PantasIcons.next,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final colors = context.colors;
    final large = MediaQuery.textScalerOf(context).scale(16) > 24;
    final barState = item == null
        ? FloatingBarState.neutral
        : wrong
            ? FloatingBarState.wrong
            : FloatingBarState.right;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: widget.onBack,
                        icon: Icon(PantasIcons.back, size: 24),
                        label: Text(
                          widget.backLabel,
                          style:
                              context.type.body.copyWith(color: colors.accent),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Report a question',
                    onPressed: () => unawaited(_report(question.id)),
                    icon: IconTheme(
                      data: IconThemeData(
                        color: _reported.contains(question.id)
                            ? colors.accent
                            : colors.secondaryLabel,
                        size: 21,
                      ),
                      child: PantasIcons.report,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (question.passageId != null && passage == null)
                    errorFor('question', widget.onReload ?? widget.onBack)
                  else
                    ListView(
                      key: ValueKey('viewer-question-${question.id}'),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        notes
                            ? MediaQuery.sizeOf(context).height * .72
                            : large
                                ? 162
                                : 118,
                      ),
                      children: [
                        LessonTextScale(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              QuestionCard(
                                subject:
                                    widget.subjectNames[question.topicId] ?? '',
                                stem: question.stem,
                                figure: question.figureSpecJson == null
                                    ? null
                                    : QuestionFigure(
                                        specJson: question.figureSpecJson,
                                      ),
                                passage: passage == null
                                    ? null
                                    : passage_ui.PassageCard(
                                        title: passage.title,
                                        text: passage.body,
                                      ),
                                choices: [
                                  for (final choice in question.choices)
                                    ChoiceRow(
                                      letter: choice.label,
                                      text: choice.text,
                                      state: choice.id == correctId
                                          ? ChoiceRowState.right
                                          : choice.id == item?.chosenChoiceId
                                              ? ChoiceRowState.wrong
                                              : ChoiceRowState.dimmed,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              AnswerReveal(
                                key: ValueKey('viewer-reveal-${question.id}'),
                                correctLetter: correct.label,
                                explanation: question.explanation,
                                pickedLetter: picked?.label,
                                wrongPick: widget.pro && wrong
                                    ? picked?.rationale
                                    : null,
                              ),
                              if (wrong && widget.proPaused) ...[
                                const SizedBox(height: 12),
                                const ProPausedLine(),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: Builder(
                      builder: (context) {
                        Widget action(
                          String tooltip,
                          IconData icon,
                          VoidCallback? onPressed, {
                          Color? color,
                        }) =>
                            IconButton(
                              tooltip: tooltip,
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              constraints: const BoxConstraints.tightFor(
                                width: 44,
                                height: 44,
                              ),
                              padding: EdgeInsets.zero,
                              icon: Icon(icon, size: 20, color: color),
                              onPressed: onPressed,
                            );
                        final previous = action(
                          'Previous question',
                          PantasIcons.back,
                          _index == 0 ? null : () => _move(_index - 1),
                        );
                        final trailing = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (canNote)
                              TweenAnimationBuilder<double>(
                                key: ValueKey((question.id, _saveSerial)),
                                tween: Tween(begin: 0, end: 1),
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 720),
                                builder: (context, progress, child) {
                                  final elapsed = progress * 720 - 300;
                                  const curve = Cubic(.3, 1.4, .5, 1);
                                  final first = (elapsed / 260).clamp(0.0, 1.0);
                                  final last =
                                      ((elapsed - 260) / 160).clamp(0.0, 1.0);
                                  final scale = _savedQuestion != question.id
                                      ? 1.0
                                      : elapsed <= 260
                                          ? .6 + .5 * curve.transform(first)
                                          : 1.1 - .1 * curve.transform(last);
                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                child: action(
                                  item?.mistakeTag != null ||
                                          item?.mistakeNote != null
                                      ? 'Edit Note'
                                      : 'Add Note',
                                  item?.mistakeTag != null ||
                                          item?.mistakeNote != null
                                      ? PantasIcons.noted
                                      : PantasIcons.addNote,
                                  () => setState(() {
                                    _editingItem = item;
                                    _notes = true;
                                    _editorEpoch++;
                                  }),
                                  color: item?.mistakeTag != null ||
                                          item?.mistakeNote != null
                                      ? colors.accent
                                      : colors.label,
                                ),
                              ),
                            action(
                              'Next question',
                              PantasIcons.next,
                              _index + 1 >= widget.questions.length
                                  ? null
                                  : () => _move(_index + 1),
                            ),
                          ],
                        );
                        final counter = Text(
                          '${_index + 1} of ${widget.questions.length}',
                          style: context.type.subheadStrong.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                        final counterRow = KeyedSubtree(
                          key: const ValueKey('quiz-viewer-counter'),
                          child: large
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    counter,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: previous,
                                          ),
                                        ),
                                        trailing,
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: previous,
                                      ),
                                    ),
                                    counter,
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: trailing,
                                      ),
                                    ),
                                  ],
                                ),
                        );
                        final row = Padding(
                          padding: const EdgeInsets.all(8),
                          child: counterRow,
                        );
                        final editor = KeyedSubtree(
                          key: const ValueKey('quiz-viewer-note-form'),
                          child: QuizNoteEditor(
                            key: ValueKey('note-${question.id}-$_editorEpoch'),
                            framed: false,
                            tag: _editingItem?.mistakeTag,
                            note: _editingItem?.mistakeNote,
                            onCancel: () => setState(() => _notes = false),
                            onSave: (tag, note) =>
                                _save(question.id, tag, note),
                          ),
                        );
                        final still = MediaQuery.disableAnimationsOf(context);
                        return FloatingBar.content(
                          key: const ValueKey('quiz-viewer-surface'),
                          state: notes ? FloatingBarState.neutral : barState,
                          radius: notes ? 24 : 30,
                          inset: 0,
                          transitionDuration: canNote
                              ? const Duration(milliseconds: 420)
                              : null,
                          transitionCurve: canNote
                              ? const Cubic(.32, .72, 0, 1)
                              : Curves.linear,
                          child: !canNote
                              ? row
                              : still
                                  ? notes
                                      ? editor
                                      : row
                                  : AnimatedCrossFade(
                                      duration:
                                          const Duration(milliseconds: 420),
                                      reverseDuration:
                                          const Duration(milliseconds: 720),
                                      alignment: Alignment.bottomCenter,
                                      sizeCurve: const Cubic(.32, .72, 0, 1),
                                      firstCurve: notes
                                          ? const Interval(0, 120 / 420)
                                          : const Interval(
                                              1 - 480 / 720,
                                              1 - 260 / 720,
                                            ),
                                      secondCurve: notes
                                          ? const Interval(120 / 420, 360 / 420)
                                          : const Interval(1 - 140 / 720, 1),
                                      crossFadeState: notes
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      firstChild: row,
                                      secondChild: editor,
                                    ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
