import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/ready_fade.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The wide report form: a drop-down panel at the top right (boards
/// QN_Report, QN_ReportAgain and QN_ReportLimit on Pantas Web). The phone has
/// no dialog: the quiz bar becomes the form in place (`ReportBar`), so this
/// is for the wide layout only.
/// The caller supplies its queue and recolors its icon when this returns a
/// delivery.
Future<ReportDelivery?> openQuestionReport(
  BuildContext context,
  String questionId, {
  required ReportQueue queue,
  String? examId,
  int? questionVersion,
}) {
  assert(context.wideWeb, 'The phone report is the bar itself (ReportBar).');
  // The board's popover drop: 0.2 s ease-out from 6 px above, or a 150 ms
  // fade in place under reduced motion.
  return showWebOverlay<ReportDelivery>(
    context: context,
    motion: WebOverlayMotion.dropdown,
    barrierColor: Colors.transparent,
    barrierLabel: 'Close report',
    builder: (_) => _WebReportPanel(
      questionId: questionId,
      queue: queue,
      examId: examId,
      questionVersion: questionVersion,
    ),
  );
}

/// What the student reads once a report is saved: the sent state, or the
/// saved-offline state (boards QN_ReportSent and QN_ReportOffline).
String reportDeliveryText(ReportDelivery delivery) => switch (delivery) {
      ReportDelivery.sent => "Thank you. We'll take a look.",
      ReportDelivery.saved => "Saved. It sends when you're back online.",
    };

/// The wide confirmation: a soft line beside the report button that fades in
/// over 300 ms (QN_ReportSent, QN_ReportOffline; 150 ms under reduced motion).
class ReportSoftLine extends StatelessWidget {
  const ReportSoftLine({
    required this.delivery,
    required this.style,
    super.key,
  });
  final ReportDelivery delivery;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(
          milliseconds: MediaQuery.disableAnimationsOf(context) ? 150 : 300,
        ),
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
        child: Semantics(
          liveRegion: true,
          child: Text(reportDeliveryText(delivery), style: style),
        ),
      );
}

/// Stops typing at the longest message the server takes, with no counter.
final _lengthLimit = <TextInputFormatter>[
  LengthLimitingTextInputFormatter(ReportQueue.maxMessageLength),
];

/// The line under the title wherever the field takes text (ruling R4). It
/// replaces the old "Something wrong or unclear?" words; it adds no line.
const reportPrivacyLine = "Tell us what's wrong. Leave out personal details.";

/// The report form. On the phone it is the contents of the bar once the bar
/// has become the form (`ReportBar` draws the surface); on wide it is a card
/// in the drop-down panel. It never draws the confirmation: it hands the
/// delivery to [onSaved] and the caller shows it (the bar itself on the
/// phone, a soft line beside the report button on wide).
class ReportForm extends StatefulWidget {
  const ReportForm({
    required this.questionId,
    required this.queue,
    required this.onClose,
    required this.onSaved,
    this.examId,
    this.questionVersion,
    super.key,
  });
  final String questionId;
  final ReportQueue queue;
  final VoidCallback onClose;
  final String? examId;
  final int? questionVersion;
  final ValueChanged<ReportDelivery> onSaved;

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  bool _ready = false;
  bool _busy = false;
  bool _failed = false;
  bool _reported = false;
  ReportResult? _limit;

  /// Bumps each time Send becomes available, so its color blend replays.
  int _sendSerial = 0;
  bool _sendWasReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final reports = await widget.queue.history();
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

  bool get _canSend =>
      _ready && !_busy && _limit == null && _text.text.trim().isNotEmpty;

  void _changed() {
    setState(() {});
    final ready = _canSend;
    if (ready && !_sendWasReady) _sendSerial++;
    _sendWasReady = ready;
  }

