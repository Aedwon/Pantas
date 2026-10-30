import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

class QuizNoteEditor extends StatefulWidget {
  const QuizNoteEditor({
    required this.onSave,
    required this.onCancel,
    this.tag,
    this.note,
    this.framed = true,
    super.key,
  });
  final Future<void> Function(MistakeTag? tag, String? note) onSave;
  final VoidCallback onCancel;
  final MistakeTag? tag;
  final String? note;
  final bool framed;
  @override
  State<QuizNoteEditor> createState() => _QuizNoteEditorState();
}

class _QuizNoteEditorState extends State<QuizNoteEditor> {
  late MistakeTag? _tag = widget.tag;
  late final TextEditingController _text =
      TextEditingController(text: widget.note);
  final FocusNode _focus = FocusNode();
  final FocusNode _shortcutFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.wideWeb) _shortcutFocus.requestFocus();
    });
  }

  int _selectionSerial = 0;
  int _actionSerial = 0;
  bool _actionReady = false;
  bool _busy = false;
  bool _failed = false;
  (MistakeTag?, String?)? _retry;
  bool get _existing => widget.tag != null || widget.note != null;
  bool get _valid =>
      _tag != null &&
      (_tag != MistakeTag.other || _text.text.trim().isNotEmpty) &&
      (!_existing ||
          _tag != widget.tag ||
          (_tag == MistakeTag.other ? _text.text.trim() : null) !=
              (widget.tag == MistakeTag.other ? widget.note?.trim() : null));

  Future<void> _write(MistakeTag? tag, String? note) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
      _retry = (tag, note);
    });
    try {
      await widget.onSave(tag, note);
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _choose(MistakeTag tag) {
    if (_busy) return;
    setState(() {
      _tag = tag;
      _selectionSerial++;
      _trackAction();
      _failed = false;
      _retry = null;
    });
    if (tag == MistakeTag.other) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    } else {
      _focus.unfocus();
    }
  }

  void _trackAction() {
    final ready = _valid;
    if (ready && !_actionReady) _actionSerial++;
    _actionReady = ready;
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    _shortcutFocus.dispose();
    super.dispose();
  }

  Widget _web(BuildContext context) {
    final t = context.webTokens;
    const reasons = [
      (MistakeTag.misread, 'I misread'),
      (MistakeTag.slipped, 'I forgot'),
      (MistakeTag.unknown, "I didn't know"),
      (MistakeTag.other, 'Type my own'),
    ];
    return CallbackShortcuts(
      bindings: {
        for (var i = 0; i < reasons.length; i++)
          SingleActivator(
            [
              LogicalKeyboardKey.digit1,
              LogicalKeyboardKey.digit2,
              LogicalKeyboardKey.digit3,
              LogicalKeyboardKey.digit4,
            ][i],
          ): () {
            if (FocusManager.instance.primaryFocus?.context?.widget
                is EditableText) {
              return;
            }
            _choose(reasons[i].$1);
          },
      },
      child: Focus(
        focusNode: _shortcutFocus,
        autofocus: true,
        child: WebCard(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Why did you miss it?',
                      style: t.style(17, weight: FontWeight.w600),
                    ),
                  ),
                  if (_existing)
                    TextButton(
                      onPressed:
                          _busy ? null : () => unawaited(_write(null, null)),
                      child: const Text('Remove'),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, reason) in reasons.indexed)
                    SizedBox(
                      width: 196,
                      child: Semantics(
                        checked: _tag == reason.$1,
                        inMutuallyExclusiveGroup: true,
                        child: TextButton(
                          onPressed: _busy ? null : () => _choose(reason.$1),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            backgroundColor: _tag == reason.$1
                                ? t.colors.accentTint
                                : t.colors.background,
                            foregroundColor: t.colors.label,
                            side: BorderSide(
                              color: _tag == reason.$1
                                  ? t.colors.accent
                                  : Colors.transparent,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              WebKeyHint('${i + 1}'),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(reason.$2, style: t.style(15)),
                              ),
                              if (widget.tag == reason.$1)
                                Text('Your note', style: t.style(11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_tag == MistakeTag.other) ...[
                const SizedBox(height: 14),
                Text('In your own words', style: t.sm),
                const SizedBox(height: 8),
                TextField(
                  controller: _text,
                  focusNode: _focus,
                  enabled: !_busy,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'In your own words',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              if (_failed)
                saveFailureLine(() {
                  final retry = _retry;
                  if (retry != null) unawaited(_write(retry.$1, retry.$2));
                }),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  WebButton(
                    label: _existing ? 'Cancel' : 'Not Now',
                    variant: WebButtonVariant.tertiary,
                    onPressed: _busy ? null : widget.onCancel,
                  ),
                  const SizedBox(width: 8),
                  WebButton(
                    label: _existing ? 'Update' : 'Add Note',
                    busy: _busy,
                    onPressed: _valid && !_busy
                        ? () => unawaited(
                              _write(
                                _tag,
                                _tag == MistakeTag.other
                                    ? _text.text.trim()
                                    : null,
                              ),
                            )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) return _web(context);
    final colors = context.colors;
    final type = context.type;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final removeWidth = MediaQuery.textScalerOf(context).scale(70);
    final available = MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        MediaQuery.paddingOf(context).top -
        80;
    final body = ConstrainedBox(
      constraints: BoxConstraints(minHeight: available >= 318 ? 318 : 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Why did you miss it?',
                    style: type.emphasized.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_existing) SizedBox(width: removeWidth),
              ],
            ),
            const SizedBox(height: 12),
            for (final (tag, label) in const [
              (MistakeTag.misread, 'I misread'),
              (MistakeTag.slipped, 'I forgot'),
              (MistakeTag.unknown, "I didn't know"),
              (MistakeTag.other, 'Type my own'),
            ])
              Semantics(
                label: label,
                checked: _tag == tag,
                inMutuallyExclusiveGroup: true,
                enabled: !_busy,
                onTap: _busy ? null : () => _choose(tag),
                child: ExcludeSemantics(
                  child: InkWell(
                    onTap: _busy ? null : () => _choose(tag),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 46),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _tag == tag
                                      ? colors.accent
                                      : colors.controlOutline,
                                  width: 1.5,
                                ),
                              ),
                              child: _tag == tag
                                  ? TweenAnimationBuilder<double>(
                                      key: ValueKey((tag, _selectionSerial)),
                                      tween: Tween(begin: 0, end: 1),
                                      duration: reduced
                                          ? Duration.zero
                                          : const Duration(milliseconds: 380),
                                      builder: (context, progress, child) {
                                        final first = (progress * 380 / 220)
                                            .clamp(0.0, 1.0);
                                        final last =
                                            ((progress * 380 - 220) / 160)
                                                .clamp(0.0, 1.0);
                                        const curve = Cubic(.3, 1.4, .5, 1);
                                        final scale = progress <= 220 / 380
                                            ? .5 + .65 * curve.transform(first)
                                            : 1.15 -
                                                .15 * curve.transform(last);
                                        return Opacity(
                                          opacity: first,
                                          child: Transform.scale(
                                            scale: scale,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: colors.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                label,
                                style: type.body.copyWith(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_tag == MistakeTag.other) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _text,
                focusNode: _focus,
                enabled: !_busy,
                minLines: 2,
                maxLines: 4,
                style: type.body.copyWith(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'In your own words',
                  filled: true,
                  fillColor: colors.fill,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {
                  _failed = false;
                  _retry = null;
                  _trackAction();
                }),
              ),
            ],
            const SizedBox(height: 20),
            if (_failed)
              saveFailureLine(() {
                final retry = _retry;
                if (retry != null) unawaited(_write(retry.$1, retry.$2));
              }),
            ButtonPair(
              secondary: PantasButton(
                label: 'Cancel',
                variant: PantasButtonVariant.neutral,
                height: 44,
                radius: 99,
                fontSize: 16,
                onPressed: _busy ? null : widget.onCancel,
              ),
              primary: TweenAnimationBuilder<double>(
                key: ValueKey(_actionSerial),
                tween: Tween(begin: 0, end: 1),
                duration:
                    reduced ? Duration.zero : const Duration(milliseconds: 300),
                builder: (context, progress, child) {
                  final blend = const Interval(1 / 3, 1).transform(progress);
                  final theme = Theme.of(context);
                  return Theme(
                    data: theme.copyWith(
                      extensions: [
                        for (final extension in theme.extensions.values)
                          if (extension is PantasColors)
                            colors.copyWith(
                              accentFill: Color.lerp(
                                colors.fill,
                                colors.accentFill,
                                blend,
                              ),
                              onAccent: Color.lerp(
                                colors.disabledActionLabel,
                                colors.onAccent,
                                blend,
                              ),
                            )
                          else
                            extension,
                      ],
                    ),
                    child: child!,
                  );
                },
                child: PantasButton(
                  label: _existing ? 'Update' : 'Add Note',
                  height: 44,
                  radius: 99,
                  fontSize: 16,
                  busy: _busy,
                  disabledForeground: colors.disabledActionLabel,
                  onPressed: _valid && !_busy
                      ? () => unawaited(
                            _write(
                              _tag,
                              _tag == MistakeTag.other
                                  ? _text.text.trim()
                                  : null,
                            ),
                          )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final form = Stack(
      children: [
        body,
        if (_existing)
          Positioned(
            top: 8,
            right: 8,
            width: removeWidth,
            height: 44,
            child: TextButton(
              onPressed: _busy ? null : () => unawaited(_write(null, null)),
              child: Text(
                'Remove',
                style: type.subhead.copyWith(color: colors.wrongText),
              ),
            ),
          ),
      ],
    );
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: available.clamp(100, double.infinity)),
      child: SingleChildScrollView(
        child: widget.framed
            ? FloatingBar.content(
                state: FloatingBarState.wrong,
                radius: 24,
                inset: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: form,
                ),
              )
            : form,
      ),
    );
  }
}
