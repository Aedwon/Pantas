import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/theme/reader_full_width.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_tap.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_pull_to_advance.dart';

/// Where the outline and the lesson column sit on wide web.
///
/// The outline margin is worked out from the standard 680 px column and does
/// not change when the student widens the lesson, so the outline never moves
/// or shrinks. The column takes what is left after the two margins and the
/// two 56 px gaps, up to its own width.
///
/// The outline needs a 220 px margin for one line per label and a gutter at
/// the window edge like the Back link's. Only the desktop layout (1280 px and
/// up, the sidebar layout) has that room. Below it the outline is left out,
/// as on the phone, and the column sits centered between its two gaps. The
/// 1024 to 1279 px layout is the tablet one, which borrows the phone's
/// chrome.
abstract final class WebReaderMetrics {
  static const double gap = 56;

  /// The narrowest window that shows the outline.
  static const double outlineMinWidth = 1280;

  /// Whether a window [maxWidth] wide shows the outline.
  static bool showsOutline(double maxWidth) => maxWidth >= outlineMinWidth;

  /// The outline margin on the left and the matching space on the right.
  /// Zero where the outline is left out.
  static double margin(double maxWidth) => showsOutline(maxWidth)
      ? ((maxWidth - readerStandardWidth - 2 * gap) / 2).clamp(120.0, 220.0)
      : 0;

  /// The space kept at each window edge beside the outline, as the Back
  /// link keeps 16 px.
  static const double edge = 16;

  /// The lesson column for a window [maxWidth] wide.
  ///
  /// Where the full width does not fit, the column is the room that is left,
  /// after the outline's edge gutter too.
  static double columnWidth(double maxWidth, {required bool fullWidth}) {
    final wanted = fullWidth ? readerFullWidthMax : readerStandardWidth;
    final outer = showsOutline(maxWidth) ? 2 * edge : 0;
    final room = maxWidth - 2 * margin(maxWidth) - 2 * gap - outer;
    return wanted < room ? wanted : room;
  }
}

/// The lesson list drops 24 px into place and fades, on the phone's contents
/// sheet numbers: 450 ms in, 400 ms out, `slideC`.
const _contentsMotion = WebOverlayMotion(
  open: PantasDurations.long1,
  close: Duration(milliseconds: 400),
  curve: PantasCurves.slide,
  scrim: Duration(milliseconds: 350),
  scrimCurve: PantasCurves.fade,
  rise: -24,
  fade: true,
);

/// The height of the reader bar, and the ease its slide and the lesson window
/// share.
const double _barHeight = PantasLayout.focusHead;
const _barCurve = PantasCurves.move;

/// The thread sits on the bar's bottom edge (ReaderTopBar, `size-thread`).
const double _threadTop = _barHeight - PantasSize.thread;

/// The "Picked up where you left off" notice hangs a step under the bar.
const double _noticeTop = _barHeight + PantasSpace.s12;

/// Where the lesson column starts under the bar (snapped from 48 to the 44
/// step).
const double _columnTop = PantasSpace.s44;

/// The contents popover: the system gives a 380 maximum width and no token.
const double _menuWidth = 380;

/// The contents popover keeps the room above it (the top offset) and the
/// same step below it.
const double _menuInset = PantasSpace.s56 + PantasSpace.s44;

/// The lesson title in the bar stops at this width (board value, no token).
const double _titleMaxWidth = 400;

/// An outline row: its text plus the two vertical paddings of its button.
const double _outlineRowPad = PantasSpace.s12;

/// What the outline row's padding takes from the text width: the button's
/// sides and the indent beside the dot.
const double _outlineTextInset = PantasSpace.s10 * 2 + PantasSpace.s16;

/// How long a jump from the outline takes. It runs on the reader's shared ease.
const _jumpDuration = Duration(milliseconds: 500);

/// The owner keeps position, read marking and guarded writes.
class WebReaderLayout extends ConsumerStatefulWidget {
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
    this.pull,
    super.key,
  });

  /// Lets the wheel pull up for the next lesson at the end of the column.
  final WebPullController? pull;
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
  ConsumerState<WebReaderLayout> createState() => _WebReaderLayoutState();
}

