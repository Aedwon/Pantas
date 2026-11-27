/// The lesson parts of the walk-through format, drawn as the approved board
/// draws them (Quick Check, Try, Why?, the right and wrong pair, the trap
/// checklist, stepped solutions and the tap-back that ties them together).
///
/// The Portable Text schema they read is in
/// `docs/superpowers/specs/2026-11-26-walkthrough-renderer-build.md`. Board:
/// `walk.css` and the `PT_*` frames of "Lesson Walk-Through Samples".
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

// Radius of a card and of the checklist (`.wcard`, `.wcl`): no token holds 16.
// ds-board: walk.css
const double _cardRadius = 16;

// Radius of the tap-back tint on a block target (`.hlt:before`): no token
// holds 20.
// ds-board: walk.css
const double _tintRadius = 20;

// The tint holds for `PantasDurations.wait` (300 ms), then fades over 1200 ms
// (`hlfa`); no duration token holds 1200.
// ds-board: walk.css
const Duration _tintFade = Duration(milliseconds: 1200);

// How long the page takes to scroll a target to the middle. The board scrolls
// smoothly and gives no time.
// ds-board: LB_SignedB script, scrollIntoView smooth
const Duration _scrollDuration = PantasDurations.medium3;

// The check inside the filled disc (`--accon`). Light is `onAccent`; dark uses
// the page color, the nearest role to the board's near-black #10201C (white
// `onAccent` would sit on the light teal disc there). Lead decision, E-196.

/// The first sentence of [runs] marked bold, for a revealed answer.
///
/// The sentence ends at the first `.`, `!` or `?` that sits in text (not in
/// maths), with any closing quote or bracket right after it, and is followed
/// by a space or the end of its run, so "3.5" does not end it and `"was."`
/// keeps its quote in the bold. Maths before the end is bold too. Runs with no
/// sentence end come back as they were.
List<Map<String, Object?>> boldFirstSentence(
  List<Map<String, Object?>> runs,
) =>
    _boldFirst(runs, onlyQuestion: false);

/// The first sentence of a Why? panel marked bold when it is a question (it
/// ends with `?`), as the board draws it. A panel that opens with a statement
/// comes back as it was. The sentence ends as [boldFirstSentence]'s does.
List<Map<String, Object?>> boldFirstQuestion(
  List<Map<String, Object?>> runs,
) =>
    _boldFirst(runs, onlyQuestion: true);

// The end of a sentence: the mark, then any closing quotes or brackets. The
// curly closing quotes are matched by code point, so no student-facing curly
// apostrophe appears in this source (the straight-apostrophe check).
final _sentenceEnd = RegExp(
  '([.!?])["\')\\]${String.fromCharCodes(const [0x201D, 0x2019])}]*'
  r'(?=\s|$)',
);

List<Map<String, Object?>> _boldFirst(
  List<Map<String, Object?>> runs, {
  required bool onlyQuestion,
}) {
  int? endRun;
  var endAt = 0;
  for (var i = 0; i < runs.length && endRun == null; i++) {
    final marks = runs[i]['marks'];
    if (marks is List<Object?> && marks.contains('latex')) continue;
    final text = runs[i]['text'];
    if (text is! String) continue;
    final match = _sentenceEnd.firstMatch(text);
    if (match != null) {
      if (onlyQuestion && match.group(1) != '?') return runs;
      endRun = i;
      endAt = match.end;
    }
  }
  if (endRun == null) return runs;

  Map<String, Object?> strong(Map<String, Object?> run, [String? text]) {
    final marks = run['marks'];
    final list = marks is List<Object?> ? marks : const <Object?>[];
    return {
      ...run,
      if (text != null) 'text': text,
      'marks': [
        ...list,
        if (!list.contains('strong')) 'strong',
      ],
    };
  }

  final out = <Map<String, Object?>>[];
  for (var i = 0; i < runs.length; i++) {
    if (i < endRun) {
      out.add(strong(runs[i]));
    } else if (i == endRun) {
      final text = runs[i]['text']! as String;
      out.add(strong(runs[i], text.substring(0, endAt)));
      if (endAt < text.length) {
        out.add({...runs[i], 'text': text.substring(endAt)});
      }
    } else {
      out.add(runs[i]);
    }
  }
  return out;
}

List<Map<String, Object?>> _maps(Object? value) => value is List<Object?>
    ? value.whereType<Map<String, Object?>>().toList()
    : const [];

