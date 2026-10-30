import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_shape.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Marks the main sections of a loading skeleton so tests and layout checks can
/// compare them with the loaded screen.
const skeletonSectionKey = ValueKey<String>('skeleton-section');

/// Shows its skeleton after 300ms, pulses it, and holds it still under reduced
/// motion. Wrap a whole skeleton layout in one of these so every block pulses
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
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  Timer? _delay;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _delay = Timer(const Duration(milliseconds: 300), () {
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
                      ? 1 - .55 * PantasCurves.easeInOut.transform(t * 2)
                      : .45 +
                          .55 * PantasCurves.easeInOut.transform((t - .5) * 2);
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
    this.radius = 6,
    this.section = false,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  /// Tags the block as a main section of the skeleton.
  final bool section;

  @override
  Widget build(BuildContext context) => Container(
        key: section ? skeletonSectionKey : null,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.skeleton,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// A large card placeholder. Radius 18 is the card radius on every screen.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({required this.height, this.width, super.key});
  final double height;
  final double? width;
  @override
  Widget build(BuildContext context) => SkeletonBlock(
        width: width,
        height: height,
        radius: PantasShape.cardRadius,
        section: true,
      );
}

/// The placeholder for a grouped list surface (radius 14) on phone.
class SkeletonSurface extends StatelessWidget {
  const SkeletonSurface({required this.height, super.key});
  final double height;
  @override
  Widget build(BuildContext context) => SkeletonBlock(
        height: height,
        radius: PantasShape.groupRadius,
        section: true,
      );
}

/// A heading placeholder followed by a [SkeletonSurface] of [height], for a
/// phone section whose rows are too varied to draw one by one.
class SkeletonSection extends StatelessWidget {
  const SkeletonSection({
    required this.height,
    this.headerWidth = 140,
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
  const SkeletonHeading({this.width = 140, this.height = 17.55, super.key});
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
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
    this.headerWidth = 140,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
  const WebSkeletonEyebrow({this.width = 140, super.key});
  final double width;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
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
    this.gap = 24,
    this.headerWidth = 140,
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
        const SkeletonBlock(width: 90, height: 14),
        const SizedBox(height: 18),
        const SkeletonBlock(height: 20),
        const SizedBox(height: 10),
        const SkeletonBlock(height: 20),
        const SizedBox(height: 10),
        const FractionallySizedBox(
          widthFactor: .6,
          alignment: Alignment.centerLeft,
          child: SkeletonBlock(height: 20),
        ),
        const SizedBox(height: 26),
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) SizedBox(height: wide ? 12 : 10),
          SkeletonBlock(
            height: wide ? 64 : 58,
            radius: PantasShape.groupRadius,
            section: true,
          ),
        ],
      ],
    );
    return SkeletonPulse(
      child: Padding(
        padding: EdgeInsets.fromLTRB(wide ? 40 : 16, 12, wide ? 40 : 16, 16),
        child: wide
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
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
          padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: SkeletonPulse(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: SkeletonBlock(width: 220, height: 32, radius: 9)),
                SizedBox(height: 22),
                SkeletonBlock(height: 210, radius: 18, section: true),
                SizedBox(height: 22),
                SkeletonSection(height: 240, headerWidth: 120),
              ],
            ),
          ),
        ),
      );
}
