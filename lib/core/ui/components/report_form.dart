import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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
    // The dialog motion: a rise and a fade, or a 150 ms fade in place under
    // reduced motion (Dialog README).
    showWebOverlay<bool>(
      context: context,
      motion: WebOverlayMotion.dialog,
      barrierColor: Colors.transparent,
      barrierLabel: 'Close report',
      builder: context.wideWeb
          ? (_) => _WebReportPanel(questionId: questionId, queue: queue)
          : (context) => Align(
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
                PantasField.unlabeled(
                  semanticLabel: 'What did you notice?',
                  controller: _text,
                  focusNode: _focus,
                  autofocus: _ready && _limit == null,
                  enabled: _ready && _limit == null && !_busy,
                  multiline: true,
                  maxLines: 5,
                  onChanged: (_) => setState(() {}),
                  hint: _limit == ReportResult.dailyLimit
                      ? 'Reports open again tomorrow'
                      : 'What did you notice?',
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
                  secondary: PantasButton(
                    label: 'Cancel',
                    variant: PantasButtonVariant.secondary,
                    onPressed: widget.onClose,
                  ),
                  primary: PantasButton(
                    label: 'Save',
                    busy: _busy,
                    onPressed: _ready &&
                            !_busy &&
                            _limit == null &&
                            _text.text.trim().isNotEmpty
                        ? () => unawaited(_send())
                        : null,
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
            PantasField.unlabeled(
              semanticLabel: 'What did you notice?',
              controller: _text,
              focusNode: _focus,
              autofocus: _ready && _limit == null,
              enabled: _ready && _limit == null && !_busy,
              multiline: true,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              hint: _limit == ReportResult.dailyLimit
                  ? 'Reports open again tomorrow'
                  : 'What did you notice?',
            ),
            if (_failed)
              saveFailureLine(
                () => unawaited(_ready ? _send() : _load()),
              ),
            const SizedBox(height: PantasSpace.s12),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                WebButton(
                  label: 'Cancel',
                  kind: PantasButtonKind.tertiary,
                  onPressed: widget.onClose,
                ),
                const SizedBox(width: PantasSpace.s8, height: PantasSpace.s8),
                WebButton(
                  label: 'Save',
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
                            PantasIconButton(
                              tooltip: 'Close report',
                              glyph: PantasIcons.close,
                              size: PantasIconButtonSize.sm,
                              onPressed: () => Navigator.of(context).pop(),
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