Map<String, Object?> _paragraph(List<Map<String, Object?>> runs) => {
      '_type': 'block',
      'style': 'normal',
      'children': runs,
    };

/// What a screen reader says for [runs]: the words, with the spoken form of
/// any maths.
String _spoken(List<Map<String, Object?>> runs) {
  final out = StringBuffer();
  for (final run in runs) {
    final text = run['text'] is String ? run['text']! as String : '';
    final marks = run['marks'];
    if (marks is List<Object?> && marks.contains('latex')) {
      out.write(inlineMathExpressionSemanticsLabel(text) ?? text);
    } else {
      out.write(inlineMathSemantics(text)?.label ?? text);
    }
  }
  return out.toString();
}

/// Draws one lesson part for the reader, or null when [block] is not a
/// walk-through part this build knows.
Widget? buildWalkPart(BuildContext context, Map<String, Object?> block) {
  switch (block['_type']) {
    case 'walkCheck':
      return WalkCheckCard(
        label: 'Quick Check',
        question: _maps(block['question']),
        answer: _maps(block['answer']),
      );
    case 'walkTry':
      return WalkCheckCard(
        label: 'Try the last step',
        question: _maps(block['prompt']),
        answer: _maps(block['answer']),
      );
    case 'walkWhy':
      return WalkWhy(body: _maps(block['body']));
    case 'walkPair':
      final pair = WalkPair(
        right: _maps(block['right']),
        wrong: _maps(block['wrong']),
        note: _maps(block['note']),
      );
      final id = block['id'];
      return id is String && id.isNotEmpty
          ? WalkTarget(slug: id, child: pair)
          : pair;
    case 'walkChecklist':
      final items = block['items'];
      return WalkChecklist(
        items: [
          if (items is List<Object?>)
            for (final item in items.whereType<Map<String, Object?>>())
              WalkChecklistItem(
                cue: _maps(item['cue']),
                move: _maps(item['move']),
                target:
                    item['target'] is String ? item['target']! as String : '',
              ),
        ],
      );
  }
  return null;
}

// ---------------------------------------------------------------------------
// Text and color helpers
// ---------------------------------------------------------------------------

/// The text of a part: 17/1.55 wide and 16 on a phone (`.wans`, `.pm`,
/// `.wpanel`, `.clr`).
TextStyle _partType(BuildContext context, {double height = 1.55}) =>
    (context.wideWeb ? PantasType.webExplanation : PantasType.webReaderBlock)
        .copyWith(height: height);

/// The small uppercase label of a part (`.wlab`, `.plab`).
TextStyle _labelType(Color color) =>
    // ds-board: walk.css .wlab 12/600 with .48 tracking
    PantasType.webTag.copyWith(color: color, letterSpacing: .48);

/// Lesson blocks drawn by a reader of their own, so a part keeps the reader's
/// maths and spacing. [body] and [strong] replace the reader's text colors
/// where the board draws a part in its own ink.
Widget _content(
  BuildContext context,
  List<Map<String, Object?>> blocks, {
  TextStyle? style,
  Color? body,
  Color? strong,
}) {
  final reader = ContentRenderer(
    blocks: blocks,
    readerFigures: true,
    style: style,
    walkthrough: false,
    // A line with a fraction would otherwise touch the next line's.
    mathLinePadding: PantasSpace.s2,
  );
  if (body == null && strong == null) return reader;
  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      extensions: [
        for (final extension in theme.extensions.values)
          if (extension is PantasColors)
            extension.copyWith(readerBody: body, readerStrong: strong)
          else
            extension,
      ],
    ),
    child: reader,
  );
}

Color _checkInk(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? context.colors.bgPage
        : context.colors.onAccent;

/// A design-system button for a part: tonal (`.wbtn`) or the teal tertiary
/// (`.wtert`), 44 high. [block] fills the width (phone).
Widget _walkButton(
  BuildContext context, {
  required Key key,
  required String label,
  required VoidCallback onPressed,
  required bool tonal,
  bool block = false,
}) =>
    WebButton(
      key: key,
      label: label,
      onPressed: onPressed,
      kind: tonal ? PantasButtonKind.secondary : PantasButtonKind.tertiary,
      tone: tonal ? null : PantasButtonTone.accent,
      height: PantasSize.btn,
      expand: block,
    );

// ---------------------------------------------------------------------------
// Painted marks
// ---------------------------------------------------------------------------

/// The filled accent disc with a check (`.fa` and the check path).
class _CheckDisc extends CustomPainter {
  const _CheckDisc({required this.fill, required this.ink});
  final Color fill;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      const Offset(10, 10),
      10,
      Paint()..color = fill,
    );
    final path = Path()
      ..moveTo(5.5, 10.4)
      ..lineTo(8.5, 13.4)
      ..lineTo(14.5, 7);
    canvas.drawPath(
      path,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckDisc old) => old.fill != fill || old.ink != ink;
}

