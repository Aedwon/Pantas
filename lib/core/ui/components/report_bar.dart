import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/report_providers.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// What the one bar shows (phone boards QN_Report, QN_ReportOffline).
enum ReportBarPhase { rest, form, notice }

/// The morph: 0.42 s on the shared ease (QN_Report, the bar's own keyframes).
const Duration reportMorphDuration = PantasDurations.medium3;
const Curve reportMorphCurve = PantasCurves.move;

/// How long the confirmation stays once the bar is back to its size.
const Duration reportNoticeHold = Duration(milliseconds: 2400);

/// The phone report. One surface: the quiz bar becomes the report form, the
/// form becomes the confirmation, and the confirmation gives the bar back.
/// The confirmation is never a second element over the bar (finding 5).
///
/// [rest] is what the bar shows at rest. [open] asks for the form; the bar
/// reports through [onClosed] when it is back to rest, with the delivery if a
/// report was sent.
class ReportBar extends ConsumerStatefulWidget {
  const ReportBar({
    required this.rest,
    required this.open,
    required this.questionId,
    required this.onClosed,
    this.restState = FloatingBarState.neutral,
    this.restInset = PantasSpace.s8,
    this.examId,
    this.questionVersion,
    this.surfaceKey,
    super.key,
  });
  final Widget rest;
  final bool open;
  final String questionId;
  final void Function(ReportDelivery? delivered) onClosed;
  final FloatingBarState restState;
  final double restInset;
  final String? examId;
  final int? questionVersion;
  final Key? surfaceKey;

  @override
  ConsumerState<ReportBar> createState() => _ReportBarState();
}

