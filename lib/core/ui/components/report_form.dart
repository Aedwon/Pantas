import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Shared entry for assessment, live quizzes and the question viewer.
/// The caller supplies its queue and recolors its icon when this returns true.
Future<bool?> openQuestionReport(
  BuildContext context,
  String questionId, {
  required ReportQueue queue,
}) =>
    context.wideWeb
        ? showGeneralDialog<bool>(
            context: context,
            barrierColor: Colors.transparent,
            barrierDismissible: true,
            barrierLabel: 'Close report',
            pageBuilder: (_, __, ___) =>
                _WebReportPanel(questionId: questionId, queue: queue),
          )
        : showGeneralDialog<bool>(
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
                position: Tween(begin: const Offset(0, .15), end: Offset.zero)
                    .animate(
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
        if (callback != null && context.wideWeb) {
          callback();
        } else if (callback != null) {
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
    if (context.wideWeb) return _web(context);
    if (_saved) {
      return Semantics(
        liveRegion: true,
        child: FloatingBar.content(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Text(
              'Saved on this device.',
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
                      vertical: 12.5,
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
                // QN_Report: the buttons sit 5 px under the field.
                const SizedBox(height: 5),
                ButtonPair(
                  secondary: _pill('Cancel', widget.onClose, primary: false),
                  primary: _pill(
                    'Save',
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

  Widget _web(BuildContext context) {
    final t = context.webTokens;
    if (_saved) {
      return WebCard(
        padding: const EdgeInsets.all(20),
        child: Text('Saved on this device.', style: t.sub),
      );
    }
    final canSend =
        _ready && !_busy && _limit == null && _text.text.trim().isNotEmpty;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
          if (canSend) unawaited(_send());
        },
      },
      child: WebCard(
        radius: 14,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 54),
            if (_reported && _limit == null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: t.colors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'You reported this question before. '
                  'Feel free to add any other concern so we can '
                  'work on it right away.',
                  style: t.sm,
                ),
              )
            else
              Text(
                _limit == ReportResult.dailyLimit
                    ? "You've sent a lot of reports today. "
                        'You can send more tomorrow.'
                    : _limit == ReportResult.questionLimit
                        ? 'You reported this question before.'
                        : 'Something wrong or unclear? Tell us '
                            "and we'll check it.",
                style: t.sub,
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              focusNode: _focus,
              autofocus: _ready && _limit == null,
              enabled: _ready && _limit == null && !_busy,
              minLines: 3,
              maxLines: 5,
              style: t.style(16, height: 1.4),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _limit == ReportResult.dailyLimit
                    ? 'Reports open again tomorrow'
                    : 'What did you notice?',
                hintStyle: t.style(16, height: 1.4, color: t.disabledText),
                filled: true,
                fillColor: _reported && _limit == null
                    ? t.colors.surface
                    : t.colors.background,
                isDense: true,
                // QN_ReportAgain: the board's box is 92 px with three lines.
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: _reported && _limit == null
                      ? BorderSide(color: t.strongDivider)
                      : BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.colors.accent, width: 2),
                ),
              ),
            ),
            if (_failed)
              saveFailureLine(
                () => unawaited(_ready ? _send() : _load()),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ReportButton(label: 'Cancel', onPressed: widget.onClose),
                const SizedBox(width: 8),
                _ReportButton(
                  label: 'Save',
                  solid: true,
                  keyHint: 'Ctrl Enter',
                  busy: _busy,
                  onPressed: canSend ? () => unawaited(_send()) : null,
                ),
              ],
            ),
          ],
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

class _WebReportPanel extends StatefulWidget {
  const _WebReportPanel({required this.questionId, required this.queue});
  final String questionId;
  final ReportQueue queue;
  @override
  State<_WebReportPanel> createState() => _WebReportPanelState();
}

class _WebReportPanelState extends State<_WebReportPanel> {
  Offset? _position;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final position = _position ?? Offset(size.width - 436, 60);
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          width: 416,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                ReportForm(
                  questionId: widget.questionId,
                  queue: widget.queue,
                  onClose: () => Navigator.of(context).pop(),
                  onSaved: () => Navigator.of(context).pop(true),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 12,
                  height: 32,
                  child: GestureDetector(
                    onPanUpdate: (details) => setState(
                      () => _position = Offset(
                        ((_position ?? position).dx + details.delta.dx)
                            .clamp(0, size.width - 416),
                        ((_position ?? position).dy + details.delta.dy)
                            .clamp(0, size.height - 360),
                      ),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.move,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18, right: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Report this question',
                                style: context.webTokens
                                    .style(17, weight: FontWeight.w700),
                              ),
                            ),
                            SizedBox.square(
                              dimension: 32,
                              child: IconButton(
                                tooltip: 'Close report',
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: context.webTokens.colors.tertiaryLabel,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Board `.btn` and `.btn3`: 40 px buttons, 15 px label.
class _ReportButton extends StatelessWidget {
  const _ReportButton({
    required this.label,
    required this.onPressed,
    this.solid = false,
    this.keyHint,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool solid;
  final String? keyHint;
  final bool busy;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final off = onPressed == null && !busy;
    final showHint = keyHint != null && WebKeyboardHints.visibleOf(context);
    return TextButton(
      onPressed: busy ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: EdgeInsets.only(
          left: solid ? 20 : 14,
          right: solid ? (showHint ? 14 : 20) : 14,
        ),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: Colors.transparent,
        backgroundColor: !solid
            ? Colors.transparent
            : off
                ? t.disabledBackground
                : t.colors.accentFill,
        foregroundColor: !solid
            ? t.colors.secondaryLabel
            : off
                ? t.disabledText
                : Colors.white,
        disabledBackgroundColor:
            solid && !busy ? t.disabledBackground : t.colors.accentFill,
        disabledForegroundColor: solid && !busy ? t.disabledText : Colors.white,
        textStyle: t.style(15, weight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(solid ? 10 : 11),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy) ...[
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(label),
          if (showHint) ...[
            const SizedBox(width: 12),
            WebKeyHint(keyHint!, onButton: true, enabled: !off),
          ],
        ],
      ),
    );
  }
}
