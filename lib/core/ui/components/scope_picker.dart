import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
    this.checkIconSize = 14,
    super.key,
  });
  final List<ScopeSubject> subjects;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final bool atLeastOne;
  final double checkIconSize;
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
    final mark = SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.controlOutline, width: 1.5),
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: count > 0 ? 1 : 0),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: PantasCurves.popB,
            builder: (context, value, child) => Transform.scale(
              key: ValueKey('scope-mark-scale-$id'),
              scale: .5 + .5 * value,
              child: Opacity(
                key: ValueKey('scope-mark-opacity-$id'),
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            ),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accentFill,
              ),
              child: partial
                  ? Center(
                      child: Container(
                        key: ValueKey('scope-partial-$id'),
                        width: 10,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: c.onAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )
                  : checked
                      ? Icon(
                          PantasIcons.check,
                          size: widget.checkIconSize,
                          color: c.onAccent,
                        )
                      : null,
            ),
          ),
        ],
      ),
    );
    final body = Material(
      color: lesson ? c.pickerBackground : c.surface,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('scope-select-$id'),
              onTap: enabled ? () => toggle(id, ids) : null,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  lesson ? 42 : 16,
                  12,
                  expand == null ? 16 : 0,
                  12,
                ),
                child: Row(
                  children: [
                    mark,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.body.copyWith(
                          fontSize: lesson ? 16 : 17,
                          letterSpacing: lesson ? 0 : -.204,
                        ),
                      ),
                    ),
                    if (!enabled)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'No questions yet',
                            style: context.type.footnote,
                          ),
                        ),
                      ),
                    if (unread)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'Unread',
                            style: context.type.footnote.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.warningText,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (expand != null)
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                key: ValueKey('scope-expand-$id'),
                onPressed: expand,
                tooltip: expanded ? 'Hide lessons' : 'Show lessons',
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
                      color: c.controlOutline,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return Semantics(
      checked: checked,
      mixed: partial,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) => Transform.translate(
          key: ValueKey('scope-shake-$id'),
          offset: Offset(_shaking == id ? _offset.value : 0, 0),
          child: child,
        ),
        child: Opacity(opacity: enabled ? 1 : .45, child: body),
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
                Container(height: .5, color: context.colors.separator),
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
              borderRadius: BorderRadius.circular(14),
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
                      expand: topic.lessons.isEmpty
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
                      Container(
                        key: ValueKey('scope-rule-${topic.id}'),
                        height: .5,
                        color: context.colors.separator,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      );
}
