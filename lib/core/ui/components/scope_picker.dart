import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

@immutable
class ScopeLesson {
  const ScopeLesson({
    required this.id,
    required this.title,
    this.unread = false,
    this.hasQuestions = true,
  });
  final String id;
  final String title;
  final bool unread;
  final bool hasQuestions;
}

@immutable
class ScopeTopic {
  const ScopeTopic({
    required this.id,
    required this.title,
    this.hasQuestions = true,
    this.lessons = const [],
  });
  final String id;
  final String title;
  final bool hasQuestions;
  final List<ScopeLesson> lessons;
}

@immutable
class ScopeSubject {
  const ScopeSubject({required this.title, required this.topics, this.mark});
  final String title;

  /// Plain text after the title, such as "Civil Service-level" on a subject
  /// above Student. Not a tag.
  final String? mark;
  final List<ScopeTopic> topics;
}

class ScopePicker extends StatefulWidget {
  const ScopePicker({
    required this.subjects,
    required this.selectedIds,
    required this.onChanged,
    this.atLeastOne = true,
    this.minimumSelectionMessage,
    this.settingsRows = false,
    this.phoneBoardRows = false,
    super.key,
  });
  final List<ScopeSubject> subjects;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final bool atLeastOne;
  final String? minimumSelectionMessage;

  /// Wide web, Settings "What's included": the board's 62 px rows with 17 px
  /// titles and a 32 px expand button, and 46 px lesson rows.
  final bool settingsRows;

  /// Phone boards QZ_Picker and QZS_*: 47.5 px topic rows, 46.5 px lesson
  /// rows and rules that start at the text. Wide web is unchanged.
  final bool phoneBoardRows;
  @override
  State<ScopePicker> createState() => _ScopePickerState();
}

