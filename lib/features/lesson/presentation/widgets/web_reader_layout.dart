import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

/// The owner keeps position, read marking and guarded writes.
class WebReaderLayout extends StatefulWidget {
  const WebReaderLayout({
    required this.reader,
    required this.controller,
    required this.scrollOffset,
    required this.progress,
    required this.onBack,
    required this.onBookmark,
    required this.onLesson,
    required this.footer,
    this.onNext,
    this.backLabel = 'Study',
    this.position,
    this.total,
    this.lessons,
    this.menuTitle,
    this.onMenuChanged,
    this.resumed = false,
    this.ending,
    super.key,
  });
  final ReaderContext reader;
  final ScrollController controller;
  final ValueListenable<double> scrollOffset;
  final ValueListenable<double> progress;
  final VoidCallback onBack;
  final VoidCallback? onNext;
  final VoidCallback onBookmark;
  final ValueChanged<String> onLesson;
  final ValueChanged<bool>? onMenuChanged;
  final Widget footer;
  final String backLabel;
  final int? position;
  final int? total;
  final List<StudyLesson>? lessons;
  final String? menuTitle;
  final bool resumed;
  final Widget? ending;
  @override
  State<WebReaderLayout> createState() => _WebReaderLayoutState();
}

class _WebReaderLayoutState extends State<WebReaderLayout> {
  final _anchors = <GlobalKey>[];
  int _active = 0;
  bool _bookmarkNotice = false;
  Timer? _noticeTimer;
  bool _menuOpen = false;
  bool _showBar = true;
  bool _resumeVisible = false;
  double _previousOffset = 0;
  @override
  void initState() {
    super.initState();
    _resumeVisible = widget.resumed;
    widget.scrollOffset.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(WebReaderLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.reader.isBookmarked && widget.reader.isBookmarked) {
      _bookmarkNotice = true;
      _resumeVisible = false;
      _noticeTimer?.cancel();
      _noticeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _bookmarkNotice = false);
      });
    }
    if (oldWidget.reader.lesson.id != widget.reader.lesson.id) {
      _active = 0;
      _anchors.clear();
      _bookmarkNotice = false;
      _resumeVisible = widget.resumed;
    }
    if (oldWidget.scrollOffset != widget.scrollOffset) {
      oldWidget.scrollOffset.removeListener(_onScroll);
      widget.scrollOffset.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollOffset.removeListener(_onScroll);
    _noticeTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollOffset.value;
    final show = offset <= 210 || offset < _previousOffset || _menuOpen;
    _previousOffset = offset;
    var active = 0;
    for (var i = 0; i < _anchors.length; i++) {
      final box = _anchors[i].currentContext?.findRenderObject() as RenderBox?;
      if (box != null &&
          box.attached &&
          box.localToGlobal(Offset.zero).dy <= 150) {
        active = i;
      }
    }
    if (active != _active || show != _showBar) {
      setState(() {
        _active = active;
        _showBar = show;
      });
    }
  }

  void _bookmark() {
    widget.onBookmark();
    // The owner shows failed saves. The provider confirms bookmark changes.
  }

  Future<void> _menu() async {
    setState(() {
      _menuOpen = true;
      _showBar = true;
    });
    widget.onMenuChanged?.call(true);
    final lessons = widget.lessons ?? widget.reader.topicLessons;
    final menuTitle =
        (widget.menuTitle ?? widget.reader.topicName).toUpperCase();
    await showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        final t = context.webTokens;
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 56),
            child: SizedBox(
              width: 380,
              child: Material(
                color: t.colors.surface,
                elevation: 10,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: t.cardEdge),
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height - 100,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            8,
                            12,
                            10,
                          ),
                          child: Text(
                            '$menuTitle · '
                            '${lessons.length} LESSONS',
                            style: t.eb.copyWith(fontSize: 12),
                          ),
                        ),
                        for (var i = 0; i < lessons.length; i++)
                          WebRow(
                            title: lessons[i].title,
                            horizontalPadding: 12,
                            titleStyle: t.style(
                              15,
                              weight: lessons[i].id == widget.reader.lesson.id
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            divider: false,
                            leading: Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: lessons[i].id == widget.reader.lesson.id
                                    ? t.colors.accentFill
                                    : null,
                                border: lessons[i].id == widget.reader.lesson.id
                                    ? null
                                    : Border.all(
                                        color: t.strongDivider,
                                        width: 1.5,
                                      ),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: t.style(
                                  12,
                                  weight: FontWeight.w700,
                                  color:
                                      lessons[i].id == widget.reader.lesson.id
                                          ? Colors.white
                                          : t.colors.secondaryLabel,
                                ),
                              ),
                            ),
                            value: lessons[i].id == widget.reader.lesson.id
                                ? 'Reading'
                                : '${lessons[i].estimatedMinutes} min',
                            selected: lessons[i].id == widget.reader.lesson.id,
                            compact: true,
                            onPressed: () {
                              Navigator.pop(context);
                              if (lessons[i].id != widget.reader.lesson.id) {
                                widget.onLesson(lessons[i].id);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _menuOpen = false);
    widget.onMenuChanged?.call(false);
  }

  Widget _lessonControl(BuildContext context) {
    final t = context.webTokens;
    final reader = widget.reader;
    final position = widget.position ?? reader.positionInTopic;
    final total = widget.total ?? reader.lessonsInTopic;
    return Semantics(
      expanded: _menuOpen,
      label: 'Lesson $position of $total. Show all lessons',
      child: TextButton(
        onPressed: _menu,
        child: ValueListenableBuilder<double>(
          valueListenable: widget.scrollOffset,
          builder: (_, offset, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (offset <= 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < total; i++)
                      Container(
                        width: 18,
                        height: 4,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          color: i + 1 == position
                              ? t.colors.accent
                              : t.strongDivider,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                  ],
                ),
              if (offset > 0)
                Opacity(
                  opacity: (offset / 90).clamp(0, 1),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Text(
                      reader.lesson.title,
                      style: t.style(14, weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Text('$position of $total', style: t.sm),
              const SizedBox(width: 8),
              Icon(
                _menuOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: t.colors.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final reader = widget.reader;
    final meta = '${reader.topicName} · '
        '${reader.lesson.estimatedMinutes} min';
    final groups = <List<Map<String, dynamic>>>[];
    final headings = <String?>[];
    for (final block in reader.lesson.bodyJson) {
      if (block['style'] == 'h2') {
        final children = block['children'];
        headings.add(
          children is List
              ? children
                  .whereType<Map<String, dynamic>>()
                  .map((child) => child['text'] as String? ?? '')
                  .join()
              : '',
        );
        groups.add([]);
      }
      if (groups.isEmpty) {
        groups.add([]);
        headings.add(null);
      }
      groups.last.add(block);
    }
    while (_anchors.length < groups.length) {
      _anchors.add(GlobalKey());
    }
    final ending = widget.ending;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onBack,
        if (ending == null) ...{
          const SingleActivator(LogicalKeyboardKey.keyB): _bookmark,
          if (widget.onNext != null)
            const SingleActivator(LogicalKeyboardKey.arrowRight):
                widget.onNext!,
        },
      },
      child: Focus(
        autofocus: true,
        onFocusChange: (focused) {
          if (focused && !_showBar) setState(() => _showBar = true);
        },
        child: ColoredBox(
          color: t.colors.background,
          child: Stack(
            children: [
              Positioned.fill(
                top: 60,
                child: ending ??
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final margin = ((constraints.maxWidth - 680 - 112) / 2)
                            .clamp(120.0, 220.0);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: margin,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 48),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        0,
                                        10,
                                        10,
                                      ),
                                      child: Text(
                                        'IN THIS LESSON',
                                        style: t.eb,
                                      ),
                                    ),
                                    for (var i = 0; i < headings.length; i++)
                                      if (headings[i] != null)
                                        TextButton(
                                          onPressed: () {
                                            final anchor =
                                                _anchors[i].currentContext;
                                            if (anchor != null) {
                                              Scrollable.ensureVisible(
                                                anchor,
                                                alignment: .05,
                                              );
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            alignment: Alignment.centerLeft,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                margin: const EdgeInsets.only(
                                                  top: 6,
                                                  right: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _active == i
                                                      ? t.colors.accent
                                                      : Colors.transparent,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  headings[i]!,
                                                  style: t.style(
                                                    14,
                                                    height: 1.35,
                                                    weight: _active == i
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                    color: _active == i
                                                        ? t.colors.label
                                                        : t.colors
                                                            .secondaryLabel,
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
                            const SizedBox(width: 56),
                            Flexible(
                              child: SizedBox(
                                key: const ValueKey('web-reader-column'),
                                width: 680,
                                child: SingleChildScrollView(
                                  controller: widget.controller,
                                  primary: false,
                                  padding: const EdgeInsets.only(
                                    top: 48,
                                    bottom: 80,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      LessonTextScale(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              meta,
                                              style: t.sub,
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              reader.lesson.title,
                                              style: t.style(
                                                42,
                                                weight: FontWeight.w700,
                                                height: 1.1,
                                                spacing: -1.092,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 28,
                                            ),
                                            for (var i = 0;
                                                i < groups.length;
                                                i++)
                                              Padding(
                                                key: _anchors[i],
                                                padding: EdgeInsets.only(
                                                  top: i == 0 ? 0 : 16,
                                                ),
                                                child: ContentRenderer(
                                                  blocks: groups[i],
                                                  readerFigures: true,
                                                  style: t.style(
                                                    18,
                                                    height: 1.65,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      widget.footer,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 56),
                            SizedBox(width: margin),
                          ],
                        );
                      },
                    ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedSlide(
                  key: const ValueKey('web-reader-focus-slide'),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : Duration(milliseconds: _showBar ? 420 : 700),
                  curve: const Cubic(.32, .72, 0, 1),
                  offset: _showBar || _menuOpen || ending != null
                      ? Offset.zero
                      : const Offset(0, -1),
                  child: Material(
                    color: t.colors.background,
                    child: SizedBox(
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (ending == null)
                              Center(child: _lessonControl(context)),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: widget.onBack,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        PantasIcons.back,
                                        size: 20,
                                        color: t.colors.accent,
                                      ),
                                      Text(
                                        widget.backLabel,
                                        style: t.style(
                                          15,
                                          color: t.colors.accent,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const WebKeyHint('Esc'),
                                const Spacer(),
                                if (ending == null)
                                  Tooltip(
                                    message: reader.isBookmarked
                                        ? 'Remove bookmark (B)'
                                        : 'Bookmark this lesson (B)',
                                    child: IconButton(
                                      onPressed: _bookmark,
                                      icon: Icon(
                                        reader.isBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        size: 22,
                                        color: reader.isBookmarked
                                            ? t.colors.accent
                                            : t.colors.tertiaryLabel,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : Duration(milliseconds: _showBar ? 420 : 700),
                curve: const Cubic(.32, .72, 0, 1),
                top: _showBar || _menuOpen || ending != null ? 58 : 0,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<double>(
                  valueListenable: widget.progress,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: ending != null ? 1 : value,
                    minHeight: 2,
                    backgroundColor: t.colors.separator,
                    color: t.colors.accent,
                  ),
                ),
              ),
              if (_bookmarkNotice && ending == null)
                const Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 220,
                      child: Toast(message: 'Bookmarked', keyHint: 'B'),
                    ),
                  ),
                ),
              if (_resumeVisible && ending == null)
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: WebCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Picked up where you left off',
                            style: t.sub,
                          ),
                          const SizedBox(width: 16),
                          WebButton(
                            label: 'Start Over',
                            variant: WebButtonVariant.tertiary,
                            onPressed: () {
                              widget.controller.jumpTo(0);
                              setState(
                                () => _resumeVisible = false,
                              );
                            },
                          ),
                        ],
                      ),
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

class WebReaderNext extends StatelessWidget {
  const WebReaderNext({
    required this.label,
    required this.title,
    this.detail,
    this.onPressed,
    super.key,
  });
  final String label;
  final String title;
  final String? detail;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return CallbackShortcuts(
      bindings: {
        if (onPressed != null)
          const SingleActivator(LogicalKeyboardKey.arrowRight): onPressed!,
      },
      child: Focus(
        autofocus: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 36),
          child: WebCard(
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(padding: const EdgeInsets.all(24)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label.toUpperCase(), style: t.eb),
                        const SizedBox(height: 8),
                        Text(title, style: t.h3),
                        if (detail != null) ...[
                          const SizedBox(height: 4),
                          Text(detail!, style: t.sub),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  const WebKeyHint('→'),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: t.colors.accentFill,
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
