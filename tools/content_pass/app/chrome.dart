import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

import 'api.dart';
import 'chrome_switch.dart';
import 'databases.dart';
import 'device.dart';
import 'exams.dart';
import 'models.dart';
import 'motion.dart';
import 'palette.dart';
import 'review_controller.dart';
import 'screen_host.dart';

// Phosphor glyphs from the app's own icon font. The app's icon set has no
// device or theme icons, so these use the same font and code points.
const _desktopIcon = IconData(0xe560, fontFamily: 'Phosphor');
const _tabletIcon = IconData(0xe1e6, fontFamily: 'Phosphor');
const _phoneIcon = IconData(0xe1e0, fontFamily: 'Phosphor');
const _sunIcon = IconData(0xe472, fontFamily: 'Phosphor');
const _moonIcon = IconData(0xe330, fontFamily: 'Phosphor');

const _font = 'Geist';

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
        return TweenAnimationBuilder<Palette>(
          tween: PaletteTween(end: Palette.of(dark: c.dark)),
          duration: chromeDuration(context, 200),
          curve: Curves.easeOut,
          builder: (context, p, _) => Theme(
            data: ThemeData(
              brightness: c.dark ? Brightness.dark : Brightness.light,
              fontFamily: _font,
              scaffoldBackgroundColor: p.bg,
              colorScheme: ColorScheme.fromSeed(
                seedColor: thumbGreen,
                brightness: c.dark ? Brightness.dark : Brightness.light,
              ),
              textSelectionTheme: TextSelectionThemeData(cursorColor: p.text),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Material(
                color: p.bg,
                child: DefaultTextStyle(
                  style:
                      TextStyle(fontFamily: _font, fontSize: 12, color: p.text),
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
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.c, required this.p});

  final ReviewController c;
  final Palette p;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.panel,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          const Text(
            'Content Pass',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(c.commitLabel, style: TextStyle(color: p.muted)),
          const SizedBox(width: 8),
          HoverFill(
            hover: p.hover,
            enabled: !c.checking,
            builder: (context, _) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: c.checking ? null : c.checkForUpdates,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  c.checking ? 'Checking' : 'Check for updates',
                  style: TextStyle(color: p.muted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.c, required this.p});

  final ReviewController c;
  final Palette p;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: p.track,
        child: Row(
          children: [
            Expanded(child: Text(c.notice!)),
            HoverFill(
              hover: p.hover,
              builder: (context, _) => GestureDetector(
                onTap: c.dismissNotice,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text('Dismiss', style: TextStyle(color: p.muted)),
                ),
              ),
            ),
          ],
        ),
      );
}

const _rowHeight = 32.0;

class _Queue extends StatefulWidget {
  const _Queue({required this.c, required this.p});

  final ReviewController c;
  final Palette p;

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
      if (!mounted || !_scroll.hasClients) return;
      final top = at * _rowHeight;
      final view = _scroll.position.viewportDimension;
      if (top >= _scroll.offset && top + _rowHeight <= _scroll.offset + view) {
        return;
      }
      final target =
          (top - view / 3).clamp(0.0, _scroll.position.maxScrollExtent);
      final duration = chromeDuration(context, 240);
      if (duration == Duration.zero) {
        _scroll.jumpTo(target);
      } else {
        _scroll.animateTo(
          target,
          duration: duration,
          curve: PantasCurves.houseOut,
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
    final examIndex = examCodes.indexOf(c.exam);
    const statuses = ['not_reviewed', 'tagged', 'all'];
    return ColoredBox(
      color: p.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChromeSwitch(
                  palette: p,
                  segments: [
                    for (final e in examCodes)
                      SwitchSegment.text(examLabels[e]!),
                  ],
                  selected: examIndex,
                  onChanged: (i) => c.setExam(examCodes[i]),
                ),
                const SizedBox(height: 8),
                ChromeSwitch(
                  palette: p,
                  segments: const [
                    SwitchSegment.text('Not reviewed'),
                    SwitchSegment.text('Tagged'),
                    SwitchSegment.text('All'),
                  ],
                  selected: statuses.indexOf(c.statusFilter),
                  onChanged: (i) => c.setStatusFilter(statuses[i]),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: p.line),
          Expanded(
            child: rows.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nothing left here.',
                      style: TextStyle(color: p.muted),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    itemExtent: _rowHeight,
                    itemCount: rows.length,
                    itemBuilder: (context, i) => _row(rows[i], p),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(QueueRow row, Palette p) {
    final c = widget.c;
    final item = row.item;
    if (item == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            Text(
              row.heading!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const Spacer(),
            _Count(done: row.done, total: row.total, p: p),
          ],
        ),
      );
    }
    final status = c.recordOf(item.id).status;
    final isCurrent = item.id == c.currentId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => c.select(item),
      child: HoverFill(
        hover: p.hover,
        radius: 0,
        builder: (context, _) => AnimatedContainer(
          duration: chromeDuration(context, 180),
          curve: PantasCurves.houseOut,
          color: isCurrent ? p.greenTint : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: item.cantShow != null ? p.muted : p.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Done over total, where the done number slides when it changes.
class _Count extends StatelessWidget {
  const _Count({required this.done, required this.total, required this.p});

  final int done;
  final int total;
  final Palette p;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: p.muted, fontSize: 12);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRect(
          child: AnimatedSwitcher(
            duration: chromeDuration(context, 180),
            switchInCurve: PantasCurves.houseOut,
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.8),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text('$done', key: ValueKey(done), style: style),
          ),
        ),
        Text('/$total', style: style),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.status, required this.p});

  final String status;
  final Palette p;

  @override
  Widget build(BuildContext context) {
    final good = status == 'looks_good';
    final filled = status != 'not_reviewed';
    final fill = good
        ? thumbGreen
        : filled
            ? p.text
            : Colors.transparent;
    return AnimatedContainer(
      duration: chromeDuration(context, 180),
      curve: Curves.easeOut,
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: filled ? fill : p.muted),
      ),
      child: AnimatedSwitcher(
        duration: chromeDuration(context, 260),
        switchInCurve: PantasCurves.popC,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: good
            ? const Icon(
                key: ValueKey('good'),
                Icons.check,
                size: 9,
                color: Colors.white,
              )
            : const SizedBox.shrink(key: ValueKey('none')),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.c, required this.p});

  final ReviewController c;
  final Palette p;

  @override
  Widget build(BuildContext context) {
    final item = c.current;
    if (item == null) return ColoredBox(color: p.panel);
    final record = c.recordOf(item.id);
    return ColoredBox(
      color: p.panel,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < tagNames.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TagTile(
                  p: p,
                  label: tagLabels[i],
                  number: i + 1,
                  on: record.tags.contains(tagNames[i]),
                  onTap: () => c.toggleTag(i),
                ),
              ),
            const SizedBox(height: 8),
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
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: p.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: p.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: p.muted),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _GoodButton(c: c, p: p)),
                const SizedBox(width: 8),
                Expanded(
                  child: PressScale(
                    onTap: c.next,
                    child: HoverFill(
                      hover: p.hover,
                      radius: 8,
                      builder: (context, _) => Container(
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: p.line),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: p.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (record.previous != null) ...[
              const SizedBox(height: 16),
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

/// One tag. Fill and border animate, a press shrinks it, and switching on
/// gives a small pop.
class _TagTile extends StatefulWidget {
  const _TagTile({
    required this.p,
    required this.label,
    required this.number,
    required this.on,
    required this.onTap,
  });

  final Palette p;
  final String label;
  final int number;
  final bool on;
  final VoidCallback onTap;

  @override
  State<_TagTile> createState() => _TagTileState();
}

class _TagTileState extends State<_TagTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void didUpdateWidget(_TagTile old) {
    super.didUpdateWidget(old);
    if (widget.on && !old.on && !MediaQuery.disableAnimationsOf(context)) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return PressScale(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pop,
        builder: (context, child) => Transform.scale(
          scale: 1 +
              0.04 *
                  Curves.easeOut.transform(
                    _pop.value < 0.5 ? _pop.value * 2 : 2 - _pop.value * 2,
                  ),
          child: child,
        ),
        child: HoverFill(
          hover: p.hover,
          radius: 8,
          builder: (context, _) => AnimatedContainer(
            duration: chromeDuration(context, 140),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.on ? p.greenTint : Colors.transparent,
              border: Border.all(color: widget.on ? p.greenLine : p.line),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: widget.on ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text('${widget.number}', style: TextStyle(color: p.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The green Looks good button. A check pops in when it is pressed.
class _GoodButton extends StatefulWidget {
  const _GoodButton({required this.c, required this.p});

  final ReviewController c;
  final Palette p;

  @override
  State<_GoodButton> createState() => _GoodButtonState();
}

class _GoodButtonState extends State<_GoodButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _check = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late int _tick = widget.c.goodTick;

  @override
  void didUpdateWidget(_GoodButton old) {
    super.didUpdateWidget(old);
    if (widget.c.goodTick != _tick) {
      _tick = widget.c.goodTick;
      if (!MediaQuery.disableAnimationsOf(context)) _check.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _check.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: widget.c.looksGood,
      child: HoverFill(
        hover: const Color(0x1AFFFFFF),
        radius: 8,
        builder: (context, _) => Container(
          height: 32,
          decoration: BoxDecoration(
            color: thumbGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'Looks good',
                softWrap: false,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Positioned(
                left: 8,
                child: AnimatedBuilder(
                  animation: _check,
                  builder: (context, _) {
                    final t = _check.value;
                    final scale = t == 0
                        ? 0.0
                        : PantasCurves.popC.transform((t * 2.5).clamp(0, 1));
                    final fade = t < 0.6 ? 1.0 : (1 - (t - 0.6) / 0.4);
                    return Opacity(
                      opacity: fade.clamp(0, 1),
                      child: Transform.scale(
                        scale: scale,
                        child: Icon(
                          PantasIcons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  final Palette p;
  final ReviewDatabases databases;
  final ContentPassApi api;

  @override
  Widget build(BuildContext context) {
    final item = c.current;
    final Widget body;
    if (c.nothingLeft || item == null) {
      body = Center(
        child: Text('Nothing left here.', style: TextStyle(color: p.muted)),
      );
    } else if (item.cantShow != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Can't show this here",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(item.cantShow!, style: TextStyle(color: p.muted)),
          ],
        ),
      );
    } else {
      body = _Frame(
        c: c,
        item: item,
        databases: databases,
        api: api,
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _Toolbar(c: c, p: p, item: item, databases: databases),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

/// One row: item state, device, theme, plan.
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.c,
    required this.p,
    required this.item,
    required this.databases,
  });

  final ReviewController c;
  final Palette p;
  final ReviewItem? item;
  final ReviewDatabases databases;

  @override
  Widget build(BuildContext context) {
    final isQuestion = item?.kind == 'question';
    final hasStates = item != null &&
        item!.cantShow == null &&
        (isQuestion || item!.kind == 'mock');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: chromeDuration(context, 200),
          curve: PantasCurves.houseOut,
          alignment: Alignment.centerRight,
          child: hasStates
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StateSwitch(
                    c: c,
                    p: p,
                    item: item!,
                    databases: databases,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        ChromeSwitch(
          palette: p,
          segments: const [
            SwitchSegment.icon(_desktopIcon, 'Desktop'),
            SwitchSegment.icon(_tabletIcon, 'Tablet'),
            SwitchSegment.icon(_phoneIcon, 'Phone'),
          ],
          selected: Device.values.indexOf(c.device),
          onChanged: (i) => c.setDevice(Device.values[i]),
        ),
        const SizedBox(width: 8),
        ChromeSwitch(
          palette: p,
          segments: const [
            SwitchSegment.icon(_sunIcon, 'Light'),
            SwitchSegment.icon(_moonIcon, 'Dark'),
          ],
          selected: c.dark ? 1 : 0,
          onChanged: (i) => c.setDark(value: i == 1),
        ),
        const SizedBox(width: 8),
        ChromeSwitch(
          palette: p,
          enabled: isQuestion && item!.cantShow == null,
          segments: const [
            SwitchSegment.text('Free'),
            SwitchSegment.text('Pro'),
          ],
          selected: c.pro ? 1 : 0,
          onChanged: (i) => c.setPro(value: i == 1),
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
  final Palette p;
  final ReviewItem item;
  final ReviewDatabases databases;

  @override
  Widget build(BuildContext context) {
    if (item.kind == 'mock') {
      const states = ['start', 'exam'];
      return ChromeSwitch(
        palette: p,
        segments: const [
          SwitchSegment.text('Start'),
          SwitchSegment.text('Exam'),
        ],
        selected: states.indexOf(c.screenState).clamp(0, 1),
        onChanged: (i) => c.setScreenState(states[i]),
      );
    }
    const states = ['question', 'correct', 'wrong'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChromeSwitch(
          palette: p,
          segments: const [
            SwitchSegment.text('Question'),
            SwitchSegment.text('Correct'),
            SwitchSegment.text('Wrong'),
          ],
          selected: states.indexOf(c.screenState).clamp(0, 2),
          onChanged: (i) => c.setScreenState(states[i]),
        ),
        AnimatedSize(
          duration: chromeDuration(context, 200),
          curve: PantasCurves.houseOut,
          alignment: Alignment.centerLeft,
          child: c.screenState != 'wrong'
              ? const SizedBox.shrink()
              : FutureBuilder<Question?>(
                  future: ContentRepository(databases.content)
                      .questionById(item.id),
                  builder: (context, snapshot) {
                    final question = snapshot.data;
                    if (question == null) return const SizedBox.shrink();
                    final wrong = [
                      for (final choice in question.choices)
                        if (!choice.isCorrect) choice.label,
                    ];
                    final picked = c.wrongLetter ?? wrong.first;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChromeSwitch(
                        palette: p,
                        segments: [
                          for (final l in wrong) SwitchSegment.text(l),
                        ],
                        selected:
                            wrong.indexOf(picked).clamp(0, wrong.length - 1),
                        onChanged: (i) => c.setWrongLetter(wrong[i]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// The real screen in a frame that animates to the device's shape.
///
/// A new screen cross-fades in with a very small scale. The screen inside is
/// laid out at the device's exact size, so its own layout and motion are
/// untouched. The scaling to fit the window is a plain FittedBox.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.c,
    required this.item,
    required this.databases,
    required this.api,
  });

  final ReviewController c;
  final ReviewItem item;
  final ReviewDatabases databases;
  final ContentPassApi api;

  @override
  Widget build(BuildContext context) {
    final spec = ScreenSpec(
      kind: item.kind,
      itemId: item.id,
      examId: examIdFor(c.exam),
      device: c.device,
      dark: c.dark,
      pro: c.pro,
      state: c.screenState,
      choice: c.wrongLetter,
      generation: c.generation,
    );
    final p = Palette.of(dark: c.dark);
    final target = Size(spec.size.width, spec.size.height);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Center(
        child: TweenAnimationBuilder<Size?>(
          tween: SizeTween(end: target),
          duration: chromeDuration(context, 240),
          curve: PantasCurves.houseOut,
          builder: (context, size, _) => FittedBox(
            child: SizedBox(
              width: size!.width,
              height: size.height,
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(border: Border.all(color: p.line)),
                child: ClipRect(
                  child: AnimatedSwitcher(
                    duration: chromeDuration(context, 160),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.985, end: 1)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: OverflowBox(
                      key: ValueKey(spec.key),
                      minWidth: target.width,
                      maxWidth: target.width,
                      minHeight: target.height,
                      maxHeight: target.height,
                      child: ScreenHost(
                        databases: databases,
                        api: api,
                        spec: spec,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