/// The neutral cross in a ring that marks a wrong line (`.fz.ss`).
class _CrossRing extends CustomPainter {
  const _CrossRing(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      const Offset(10, 10),
      9,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final cross = Path()
      ..moveTo(7, 7)
      ..lineTo(13, 13)
      ..moveTo(13, 7)
      ..lineTo(7, 13);
    canvas.drawPath(
      cross,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CrossRing old) => old.color != color;
}

/// The small up arrow at the right of a checklist row.
class _UpArrow extends CustomPainter {
  const _UpArrow(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(10, 15.5)
        ..lineTo(10, 5)
        ..moveTo(5.5, 9.5)
        ..lineTo(10, 5)
        ..lineTo(14.5, 9.5),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_UpArrow old) => old.color != color;
}

Widget _mark(Key key, CustomPainter painter) => ExcludeSemantics(
      child: CustomPaint(key: key, size: const Size(20, 20), painter: painter),
    );

// ---------------------------------------------------------------------------
// Reveal
// ---------------------------------------------------------------------------

/// Opens and closes its child: height over 240 ms on the house curve, opacity
/// over 180 ms on the fade curve (`.rv`). With Reduce Motion the end state
/// shows at once. A closed child is built but not shown, so it takes no
/// focus, no tap and no screen reader word. Every change sends a
/// [ReaderResizedNotification] when it ends, so the page can measure itself.
class WalkReveal extends StatefulWidget {
  const WalkReveal({required this.open, required this.child, super.key});

  final bool open;
  final Widget child;

  @override
  State<WalkReveal> createState() => _WalkRevealState();
}

class _WalkRevealState extends State<WalkReveal> with TickerProviderStateMixin {
  late final AnimationController _height;
  late final AnimationController _fade;
  late final Animation<double> _size;
  late final Animation<double> _opacity;
  var _moving = false;

  @override
  void initState() {
    super.initState();
    final value = widget.open ? 1.0 : 0.0;
    _height = AnimationController(
      vsync: this,
      duration: PantasDurations.medium1,
      value: value,
    )..addStatusListener(_heightStatus);
    _fade = AnimationController(
      vsync: this,
      duration: PantasDurations.short3,
      value: value,
    );
    _size = CurvedAnimation(parent: _height, curve: PantasCurves.house);
    _opacity = CurvedAnimation(parent: _fade, curve: PantasCurves.fade);
  }

  @override
  void didUpdateWidget(WalkReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open == widget.open) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _height.value = widget.open ? 1 : 0;
      _fade.value = widget.open ? 1 : 0;
      _resized();
      return;
    }
    _moving = true;
    if (widget.open) {
      unawaited(_height.forward());
      unawaited(_fade.forward());
    } else {
      unawaited(_height.reverse());
      unawaited(_fade.reverse());
    }
  }

  void _heightStatus(AnimationStatus status) {
    if (!_moving) return;
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _moving = false;
      _resized();
    }
  }

  /// Tells the page, once the frame is laid out, that its length changed.
  void _resized() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) const ReaderResizedNotification().dispatch(context);
    });
  }

  @override
  void dispose() {
    _height.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_height, _fade]),
        child: widget.child,
        builder: (context, child) {
          final closed = _height.isDismissed && !widget.open;
          final grown = _size.value >= 1;
          return Offstage(
            offstage: closed,
            child: ExcludeFocus(
              excluding: closed,
              child: ClipRect(
                clipBehavior: grown ? Clip.none : Clip.hardEdge,
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _size.value,
                  child: FadeTransition(opacity: _opacity, child: child),
                ),
              ),
            ),
          );
        },
      );
}

// ---------------------------------------------------------------------------
// Tap-back: the controller, its scope and the targets
// ---------------------------------------------------------------------------

/// What the tap-back shows on a target: the tint that fades, or, with Reduce
/// Motion, the outline that stays.
class WalkHighlight {
  const WalkHighlight({
    required this.slug,
    required this.serial,
    required this.outline,
  });

