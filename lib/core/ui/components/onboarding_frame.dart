// ignore_for_file: avoid_setters_without_getters, cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Wide web: the width of every step's content column.
const double onboardingColumnWidth = 580;

/// Wide web: space below the action row, in the window and at the end of the
/// list, so the row rests where it was pinned.
const double onboardingActionsMargin = 24;

/// What the still part of onboarding needs to know about the visible step.
@immutable
class OnboardingFrameSpec {
  const OnboardingFrameSpec({
    this.progress,
    this.surfaceBackground = false,
    this.bare = false,
    this.hideBack = false,
  });

  /// Step number from 1 to 6, or null when the step has no number.
  final int? progress;

  final bool surfaceBackground;

  /// Wide web: show the top bar only, with no steps list and no scrolling.
  final bool bare;

  /// Phone: keep the Back row's space but draw no Back, for a step with no way
  /// back (the under-age block).
  final bool hideBack;

  @override
  bool operator ==(Object other) =>
      other is OnboardingFrameSpec &&
      other.progress == progress &&
      other.surfaceBackground == surfaceBackground &&
      other.bare == bare &&
      other.hideBack == hideBack;

  @override
  int get hashCode => Object.hash(progress, surfaceBackground, bare, hideBack);
}

/// Carries the visible step's frame needs up to the frame that stays on screen.
///
/// A step cannot change the frame while it builds, so [publish] applies the new
/// spec after the frame. [onBack] is read when the student presses Back.
class OnboardingFrameController extends ValueNotifier<OnboardingFrameSpec> {
  OnboardingFrameController() : super(const OnboardingFrameSpec());

  VoidCallback? onBack;
  OnboardingFrameSpec? _pending;
  bool _scheduled = false;
  bool _disposed = false;

  void publish(OnboardingFrameSpec spec, VoidCallback? back) {
    onBack = back;
    if (spec == (_pending ?? value)) return;
    _pending = spec;
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      final next = _pending;
      _pending = null;
      if (!_disposed && next != null) value = next;
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Tells a step whether a frame outside it already draws the top bar, steps
/// list, Back and progress.
class OnboardingFrameScope extends InheritedWidget {
  const OnboardingFrameScope({
    required this.controller,
    required this.hosted,
    required super.child,
    super.key,
  });
  final OnboardingFrameController controller;
  final bool hosted;

  /// The controller when a frame hosts this step, otherwise null.
  static OnboardingFrameController? hostOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<OnboardingFrameScope>();
    return scope != null && scope.hosted ? scope.controller : null;
  }

  @override
  bool updateShouldNotify(OnboardingFrameScope oldWidget) =>
      hosted != oldWidget.hosted || controller != oldWidget.controller;
}

/// Wraps a step's content and hands its frame needs to the host.
class OnboardingFrameClaim extends StatelessWidget {
  const OnboardingFrameClaim({
    required this.host,
    required this.spec,
    required this.onBack,
    required this.child,
    super.key,
  });
  final OnboardingFrameController host;
  final OnboardingFrameSpec spec;
  final VoidCallback? onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    host.publish(spec, onBack);
    return child;
  }
}

/// The part of onboarding that stays put while a step's content changes: the
/// top bar and steps list on wide web, Back and the progress bar on a phone.
class OnboardingFrame extends StatefulWidget {
  const OnboardingFrame({
    required this.controller,
    required this.enabled,
    required this.resetToken,
    required this.child,
    super.key,
  });
  final OnboardingFrameController controller;

  /// False for screens that draw their own whole page.
  final bool enabled;

  /// Changes with the step, so the wide scroll position returns to the top.
  final Object resetToken;
  final Widget child;

  @override
  State<OnboardingFrame> createState() => _OnboardingFrameState();
}

