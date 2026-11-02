import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';

import 'api.dart';
import 'databases.dart';
import 'exams.dart';
import 'models.dart';
import 'review_controller.dart';
import 'screen_host.dart';

/// Quiet monochrome colors for the reviewer chrome. The screen in the middle
/// has its own theme.
class _Palette {
  const _Palette({required this.dark});

  final bool dark;
  Color get bg => dark ? const Color(0xFF161616) : const Color(0xFFF4F4F2);
  Color get panel => dark ? const Color(0xFF1C1C1C) : const Color(0xFFFFFFFF);
  Color get line => dark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0DC);
  Color get text => dark ? const Color(0xFFE8E8E6) : const Color(0xFF1D1D1B);
  Color get muted => dark ? const Color(0xFF8E8E8A) : const Color(0xFF74746F);
  Color get select => dark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E4);
}

/// The whole reviewer window.
class ReviewShell extends StatefulWidget {
  const ReviewShell({
    required this.controller,
    required this.databases,
    required this.api,
    super.key,
  });

  final ReviewController controller;
  final ReviewDatabases databases;
  final ContentPassApi api;

  @override
  State<ReviewShell> createState() => _ReviewShellState();
}

class _ReviewShellState extends State<ReviewShell> {
  ReviewController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isMetaPressed || keyboard.isControlPressed) return false;
    final key = event.logicalKey;
    if (c.commentFocus.hasFocus) {
      if (key == LogicalKeyboardKey.escape) {
        c.commentFocus.unfocus();
        return true;
      }
      if (key == LogicalKeyboardKey.enter && !keyboard.isShiftPressed) {
        c.next();
        return true;
      }
      return false;
    }
    final digits = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
    ];
    final at = digits.indexOf(key);
    if (at >= 0) {
      c.toggleTag(at);
      return true;
    }
    if (key == LogicalKeyboardKey.keyC) {
      c.commentFocus.requestFocus();
      return true;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      c.next();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final p = _Palette(dark: c.dark);
        return Theme(
          data: ThemeData(
            brightness: c.dark ? Brightness.dark : Brightness.light,
            fontFamily: 'Geist',
            scaffoldBackgroundColor: p.bg,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF555555),
              brightness: c.dark ? Brightness.dark : Brightness.light,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: p.text,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: p.bg,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  color: p.text,
                ),
                child: Column(
                  children: [
                    _TopBar(c: c, p: p),
                    if (c.notice != null) _Notice(c: c, p: p),
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(width: 280, child: _Queue(c: c, p: p)),
                          VerticalDivider(width: 1, color: p.line),
                          Expanded(
                            child: _Center(
                              c: c,
                              p: p,
                              databases: widget.databases,
                              api: widget.api,
                            ),
                          ),
                          VerticalDivider(width: 1, color: p.line),
                          SizedBox(width: 280, child: _Panel(c: c, p: p)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.p,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final _Palette p;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(i),
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: i == selected ? p.select : null,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: i == selected ? FontWeight.w600 : null,
                    color: i == selected ? p.text : p.muted,
                  ),
                ),
              ),
            ),
        ],
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.c, required this.p});

  final ReviewController c;
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    const statuses = ['not_reviewed', 'tagged', 'all'];
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: p.panel,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          const Text(
            'Content Pass',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 20),
          _Seg(
            p: p,
            labels: [for (final e in examCodes) examLabels[e]!],
            selected: examCodes.indexOf(c.exam),
            onSelect: (i) => c.setExam(examCodes[i]),
          ),
          const SizedBox(width: 14),
          _Seg(
            p: p,
            labels: const ['Not reviewed', 'Tagged', 'All'],
            selected: statuses.indexOf(c.statusFilter),
            onSelect: (i) => c.setStatusFilter(statuses[i]),
          ),
          const SizedBox(width: 14),
          _Seg(
            p: p,
            labels: const ['Phone', 'Wide'],
            selected: c.wide ? 1 : 0,
            onSelect: (i) => c.setWide(value: i == 1),
          ),
          const SizedBox(width: 14),
          _Seg(
            p: p,
            labels: const ['Light', 'Dark'],
            selected: c.dark ? 1 : 0,
            onSelect: (i) => c.setDark(value: i == 1),
          ),
          const Spacer(),
          Text(c.commitLabel, style: TextStyle(color: p.muted)),
          const SizedBox(width: 10),
          TextButton(
            onPressed: c.checking ? null : c.checkForUpdates,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              textStyle: const TextStyle(fontSize: 12),
              foregroundColor: p.muted,
            ),
            child: Text(c.checking ? 'Checking' : 'Check for updates'),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.c, required this.p});

  final ReviewController c;
  final _Palette p;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        color: p.select,
        child: Row(
          children: [
            Expanded(child: Text(c.notice!)),
            GestureDetector(
              onTap: c.dismissNotice,
              child: Text('Dismiss', style: TextStyle(color: p.muted)),
            ),
          ],
        ),
      );
}

