import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The width of a section heading placeholder.
const double _headerWidth = 140;

/// Space under a section heading placeholder.
const double _headingGap = PantasSpace.s6 + 1;

/// Space under an eyebrow placeholder.
const double _eyebrowGap = PantasSpace.s8 + 1;

/// The width of the small label above a question stem.
const double _kickerWidth = 90;

/// Space between the stem and the answer cards.
const double _stemGap = PantasSpace.s24 + PantasSpace.s2;

const double _resultsTitleWidth = 220;
const double _resultsCardHeight = 210;

/// Space between the blocks of the results page.
const double _resultsGap = PantasSpace.s20 + PantasSpace.s2;

/// Marks the main sections of a loading skeleton so tests and layout checks can
/// compare them with the loaded screen.
const skeletonSectionKey = ValueKey<String>('skeleton-section');

/// Lets the [SkeletonPulse]s below it show their shapes at the first frame
/// instead of after the usual wait. Home sets it while the logo splash is still
/// up, so the shapes are already drawn when the logo starts to fade.
class SkeletonRevealScope extends InheritedWidget {
  const SkeletonRevealScope({
    required this.immediate,
    required super.child,
    super.key,
  });

  final bool immediate;

  static bool immediateOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SkeletonRevealScope>()?.immediate ??
      false;

  @override
  bool updateShouldNotify(SkeletonRevealScope oldWidget) =>
      oldWidget.immediate != immediate;
}

/// Shows its skeleton after `PantasDurations.wait` (300ms), pulses its opacity
/// between 1 and 0.45 over `PantasDurations.pulse` (1300ms, ease in and out),
/// and holds it still under reduced motion. Wrap a whole skeleton layout in
/// one of these so every block pulses
/// together.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({
    required this.child,
    this.still = false,
    this.label = 'Loading',
    super.key,
  });

  final Widget child;

  /// Draws the skeleton without the pulse, such as the Pro gate.
  final bool still;
  final String label;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  /// Opacity falls from 1 to 0.45 (`pn-pulse`): a drop of 0.55.
  static const double _pulseDrop = .55;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: PantasDurations.pulse,
  );
  Timer? _delay;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    if (SkeletonRevealScope.immediateOf(context)) {
      // Pulsing starts in didChangeDependencies, which runs next.
      _shown = true;
      return;
    }
    _delay = Timer(PantasDurations.wait, () {
      if (!mounted) return;
      setState(() => _shown = true);
      _updatePulse();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePulse();
  }

  @override
  void didUpdateWidget(SkeletonPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  void _updatePulse() {
    if (_shown && !widget.still && !MediaQuery.disableAnimationsOf(context)) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A pulse inside another pulse would fade twice, so the inner one defers.
    if (_PulseScope.of(context)) return widget.child;
    return Semantics(
      liveRegion: true,
      label: widget.label,
      excludeSemantics: true,
      child: !_shown
          ? const SizedBox.shrink()
          : _PulseScope(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final t = _pulse.value;
                  final opacity = t <= .5
                      ? 1 - _pulseDrop * Curves.easeInOut.transform(t * 2)
                      : 1 -
                          _pulseDrop *
                              (1 - Curves.easeInOut.transform((t - .5) * 2));
                  return Opacity(
                    key: const ValueKey('loading-shapes-opacity'),
                    opacity: opacity,
                    child: child,
                  );
                },
                child: widget.child,
              ),
            ),
    );
  }
}

class _PulseScope extends InheritedWidget {
  const _PulseScope({required super.child});
  static bool of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_PulseScope>() != null;
  @override
  bool updateShouldNotify(_PulseScope oldWidget) => false;
}

/// One placeholder shape. Width is null to fill the available width.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    required this.height,
    this.width,
    this.radius,
    this.section = false,
    super.key,
  });

  final double? width;
  final double height;

  /// Null picks the system radius: `radius-xs` (5) for a line, `radius-md`
  /// (12) for a block. A block up to 24 high is a line.
  final double? radius;

  /// The tallest block that counts as a line.
  static const double _lineMax = PantasSpace.s24;

  /// Tags the block as a main section of the skeleton.
  final bool section;

  @override
  Widget build(BuildContext context) => Container(
        key: section ? skeletonSectionKey : null,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.fillSkeleton,
          borderRadius: BorderRadius.circular(
            radius ?? (height <= _lineMax ? PantasRadius.xs : PantasRadius.md),
          ),
        ),
      );
}

/// A large card placeholder. `radius-xl` (18) is the card radius.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({required this.height, this.width, super.key});
  final double height;
  final double? width;
  @override
  Widget build(BuildContext context) => SkeletonBlock(
        width: width,
        height: height,
        radius: PantasRadius.xl,
        section: true,
      );
}

/// The placeholder for a grouped list surface (`radius-lg`, 14) on phone.
class SkeletonSurface extends StatelessWidget {
  const SkeletonSurface({required this.height, super.key});
  final double height;
  @override
  Widget build(BuildContext context) => SkeletonBlock(
        height: height,
        radius: PantasRadius.lg,
        section: true,
      );
}

