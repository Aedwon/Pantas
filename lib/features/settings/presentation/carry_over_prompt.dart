import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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

class CarryOverScreen extends StatefulWidget {
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
  State<CarryOverScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<CarryOverScreen>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3300),
  );
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
    try {
      await widget.onDecision?.call(count: count);
      if (!mounted) return;
      if (!count) {
        Navigator.of(context).pop(false);
        return;
      }
      widget.onCounted();
      setState(() => _counted = true);
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        unawaited(_controller.forward());
      }
    } catch (_) {
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
      ((_controller.value * 3300 - start) / (end - start)).clamp(0, 1);
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final drain =
                const Cubic(.45, 0, .25, 1).transform(phase(750, 2350));
            final finish = phase(2950, 3300);
            Widget vessel(
              String name,
              double fill, {
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
                        color: old && _counted ? c.accentTint : c.fill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: fill,
                              widthFactor: 1,
                              child: const DecoratedBox(
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
                              child: Icon(
                                Icons.check,
                                size: 40,
                                color: c.onAccent,
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
                        style: context.type.footnote,
                      ),
                    ),
                  ],
                );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: vessel(
                          widget.previous ?? '',
                          1 - drain,
                          check: false,
                          old: true,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 8,
                        color: _counted &&
                                phase(550, 850) > 0 &&
                                phase(2350, 2650) < 1
                            ? c.accentFill
                            : c.fill,
                      ),
                      Expanded(
                        child: vessel(
                          widget.exam,
                          drain,
                          check: phase(2650, 2950) >= 1,
                          old: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  if (!_counted) ...[
                    Text(
                      "You're not starting from zero",
                      textAlign: TextAlign.center,
                      style: context.type.pageTitle,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Some content on ${widget.previous ?? 'your exam'} '
                      'is on ${widget.exam} too. '
                      'Count them and continue where you are.',
                      textAlign: TextAlign.center,
                      style: context.type.body,
                    ),
                    const SizedBox(height: 40),
                    if (_failed)
                      saveFailureLine(() => _choose(count: _lastDecision)),
                    PantasButton(
                      label: 'Count Them',
                      busy: _saving,
                      onPressed: _saving ? null : () => _choose(count: true),
                    ),
                    PantasButton(
                      label: 'Start My Numbers Fresh',
                      variant: PantasButtonVariant.tertiary,
                      onPressed: _saving ? null : () => _choose(count: false),
                    ),
                  ] else if (finish > 0)
                    Opacity(
                      opacity: finish,
                      child: Column(
                        children: [
                          Text(
                            'You pick up where you are',
                            style: context.type.pageTitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
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
                ],
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
