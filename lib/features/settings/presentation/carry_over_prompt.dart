import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';

Future<bool?> showCarryOverPrompt({
  required BuildContext context,
  required String examShortName,
  required int carryableCount,
  String? previousExam,
  Future<void> Function({required bool count})? onDecision,
}) async {
  if (carryableCount <= 0) return null;
  bool? selected;
  final request = CarryOverRequest(
    exam: examShortName,
    previous: previousExam,
    onCounted: () => selected = true,
    onDecision: onDecision,
  );
  final router = GoRouter.maybeOf(context);
  final result = router != null
      ? await context.push<bool>('/settings/exam/transfer', extra: request)
      : await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => CarryOverScreen(
              exam: request.exam,
              previous: request.previous,
              onCounted: request.onCounted,
              onDecision: request.onDecision,
            ),
          ),
        );
  return result ?? selected;
}

class CarryOverScreen extends ConsumerStatefulWidget {
  const CarryOverScreen({
    required this.exam,
    required this.onCounted,
    super.key,
    this.previous,
    this.onDecision,
  });
  final VoidCallback onCounted;
  final Future<void> Function({required bool count})? onDecision;
  final String exam;
  final String? previous;
  @override
  ConsumerState<CarryOverScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<CarryOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5400),
    );
  }

  bool _counted = false;
  bool _saving = false;
  bool _failed = false;
  bool _lastDecision = true;
  Future<void> _choose({required bool count}) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
      _lastDecision = count;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      await widget.onDecision?.call(count: count);
      if (!mounted) return;
      if (!count) {
        Navigator.of(context).pop(false);
        return;
      }
      widget.onCounted();
      setState(() => _counted = true);
      if (context.wideWeb) {
        _controller.duration = const Duration(milliseconds: 6400);
        if (MediaQuery.disableAnimationsOf(context)) {
          _controller.value = 1;
        } else {
          await _controller.forward();
        }
        return;
      }
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        await _controller.forward();
      }
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (error, stack) {
      await telemetry.recordError(error, stack);
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _wideTransfer(BuildContext context, String previousName) {
    final t = context.webTokens;
    final c = t.colors;
    final extra =
        (MediaQuery.textScalerOf(context).scale(16) / 16 - 1).clamp(0.0, 3.0) *
            180;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final ms = (_controller.value * 6400).clamp(0.0, 6100.0);
        double at(double a, double b, [Curve curve = Curves.ease]) =>
            curve.transform(((ms - a) / (b - a)).clamp(0.0, 1.0));
        final group = at(750, 1200, const Cubic(.3, .9, .3, 1));
        final drain = at(1450, 3050, const Cubic(.45, 0, .25, 1));
        final labels = at(3300, 3600);
        final check = at(3350, 3650, const Cubic(.3, 1.5, .5, 1));
        final prompt = 1 - at(700, 1000);
        final done = at(3800, 4150);
        Widget vessel(String name, {required bool old}) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 104,
                  height: 168,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color:
                        old ? Color.lerp(c.fill, c.accentTint, drain) : c.fill,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: c.separator, width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      Transform.translate(
                        key: ValueKey(
                          old ? 'web-transfer-old' : 'web-transfer-new',
                        ),
                        offset:
                            Offset(0, 168 * 1.1 * (old ? drain : 1 - drain)),
                        child: SizedBox.expand(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF14937D),
                                        Color(0xFF0B7A68),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -8 -
                                    112 *
                                        (MediaQuery.disableAnimationsOf(context)
                                            ? 0
                                            : ms / 6400),
                                top: -10,
                                child: CustomPaint(
                                  key: ValueKey(
                                    old
                                        ? 'web-transfer-wave-old'
                                        : 'web-transfer-wave-new',
                                  ),
                                  size: const Size(224, 12),
                                  painter: const _TransferWave(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!old)
                        Center(
                          child: Opacity(
                            opacity: check.clamp(0, 1),
                            child: Transform.scale(
                              scale: .4 + .6 * check,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: t.style(
                    15,
                    weight: FontWeight.w600,
                    color: Color.lerp(
                      old ? c.accent : c.secondaryLabel,
                      old ? c.secondaryLabel : c.accent,
                      labels,
                    ),
                  ),
                ),
              ],
            );
        Widget fade(double value, double y, Widget child) => IgnorePointer(
              ignoring: value < 1,
              child: Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, y * (1 - value)),
                  child: child,
                ),
              ),
            );
        return WebCard(
          radius: 22,
          child: SizedBox(
            height: 476 + extra,
            child: Stack(
              children: [
                Positioned(
                  top: 34,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, 58 * group),
                      child: Transform.scale(
                        scale: 1 + .12 * group,
                        child: SizedBox(
                          width: 278,
                          height: 202,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 98,
                                top: 134,
                                width: 82,
                                height: 12,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: ColoredBox(
                                    color: c.fill,
                                    child: Transform.translate(
                                      offset: Offset(
                                        82 *
                                            (-1.01 +
                                                1.01 *
                                                    at(
                                                      1250,
                                                      1550,
                                                      const Cubic(
                                                        .45,
                                                        0,
                                                        .25,
                                                        1,
                                                      ),
                                                    ) +
                                                1.01 *
                                                    at(
                                                      3050,
                                                      3350,
                                                      const Cubic(
                                                        .45,
                                                        0,
                                                        .25,
                                                        1,
                                                      ),
                                                    )),
                                        0,
                                      ),
                                      child: ColoredBox(color: c.accentFill),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                child: vessel(previousName, old: true),
                              ),
                              Positioned(
                                left: 174,
                                top: 0,
                                child: vessel(widget.exam, old: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 266,
                  left: 40,
                  right: 40,
                  child: fade(
                    prompt,
                    10,
                    Column(
                      children: [
                        Text("You're not starting from zero", style: t.h3),
                        const SizedBox(height: 6),
                        Text(
                          'Some content on $previousName '
                          'is on ${widget.exam} too. '
                          'Count them and continue where you are.',
                          textAlign: TextAlign.center,
                          style: t.style(
                            16,
                            height: 1.45,
                            color: c.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 338 + extra,
                  left: 40,
                  right: 40,
                  child: fade(
                    at(3650, 4000),
                    8,
                    Column(
                      children: [
                        Text('You pick up where you are', style: t.h3),
                        const SizedBox(height: 6),
                        Text(
                          'Your $previousName answers '
                          'stay on $previousName too.',
                          textAlign: TextAlign.center,
                          style: t.sub,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 400 + extra,
                  left: 0,
                  right: 0,
                  child: fade(
                    prompt,
                    10,
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        WebButton(
                          label: 'Start My Numbers Fresh',
                          variant: WebButtonVariant.tertiary,
                          onPressed:
                              _saving ? null : () => _choose(count: false),
                        ),
                        Transform.scale(
                          scale: 1 - .04 * at(600, 700) + .04 * at(700, 840),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              WebButton(
                                label: 'Count Them',
                                busy: _saving && !_counted,
                                onPressed:
                                    _saving ? null : () => _choose(count: true),
                              ),
                              IgnorePointer(
                                child: Opacity(
                                  key: const ValueKey('web-transfer-ripple'),
                                  opacity:
                                      .28 * at(520, 700) * (1 - at(700, 1040)),
                                  child: Transform.scale(
                                    scale: .5 +
                                        .5 * at(520, 700) +
                                        .5 * at(700, 1040),
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: c.label,
                                        shape: BoxShape.circle,
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
                  ),
                ),
                Positioned(
                  top: 400 + extra,
                  left: 0,
                  right: 0,
                  child: fade(
                    done,
                    8,
                    Center(
                      child: WebButton(
                        label: 'Done',
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ),
                ),
                if (_failed)
                  Positioned(
                    bottom: 0,
                    left: 24,
                    right: 24,
                    child: saveFailureLine(() => _choose(count: _lastDecision)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  double phase(double start, double end) =>
      ((_controller.value * 5400 - start) / (end - start)).clamp(0, 1);
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final previousName = widget.previous ?? 'your exam';
    if (context.wideWeb) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const ExamPage(),
          const ModalBarrier(color: Color(0x521D1D1F), dismissible: false),
          Center(
            child: Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 560,
                child: _wideTransfer(context, previousName),
              ),
            ),
          ),
        ],
      );
    }
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final drain =
                const Cubic(.45, 0, .25, 1).transform(phase(750, 2350));
            final finish = PantasCurves.ease.transform(phase(2950, 3300));
            final lift = PantasCurves.houseOut.transform(phase(50, 500));
            final hide = PantasCurves.ease.transform(phase(0, 300));
            final checkProgress = phase(2650, 2950);
            final labelProgress =
                PantasCurves.ease.transform(phase(2600, 2900));
            Widget vessel(
              String name, {
              required bool check,
              required bool old,
            }) =>
                Column(
                  children: [
                    Container(
                      width: 104,
                      height: 168,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: old
                            ? Color.lerp(c.fill, c.accentTint, drain)
                            : c.fill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          Transform.translate(
                            key: ValueKey(
                              old ? 'transfer-old-fill' : 'transfer-new-fill',
                            ),
                            offset: Offset(
                              0,
                              168 * 1.1 * (old ? drain : 1 - drain),
                            ),
                            child: const SizedBox.expand(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF14937D),
                                      Color(0xFF0B7A68),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (check)
                            Center(
                              child: Opacity(
                                opacity: checkProgress,
                                child: Transform.scale(
                                  scale: .4 +
                                      .6 *
                                          PantasCurves.popB
                                              .transform(checkProgress),
                                  child: Icon(
                                    Icons.check,
                                    size: 40,
                                    color: c.onAccent,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 130,
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: context.type.footnote.copyWith(
                          color: old
                              ? Color.lerp(
                                  c.accent,
                                  c.secondaryLabel,
                                  labelProgress,
                                )
                              : Color.lerp(
                                  c.secondaryLabel,
                                  c.accent,
                                  labelProgress,
                                ),
                        ),
                      ),
                    ),
                  ],
                );
            Widget fade(Widget child) => IgnorePointer(
                  ignoring: _counted,
                  child: Opacity(
                    key: child is Column
                        ? const ValueKey('transfer-prompt')
                        : null,
                    opacity: 1 - hide,
                    child: Transform.translate(
                      offset: Offset(0, 10 * hide),
                      child: child,
                    ),
                  ),
                );
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: SizedBox(
                  height:
                      constraints.maxHeight < 760 ? 760 : constraints.maxHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 132,
                        left: 56,
                        right: 56,
                        child: Transform.translate(
                          key: const ValueKey('transfer-vessels'),
                          offset: Offset(0, 118 * lift),
                          child: Transform.scale(
                            scale: 1 + .12 * lift,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: vessel(
                                    widget.previous ?? '',
                                    check: false,
                                    old: true,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 82),
                                  child: SizedBox(
                                    width: 70,
                                    height: 8,
                                    child: ClipRect(
                                      child: Transform.translate(
                                        offset: Offset(
                                          70 *
                                              (-1.01 +
                                                  1.01 *
                                                      PantasCurves.liquid
                                                          .transform(
                                                        phase(
                                                          550,
                                                          850,
                                                        ),
                                                      ) +
                                                  1.01 *
                                                      PantasCurves.liquid
                                                          .transform(
                                                        phase(
                                                          2350,
                                                          2650,
                                                        ),
                                                      )),
                                          0,
                                        ),
                                        child: ColoredBox(
                                          color: c.accentFill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: vessel(
                                    widget.exam,
                                    check: checkProgress > 0,
                                    old: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 380,
                        left: 16,
                        right: 16,
                        child: fade(
                          Column(
                            children: [
                              Text(
                                'You’re not starting from zero',
                                textAlign: TextAlign.center,
                                style: context.type.pageTitle,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Some content on '
                                "${widget.previous ?? 'your exam'} "
                                'is on ${widget.exam} too. '
                                'Count them and continue where you are.',
                                textAlign: TextAlign.center,
                                style: context.type.body,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 16,
                        right: 16,
                        child: IgnorePointer(
                          ignoring: _counted,
                          child: Opacity(
                            opacity: 1 - hide,
                            child: Transform.translate(
                              offset: Offset(0, 10 * hide),
                              child: Column(
                                children: [
                                  if (_failed)
                                    saveFailureLine(
                                      () => _choose(count: _lastDecision),
                                    ),
                                  PantasButton(
                                    label: 'Count Them',
                                    busy: _saving,
                                    onPressed: _saving
                                        ? null
                                        : () => _choose(count: true),
                                  ),
                                  PantasButton(
                                    label: 'Start My Numbers Fresh',
                                    variant: PantasButtonVariant.tertiary,
                                    onPressed: _saving
                                        ? null
                                        : () => _choose(count: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (finish > 0)
                        Positioned(
                          top: 560,
                          left: 24,
                          right: 24,
                          child: Transform.translate(
                            offset: Offset(0, 8 * (1 - finish)),
                            child: Opacity(
                              opacity: finish,
                              child: Column(
                                children: [
                                  Text(
                                    'You pick up where you are',
                                    style: context.type.pageTitle,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  if (widget.previous != null)
                                    Text(
                                      'Your ${widget.previous} answers '
                                      'stay on ${widget.previous} too.',
                                      style: context.type.body,
                                      textAlign: TextAlign.center,
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
          },
        ),
      ),
    );
  }
}

class CarryOverRequest {
  const CarryOverRequest({
    required this.exam,
    required this.onCounted,
    this.previous,
    this.onDecision,
  });
  final Future<void> Function({required bool count})? onDecision;
  final String exam;
  final String? previous;
  final VoidCallback onCounted;
}

// ST_ExamSwitchCount's SVG surface, repeated across the moving liquid.
class _TransferWave extends CustomPainter {
  const _TransferWave();

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 240, size.height / 12);
    final wave = Path()
      ..moveTo(0, 8)
      ..cubicTo(15, 2, 30, 2, 45, 7)
      ..cubicTo(60, 12, 75, 12, 90, 6)
      ..cubicTo(105, 0, 112, 2, 120, 6)
      ..cubicTo(128, 10, 135, 2, 165, 7)
      ..cubicTo(195, 12, 195, 12, 210, 6)
      ..cubicTo(225, 0, 232, 2, 240, 6)
      ..lineTo(240, 12)
      ..lineTo(0, 12)
      ..close();
    canvas
      ..drawPath(wave, Paint()..color = const Color(0xFF14937D))
      ..restore();
  }

  @override
  bool shouldRepaint(_TransferWave oldDelegate) => false;
}