/// A heading placeholder followed by a [SkeletonSurface] of [height], for a
/// phone section whose rows are too varied to draw one by one.
class SkeletonSection extends StatelessWidget {
  const SkeletonSection({
    required this.height,
    this.headerWidth = _headerWidth,
    this.header = true,
    super.key,
  });
  final double height;
  final double headerWidth;
  final bool header;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header) SkeletonHeading(width: headerWidth),
          SkeletonSurface(height: height),
        ],
      );
}

/// A small label placeholder that stands in for a section heading. Its box is
/// the height of one line of section header text so the rows below do not move.
class SkeletonHeading extends StatelessWidget {
  const SkeletonHeading({
    this.width = _headerWidth,
    this.height = 17.55,
    super.key,
  });
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s16,
          PantasSpace.s0,
          PantasSpace.s16,
          _headingGap,
        ),
        child: SizedBox(
          height: height,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBlock(width: width, height: 13),
          ),
        ),
      );
}

/// The skeleton of a [GroupedSection] with [rows] rows of [rowHeight].
class SkeletonGroup extends StatelessWidget {
  const SkeletonGroup({
    this.rows = 3,
    this.rowHeight = 45,
    this.header = true,
    this.headerWidth = _headerWidth,
    super.key,
  });

  final int rows;
  final double rowHeight;
  final bool header;
  final double headerWidth;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header) SkeletonHeading(width: headerWidth),
          GroupedSection(
            children: [
              for (var i = 0; i < rows; i++)
                SizedBox(
                  height: rowHeight,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: PantasSpace.s16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: i.isEven ? .52 : .38,
                        child: const SkeletonBlock(height: 14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
}

/// The height of one line of [style].
double skeletonLineHeight(TextStyle style) =>
    (style.fontSize ?? 14) * (style.height ?? 1.2);

/// The web eyebrow label placeholder: same inset and line height as the
/// uppercase eyebrow text it replaces.
class WebSkeletonEyebrow extends StatelessWidget {
  const WebSkeletonEyebrow({this.width = _headerWidth, super.key});
  final double width;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s4,
          PantasSpace.s0,
          PantasSpace.s4,
          _eyebrowGap,
        ),
        child: SizedBox(
          height: skeletonLineHeight(context.webTokens.eb),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBlock(width: width, height: 12),
          ),
        ),
      );
}

/// Several [SkeletonGroup]s one under another, for list screens that open on
/// grouped rows. [gap] is the space the loaded screen leaves between groups.
class SkeletonGroups extends StatelessWidget {
  const SkeletonGroups({
    this.groups = 2,
    this.rows = 3,
    this.rowHeight = 45,
    this.header = true,
    this.gap = PantasSpace.s24,
    this.headerWidth = _headerWidth,
    super.key,
  });

  final int groups;
  final int rows;
  final double rowHeight;
  final bool header;
  final double gap;
  final double headerWidth;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < groups; i++) ...[
              if (i > 0) SizedBox(height: gap),
              SkeletonGroup(
                rows: rows,
                rowHeight: rowHeight,
                header: header,
                headerWidth: headerWidth,
              ),
            ],
          ],
        ),
      );
}

/// A question screen before its question arrives: the top bar, the stem, four
/// answer cards and the action button.
class SkeletonQuestionPage extends StatelessWidget {
  const SkeletonQuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SkeletonBlock(width: _kickerWidth, height: 14),
        const SizedBox(height: PantasSpace.s18),
        const SkeletonBlock(height: PantasSpace.s20),
        const SizedBox(height: PantasSpace.s10),
        const SkeletonBlock(height: PantasSpace.s20),
        const SizedBox(height: PantasSpace.s10),
        const FractionallySizedBox(
          widthFactor: .6,
          alignment: Alignment.centerLeft,
          child: SkeletonBlock(height: PantasSpace.s20),
        ),
        const SizedBox(height: _stemGap),
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) SizedBox(height: wide ? PantasSpace.s12 : PantasSpace.s10),
          SkeletonBlock(
            height: wide ? 64 : 58,
            radius: PantasRadius.lg,
            section: true,
          ),
        ],
      ],
    );
    return SkeletonPulse(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          wide ? PantasSpace.s40 : PantasSpace.s16,
          PantasSpace.s12,
          wide ? PantasSpace.s40 : PantasSpace.s16,
          PantasSpace.s16,
        ),
        child: wide
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: PantasLayout.qcol + PantasSpace.s40,
                  ),
                  child: body,
                ),
              )
            : body,
      ),
    );
  }
}

/// A results page before its score arrives: the title, the score card and the
/// subject group.
class SkeletonResultsPage extends StatelessWidget {
  const SkeletonResultsPage({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: PantasSpace.s16,
            vertical: PantasSpace.s24,
          ),
          child: SkeletonPulse(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SkeletonBlock(
                    width: _resultsTitleWidth,
                    height: PantasSpace.s32,
                  ),
                ),
                SizedBox(height: _resultsGap),
                SkeletonCard(height: _resultsCardHeight),
                SizedBox(height: _resultsGap),
                SkeletonSection(height: 240, headerWidth: 120),
              ],
            ),
          ),
        ),
      );
}