class _OnboardingFrameState extends State<OnboardingFrame>
    with SingleTickerProviderStateMixin {
  // Keeps the step content mounted when the frame around it changes shape.
  final GlobalKey _contentKey = GlobalKey();
  final ScrollController _scroll = ScrollController();
  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _presence, curve: PantasCurves.ease);
  bool _reduced = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (!_started) {
      _started = true;
      _syncPresence();
    }
  }

  @override
  void didUpdateWidget(OnboardingFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _syncPresence();
    if (oldWidget.resetToken != widget.resetToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients && _scroll.offset != 0) _scroll.jumpTo(0);
      });
    }
  }

  /// The frame fades in once when a framed step follows a whole-screen one.
  void _syncPresence() {
    if (!widget.enabled) {
      _presence.value = 0;
    } else if (_reduced) {
      _presence.value = 1;
    } else {
      _presence.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _presence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = KeyedSubtree(key: _contentKey, child: widget.child);
    return OnboardingFrameScope(
      controller: widget.controller,
      hosted: widget.enabled,
      child: widget.enabled
          ? ValueListenableBuilder<OnboardingFrameSpec>(
              valueListenable: widget.controller,
              child: content,
              builder: (context, spec, child) =>
                  context.wideWeb ? _wide(spec, child!) : _phone(spec, child!),
            )
          : content,
    );
  }

  Widget _phone(OnboardingFrameSpec spec, Widget child) => ColoredBox(
        color: spec.surfaceBackground
            ? context.colors.surface
            : context.colors.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                opacity: _fade,
                child: spec.hideBack
                    ? const SizedBox(height: 56)
                    : OnboardingBackBar(
                        onBack: () => widget.controller.onBack?.call(),
                      ),
              ),
              if (spec.progress != null)
                FadeTransition(
                  opacity: _fade,
                  child: OnboardingProgressBar(progress: spec.progress!),
                ),
              // Aedwon, Nov 6, 2026, over the boards' 4 px: the step title
              // needs more room below the progress bar on a phone.
              if (spec.progress != null) const SizedBox(height: 16),
              Expanded(child: child),
            ],
          ),
        ),
      );

  /// Wide web: every step uses the same 580 column in the same place, so the
  /// steps list and the content never move between steps. Aedwon decided this
  /// on Nov 2, 2026, over the boards' wider picker, study days and date steps.
  Widget _wide(OnboardingFrameSpec spec, Widget child) {
    final t = context.webTokens;
    return Material(
      color: t.colors.background,
      child: Column(
        children: [
          FadeTransition(
            opacity: _fade,
            // The boards set the logo 28 px in from the edge; the bar's own
            // 20 px inset leaves it 10 px short once the mark's margin counts.
            child: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: WebTopBar(
                leading: PantasLogo(size: 28),
                title: Text(
                  'Pantas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Expanded(
            child: spec.bare
                ? child
                : Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(
                          40,
                          40,
                          40,
                          onboardingActionsMargin,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: onboardingColumnWidth + 280,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 200),
                                const SizedBox(width: 80),
                                Expanded(child: child),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // The steps list stays still. It ignores pointers, so
                      // the wheel over it scrolls the content beneath.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 96, 40, 0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: onboardingColumnWidth + 280,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: FadeTransition(
                                    opacity: _fade,
                                    child: SizedBox(
                                      width: 200,
                                      child: OnboardingRail(
                                        progress: spec.progress,
                                      ),
                                    ),
                                  ),
                                ),
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
    );
  }
}

/// Wide web: the six setup steps beside the content (board `OB_*`).
class OnboardingRail extends StatelessWidget {
  const OnboardingRail({required this.progress, super.key});
  final int? progress;

  static const labels = [
    'Birth year',
    'Terms',
    'Your exam',
    'Exam date',
    'Study days',
    'Your name',
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final current = progress ?? 1;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return Semantics(
      label: 'Setup steps',
      container: true,
      explicitChildNodes: true,
      child: Column(
        children: [
          for (final (i, label) in labels.indexed)
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: duration,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i + 1 < current ? t.colors.accentFill : null,
                      border: Border.all(
                        color: i + 1 <= current
                            ? t.colors.accent
                            : t.strongDivider,
                        width: i + 1 == progress ? 2 : 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: i + 1 < current
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : i + 1 == progress
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: t.colors.accent,
                                ),
                              )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    style: t.style(
                      15,
                      weight:
                          i + 1 == progress ? FontWeight.w600 : FontWeight.w400,
                      color: i + 1 == progress
                          ? t.colors.label
                          : i + 1 < current
                              ? t.colors.secondaryLabel
                              : t.colors.tertiaryLabel,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Phone: the Back row above the progress bar (boards `O_*`).
class OnboardingBackBar extends StatelessWidget {
  const OnboardingBackBar({
    required this.onBack,
    this.label = 'Back',
    this.compact = false,
    super.key,
  });
  final VoidCallback? onBack;
  final String label;

  /// The settings exam picker uses a shorter row.
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
        // Boards: back label at y 21, progress bar at y 56.
        height: compact ? 49 : 56,
        child: Padding(
          padding: compact
              ? const EdgeInsets.fromLTRB(4, 4, 8, 0)
              : const EdgeInsets.fromLTRB(8, 5, 8, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onBack,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PantasIcons.back,
                    size: 24,
                    color: context.colors.accent,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    label,
                    style: context.type.body
                        .copyWith(color: context.colors.accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

/// Phone: six segments. A segment changes color over time when the step moves.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({required this.progress, super.key});
  final int progress;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 380);
    return Semantics(
      label: 'Step $progress of 6',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            for (var index = 0; index < 6; index++) ...[
              if (index > 0) const SizedBox(width: 6),
              Expanded(
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    end: index < progress
                        ? context.colors.accentFill
                        : context.colors.fill,
                  ),
                  duration: duration,
                  curve: PantasCurves.riseIn,
                  builder: (context, color, _) => DecoratedBox(
                    key: const ValueKey('onboarding-segment'),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: color,
                    ),
                    child: const SizedBox(height: 4),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wide web: an action row that sits after the content, and stays inside the
/// window when the content is taller than the window.
///
/// The row keeps its place in the layout, so the content never moves. Only the
/// painting, hit testing and semantics move it up. While pinned it sits on a
/// band of [background]. A half-point line shows on the band's top edge while
/// content is scrolled beneath it.
class StickyActions extends SingleChildRenderObjectWidget {
  const StickyActions({
    required this.background,
    required this.separator,
    required this.clearance,
    required super.child,
    super.key,
  });
  final Color background;
  final Color separator;

  /// Space between the end of the content and the row.
  final double clearance;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSticky(
        background: background,
        separator: separator,
        clearance: clearance,
        position: Scrollable.maybeOf(context)?.position,
      );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderSticky)
      ..background = background
      ..separator = separator
      ..clearance = clearance
      ..position = Scrollable.maybeOf(context)?.position;
  }
}

class _RenderSticky extends RenderProxyBox {
  _RenderSticky({
    required Color background,
    required Color separator,
    required double clearance,
    required ScrollPosition? position,
  })  : _background = background,
        _separator = separator,
        _clearance = clearance,
        _position = position;

  static const double _bandPadding = 16;

  Color _background;
  Color _separator;
  double _clearance;
  ScrollPosition? _position;

  set background(Color value) {
    if (value == _background) return;
    _background = value;
    markNeedsPaint();
  }

  set separator(Color value) {
    if (value == _separator) return;
    _separator = value;
    markNeedsPaint();
  }

  set clearance(double value) {
    if (value == _clearance) return;
    _clearance = value;
    markNeedsPaint();
  }

  set position(ScrollPosition? value) {
    if (value == _position) return;
    if (attached) _position?.removeListener(markNeedsPaint);
    _position = value;
    if (attached) _position?.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _position?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _position?.removeListener(markNeedsPaint);
    super.detach();
  }

  RenderBox? get _viewport {
    final Object? viewport = RenderAbstractViewport.maybeOf(this);
    return viewport is RenderBox && viewport.hasSize ? viewport : null;
  }

  /// Where the row sits in the viewport when the content has not moved it.
  double _naturalTop(RenderBox viewport) =>
      getTransformTo(viewport).getTranslation().y;

  /// How far up the row is drawn, zero or less.
  double get _lift {
    final viewport = _viewport;
    if (viewport == null) return 0;
    final pinnedBottom = viewport.size.height - onboardingActionsMargin;
    final lift = pinnedBottom - (_naturalTop(viewport) + size.height);
    return lift < -.01 ? lift : 0;
  }

  /// The viewport's bottom edge, in this box's own coordinates.
  double get _viewportBottom {
    final viewport = _viewport;
    return viewport == null ? 0 : viewport.size.height - _naturalTop(viewport);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final lift = _lift;
    if (lift < 0) {
      final top = offset.dy + lift - _bandPadding;
      final band = Rect.fromLTRB(
        offset.dx,
        top,
        offset.dx + size.width,
        offset.dy + _viewportBottom,
      );
      final canvas = context.canvas;
      canvas.drawRect(band, Paint()..color = _background);
      // Content shows beneath the band while it runs past the band's top.
      if (offset.dy - _clearance > top) {
        canvas.drawRect(
          Rect.fromLTWH(band.left, top, band.width, .5),
          Paint()..color = _separator,
        );
      }
    }
    super.paint(context, offset + Offset(0, lift));
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final lift = _lift;
    if (lift == 0) return super.hitTest(result, position: position);
    final moved = position - Offset(0, lift);
    if (child != null && size.contains(moved)) {
      if (child!.hitTest(result, position: moved)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    // The band takes hits meant for the list beneath it.
    final band = Rect.fromLTWH(
      0,
      lift - _bandPadding,
      size.width,
      _viewportBottom - lift + _bandPadding,
    );
    if (band.contains(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(Matrix4.translationValues(0, _lift, 0));
  }
}