class _ScopePickerState extends State<ScopePicker>
    with SingleTickerProviderStateMixin {
  final _expanded = <String>{};
  String? _shaking;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: PantasDurations.flip,
  );
  late final Animation<double> _offset = TweenSequence<double>([
    for (final pair in [
      (0.0, -5.0),
      (-5.0, 5.0),
      (5.0, -3.0),
      (-3.0, 3.0),
      (3.0, 0.0),
    ])
      TweenSequenceItem(
        tween: Tween(begin: pair.$1, end: pair.$2)
            .chain(CurveTween(curve: PantasBoardCurves.easeOut)),
        weight: 1,
      ),
  ]).animate(_shake);
  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  /// Where a row's text starts: the rules under a row start here. It is the
  /// row's left padding, the check and the gap, so a rule always lines up with
  /// the text above it.
  static double _textStart({required bool board, required bool lesson}) {
    final inset = board
        ? (lesson ? PantasSpace.s56 : PantasSpace.s20)
        : (lesson ? PantasSpace.s40 : PantasSpace.s16);
    final mark = board && lesson ? PantasSize.icon : PantasSize.check;
    return inset + mark + (board ? PantasSpace.s16 : PantasSpace.s12);
  }

  void toggle(String id, Set<String> ids) {
    final next = Set<String>.of(widget.selectedIds);
    if (ids.every(next.contains)) {
      next.removeAll(ids);
    } else {
      next.addAll(ids);
    }
    if (widget.atLeastOne && next.isEmpty) {
      setState(() => _shaking = id);
      if (!MediaQuery.disableAnimationsOf(context)) _shake.forward(from: 0);
      return;
    }
    if (_shaking != null) setState(() => _shaking = null);
    widget.onChanged(Set.unmodifiable(next));
  }

  Widget row(
    String id,
    String title,
    Set<String> ids, {
    bool enabled = true,
    bool unread = false,
    VoidCallback? expand,
    bool expanded = false,
    bool lesson = false,
  }) {
    final c = context.colors;
    final count = ids.where(widget.selectedIds.contains).length;
    final checked = ids.isNotEmpty && count == ids.length;
    final partial = count > 0 && !checked;
    final board = widget.settingsRows && context.wideWeb;
    final web = context.webTokens;
    final markSize = board && lesson ? PantasSize.icon : PantasSize.check;
    final gap = board ? PantasSpace.s16 : PantasSpace.s12;
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) => Transform.translate(
        key: ValueKey('scope-shake-$id'),
        offset: Offset(_shaking == id ? _offset.value : 0, 0),
        child: child,
      ),
      child: Material(
        color: lesson ? c.pickerBackground : c.surface,
        child: CheckboxRow(
          key: ValueKey('scope-select-$id'),
          squareEdges: context.wideWeb,
          title: title,
          padding: board
              ? EdgeInsets.fromLTRB(
                  lesson ? PantasSpace.s56 : PantasSpace.s20,
                  lesson ? PantasSpace.s12 : PantasSpace.s14,
                  expand == null ? PantasSpace.s20 : PantasSpace.s0,
                  lesson ? PantasSpace.s12 : PantasSpace.s14,
                )
              : EdgeInsets.fromLTRB(
                  lesson ? PantasSpace.s40 : PantasSpace.s16,
                  PantasSpace.s10,
                  PantasSpace.s12,
                  PantasSpace.s10,
                ),
          gap: gap,
          markSize: markSize,
          round: true,
          standardDensity: board || widget.phoneBoardRows,
          selected: checked,
          mixed: partial,
          onTap: enabled ? () => toggle(id, ids) : null,
          // The tag keeps its own width, up to half the row, and the title
          // takes the rest. A Flexible beside the title's Expanded would share
          // the free room and leave a gap at the edge.
          content: LayoutBuilder(
            builder: (context, box) {
              final tag = !enabled
                  ? Text('No questions yet', style: context.type.footnote)
                  : unread
                      ? Text(
                          'Unread',
                          style: context.type.footnote.copyWith(
                            color: c.warningText,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : null;
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: board
                          ? (lesson
                                  ? PantasType.webRowTitleSettings
                                  : PantasType.webRowTitle)
                              .copyWith(color: c.textPrimary)
                          : context.type.body,
                    ),
                  ),
                  if (tag != null) ...[
                    const SizedBox(width: PantasSpace.s8),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: box.maxWidth * .5),
                      child: tag,
                    ),
                  ],
                ],
              );
            },
          ),
          trailing: expand == null
              ? null
              : Padding(
                  padding: EdgeInsets.only(
                    right: board ? PantasSpace.s20 : PantasSpace.s0,
                  ),
                  child: IconButton(
                    key: ValueKey('scope-expand-$id'),
                    onPressed: expand,
                    style: board
                        ? IconButton.styleFrom(
                            fixedSize: const Size.square(PantasSize.iconBtnSm),
                            minimumSize:
                                const Size.square(PantasSize.iconBtnSm),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(PantasRadius.md),
                            ),
                          )
                        : !context.wideWeb &&
                                (widget.settingsRows ||
                                    widget.phoneBoardRows) &&
                                !lesson
                            // Phone boards: the button is as tall as the
                            // 47.5 px row, so it never makes the row taller.
                            ? IconButton.styleFrom(
                                fixedSize: const Size(
                                  PantasSize.field,
                                  PantasSize.rowMinPhone,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )
                            : null,
                    tooltip: expanded
                        ? 'Hide lessons in $title'
                        : 'Show lessons in $title',
                    icon: AnimatedRotation(
                      key: ValueKey('scope-caret-$id'),
                      turns: expanded ? .5 : 0,
                      curve: PantasCurves.house,
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : PantasDurations.flip,
                      child: Transform.rotate(
                        key: ValueKey('scope-caret-base-$id'),
                        angle: math.pi / 2,
                        child: Icon(
                          PantasIcons.next,
                          size: PantasSpace.s16,
                          // The board's chevron gray (#8A8A8E light, the
                          // dark boards' #949494). The web dark outline gray
                          // is for checkbox rims and left this at 1.4:1 on
                          // the card (5Q-3).
                          color: context.wideWeb
                              ? web.colors.textSecondary
                              : c.controlOutline,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget lessons(ScopeTopic topic) => _expanded.contains(topic.id)
      ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, lesson) in topic.lessons.indexed) ...[
              row(
                lesson.id,
                lesson.title,
                {lesson.id},
                enabled: topic.hasQuestions && lesson.hasQuestions,
                unread: lesson.unread && lesson.hasQuestions,
                lesson: true,
              ),
              if (index < topic.lessons.length - 1)
                Padding(
                  padding: EdgeInsets.only(
                    left: widget.settingsRows && context.wideWeb
                        ? _textStart(board: true, lesson: true)
                        : widget.phoneBoardRows && !context.wideWeb
                            ? _textStart(board: false, lesson: true)
                            : PantasSpace.s0,
                    right: widget.settingsRows && context.wideWeb
                        ? PantasSpace.s20
                        : PantasSpace.s0,
                  ),
                  child: Container(
                    height: PantasBorder.hairline,
                    color: context.colors.separator,
                  ),
                ),
            ],
          ],
        )
      : const SizedBox.shrink();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final subject in widget.subjects) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s0,
                PantasSpace.s16,
                PantasSpace.s6,
              ),
              child: Text(
                subject.mark == null
                    ? subject.title.toUpperCase()
                    : '${subject.title.toUpperCase()} · ${subject.mark}',
                style: context.type.sectionHeader,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(
                context.wideWeb ? PantasRadius.xl : PantasRadius.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, topic) in subject.topics.indexed) ...[
                    row(
                      topic.id,
                      topic.title,
                      topic.lessons.isEmpty
                          ? {topic.id}
                          : topic.lessons
                              .where((l) => l.hasQuestions)
                              .map((l) => l.id)
                              .toSet(),
                      enabled: topic.hasQuestions,
                      // QZE_None_m: a topic with no questions has nothing to
                      // open, so it has no chevron.
                      expand: topic.lessons.isEmpty || !topic.hasQuestions
                          ? null
                          : () => setState(
                                () => _expanded.contains(topic.id)
                                    ? _expanded.remove(topic.id)
                                    : _expanded.add(topic.id),
                              ),
                      expanded: _expanded.contains(topic.id),
                    ),
                    if (MediaQuery.disableAnimationsOf(context))
                      lessons(topic)
                    else
                      AnimatedSize(
                        key: ValueKey('scope-lessons-${topic.id}'),
                        duration: PantasDurations.long2,
                        curve: PantasCurves.house,
                        child: lessons(topic),
                      ),
                    if (index < subject.topics.length - 1)
                      Padding(
                        padding: EdgeInsets.only(
                          left: widget.settingsRows
                              ? _textStart(
                                  board: context.wideWeb,
                                  lesson: false,
                                )
                              : widget.phoneBoardRows && !context.wideWeb
                                  ? _textStart(board: false, lesson: false)
                                  : PantasSpace.s0,
                          right: widget.settingsRows && context.wideWeb
                              ? PantasSpace.s20
                              : PantasSpace.s0,
                        ),
                        child: Container(
                          key: ValueKey('scope-rule-${topic.id}'),
                          height: PantasBorder.hairline,
                          color: context.colors.separator,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: PantasSpace.s24),
          ],
          if (_shaking != null && widget.minimumSelectionMessage != null)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: PantasSpace.s16),
                child: Text(
                  widget.minimumSelectionMessage!,
                  // ST_IncludedLast: red 13 px on the wide layout.
                  style: widget.settingsRows && context.wideWeb
                      ? context.webTokens.sm
                          .copyWith(color: context.colors.destructive)
                      : context.type.footnote,
                ),
              ),
            ),
        ],
      );
}