const _rowHeight = 28.0;

class _Queue extends StatefulWidget {
  const _Queue({required this.c, required this.p});

  final ReviewController c;
  final _Palette p;

  @override
  State<_Queue> createState() => _QueueState();
}

class _QueueState extends State<_Queue> {
  final _scroll = ScrollController();
  String? _shown;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reveal(List<QueueRow> rows) {
    final id = widget.c.currentId;
    if (id == _shown) return;
    _shown = id;
    final at = rows.indexWhere((r) => r.item?.id == id);
    if (at < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final top = at * _rowHeight;
      final view = _scroll.position.viewportDimension;
      if (top < _scroll.offset || top + _rowHeight > _scroll.offset + view) {
        _scroll.jumpTo(
          (top - view / 3).clamp(0, _scroll.position.maxScrollExtent),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final p = widget.p;
    final rows = c.rows;
    _reveal(rows);
    return ColoredBox(
      color: p.panel,
      child: rows.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(14),
              child:
                  Text('Nothing left here.', style: TextStyle(color: p.muted)),
            )
          : ListView.builder(
              controller: _scroll,
              itemExtent: _rowHeight,
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final row = rows[i];
                final item = row.item;
                if (item == null) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Row(
                      children: [
                        Text(
                          row.heading!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${row.done}/${row.total}',
                          style: TextStyle(color: p.muted),
                        ),
                      ],
                    ),
                  );
                }
                final status = c.recordOf(item.id).status;
                final isCurrent = item.id == c.currentId;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => c.select(item),
                  child: Container(
                    color: isCurrent ? p.select : null,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        _Dot(status: status, p: p),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.w600 : null,
                              color: item.cantShow != null ? p.muted : p.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.status, required this.p});

  final String status;
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    final filled = status != 'not_reviewed';
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: !filled
            ? null
            : status == 'tagged'
                ? const Color(0xFFD08A2E)
                : const Color(0xFF3F9A6E),
        border: Border.all(color: filled ? Colors.transparent : p.muted),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.c, required this.p});