  Future<void> _send() async {
    if (_busy || !_ready || _limit != null) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      // Saves, then sends. The outcome is this report's own: a refusal (the
      // question's reports used up, even from another device) shows the limit
      // state and never a thank-you.
      final submission = await widget.queue.submit(
        widget.questionId,
        _text.text,
        DateTime.now(),
        examId: widget.examId,
        questionVersion: widget.questionVersion,
      );
      final result = submission.result;
      final delivery = submission.delivery;
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (result != ReportResult.queued && result != ReportResult.empty) {
          _limit = result;
        }
      });
      if (delivery != null) {
        FocusScope.of(context).unfocus();
        widget.onSaved(delivery);
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
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// The line under the title (boards: QN_Report, QN_ReportAgain,
  /// QN_ReportLimit). Where the field takes text it is [reportPrivacyLine].
  String get _line => switch (_limit) {
        ReportResult.dailyLimit => "You've sent a lot of reports today. "
            'You can send more tomorrow.',
        ReportResult.questionLimit => 'You reported this question before.',
        _ => reportPrivacyLine,
      };

  String get _hint => _limit == ReportResult.dailyLimit
      ? 'Reports open again tomorrow'
      : 'What did you notice?';

  Widget _field() => PantasField.unlabeled(
        semanticLabel: 'What did you notice?',
        controller: _text,
        focusNode: _focus,
        autofocus: _ready && _limit == null,
        enabled: _ready && _limit == null && !_busy,
        multiline: true,
        maxLines: 5,
        inputFormatters: _lengthLimit,
        onChanged: (_) => _changed(),
        hint: _hint,
      );

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) return _web(context);
    final colors = context.colors;
    // Boards QN_Report, QN_ReportAgain, QN_ReportLimit: a 250 px form (an 18
    // px frame, the title, the line, the 92 px field), the buttons at the
    // foot. At large text it grows and scrolls instead of leaving the screen.
    final available = MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        MediaQuery.paddingOf(context).top -
        80;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
      },
      child: Semantics(
        liveRegion: true,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: available.clamp(100, double.infinity)),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: available >= 250 ? 250 : 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s18,
                  PantasSpace.s18,
                  PantasSpace.s18,
                  PantasSpace.s16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
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
                          _line,
                          // ds-board: README type: footnote 1.35; hint 1.4
                          style: context.type.footnote.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: PantasSpace.s12),
                        _field(),
                        if (_failed)
                          saveFailureLine(
                            () => unawaited(_ready ? _send() : _load()),
                          ),
                      ],
                    ),
                    const SizedBox(height: PantasSpace.s12),
                    ButtonPair(
                      secondary: PantasButton(
                        label: 'Cancel',
                        variant: PantasButtonVariant.neutral,
                        height: PantasSize.btn,
                        radius: PantasRadius.full,
                        fontSize: PantasType.webButton.fontSize,
                        onPressed: _busy ? null : widget.onClose,
                      ),
                      primary: ReadyFade(
                        serial: _sendSerial,
                        child: PantasButton(
                          label: 'Send',
                          height: PantasSize.btn,
                          radius: PantasRadius.full,
                          fontSize: PantasType.webButton.fontSize,
                          busy: _busy,
                          disabledForeground: colors.textDisabled,
                          onPressed: _canSend ? () => unawaited(_send()) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _web(BuildContext context) {
    final t = context.webTokens;
    final canSend = _canSend;
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
              // QN_ReportAgain: the same line in a soft box.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s12,
                  vertical: PantasSpace.s10,
                ),
                decoration: BoxDecoration(
                  color: t.colors.background,
                  borderRadius: BorderRadius.circular(PantasRadius.md),
                ),
                child: Text(_line, style: t.sm),
              )
            else
              Text(_line, style: t.sub),
            const SizedBox(height: PantasSpace.s12),
            _field(),
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
                  label: 'Send',
                  // QN_ReportLimit draws Send with no key hint.
                  keyHint: _limit == null ? '$commandKeyLabel Enter' : null,
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

/// QN_Report (Pantas Web): the panel is 380 wide, 60 down and 20 in.
const double _panelWidth = 380;

class _WebReportPanel extends StatefulWidget {
  const _WebReportPanel({
    required this.questionId,
    required this.queue,
    this.examId,
    this.questionVersion,
  });
  final String questionId;
  final ReportQueue queue;
  final String? examId;
  final int? questionVersion;
  @override
  State<_WebReportPanel> createState() => _WebReportPanelState();
}

class _WebReportPanelState extends State<_WebReportPanel> {
  Offset? _position;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final position = _position ?? Offset(size.width - _panelWidth - 20, 60);
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          width: _panelWidth,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                ReportForm(
                  questionId: widget.questionId,
                  queue: widget.queue,
                  examId: widget.examId,
                  questionVersion: widget.questionVersion,
                  onClose: () => Navigator.of(context).pop(),
                  onSaved: (delivery) => Navigator.of(context).pop(delivery),
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
                            .clamp(0, size.width - _panelWidth),
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