class _ReportBarState extends ConsumerState<ReportBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  ReportBarPhase _phase = ReportBarPhase.rest;
  ReportBarPhase? _from;
  ReportDelivery? _delivered;
  FocusNode? _returnFocus;
  Timer? _hold;
  Timer? _settle;
  double _totalMs = 420;
  (double, double) _out = (0, 120);
  (double, double) _in = (120, 360);

  @override
  void initState() {
    super.initState();
    // A bar mounted already open (the viewer swaps its bar in when the report
    // button is pressed) starts the morph from its first frame.
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.open && _phase == ReportBarPhase.rest) _begin();
      });
    }
  }

  @override
  void didUpdateWidget(ReportBar old) {
    super.didUpdateWidget(old);
    if (old.questionId != widget.questionId && _phase != ReportBarPhase.rest) {
      final delivered = _delivered;
      _reset();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onClosed(delivered);
      });
      return;
    }
    if (widget.open && !old.open && _phase == ReportBarPhase.rest) {
      _begin();
    } else if (!widget.open && old.open && _phase == ReportBarPhase.form) {
      _go(ReportBarPhase.rest);
    }
  }

  void _begin() {
    _returnFocus = FocusManager.instance.primaryFocus;
    _delivered = null;
    _go(ReportBarPhase.form);
  }

  void _reset() {
    _hold?.cancel();
    _settle?.cancel();
    _c.stop();
    setState(() {
      _from = null;
      _phase = ReportBarPhase.rest;
      _delivered = null;
    });
  }

  bool get _still => MediaQuery.disableAnimationsOf(context);

  /// Fade windows, in ms from the start of the change, copied from the board:
  /// the bar's content leaves in 120 ms and the form arrives from 120 to 360;
  /// the form leaves in 140 ms and the confirmation arrives from 300 to 500;
  /// the confirmation leaves in 200 ms and the bar arrives from 200 to 420.
  void _go(ReportBarPhase to) {
    final from = _phase;
    if (from == to) return;
    if (_still) {
      // Reduced motion: no spatial motion, a short dissolve (motion.md).
      _totalMs = 150;
      _out = (0, 150);
      _in = (0, 150);
    } else if (from == ReportBarPhase.form) {
      _totalMs = 500;
      _out = (0, 140);
      _in = (300, 500);
    } else if (from == ReportBarPhase.notice) {
      _totalMs = 420;
      _out = (0, 200);
      _in = (200, 420);
    } else {
      _totalMs = 420;
      _out = (0, 120);
      _in = (120, 360);
    }
    _c.duration = Duration(milliseconds: _totalMs.round());
    setState(() {
      _from = from;
      _phase = to;
    });
    unawaited(
      _c.forward(from: 0).then((_) {
        if (mounted && _phase == to) setState(() => _from = null);
      }),
    );
    if (to == ReportBarPhase.rest) _restoreFocus();
  }

  void _restoreFocus() {
    final node = _returnFocus;
    _returnFocus = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (node != null && node.context != null && node.canRequestFocus) {
        node.requestFocus();
      }
    });
  }

  void _cancel() {
    if (_phase != ReportBarPhase.form) return;
    _go(ReportBarPhase.rest);
    widget.onClosed(null);
  }

  void _saved(ReportDelivery delivery) {
    _delivered = delivery;
    _go(ReportBarPhase.notice);
    _hold = Timer(reportNoticeHold, () {
      if (!mounted) return;
      _go(ReportBarPhase.rest);
      // The icon turns teal as the bar comes back (board: 200 ms in).
      _settle = Timer(const Duration(milliseconds: 200), () {
        if (mounted) widget.onClosed(delivery);
      });
    });
  }

  @override
  void dispose() {
    _hold?.cancel();
    _settle?.cancel();
    _c.dispose();
    super.dispose();
  }

  double _ramp((double, double) w) {
    final t = _c.value * _totalMs;
    return ((t - w.$1) / (w.$2 - w.$1)).clamp(0.0, 1.0);
  }

  Widget _layer(ReportBarPhase phase) => switch (phase) {
        ReportBarPhase.rest => Padding(
            padding: EdgeInsets.all(widget.restInset),
            child: widget.rest,
          ),
        ReportBarPhase.form => ReportForm(
            questionId: widget.questionId,
            queue: ref.read(reportQueueProvider),
            examId: widget.examId,
            questionVersion: widget.questionVersion,
            onClose: _cancel,
            onSaved: _saved,
          ),
        ReportBarPhase.notice => ReportNotice(delivery: _delivered!),
      };

  Widget _faded(ReportBarPhase phase, {required bool current}) {
    final opacity = _from == null
        ? 1.0
        : current
            ? _ramp(_in)
            : 1 - _ramp(_out);
    return Opacity(
      opacity: opacity,
      child: IgnorePointer(
        ignoring: !current,
        child: ExcludeFocus(
          excluding: !current,
          child: ExcludeSemantics(
            excluding: !current,
            child: KeyedSubtree(key: ValueKey(phase), child: _layer(phase)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = _phase == ReportBarPhase.form;
    // Back (Android or browser) while the form is open closes the form like
    // Escape; the quiz stays. During the confirmation it is held, so the
    // thank-you is not cut off by a stray back.
    return PopScope(
      canPop: _phase == ReportBarPhase.rest,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: _surface(form),
    );
  }

  Widget _surface(bool form) {
    return FloatingBar.content(
      key: widget.surfaceKey,
      state: form ? FloatingBarState.neutral : widget.restState,
      radius: form ? PantasRadius.r2xl : PantasRadius.bar,
      inset: 0,
      transitionDuration: reportMorphDuration,
      transitionCurve: reportMorphCurve,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final layers = Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (_from != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _faded(_from!, current: false),
                ),
              _faded(_phase, current: true),
            ],
          );
          return ClipRect(
            child: _still
                ? layers
                : AnimatedSize(
                    duration: reportMorphDuration,
                    curve: reportMorphCurve,
                    alignment: Alignment.bottomCenter,
                    child: layers,
                  ),
          );
        },
      ),
    );
  }
}

/// The confirmation, drawn inside the bar (boards QN_Report: the thank-you;
/// QN_ReportOffline: saved, sends when back online). It is one line at the
/// bar's height.
class ReportNotice extends StatelessWidget {
  const ReportNotice({required this.delivery, super.key});
  final ReportDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final sent = delivery == ReportDelivery.sent;
    final mark = sent
        ? DecoratedBox(
            decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
            child: SizedBox.square(
              dimension: 26,
              child: Icon(PantasIcons.check, size: 14, color: c.onAccent),
            ),
          )
        : Icon(PantasIcons.pendingSend, size: 20, color: c.textSecondary);
    return Semantics(
      liveRegion: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PantasSize.bar),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s16,
            vertical: PantasSpace.s10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The check pops once the bar is back: .4 to 1.15 to 1.
              if (sent && !still)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 860),
                  builder: (context, p, child) {
                    final e = p * 860;
                    const curve = PantasCurves.popB;
                    final scale = e < 420
                        ? .4
                        : e < 700
                            ? .4 + .75 * curve.transform((e - 420) / 280)
                            : 1.15 - .15 * curve.transform((e - 700) / 160);
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: mark,
                )
              else
                mark,
              const SizedBox(width: PantasSpace.s10),
              Flexible(
                child: Text(
                  reportDeliveryText(delivery),
                  textAlign: TextAlign.center,
                  style: context.type.subheadStrong,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
