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
  });
  final String id;
  final String title;
  final bool unread;
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
    super.key,
  });
  final List<ScopeSubject> subjects;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final bool atLeastOne;
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
    final checked = count == ids.length;
    final partial = count > 0 && !checked;
    final mark = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: count > 0 ? c.accentFill : null,
        border: Border.all(
          color: count > 0 ? c.accent : c.controlOutline,
          width: 1.5,
        ),
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
                  size: 14,
                  color: c.onAccent,
                )
              : null,
    );
    final body = Material(
      color: lesson ? c.background : c.surface,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('scope-select-$id'),
              onTap: enabled ? () => toggle(id, ids) : null,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  lesson ? 44 : 16,
                  12,
                  expand == null ? 16 : 0,
                  12,
                ),
                child: Row(
                  children: [
                    mark,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.body.copyWith(
                              fontSize: lesson ? 16 : 17,
                              letterSpacing: lesson ? 0 : -.204,
                            ),
                          ),
                          if (!enabled)
                            Text(
                              'No questions yet',
                              style: context.type.footnote,
                            ),
                          if (unread)
                            Text(
                              'Unread',
                              style: context.type.footnote.copyWith(
                                fontWeight: FontWeight.w500,
                                color: c.warningText,
                              ),
                            ),
                        ],
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
                  turns: expanded ? .25 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  child: Icon(
                    PantasIcons.next,
                    size: 16,
                    color: c.tertiaryLabel,
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
                  for (final topic in subject.topics) ...[
                    row(
                      topic.id,
                      topic.title,
                      topic.lessons.isEmpty
                          ? {topic.id}
                          : topic.lessons.map((l) => l.id).toSet(),
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
                    AnimatedSize(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      curve: PantasCurves.houseOut,
                      child: _expanded.contains(topic.id)
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final lesson in topic.lessons)
                                  row(
                                    lesson.id,
                                    lesson.title,
                                    {lesson.id},
                                    enabled: topic.hasQuestions,
                                    unread: lesson.unread,
                                    lesson: true,
                                  ),
                              ],
                            )
                          : const SizedBox.shrink(),
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
