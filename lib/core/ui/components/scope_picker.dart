import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
  const ScopeSubject({required this.title, required this.topics});
  final String title;
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
    duration: const Duration(milliseconds: 300),
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
            .chain(CurveTween(curve: PantasCurves.easeOut)),
        weight: 1,
      ),
  ]).animate(_shake);
  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
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
                  lesson ? 56 : 20,
                  lesson ? 12 : 15,
                  expand == null ? 20 : 0,
                  lesson ? 12 : 15,
                )
              : EdgeInsets.fromLTRB(lesson ? 42 : 16, 10, 12, 10),
          gap: board ? 16 : 12,
          minHeight: board
              ? (lesson ? 45 : 62)
              // ST_Included on a phone: 47.5 px rows.
              : (widget.settingsRows && !lesson
                  ? 47.5
                  : widget.phoneBoardRows
                      ? (lesson ? 46.5 : 47.5)
                      : 44),
          markSize: board && lesson ? 20 : (context.wideWeb ? 24 : 22),
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
                          ? web.style(lesson ? 16 : 17)
                          : context.type.body,
                    ),
                  ),
                  if (tag != null) ...[
                    const SizedBox(width: 8),
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
                  padding: EdgeInsets.only(right: board ? 20 : 0),
                  child: IconButton(
                    key: ValueKey('scope-expand-$id'),
                    onPressed: expand,
                    style: board
                        ? IconButton.styleFrom(
                            fixedSize: const Size.square(32),
                            minimumSize: const Size.square(32),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )
                        : !context.wideWeb &&
                                (widget.settingsRows ||
                                    widget.phoneBoardRows) &&
                                !lesson
                            // Phone boards: the button is as tall as the
                            // 47.5 px row, so it never makes the row taller.
                            ? IconButton.styleFrom(
                                fixedSize: const Size(48, 47.5),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )
                            : null,
                    tooltip: expanded
                        ? 'Hide lessons in $title'
                        : 'Show lessons in $title',
                    icon: AnimatedRotation(
                      key: ValueKey('scope-caret-$id'),
                      turns: expanded ? .5 : 0,
                      curve: PantasCurves.houseOut,
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      child: Transform.rotate(
                        key: ValueKey('scope-caret-base-$id'),
                        angle: math.pi / 2,
                        child: Icon(
                          PantasIcons.next,
                          size: 16,
                          // The board's chevron gray (#8A8A8E light, the
                          // dark boards' #949494). The web dark outline gray
                          // is for checkbox rims and left this at 1.4:1 on
                          // the card (5Q-3).
                          color: context.wideWeb
                              ? web.colors.tertiaryLabel
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
                        ? 92
                        : widget.phoneBoardRows && !context.wideWeb
                            ? 76
                            : 0,
                    right: widget.settingsRows && context.wideWeb ? 20 : 0,
                  ),
                  child: Container(height: .5, color: context.colors.separator),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
              child: Text(
                subject.title.toUpperCase(),
                style: context.type.sectionHeader,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(context.wideWeb ? 16 : 14),
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
                        duration: const Duration(milliseconds: 600),
                        curve: PantasCurves.houseOut,
                        child: lessons(topic),
                      ),
                    if (index < subject.topics.length - 1)
                      Padding(
                        padding: EdgeInsets.only(
                          left: widget.settingsRows
                              ? (context.wideWeb ? 60 : 50)
                              : widget.phoneBoardRows && !context.wideWeb
                                  ? 50
                                  : 0,
                          right:
                              widget.settingsRows && context.wideWeb ? 20 : 0,
                        ),
                        child: Container(
                          key: ValueKey('scope-rule-${topic.id}'),
                          height: .5,
                          color: context.colors.separator,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_shaking != null && widget.minimumSelectionMessage != null)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