class _WebReaderLayoutState extends ConsumerState<WebReaderLayout> {
  final _anchors = <GlobalKey>[];
  int _active = 0;
  bool _bookmarkNotice = false;
  bool _bookmarkNoticeMounted = false;
  Timer? _noticeTimer;
  Timer? _noticeExitTimer;
  bool _menuOpen = false;
  bool _showBar = true;
  bool _resumeVisible = false;
  bool _resumeMounted = false;
  Timer? _resumeExitTimer;
  double _previousOffset = 0;

  /// The section a jump from the outline is heading to. Until the page gets
  /// there the outline marks it, rather than every section on the way.
  int? _jumpTarget;
  int _jumpToken = 0;
  final _barKey = GlobalKey();

  /// True from a change of lesson until the next scroll, so the new lesson's
  /// window is in place at once instead of growing from the old one's.
  bool _instantInset = false;
  @override
  void initState() {
    super.initState();
    _resumeVisible = widget.resumed;
    _resumeMounted = widget.resumed;
    widget.scrollOffset.addListener(_onScroll);
    FocusManager.instance.addListener(_onPrimaryFocus);
  }

  @override
  void didUpdateWidget(WebReaderLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.reader.isBookmarked && widget.reader.isBookmarked) {
      _noticeExitTimer?.cancel();
      _bookmarkNotice = true;
      _bookmarkNoticeMounted = true;
      _hideResume();
      _noticeTimer?.cancel();
      _noticeTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          _bookmarkNotice = false;
          _noticeExitTimer = _afterExit(() => _bookmarkNoticeMounted = false);
        });
      });
    }
    if (oldWidget.reader.lesson.id != widget.reader.lesson.id) {
      _active = 0;
      // A lesson that rose into place already showed its bar, so the bar
      // stays put instead of sliding in a second time.
      _showBar = true;
      _instantInset = true;
      _jumpTarget = null;
      _anchors.clear();
      _noticeTimer?.cancel();
      _noticeExitTimer?.cancel();
      _resumeExitTimer?.cancel();
      _bookmarkNotice = false;
      _bookmarkNoticeMounted = false;
      _resumeVisible = widget.resumed;
      _resumeMounted = widget.resumed;
    }
    if (oldWidget.scrollOffset != widget.scrollOffset) {
      oldWidget.scrollOffset.removeListener(_onScroll);
      widget.scrollOffset.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onPrimaryFocus);
    widget.scrollOffset.removeListener(_onScroll);
    _noticeTimer?.cancel();
    _noticeExitTimer?.cancel();
    _resumeExitTimer?.cancel();
    super.dispose();
  }

  /// Runs [remove] once a notice has finished leaving: the toast's 300 ms.
  /// With reduced motion it leaves at once and no timer is left pending. Call
  /// it where a rebuild follows.
  Timer? _afterExit(VoidCallback remove) {
    if (MediaQuery.disableAnimationsOf(context)) {
      remove();
      return null;
    }
    return Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(remove);
    });
  }

  /// Fades the "Picked up where you left off" banner out and then removes it.
  void _hideResume() {
    if (!_resumeVisible) return;
    _resumeVisible = false;
    _resumeExitTimer?.cancel();
    _resumeExitTimer = _afterExit(() => _resumeMounted = false);
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
    active = _jumpTarget ?? active;
    if (active != _active || show != _showBar || _instantInset) {
      setState(() {
        _active = active;
        _showBar = show;
        _instantInset = false;
      });
    }
  }

  /// Takes the page to section [index] on the reader's shared ease, or at once
  /// with reduced motion. The section's heading lands where the old jump put
  /// it: 5 percent of the room under the bar.
  Future<void> _jumpTo(int index) async {
    final controller = widget.controller;
    final layout = context.findRenderObject();
    final heading = _anchors[index].currentContext?.findRenderObject();
    if (!controller.hasClients ||
        layout is! RenderBox ||
        heading is! RenderBox ||
        !heading.attached) {
      return;
    }
    final position = controller.position;
    // A point of the page keeps the same distance from the window's top while
    // the bar moves, so where the heading is now says where it is for good.
    final now = heading.localToGlobal(Offset.zero, ancestor: layout).dy;
    final landing = _barHeight + .05 * (layout.size.height - _barHeight);
    final destination = (position.pixels + now - landing)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.jumpTo(destination);
      return;
    }
    final token = ++_jumpToken;
    setState(() {
      _jumpTarget = index;
      _active = index;
    });
    await controller.animateTo(
      destination,
      duration: _jumpDuration,
      curve: _barCurve,
    );
    if (!mounted || token != _jumpToken) return;
    _jumpTarget = null;
    _onScroll();
  }

  void _bookmark() {
    widget.onBookmark();
    // The owner shows failed saves. The provider confirms bookmark changes.
  }

  /// Brings the bar back when keyboard focus lands on one of its controls, so
  /// a student who tabs to Back or Bookmark never sits on a control that is
  /// off the screen. Focus that lands in the lesson, such as the one that
  /// moves into a solution when it opens, leaves the bar as it is.
  void _onPrimaryFocus() {
    if (_showBar || !mounted) return;
    final focused = FocusManager.instance.primaryFocus?.context;
    final bar = _barKey.currentContext;
    if (focused == null || bar == null) return;
    var inBar = false;
    focused.visitAncestorElements((element) {
      inBar = element == bar;
      return !inBar;
    });
    if (inBar) setState(() => _showBar = true);
  }

  /// The "In this lesson" list, on the design's numbers: rows 32 px apart, the
  /// heading 38 px above the first row, and a dot on the section being read.
  Widget _outline(BuildContext context, List<String?> headings) {
    final t = context.webTokens;
    TextStyle rowStyle({required bool current}) =>
        PantasType.webRowSub.copyWith(
          fontWeight: current ? FontWeight.w600 : FontWeight.w400,
          color: current ? t.colors.textPrimary : t.colors.textSecondary,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s10,
            PantasSpace.s0,
            PantasSpace.s10,
            PantasSpace.s12,
          ),
          child: Text('IN THIS LESSON', style: t.eb.copyWith(height: 1.45)),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final positions = <int, double>{};
            var top = 0.0;
            for (var i = 0; i < headings.length; i++) {
              if (headings[i] == null) continue;
              positions[i] = top;
              final text = TextPainter(
                text: TextSpan(
                  text: headings[i],
                  style: rowStyle(current: _active == i),
                ),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
              )..layout(maxWidth: constraints.maxWidth - _outlineTextInset);
              top += text.height + _outlineRowPad;
              text.dispose();
            }
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < headings.length; i++)
                      if (headings[i] != null)
                        ReaderTap(
                          onTap: () => unawaited(_jumpTo(i)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PantasSpace.s10,
                              vertical: PantasSpace.s6,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: PantasSpace.s16),
                              child: Text(
                                headings[i]!,
                                style: rowStyle(current: _active == i),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
                if (positions.containsKey(_active))
                  AnimatedPositioned(
                    key: const ValueKey('web-reader-outline-dot'),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 250),
                    curve: _barCurve,
                    top: positions[_active]! + PantasSpace.s12,
                    left: PantasSpace.s10,
                    child: IgnorePointer(
                      child: Container(
                        width: PantasSpace.s6,
                        height: PantasSpace.s6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.colors.accent,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
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
    final lessonWord = lessons.length == 1 ? 'LESSON' : 'LESSONS';
    await showWebOverlay<void>(
      context: context,
      motion: _contentsMotion,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      builder: (context) {
        final t = context.webTokens;
        // RD_FocusOpen hangs the menu from the page's centre line to the
        // right, kept inside the window on a narrow one.
        final width = MediaQuery.sizeOf(context).width;
        final menuLeft = (width / 2)
            .clamp(
              PantasSpace.s16,
              math.max(width - _menuWidth - PantasSpace.s16, PantasSpace.s16),
            )
            .toDouble();
        // Esc closes the menu, as the board says. The menu takes focus so the
        // key reaches it and not the page under it, which would leave.
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.of(context).pop(),
          },
          child: Focus(
            autofocus: true,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: PantasSpace.s56, left: menuLeft),
                child: SizedBox(
                  width: _menuWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(PantasRadius.lg),
                      boxShadow: context.shadows.popover,
                    ),
                    child: Material(
                      color: t.colors.surfaceCard,
                      borderRadius: BorderRadius.circular(PantasRadius.lg),
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.sizeOf(context).height - _menuInset,
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(PantasSpace.s6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  PantasSpace.s12,
                                  PantasSpace.s8,
                                  PantasSpace.s12,
                                  PantasSpace.s6,
                                ),
                                // One line: a long topic name ends in an
                                // ellipsis and the count stays whole.
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        menuTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.eb.copyWith(height: 1.45),
                                      ),
                                    ),
                                    Text(
                                      ' · ${lessons.length} $lessonWord',
                                      maxLines: 1,
                                      style: t.eb.copyWith(height: 1.45),
                                    ),
                                  ],
                                ),
                              ),
                              for (var i = 0; i < lessons.length; i++)
                                _menuRow(
                                  context,
                                  lessons[i],
                                  i + 1,
                                  current:
                                      lessons[i].id == widget.reader.lesson.id,
                                ),
                            ],
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
      },
    );
    if (!mounted) return;
    setState(() => _menuOpen = false);
    widget.onMenuChanged?.call(false);
  }

  Widget _menuRow(
    BuildContext context,
    StudyLesson lesson,
    int number, {
    required bool current,
  }) {
    final t = context.webTokens;
    return ReaderTap(
      selectedFill: current ? t.colors.accentTint : null,
      onTap: () {
        Navigator.pop(context);
        if (!current) widget.onLesson(lesson.id);
      },
      child: Semantics(
        selected: current,
        // A title that is too long for one line wraps, and the row grows
        // with it, so the whole name can be read. A short one keeps the
        // board's 41 px.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: PantasSize.navItem),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s12,
              vertical: PantasSpace.s8,
            ),
            child: Row(
              children: [
                Container(
                  width: PantasSpace.s24,
                  height: PantasSpace.s24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: current ? t.colors.accentFill : null,
                    border: current
                        ? null
                        : Border.all(
                            color: t.strongDivider,
                            width: PantasBorder.ringStrong,
                          ),
                  ),
                  child: Text(
                    '$number',
                    style: PantasType.webTag.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          current ? t.colors.onAccent : t.colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: PantasSpace.s12),
                Expanded(
                  child: Text(
                    lesson.title,
                    style: PantasType.webSub.copyWith(
                      fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                      color: t.colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: PantasSpace.s12),
                Text(
                  current ? 'Reading' : '${lesson.estimatedMinutes} min',
                  style: current
                      ? PantasType.webTag.copyWith(color: t.tintText)
                      : PantasType.webSmall.copyWith(
                          color: t.colors.textSecondary,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lessonControl(BuildContext context) {
    final t = context.webTokens;
    final reader = widget.reader;
    final position = widget.position ?? reader.positionInTopic;
    final total = widget.total ?? reader.lessonsInTopic;
    return Semantics(
      expanded: _menuOpen,
      label: 'Lesson $position of $total. Show all lessons',
      child: ReaderTap(
        onTap: _menu,
        selectedFill: _menuOpen ? t.disabledBackground : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: PantasSize.targetTouch),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s14,
              PantasSpace.s0,
              PantasSpace.s10,
              PantasSpace.s0,
            ),
            child: Center(
              widthFactor: 1,
              child: ValueListenableBuilder<double>(
                valueListenable: widget.scrollOffset,
                builder: (_, offset, __) {
                  final shown = (offset / 90).clamp(0.0, 1.0);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRect(
                        child: Align(
                          key: const ValueKey('web-reader-title-width'),
                          widthFactor: shown,
                          alignment: Alignment.centerRight,
                          child: Opacity(
                            opacity: shown,
                            child: Transform.translate(
                              offset: Offset(0, 6 * (1 - shown)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: PantasSpace.s12,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _titleMaxWidth,
                                  ),
                                  child: Text(
                                    reader.lesson.title,
                                    style: PantasType.webLabel
                                        .copyWith(color: t.colors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < total; i++) ...[
                            Container(
                              width: PantasSpace.s18,
                              height: PantasSpace.s4,
                              decoration: BoxDecoration(
                                color: i + 1 == position
                                    ? t.colors.accent
                                    : t.strongDivider,
                                borderRadius:
                                    BorderRadius.circular(PantasRadius.full),
                              ),
                            ),
                            if (i + 1 < total)
                              const SizedBox(width: PantasSpace.s2),
                          ],
                        ],
                      ),
                      const SizedBox(width: PantasSpace.s12),
                      Text(
                        '$position of $total',
                        style: PantasType.webSmall
                            .copyWith(color: t.colors.textSecondary),
                      ),
                      const SizedBox(width: PantasSpace.s12),
                      Icon(
                        _menuOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: t.colors.tertiaryLabel,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Lets the wheel pull up for the next lesson while it is over the column.
  /// The pull stays on the column: over the outline or a margin it would be
  /// a surprise.
  Widget _wheel(Widget column) {
    final pull = widget.pull;
    if (pull == null) return column;
    return Listener(onPointerSignal: pull.handleSignal, child: column);
  }

  /// The wheel scrolls the lesson anywhere on the page, not only over the
  /// lesson column.
  ///
  /// A scroll view only hears the wheel while the pointer is over it. The
  /// outline and the two side margins sit outside the lesson's scroll view,
  /// so over them the page went dead. This listener covers the whole page and
  /// offers the lesson's scroll as a fallback. The fallback is registered
  /// with the pointer signal resolver, which keeps the first registration it
  /// gets: the lesson's own scroll view, the pull at the end of the lesson,
  /// or an outline that scrolls, all win when the pointer is over them.
  void _onWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final delta = event.scrollDelta;
    if (delta.dy == 0 || delta.dx.abs() > delta.dy.abs()) return;
    if (!widget.controller.hasClients) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      if (!widget.controller.hasClients) return;
      widget.controller.position.pointerScroll(delta.dy);
    });
  }

  /// Widens the lesson column to 800 px and back, and remembers the choice.
  Widget _widthControl(WebTokens t, {required bool fullWidth}) {
    final tip = fullWidth ? 'Standard width' : 'Full width';
    final color = fullWidth ? t.colors.accent : t.colors.tertiaryLabel;
    return Semantics(
      container: true,
      button: true,
      toggled: fullWidth,
      label: tip,
      excludeSemantics: true,
      onTap: () => _setFullWidth(!fullWidth),
      child: PantasIconButton(
        key: const ValueKey('web-reader-width-control'),
        tooltip: tip,
        onPressed: () => _setFullWidth(!fullWidth),
        accent: fullWidth,
        icon: CustomPaint(
          size: const Size.square(22),
          painter: _WidthIconPainter(fullWidth: fullWidth, color: color),
        ),
      ),
    );
  }

  void _setFullWidth(bool value) {
    // The choice applies at once. A failed save leaves it on for this visit.
    unawaited(
      ref
          .read(readerFullWidthProvider.notifier)
          .setFullWidth(fullWidth: value)
          .catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final fullWidth = ref.watch(readerFullWidthProvider);
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
    final barShown = _showBar || _menuOpen || ending != null;
    final inset = barShown ? _barHeight : 0.0;
    final insetDuration =
        MediaQuery.disableAnimationsOf(context) || _instantInset
            ? Duration.zero
            : Duration(milliseconds: _showBar ? 420 : 700);
    // Built once here, so the window's slide does not rebuild the lesson.
    final columnBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LessonTextScale(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(meta, style: t.sub),
              const SizedBox(height: PantasSpace.s8),
              Text(
                reader.lesson.title,
                style: PantasType.webH1.copyWith(color: t.colors.textPrimary),
              ),
              const SizedBox(height: PantasSpace.s32),
              for (var i = 0; i < groups.length; i++)
                Padding(
                  // Space alone separates the sections, so the anchor is the
                  // group, not its gap.
                  padding: i == 0
                      ? EdgeInsets.zero
                      : EdgeInsets.only(
                          top: ContentRenderer.sectionGap(context),
                        ),
                  child: ContentRenderer(
                    key: _anchors[i],
                    blocks: groups[i],
                    readerFigures: true,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: PantasSpace.s20),
        widget.footer,
      ],
    );
    return LetterShortcuts(
      bindings: {if (ending == null) 'b': _bookmark},
      also: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onBack,
        if (ending == null && widget.onNext != null)
          const SingleActivator(LogicalKeyboardKey.arrowRight): widget.onNext!,
      },
      child: Focus(
        autofocus: true,
        child: ColoredBox(
          color: t.colors.background,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerSignal: ending == null ? _onWheel : null,
            child: Stack(
              children: [
                AnimatedPositioned(
                  key: const ValueKey('web-reader-viewport'),
                  duration: insetDuration,
                  curve: _barCurve,
                  top: inset,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ending ??
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: inset),
                        duration: insetDuration,
                        curve: _barCurve,
                        builder: (context, shown, _) {
                          // The window's top edge follows the bar's bottom
                          // edge, so no hard line cuts the lesson under a bar
                          // that has gone. What the window gives up is added
                          // to the lesson's own top padding, so the text stays
                          // exactly where it was.
                          final lift = _barHeight - shown;
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final margin =
                                  WebReaderMetrics.margin(constraints.maxWidth);
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (margin > 0) ...[
                                    SizedBox(
                                      key: const ValueKey('web-reader-outline'),
                                      width: margin,
                                      child: SingleChildScrollView(
                                        padding: EdgeInsets.only(
                                          top: _columnTop + lift,
                                        ),
                                        child: _outline(context, headings),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: WebReaderMetrics.gap),
                                  Flexible(
                                    child: SizedBox(
                                      key: const ValueKey('web-reader-column'),
                                      width: WebReaderMetrics.columnWidth(
                                        constraints.maxWidth,
                                        fullWidth: fullWidth,
                                      ),
                                      child: _wheel(
                                        SingleChildScrollView(
                                          controller: widget.controller,
                                          primary: false,
                                          padding: EdgeInsets.only(
                                            top: _columnTop + lift,
                                            bottom: PantasSpace.s56,
                                          ),
                                          child: columnBody,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: WebReaderMetrics.gap),
                                  if (margin > 0) SizedBox(width: margin),
                                ],
                              );
                            },
                          );
                        },
                      ),
                ),
                Positioned(
                  // New for each lesson, so the bar of a lesson that rose into
                  // place does not slide in a second time.
                  key: ValueKey(('web-reader-bar', reader.lesson.id)),
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedSlide(
                    key: const ValueKey('web-reader-focus-slide'),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : Duration(milliseconds: _showBar ? 420 : 700),
                    curve: _barCurve,
                    offset: _showBar || _menuOpen || ending != null
                        ? Offset.zero
                        : const Offset(0, -1),
                    child: Material(
                      key: _barKey,
                      color: t.colors.background,
                      child: SizedBox(
                        height: _barHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PantasSpace.s24,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                children: [
                                  WebReaderBackControl(
                                    label: widget.backLabel,
                                    onPressed: widget.onBack,
                                  ),
                                  if (ending == null) ...[
                                    const SizedBox(width: PantasSpace.s12),
                                    const Spacer(),
                                    const SizedBox(width: PantasSpace.s12),
                                    _lessonControl(context),
                                    const SizedBox(width: PantasSpace.s12),
                                  ],
                                  const Spacer(),
                                  if (ending == null) ...[
                                    const SizedBox(width: PantasSpace.s12),
                                    _widthControl(t, fullWidth: fullWidth),
                                    const SizedBox(width: PantasSpace.s12),
                                    PantasIconButton(
                                      tooltip: withLetterKey(
                                        context,
                                        reader.isBookmarked
                                            ? 'Remove bookmark'
                                            : 'Bookmark this lesson',
                                        'B',
                                      ),
                                      onPressed: _bookmark,
                                      icon: ReaderBookmarkPop(
                                        key: ValueKey(
                                          (
                                            'web-reader-bookmark',
                                            reader.lesson.id
                                          ),
                                        ),
                                        bookmarked: reader.isBookmarked,
                                        child: Icon(
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (ending == null)
                  AnimatedPositioned(
                    key: ValueKey(('web-reader-progress', reader.lesson.id)),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : Duration(milliseconds: _showBar ? 420 : 700),
                    curve: _barCurve,
                    top: _showBar || _menuOpen || ending != null
                        ? _threadTop
                        : 0,
                    left: 0,
                    right: 0,
                    child: ValueListenableBuilder<double>(
                      valueListenable: widget.progress,
                      builder: (_, value, __) => Semantics(
                        label: 'Lesson progress',
                        value: '${(value.clamp(0.0, 1.0) * 100).round()}%',
                        child: ExcludeSemantics(
                          child: SizedBox(
                            height: PantasSize.thread,
                            child: ColoredBox(
                              color: t.colors.fill,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: value.clamp(0.0, 1.0),
                                  child: ColoredBox(
                                    color: t.colors.accent,
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_bookmarkNoticeMounted && ending == null)
                  Positioned(
                    bottom: PantasLayout.barBottom,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Toast(
                        message: 'Bookmarked',
                        keyHint: 'B',
                        web: true,
                        visible: _bookmarkNotice,
                      ),
                    ),
                  ),
                if (_resumeMounted && ending == null)
                  Positioned(
                    top: _noticeTop,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _NoticeTransition(
                        visible: _resumeVisible,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: t.colors.toastBg,
                            borderRadius:
                                BorderRadius.circular(PantasRadius.lg),
                            boxShadow: context.shadows.toast,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              PantasSpace.s18,
                              PantasSpace.s12,
                              PantasSpace.s10,
                              PantasSpace.s12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Picked up where you left off',
                                  style: PantasType.webSub
                                      .copyWith(color: t.colors.toastText),
                                ),
                                const SizedBox(width: PantasSpace.s14),
                                ReaderTap(
                                  onTap: () {
                                    widget.controller.jumpTo(0);
                                    setState(_hideResume);
                                  },
                                  radius: PantasRadius.sm,
                                  hoverFill: t.colors.toastActionHover,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: PantasSpace.s10,
                                      vertical: PantasSpace.s6,
                                    ),
                                    child: Text(
                                      'Start Over',
                                      style: PantasType.webLink.copyWith(
                                        color: t.colors.toastAction,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The reader bar's back link (ReaderTopBar, D192): the system BackLink with
/// the parent's name ("< Study") and the Esc key hint. Esc goes back from the
/// key handler of the page that owns the bar. The loading and error bars use
/// it too, so the bar does not move when the lesson arrives.
class WebReaderBackControl extends StatelessWidget {
  const WebReaderBackControl({
    required this.label,
    required this.onPressed,
    super.key,
  });
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebBackLink(label: label, onPressed: onPressed),
          const SizedBox(width: PantasSpace.s12),
          const WebKeyHint('Esc'),
        ],
      );
}

/// A notice that fades in and rises 12 px, and fades out as it leaves, on the
/// toast's numbers: 250 ms in, 300 ms out, `houseOut`. The owner keeps it
/// mounted until the 300 ms are over. With reduced motion it is simply there.
class _NoticeTransition extends StatelessWidget {
  const _NoticeTransition({required this.visible, required this.child});
  final bool visible;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: still ? (visible ? 1 : 0) : 0,
        end: visible ? 1 : 0,
      ),
      duration:
          still ? Duration.zero : Duration(milliseconds: visible ? 250 : 300),
      curve: PantasCurves.house,
      builder: (context, value, child) => ExcludeFocus(
        excluding: !visible,
        child: IgnorePointer(
          ignoring: !visible,
          child: ExcludeSemantics(
            excluding: !visible,
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                key: const ValueKey('web-reader-notice-rise'),
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            ),
          ),
        ),
      ),
      child: child,
    );
  }
}

/// Two arrows on one line. They point out to offer the full width and in to
/// go back to the standard width. Drawn on the 24 px grid of the approved
/// preview, 1.8 px stroke, round ends.
class _WidthIconPainter extends CustomPainter {
  const _WidthIconPainter({required this.fullWidth, required this.color});
  final bool fullWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (fullWidth) {
      path
        ..moveTo(3.5, 12)
        ..relativeLineTo(6, 0)
        ..moveTo(20.5, 12)
        ..relativeLineTo(-6, 0)
        ..moveTo(7, 8.5)
        ..lineTo(10.5, 12)
        ..lineTo(7, 15.5)
        ..moveTo(17, 8.5)
        ..lineTo(13.5, 12)
        ..lineTo(17, 15.5);
    } else {
      path
        ..moveTo(3.5, 12)
        ..relativeLineTo(7, 0)
        ..moveTo(20.5, 12)
        ..relativeLineTo(-7, 0)
        ..moveTo(7, 8.5)
        ..lineTo(3.5, 12)
        ..lineTo(7, 15.5)
        ..moveTo(17, 8.5)
        ..lineTo(20.5, 12)
        ..lineTo(17, 15.5);
    }
    canvas
      ..save()
      ..scale(size.width / 24, size.height / 24)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_WidthIconPainter oldDelegate) =>
      oldDelegate.fullWidth != fullWidth || oldDelegate.color != color;
}

class WebReaderNext extends StatelessWidget {
  const WebReaderNext({
    required this.label,
    required this.title,
    this.detail,
    this.onPressed,
    this.topGap = PantasSpace.s18,
    this.pull,
    super.key,
  });
  final double topGap;

  /// Shows the pull on the card: a ring around the arrow and words that
  /// follow it. Without it the card is just the card.
  final WebPullController? pull;
  final String label;
  final String title;
  final String? detail;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final circle = CircleAvatar(
      radius: PantasSize.avatarLg / 2,
      backgroundColor: t.colors.accentFill,
      child: Icon(
        Icons.arrow_forward,
        color: t.colors.onAccent,
        size: 20,
      ),
    );
    return CallbackShortcuts(
      bindings: {
        if (onPressed != null)
          const SingleActivator(LogicalKeyboardKey.arrowRight): onPressed!,
      },
      child: Focus(
        autofocus: true,
        child: Padding(
          padding: EdgeInsets.only(top: topGap),
          child: ReaderTap(
            onTap: onPressed,
            radius: PantasRadius.xl,
            washOnTop: true,
            child: WebCard(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s24,
                PantasSpace.s20,
                PantasSpace.s20,
                PantasSpace.s20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pull == null)
                          Text(
                            label.toUpperCase(),
                            style: t.eb.copyWith(height: 1.45),
                          )
                        else
                          WebPullLabel(
                            pull: pull!,
                            label: label,
                            style: t.eb.copyWith(height: 1.45),
                          ),
                        const SizedBox(height: PantasSpace.s2),
                        Text(
                          title,
                          style: PantasType.webH3Lg
                              .copyWith(color: t.colors.textPrimary),
                        ),
                        if (detail != null) ...[
                          const SizedBox(height: PantasSpace.s2),
                          Text(detail!, style: t.sub),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: PantasSpace.s16),
                  const WebKeyHint('→'),
                  const SizedBox(width: PantasSpace.s16),
                  if (pull == null)
                    circle
                  else
                    WebPullCircle(
                      pull: pull!,
                      track: t.colors.separator,
                      arc: t.colors.accent,
                      child: circle,
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
