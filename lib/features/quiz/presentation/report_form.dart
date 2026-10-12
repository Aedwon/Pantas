import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/data/report_queue.dart';

/// Shared entry for assessment, live quizzes and the question viewer.
/// The caller supplies its queue and recolors its icon when this returns true.
Future<bool?> openQuestionReport(
  BuildContext context,
  String questionId, {
  required ReportQueue queue,
}) =>
    showGeneralDialog<bool>(
      context: context,
      barrierColor: context.colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'Close report',
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 420),
      pageBuilder: (context, _, __) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 18,
          ),
          child: Material(
            color: context.colors.transparent,
            child: ReportForm(
              questionId: questionId,
              queue: queue,
              onClose: () => Navigator.of(context).pop(),
              onSaved: () => Navigator.of(context).pop(true),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position:
              Tween(begin: const Offset(0, .15), end: Offset.zero).animate(
            CurvedAnimation(
              parent: animation,
              curve: PantasCurves.edgeGrow,
            ),
          ),
          child: child,
        ),
      ),
    );

class ReportForm extends StatefulWidget {
  const ReportForm({
    required this.questionId,
    required this.queue,
    required this.onClose,
    this.onSaved,
    super.key,
  });
  final String questionId;
  final ReportQueue queue;
  final VoidCallback onClose;
  final VoidCallback? onSaved;

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  bool _ready = false;
  bool _busy = false;
  bool _saved = false;
  bool _failed = false;
  bool _reported = false;
  ReportResult? _limit;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final reports = await widget.queue.pending();
      final limit = await widget.queue.limit(widget.questionId, DateTime.now());
      if (!mounted) return;
      setState(() {
        _reported = reports.any((r) => r.questionId == widget.questionId);
        _limit = limit;
        _ready = true;
      });
      if (limit == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focus.requestFocus();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  Future<void> _send() async {
    if (_busy || !_ready || _limit != null) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final result = await widget.queue.add(
        widget.questionId,
        _text.text,
        DateTime.now(),
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (result == ReportResult.queued) {
          _saved = true;
        } else if (result != ReportResult.empty) {
          _limit = result;
        }
      });
      if (_saved) {
        FocusScope.of(context).unfocus();
        final callback = widget.onSaved;
        if (callback != null) {
          _closeTimer = Timer(const Duration(milliseconds: 2300), callback);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_saved) {
      return Semantics(
        liveRegion: true,
        child: FloatingBar.content(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Text(
              "Saved. It sends when you're back online.",
              textAlign: TextAlign.center,
              style: context.type.subheadStrong,
            ),
          ),
        ),
      );
    }
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
      },
      child: Semantics(
        liveRegion: true,
        child: FloatingBar.content(
          radius: 24,
          inset: 0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Report this question',
                  style: context.type.emphasized
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _limit == ReportResult.dailyLimit
                      ? "You've sent a lot of reports today. "
                          'You can send more tomorrow.'
                      : _limit == ReportResult.questionLimit
                          ? 'You reported this question before.'
                          : _reported
                              ? 'You reported this question before. '
                                  'Feel free to add '
                                  'any other concern so we can work on it '
                                  'right away.'
                              : 'Something wrong or unclear? Tell us '
                                  "and we'll check it.",
                  style: context.type.footnote.copyWith(height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _text,
                  focusNode: _focus,
                  autofocus: _ready && _limit == null,
                  enabled: _ready && _limit == null && !_busy,
                  minLines: 3,
                  maxLines: 5,
                  style: context.type.body.copyWith(fontSize: 16, height: 1.4),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _limit == ReportResult.dailyLimit
                        ? 'Reports open again tomorrow'
                        : 'What did you notice?',
                    hintStyle: context.type.body.copyWith(
                      fontSize: 16,
                      color: c.tertiaryLabel,
                    ),
                    filled: true,
                    fillColor: c.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_failed)
                  saveFailureLine(
                    () => unawaited(
                      _ready ? _send() : _load(),
                    ),
                  ),
                const SizedBox(height: 14),
                ButtonPair(
                  secondary: _pill('Cancel', widget.onClose, primary: false),
                  primary: _pill(
                    'Send',
                    _ready &&
                            !_busy &&
                            _limit == null &&
                            _text.text.trim().isNotEmpty
                        ? () => unawaited(_send())
                        : null,
                    primary: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, VoidCallback? callback, {required bool primary}) {
    final c = context.colors;
    final active = primary && callback != null;
    return TextButton(
      onPressed: callback,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const StadiumBorder(),
        backgroundColor: active ? c.accent : c.fill,
        foregroundColor: active ? c.onAccent : c.label,
      ),
      child: Text(
        label,
        style: context.type.emphasized.copyWith(
          fontSize: 16,
          color: active
              ? c.onAccent
              : callback == null
                  ? c.tertiaryLabel
                  : c.label,
        ),
      ),
    );
  }
}
