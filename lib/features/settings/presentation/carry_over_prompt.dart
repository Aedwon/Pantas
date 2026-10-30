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
      if (context.wideWeb) return;
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

  double phase(double start, double end) =>
      ((_controller.value * 5400 - start) / (end - start)).clamp(0, 1);
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final previousName = widget.previous ?? 'your exam';
    if (context.wideWeb) {
      final t = context.webTokens;
      Widget vessel(String name, {required bool old}) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 170,
                decoration: BoxDecoration(
                  color: old
                      ? _counted
                          ? c.accentTint
                          : c.accentFill
                      : _counted
                          ? c.accentFill
                          : c.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: c.label, width: 2),
                ),
                child: !old && _counted
                    ? const Icon(Icons.check, size: 36, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 150,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: t.style(15, weight: FontWeight.w600),
                ),
              ),
            ],
          );
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
                child: WebCard(
                  radius: 22,
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            vessel(widget.previous ?? '', old: true),
                            Container(
                              width: 80,
                              height: 10,
                              margin: const EdgeInsets.only(bottom: 40),
                              decoration: BoxDecoration(
                                color: c.separator,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            vessel(widget.exam, old: false),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Text(
                          _counted
                              ? 'You pick up where you are'
                              : "You're not starting from zero",
                          textAlign: TextAlign.center,
                          style: t.h3,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _counted
                              ? 'Your $previousName answers '
                                  'stay on $previousName too.'
                              : 'Some content on $previousName '
                                  'is on ${widget.exam} too. '
                                  'Count them and continue where you are.',
                          textAlign: TextAlign.center,
                          style: t.style(
                            16,
                            height: 1.45,
                            color: c.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 26),
                        if (_failed)
                          saveFailureLine(() => _choose(count: _lastDecision)),
                        if (_counted)
                          WebButton(
                            label: 'Done',
                            onPressed: () => Navigator.of(context).pop(true),
                          )
                        else
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              WebButton(
                                label: 'Start My Numbers Fresh',
                                variant: WebButtonVariant.tertiary,
                                onPressed: _saving
                                    ? null
                                    : () => _choose(count: false),
                              ),
                              WebButton(
                                label: 'Count Them',
                                busy: _saving,
                                onPressed:
                                    _saving ? null : () => _choose(count: true),
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
