import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
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
            transitionDuration: _reportDuration(context),
            pageBuilder: (_, __, ___) =>
                _WebReportPanel(questionId: questionId, queue: queue),
            transitionBuilder: _reportTransition,
          )
        : showGeneralDialog<bool>(
            context: context,
            barrierColor: context.colors.transparent,
            barrierDismissible: true,
            barrierLabel: 'Close report',
            transitionDuration: _reportDuration(context),
            pageBuilder: (context, _, __) => Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s16,
                  PantasSpace.s16,
                  MediaQuery.viewInsetsOf(context).bottom + PantasSpace.s18,
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
            transitionBuilder: _reportTransition,
          );

/// The report form's arrival on the phone and on wide web: 420 ms, or none
/// under reduced motion.
Duration _reportDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 420);

/// A fade and a 15% slide up on edgeGrow.
Widget _reportTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .15), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: PantasCurves.move),
        ),
        child: child,
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
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s8,
              vertical: PantasSpace.s10,
            ),
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
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s18,
              PantasSpace.s18,
              PantasSpace.s18,
              PantasSpace.s16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Report this question',
                  style: context.type.emphasized
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: PantasSpace.s4),
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
                  // ds-board: README type: footnote 1.35; hint 1.4 as built
                  style: context.type.footnote.copyWith(height: 1.4),
                ),
                const SizedBox(height: PantasSpace.s12),
                TextField(
                  controller: _text,
                  focusNode: _focus,
                  autofocus: _ready && _limit == null,
                  enabled: _ready && _limit == null && !_busy,
                  minLines: 3,
                  maxLines: 5,
                  style: PantasType.phoneCallout.copyWith(color: c.textPrimary),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _limit == ReportResult.dailyLimit
                        ? 'Reports open again tomorrow'
                        : 'What did you notice?',
                    hintStyle: PantasType.phoneCallout
                        .copyWith(color: c.textSecondary),
                    filled: true,
                    fillColor: c.surfaceCard,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s14,
                      vertical: PantasSpace.s12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PantasRadius.md),
                      borderSide: BorderSide(color: c.borderControl),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PantasRadius.md),
                      borderSide: BorderSide(
                        color: c.accent,
                        width: PantasBorder.ringSelected,
                      ),
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
                const SizedBox(height: PantasSpace.s4),
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
        padding: const EdgeInsets.all(PantasSpace.s20),
        child: Text('Saved on this device.', style: t.sub),
      );
    }
    final canSend =
        _ready && !_busy && _limit == null && _text.text.trim().isNotEmpty;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
        const SingleActivator(
          LogicalKeyboardKey.enter,
          control: true,
          includeRepeats: false,
        ): () {
          if (canSend) unawaited(_send());
        },
        const SingleActivator(
          LogicalKeyboardKey.enter,
          meta: true,
          includeRepeats: false,
        ): () {
          if (canSend) unawaited(_send());
        },
      },
      child: WebCard(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s18,
          PantasSpace.s0,
          PantasSpace.s18,
          PantasSpace.s18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: PantasSpace.s56),
            if (_reported && _limit == null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s12,
                  vertical: PantasSpace.s10,
                ),
                decoration: BoxDecoration(
                  color: t.colors.background,
                  borderRadius: BorderRadius.circular(PantasRadius.md),
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
            const SizedBox(height: PantasSpace.s12),
            TextField(
              controller: _text,
              focusNode: _focus,
              autofocus: _ready && _limit == null,
              enabled: _ready && _limit == null && !_busy,
              minLines: 3,
              maxLines: 5,
              style: PantasType.webBody.copyWith(color: t.colors.textPrimary),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _limit == ReportResult.dailyLimit
                    ? 'Reports open again tomorrow'
                    : 'What did you notice?',
                hintStyle:
                    PantasType.webBody.copyWith(color: t.colors.textSecondary),
                filled: true,
                fillColor: t.colors.surfaceCard,
                isDense: true,
                // QN_ReportAgain: the board's box is 92 px with three lines.
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s14,
                  vertical: PantasSpace.s16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PantasRadius.md),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PantasRadius.md),
                  borderSide: BorderSide(color: t.colors.borderControl),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PantasRadius.md),
                  borderSide: BorderSide(color: t.colors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PantasRadius.md),
                  borderSide: BorderSide(
                    color: t.colors.accent,
                    width: PantasBorder.ringSelected,
                  ),
                ),
              ),
            ),
            if (_failed)
              saveFailureLine(
                () => unawaited(_ready ? _send() : _load()),
              ),
            const SizedBox(height: PantasSpace.s12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ReportButton(label: 'Cancel', onPressed: widget.onClose),
                const SizedBox(width: PantasSpace.s8),
                _ReportButton(
                  label: 'Save',
                  solid: true,
                  keyHint: '$commandKeyLabel Enter',
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
        minimumSize: const Size(0, PantasSize.btn),
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s12,
          vertical: PantasSpace.s10,
        ),
        shape: const StadiumBorder(),
        backgroundColor: active ? c.accent : c.fill,
        foregroundColor: active ? c.onAccent : c.textPrimary,
      ),
      child: Text(
        label,
        style: PantasType.webButton.copyWith(
          color: active
              ? c.onAccent
              : callback == null
                  ? c.textDisabled
                  : c.textPrimary,
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
                        padding: const EdgeInsets.only(
                          left: PantasSpace.s18,
                          right: PantasSpace.s10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Report this question',
                                style: PantasType.webTitleSm.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox.square(
                              dimension: PantasSize.iconBtnSm,
                              child: IconButton(
                                tooltip: 'Close report',
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(PantasRadius.sm),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.close,
                                  // ds-board: no README for this glyph
                                  size: 16,
                                  color: context.colors.textSecondary,
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
    final showHint = keyHintShown(context, keyHint);
    return TextButton(
      onPressed: busy ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, PantasSize.iconBtnMd),
        padding: EdgeInsets.only(
          left: solid ? PantasSpace.s20 : PantasSpace.s14,
          right: solid
              ? (showHint ? PantasSpace.s14 : PantasSpace.s20)
              : PantasSpace.s14,
        ),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: Colors.transparent,
        backgroundColor: !solid
            ? Colors.transparent
            : off
                ? t.colors.fill
                : t.colors.accentFill,
        foregroundColor: !solid
            ? t.colors.textSecondary
            : off
                ? t.colors.textDisabled
                : t.colors.onAccent,
        disabledBackgroundColor:
            solid && !busy ? t.colors.fill : t.colors.accentFill,
        disabledForegroundColor:
            solid && !busy ? t.colors.textDisabled : t.colors.onAccent,
        textStyle: PantasType.webLink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PantasRadius.md),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy) ...[
            SizedBox.square(
              dimension: PantasSpace.s16,
              child: CircularProgressIndicator(
                strokeWidth: PantasBorder.ringSelected,
                color: t.colors.onAccent,
              ),
            ),
            const SizedBox(width: PantasSpace.s8),
          ],
          Text(label),
          if (showHint) ...[
            const SizedBox(width: PantasSpace.s12),
            WebKeyHint(keyHint!, onButton: true, enabled: !off),
          ],
        ],
      ),
    );
  }
}