  final ReviewController c;
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    final item = c.current;
    if (item == null) return ColoredBox(color: p.panel);
    final record = c.recordOf(item.id);
    return ColoredBox(
      color: p.panel,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < tagNames.length; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => c.toggleTag(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: record.tags.contains(tagNames[i]) ? p.select : null,
                    border: Border.all(
                      color:
                          record.tags.contains(tagNames[i]) ? p.text : p.line,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(tagLabels[i]),
                      const Spacer(),
                      Text('${i + 1}', style: TextStyle(color: p.muted)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: c.commentText,
              focusNode: c.commentFocus,
              maxLines: 7,
              minLines: 5,
              onChanged: (_) => c.commentChanged(),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Comment (C)',
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: p.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: p.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: p.muted),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: c.looksGood,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.text,
                      side: BorderSide(color: p.line),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Looks good', softWrap: false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: c.next,
                    style: FilledButton.styleFrom(
                      backgroundColor: p.text,
                      foregroundColor: p.bg,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
            if (record.previous != null) ...[
              const SizedBox(height: 12),
              Text(
                'This item changed. Earlier note: '
                '${_earlier(record.previous!)}',
                style: TextStyle(color: p.muted),
              ),
            ],
            const Spacer(),
            Text(item.file, style: TextStyle(fontSize: 10, color: p.muted)),
          ],
        ),
      ),
    );
  }

  String _earlier(Map<String, Object?> previous) {
    final tags = [
      for (final t in (previous['tags'] as List? ?? const [])) '$t',
    ];
    final comment = '${previous['comment'] ?? ''}'.trim();
    return [
      if (tags.isNotEmpty) tags.join(', '),
      if (comment.isNotEmpty) comment,
      if (tags.isEmpty && comment.isEmpty) '${previous['status']}',
    ].join('. ');
  }
}

class _Center extends StatelessWidget {
  const _Center({
    required this.c,
    required this.p,
    required this.databases,
    required this.api,
  });

  final ReviewController c;
  final _Palette p;
  final ReviewDatabases databases;
  final ContentPassApi api;

  @override
  Widget build(BuildContext context) {
    final item = c.current;
    if (c.nothingLeft || item == null) {
      return Center(
        child: Text('Nothing left here.', style: TextStyle(color: p.muted)),
      );
    }
    if (item.cantShow != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Can't show this here",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(item.cantShow!, style: TextStyle(color: p.muted)),
          ],
        ),
      );
    }
    final spec = ScreenSpec(
      kind: item.kind,
      itemId: item.id,
      examId: examIdFor(c.exam),
      wide: c.wide,
      dark: c.dark,
      state: c.screenState,
      choice: c.wrongLetter,
      generation: c.generation,
    );
    return Column(
      children: [
        if (item.kind == 'question' || item.kind == 'mock')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _StateSwitch(c: c, p: p, item: item, databases: databases),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: FittedBox(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: p.line),
                  ),
                  child: ScreenHost(
                    key: ValueKey(spec.key),
                    databases: databases,
                    api: api,
                    spec: spec,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StateSwitch extends StatelessWidget {
  const _StateSwitch({
    required this.c,
    required this.p,
    required this.item,
    required this.databases,
  });

  final ReviewController c;
  final _Palette p;
  final ReviewItem item;
  final ReviewDatabases databases;

  @override
  Widget build(BuildContext context) {
    if (item.kind == 'mock') {
      const states = ['start', 'exam'];
      return _Seg(
        p: p,
        labels: const ['Start', 'Exam'],
        selected: states.indexOf(c.screenState).clamp(0, 1),
        onSelect: (i) => c.setScreenState(states[i]),
      );
    }
    const states = ['question', 'correct', 'wrong'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Seg(
          p: p,
          labels: const ['Question', 'Correct', 'Wrong'],
          selected: states.indexOf(c.screenState).clamp(0, 2),
          onSelect: (i) => c.setScreenState(states[i]),
        ),
        if (c.screenState == 'wrong')
          FutureBuilder<Question?>(
            future: ContentRepository(databases.content).questionById(item.id),
            builder: (context, snapshot) {
              final question = snapshot.data;
              if (question == null) return const SizedBox.shrink();
              final wrong = [
                for (final choice in question.choices)
                  if (!choice.isCorrect) choice.label,
              ];
              final picked = c.wrongLetter ?? wrong.first;
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _Seg(
                  p: p,
                  labels: wrong,
                  selected: wrong.indexOf(picked).clamp(0, wrong.length - 1),
                  onSelect: (i) => c.setWrongLetter(wrong[i]),
                ),
              );
            },
          ),
      ],
    );
  }
}