  final String slug;
  final int serial;
  final bool outline;
}

class _WalkEntry {
  _WalkEntry({required this.context, required this.reveal});

  /// The target's context, or null once it has left the tree.
  final BuildContext? Function() context;

  /// Opens the steps that hide the target. True when something opened.
  final bool Function() reveal;
}

/// One controller for a rendered lesson. It knows every target by its slug
/// (a pair's id or a heading's anchor), opens the steps that hide one, scrolls
/// it to the middle and starts the highlight.
class WalkController {
  final Map<String, _WalkEntry> _targets = {};

  /// The target now lit, or null.
  final ValueNotifier<WalkHighlight?> highlight = ValueNotifier(null);
  var _serial = 0;
  var _disposed = false;

  void _register(String slug, _WalkEntry entry) => _targets[slug] = entry;

  void _unregister(String slug, _WalkEntry entry) {
    if (identical(_targets[slug], entry)) _targets.remove(slug);
  }

  /// Takes the reader to the target named [slug]. A slug nothing registered
  /// does nothing. [still] is the Reduce Motion setting.
  Future<void> go(String slug, {required bool still}) async {
    final entry = _targets[slug];
    if (entry == null || _disposed) return;
    final serial = ++_serial;
    highlight.value = null;
    final opened = entry.reveal();
    if (opened) {
      if (still) {
        await SchedulerBinding.instance.endOfFrame;
      } else {
        await Future<void>.delayed(PantasDurations.medium1);
      }
    }
    if (_disposed || serial != _serial) return;
    final target = entry.context();
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        alignment: .5,
        duration: still ? Duration.zero : _scrollDuration,
        curve: PantasCurves.move,
      );
    }
    if (_disposed || serial != _serial) return;
    highlight.value = WalkHighlight(slug: slug, serial: serial, outline: still);
  }

  void dispose() {
    _disposed = true;
    highlight.dispose();
  }
}

class _WalkScopeData extends InheritedWidget {
  const _WalkScopeData({required this.controller, required super.child});
  final WalkController controller;

  @override
  bool updateShouldNotify(_WalkScopeData oldWidget) => false;
}

/// Holds the controller of one lesson. It lives as long as the lesson is on
/// screen, so a Reduce Motion outline stays until the reader leaves.
class WalkScope extends StatefulWidget {
  const WalkScope({required this.child, super.key});

  final Widget child;

  /// The controller of the lesson above [context], or null.
  static WalkController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_WalkScopeData>()?.controller;

  @override
  State<WalkScope> createState() => _WalkScopeState();
}

class _WalkScopeState extends State<WalkScope> {
  final _controller = WalkController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _WalkScopeData(controller: _controller, child: widget.child);
}

/// Tells a target which step group it sits in and how to open the example.
class _WalkGroupScope extends InheritedWidget {
  const _WalkGroupScope({
    required this.steps,
    required this.index,
    required super.child,
  });

  final _WalkStepsState steps;
  final int index;

  @override
  bool updateShouldNotify(_WalkGroupScope oldWidget) => false;
}

/// Wraps a pair or a heading so a checklist tap can reach it, and draws the
/// tint (or the Reduce Motion outline) behind it.
///
/// The tint sits 12 px outside a block (radius 20) and 8 by 12 outside a
/// heading (radius 12, [heading]); it holds 300 ms and fades over 1200 ms.
class WalkTarget extends StatefulWidget {
  const WalkTarget({
    required this.slug,
    required this.child,
    this.heading = false,
    super.key,
  });

  final String slug;
  final Widget child;
  final bool heading;

  @override
  State<WalkTarget> createState() => _WalkTargetState();
}

class _WalkTargetState extends State<WalkTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  late final Animation<double> _opacity;
  late final _WalkEntry _entry;
  WalkController? _controller;
  _WalkGroupScope? _group;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: PantasDurations.wait + _tintFade,
    );
    final hold = PantasDurations.wait.inMilliseconds /
        (PantasDurations.wait + _tintFade).inMilliseconds;
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _clock,
        curve: Interval(hold, 1, curve: PantasCurves.fade),
      ),
    );
    _entry = _WalkEntry(
      context: () => mounted ? context : null,
      reveal: () => _group?.steps._revealFrom(_group!.index) ?? false,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = context.dependOnInheritedWidgetOfExactType<_WalkGroupScope>();
    final scope = WalkScope.maybeOf(context);
    if (identical(scope, _controller)) return;
    _detach();
    _controller = scope
      ?.._register(widget.slug, _entry)
      ..highlight.addListener(_lit);
  }

  @override
  void didUpdateWidget(WalkTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug == widget.slug) return;
    _controller
      ?.._targets.remove(oldWidget.slug)
      .._register(widget.slug, _entry);
  }

  void _detach() {
    _controller
      ?.._unregister(widget.slug, _entry)
      ..highlight.removeListener(_lit);
  }

  void _lit() {
    final lit = _controller?.highlight.value;
    if (lit != null && lit.slug == widget.slug && !lit.outline) {
      unawaited(_clock.forward(from: 0));
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _detach();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lit = _controller?.highlight.value;
    final mine = lit != null && lit.slug == widget.slug;
    final inset = widget.heading
        ? const EdgeInsets.symmetric(
            horizontal: PantasSpace.s12,
            vertical: PantasSpace.s8,
          )
        : const EdgeInsets.all(PantasSpace.s12);
    final radius = BorderRadius.circular(
      widget.heading ? PantasRadius.md : _tintRadius,
    );
    final accent = context.colors.accent;
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        if (mine && !lit.outline)
          Positioned(
            left: -inset.left,
            right: -inset.right,
            top: -inset.top,
            bottom: -inset.bottom,
            child: IgnorePointer(
              key: ValueKey('walk-tint-${widget.slug}'),
              child: FadeTransition(
                opacity: _opacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.accentTint,
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ),
        if (mine && lit.outline)
          Positioned(
            left: -inset.left,
            right: -inset.right,
            top: -inset.top,
            bottom: -inset.bottom,
            child: IgnorePointer(
              child: DecoratedBox(
                key: ValueKey('walk-outline-${widget.slug}'),
                decoration: BoxDecoration(
                  border: Border.all(color: accent, width: 2),
                  borderRadius: radius,
                ),
              ),
            ),
          ),
        KeyedSubtree(
          key: ValueKey('walk-target-${widget.slug}'),
          child: widget.child,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Check and Try the last step
// ---------------------------------------------------------------------------

/// The Quick Check card, and the same card for "Try the last step": a label,
/// a question, "Show answer", and an answer that opens in place. After the
/// answer shows, the button is gone.
class WalkCheckCard extends StatefulWidget {
  const WalkCheckCard({
    required this.label,
    required this.question,
    required this.answer,
    super.key,
  });

  final String label;
  final List<Map<String, Object?>> question;
  final List<Map<String, Object?>> answer;

  @override
  State<WalkCheckCard> createState() => _WalkCheckCardState();
}

class _WalkCheckCardState extends State<WalkCheckCard> {
  final _button = FocusNode(
    debugLabel: 'Show answer',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final _answer = FocusNode(debugLabel: 'Answer', skipTraversal: true);
  var _revealed = false;

  @override
  void dispose() {
    _button.dispose();
    _answer.dispose();
    super.dispose();
  }

  void _reveal() {
    // A keyboard reader pressed the button, which is about to leave, so focus
    // moves to the answer instead of being lost.
    final moveFocus = _button.hasFocus;
    setState(() => _revealed = true);
    if (moveFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _answer.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wide = context.wideWeb;
    final answer = [...widget.answer];
    if (answer.isNotEmpty && answer.first['children'] is List<Object?>) {
      answer[0] = {
        ...answer.first,
        'children': boldFirstSentence(_maps(answer.first['children'])),
      };
    }
    final button = _showButton(context);
    return Semantics(
      container: true,
      label: widget.label,
      child: Container(
        key: const ValueKey('walk-card'),
        padding: EdgeInsets.all(wide ? PantasSpace.s20 : PantasSpace.s16),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.separator),
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Text(
                widget.label.toUpperCase(),
                style: _labelType(c.accent),
              ),
            ),
            const SizedBox(height: PantasSpace.s6),
            _content(context, widget.question),
            WalkReveal(
              key: const ValueKey('walk-button-reveal'),
              open: !_revealed,
              child: Padding(
                padding: const EdgeInsets.only(top: PantasSpace.s12),
                child: Focus(
                  focusNode: _button,
                  child: wide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [button],
                        )
                      : button,
                ),
              ),
            ),
            Semantics(
              liveRegion: true,
              child: WalkReveal(
                key: const ValueKey('walk-answer-reveal'),
                open: _revealed,
                child: Padding(
                  padding: const EdgeInsets.only(top: PantasSpace.s12),
                  child: Focus(
                    focusNode: _answer,
                    child: _answerPanel(context, answer),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showButton(BuildContext context) => _walkButton(
        context,
        key: const ValueKey('walk-answer-button'),
        label: 'Show answer',
        onPressed: _reveal,
        tonal: true,
        block: !context.wideWeb,
      );

  Widget _answerPanel(
    BuildContext context,
    List<Map<String, Object?>> answer,
  ) {
    final c = context.colors;
    // ds-board: walk.css .ph .wans 16/1.55
    final type = _partType(context);
    return Container(
      key: const ValueKey('walk-answer'),
      padding: const EdgeInsets.symmetric(
        horizontal: PantasSpace.s14,
        vertical: PantasSpace.s12,
      ),
      decoration: BoxDecoration(
        color: c.accentTint,
        borderRadius: BorderRadius.circular(PantasRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: PantasSpace.s2),
            child: _mark(
              const ValueKey('walk-answer-check'),
              _CheckDisc(fill: c.accent, ink: _checkInk(context)),
            ),
          ),
          const SizedBox(width: PantasSpace.s10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < answer.length; i++) ...[
                  if (i > 0) const SizedBox(height: PantasSpace.s8),
                  _content(
                    context,
                    [answer[i]],
                    style: type,
                    body: c.readerNoteText,
                    strong: c.readerNoteText,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Why?
// ---------------------------------------------------------------------------

/// The small teal "Why?" button and the panel it opens. The label becomes
/// "Hide" while the panel is open.
class WalkWhy extends StatefulWidget {
  const WalkWhy({required this.body, super.key});

  final List<Map<String, Object?>> body;

  @override
  State<WalkWhy> createState() => _WalkWhyState();
}

class _WalkWhyState extends State<WalkWhy> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // The board bolds a panel's first sentence when it is a question.
    final body = [...widget.body];
    if (body.isNotEmpty && body.first['children'] is List<Object?>) {
      body[0] = {
        ...body.first,
        'children': boldFirstQuestion(_maps(body.first['children'])),
      };
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The label lines up with the text above it (`.why .wtert` -14).
        Transform.translate(
          offset: const Offset(-PantasSpace.s14, 0),
          // A row keeps the button at its natural width in a stretching column.
          child: Row(
            children: [
              MergeSemantics(
                child: Semantics(
                  expanded: _open,
                  child: _walkButton(
                    context,
                    key: const ValueKey('walk-why-button'),
                    label: _open ? 'Hide' : 'Why?',
                    onPressed: () => setState(() => _open = !_open),
                    tonal: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        WalkReveal(
          key: const ValueKey('walk-why-reveal'),
          open: _open,
          child: Padding(
            padding: const EdgeInsets.only(top: PantasSpace.s6),
            child: Container(
              key: const ValueKey('walk-why-panel'),
              padding: const EdgeInsets.symmetric(
                horizontal: PantasSpace.s16,
                vertical: PantasSpace.s14,
              ),
              decoration: BoxDecoration(
                color: c.readerDeep,
                border: Border.all(color: c.separator),
                borderRadius: BorderRadius.circular(PantasRadius.md),
              ),
              child: _content(
                context,
                body,
                // ds-board: walk.css .wpanel 17/1.6
                style: _partType(context, height: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Right and wrong pair
// ---------------------------------------------------------------------------

/// A right line in a card, a wrong line under it with no card, and the note
/// under both. Always open, stacked at every width. Wrong is quieter: gray,
/// one size smaller, a neutral cross, never red.
class WalkPair extends StatelessWidget {
  const WalkPair({
    required this.right,
    required this.wrong,
    required this.note,
    super.key,
  });

  final List<Map<String, Object?>> right;
  final List<Map<String, Object?>> wrong;
  final List<Map<String, Object?>> note;

  Widget _head(String label, Key icon, CustomPainter mark, Color color) => Row(
        children: [
          _mark(icon, mark),
          const SizedBox(width: PantasSpace.s8),
          Semantics(
            label: label,
            excludeSemantics: true,
            child: Text(label.toUpperCase(), style: _labelType(color)),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wide = context.wideWeb;
    return Semantics(
      container: true,
      label: 'Right and wrong',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const ValueKey('walk-pair-right'),
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s16,
              vertical: PantasSpace.s14,
            ),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(color: c.separator),
              borderRadius: BorderRadius.circular(PantasRadius.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _head(
                  'Right',
                  const ValueKey('walk-pair-right-icon'),
                  _CheckDisc(fill: c.accent, ink: _checkInk(context)),
                  c.accent,
                ),
                const SizedBox(height: PantasSpace.s8),
                _content(
                  context,
                  [_paragraph(right)],
                  style: _partType(context),
                  body: c.label,
                  strong: c.label,
                ),
              ],
            ),
          ),
          Padding(
            key: const ValueKey('walk-pair-wrong'),
            // ds-board: walk.css .pwr padding 12 17 0 (17 has no token: 16)
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s12,
              PantasSpace.s16,
              PantasSpace.s0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _head(
                  'Wrong',
                  const ValueKey('walk-pair-wrong-icon'),
                  _CrossRing(c.secondaryLabel),
                  c.secondaryLabel,
                ),
                const SizedBox(height: PantasSpace.s8),
                _content(
                  context,
                  [_paragraph(wrong)],
                  // One size under Right: 16 wide, 15 on a phone.
                  style: wide ? PantasType.webReaderBlock : PantasType.webSub,
                  body: c.secondaryLabel,
                  strong: c.secondaryLabel,
                ),
              ],
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: PantasSpace.s12),
            _content(context, note),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trap checklist
// ---------------------------------------------------------------------------

/// One line of the trap checklist: the cue, the right move after it, and the
/// slug of the pair or heading it points at.
class WalkChecklistItem {
  const WalkChecklistItem({
    required this.cue,
    required this.move,
    required this.target,
  });

  final List<Map<String, Object?>> cue;
  final List<Map<String, Object?>> move;
  final String target;
}

/// The "Traps to Watch For" checklist. A tap takes the reader to the pair or
/// the heading the line points at.
class WalkChecklist extends StatelessWidget {
  const WalkChecklist({required this.items, super.key});

  final List<WalkChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      key: const ValueKey('walk-checklist'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.separator),
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++)
            _ChecklistRow(index: i, item: items[i]),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatefulWidget {
  const _ChecklistRow({required this.index, required this.item});

  final int index;
  final WalkChecklistItem item;

  @override
  State<_ChecklistRow> createState() => _ChecklistRowState();
}

class _ChecklistRowState extends State<_ChecklistRow> {
  var _hovered = false;
  var _pressed = false;
  var _focused = false;

  void _go() {
    final controller = WalkScope.maybeOf(context);
    if (controller == null) return;
    unawaited(
      controller.go(
        widget.item.target,
        still: MediaQuery.disableAnimationsOf(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wide = context.wideWeb;
    final item = widget.item;
    final still = MediaQuery.disableAnimationsOf(context);
    // The cue is semibold in the heading ink; the move follows in body ink.
    final cue = [
      for (final run in item.cue)
        {
          ...run,
          'marks': [
            ...(run['marks'] is List<Object?>
                ? run['marks']! as List<Object?>
                : const <Object?>[]),
            'strong',
          ],
        },
    ];
    final move = [...item.move];
    if (cue.isNotEmpty &&
        move.isNotEmpty &&
        move.first['text'] is String &&
        !(move.first['text']! as String).startsWith(RegExp(r'\s'))) {
      move[0] = {...move.first, 'text': ' ${move.first['text']}'};
    }
    final fill = _pressed
        ? c.accentTint
        : _hovered
            ? c.readerDeep
            : Colors.transparent;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${_spoken(item.cue)}${_spoken(item.move)}. Go to its step',
      onTap: _go,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: FocusableActionDetector(
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter, includeRepeats: false):
                ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space, includeRepeats: false):
                ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _go();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: _go,
            child: Stack(
              children: [
                AnimatedContainer(
                  key: ValueKey('walk-checklist-row-${widget.index}'),
                  duration: still ? Duration.zero : PantasDurations.short2,
                  curve: PantasCurves.fade,
                  constraints: const BoxConstraints(minHeight: PantasSize.btn),
                  padding: wide
                      // ds-board: walk.css .clr padding 14 18
                      ? const EdgeInsets.symmetric(
                          horizontal: PantasSpace.s18,
                          vertical: PantasSpace.s14,
                        )
                      // ds-board: walk.css .ph .clr padding 13 14 13 16
                      // (13 has no token: 14, which also brings the row
                      // heights closer to the board's)
                      : const EdgeInsets.fromLTRB(
                          PantasSpace.s16,
                          PantasSpace.s14,
                          PantasSpace.s14,
                          PantasSpace.s14,
                        ),
                  decoration: BoxDecoration(
                    color: fill,
                    border: widget.index == 0
                        ? null
                        : Border(top: BorderSide(color: c.separator)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _content(
                          context,
                          [
                            _paragraph([...cue, ...move]),
                          ],
                          style: _partType(context, height: wide ? 1.55 : 1.5),
                          strong: c.label,
                        ),
                      ),
                      SizedBox(
                        width: wide ? PantasSpace.s14 : PantasSpace.s12,
                      ),
                      _mark(
                        ValueKey('walk-checklist-arrow-${widget.index}'),
                        _UpArrow(c.accent),
                      ),
                    ],
                  ),
                ),
                if (_focused)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        key: ValueKey('walk-checklist-ring-${widget.index}'),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.accent, width: 2),
                          borderRadius: BorderRadius.circular(_cardRadius),
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

// ---------------------------------------------------------------------------
// Stepped solutions
// ---------------------------------------------------------------------------

/// The step groups of one solution. The first group shows; the rest open one
/// at a time with "Next step", or all at once with "Show all steps". The row
/// goes once every group shows. A tap-back that targets a hidden group opens
/// them all. A solution that is not [stepped] shows every group at once, with
/// the same space between groups.
class WalkSteps extends StatefulWidget {
  const WalkSteps({required this.groups, this.stepped = true, super.key});

  /// One widget per step group, in order. Each is a column of its blocks.
  final List<Widget> groups;

  /// Whether the groups open one at a time (four or more steps).
  final bool stepped;

  @override
  State<WalkSteps> createState() => _WalkStepsState();
}

class _WalkStepsState extends State<WalkSteps> {
  final _row = FocusNode(
    debugLabel: 'Step buttons',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final _landing = <FocusNode>[];
  late var _shown = widget.stepped ? 1 : widget.groups.length;

  int get _count => widget.groups.length;

  FocusNode _landingFor(int index) {
    while (_landing.length <= index) {
      _landing.add(FocusNode(debugLabel: 'Step', skipTraversal: true));
    }
    return _landing[index];
  }

  @override
  void dispose() {
    _row.dispose();
    for (final node in _landing) {
      node.dispose();
    }
    super.dispose();
  }

  /// Opens every group when [index] is still hidden. True when it did.
  bool _revealFrom(int index) {
    if (index < _shown) return false;
    setState(() => _shown = _count);
    return true;
  }

  void _showTo(int shown) {
    final from = _shown;
    final moveFocus = _row.hasFocus && shown >= _count;
    setState(() => _shown = shown.clamp(1, _count));
    // The button that was pressed is about to leave, so focus moves to the
    // first step it opened.
    if (moveFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _landingFor(from).requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final last = _count - 1;
    Widget group(int i) => _WalkGroupScope(
          steps: this,
          index: i,
          child: Focus(
            focusNode: _landingFor(i),
            skipTraversal: true,
            child: Padding(
              // ds-board: walk.css .sg padding-bottom 24, none on the last
              padding: EdgeInsets.only(
                bottom: i < last ? PantasSpace.s24 : PantasSpace.s0,
              ),
              child: widget.groups[i],
            ),
          ),
        );
    if (!widget.stepped) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (var i = 0; i < _count; i++) group(i)],
      );
    }
    final all = _walkButton(
      context,
      key: const ValueKey('walk-show-all-steps'),
      label: 'Show all steps',
      onPressed: () => _showTo(_count),
      tonal: false,
      block: !wide,
    );
    final next = _walkButton(
      context,
      key: const ValueKey('walk-next-step'),
      label: 'Next step',
      onPressed: () => _showTo(_shown + 1),
      tonal: true,
      block: !wide,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _count; i++)
          if (i == 0)
            group(i)
          else
            WalkReveal(open: _shown > i, child: group(i)),
        WalkReveal(
          key: const ValueKey('walk-step-row'),
          open: _shown < _count,
          child: Focus(
            focusNode: _row,
            child: Padding(
              // ds-board: walk.css .srow padding 6 0 10
              padding: const EdgeInsets.only(
                top: PantasSpace.s6,
                bottom: PantasSpace.s10,
              ),
              child: wide
                  // Secondary first, the main button last at the right end.
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        all,
                        const SizedBox(width: PantasSpace.s8),
                        next,
                      ],
                    )
                  // Stacked, the main button on top, both the same width.
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        next,
                        const SizedBox(height: PantasSpace.s8),
                        all,
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
