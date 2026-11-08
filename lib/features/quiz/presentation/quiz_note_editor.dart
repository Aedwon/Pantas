import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/quiz/presentation/quiz_tap_area.dart';

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
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s20,
            PantasSpace.s20,
            PantasSpace.s20,
            PantasSpace.s18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(PantasIcons.addNote, size: 22, color: t.colors.accent),
                  const SizedBox(width: PantasSpace.s8),
                  Expanded(
                    child: Text(
                      'Why did you miss it?',
                      style: PantasType.webButtonLg
                          .copyWith(color: t.colors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PantasSpace.s14),
              for (var row = 0; row < reasons.length; row += 2) ...[
                if (row > 0) const SizedBox(height: PantasSpace.s8),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = row; i < row + 2; i++) ...[
                        if (i > row) const SizedBox(width: PantasSpace.s8),
                        Expanded(child: _reason(t, i, reasons[i])),
                      ],
                    ],
                  ),
                ),
              ],
              if (_tag == MistakeTag.other) ...[
                const SizedBox(height: PantasSpace.s14),
                ConstrainedBox(
                  // Four lines of the field text, its padding and its label.
                  constraints: BoxConstraints(
                    maxHeight: 4 *
                            PantasType.webBody.fontSize! *
                            (PantasType.webBody.height ?? 1) +
                        2 * PantasSpace.s12 +
                        PantasSpace.s32,
                  ),
                  child: SingleChildScrollView(
                    child: PantasField(
                      label: 'In your own words',
                      hint: 'In your own words',
                      controller: _text,
                      focusNode: _focus,
                      enabled: !_busy,
                      multiline: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ],
              if (_failed)
                saveFailureLine(() {
                  final retry = _retry;
                  if (retry != null) unawaited(_write(retry.$1, retry.$2));
                }),
              const SizedBox(height: PantasSpace.s14),
              Row(
                children: [
                  if (_existing)
                    _NoteButton(
                      label: 'Remove',
                      danger: true,
                      onPressed:
                          _busy ? null : () => unawaited(_write(null, null)),
                    ),
                  const Spacer(),
                  _NoteButton(
                    label: _existing ? 'Cancel' : 'Not Now',
                    onPressed: _busy ? null : widget.onCancel,
                  ),
                  const SizedBox(width: PantasSpace.s4),
                  _NoteButton(
                    label: _existing ? 'Update' : 'Add Note',
                    solid: true,
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

  Widget _reason(WebTokens t, int i, (MistakeTag, String) reason) {
    final selected = _tag == reason.$1;
    final saved = widget.tag == reason.$1;
    final radius = BorderRadius.circular(PantasRadius.md);
    return QuizTapArea(
      onTap: _busy ? null : () => _choose(reason.$1),
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? t.colors.accentTint : t.colors.bgPage,
          borderRadius: radius,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s12,
              vertical: PantasSpace.s8,
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: PantasSpace.s6),
                  decoration: BoxDecoration(
                    color: selected ? t.colors.accentFill : null,
                    borderRadius: BorderRadius.circular(PantasRadius.xs),
                    border:
                        selected ? null : Border.all(color: t.strongDivider),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: PantasType.webKeyHintSm.copyWith(
                      color:
                          selected ? t.colors.onAccent : t.colors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: PantasSpace.s10),
                Expanded(
                  child: Text(
                    reason.$2,
                    style: PantasType.webRowValue.copyWith(
                      color: t.colors.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (saved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s8,
                      vertical: PantasSpace.s2,
                    ),
                    decoration: BoxDecoration(
                      color: t.disabledBackground,
                      borderRadius: BorderRadius.circular(PantasRadius.full),
                    ),
                    child: Text(
                      'Your note',
                      style: PantasType.webTag
                          .copyWith(color: t.colors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) return _web(context);
    final colors = context.colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final removeWidth = MediaQuery.textScalerOf(context).scale(70);
    final available = MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        MediaQuery.paddingOf(context).top -
        80;
    final body = ConstrainedBox(
      constraints: BoxConstraints(minHeight: available >= 318 ? 318 : 0),
      child: Padding(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Why did you miss it?',
                    style: PantasType.phoneHeadline.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_existing) SizedBox(width: removeWidth),
              ],
            ),
            // QN_WrongOpen: 47 px rows with a hairline between them.
            const SizedBox(height: PantasSpace.s10),
            for (final (index, (tag, label)) in const [
              (MistakeTag.misread, 'I misread'),
              (MistakeTag.slipped, 'I forgot'),
              (MistakeTag.unknown, "I didn't know"),
              (MistakeTag.other, 'Type my own'),
            ].indexed) ...[
              if (index > 0)
                Divider(
                  height: .5,
                  thickness: .5,
                  color: colors.divider,
                ),
              RadioRow(
                title: label,
                selected: _tag == tag,
                onTap: _busy ? null : () => _choose(tag),
                padding: const EdgeInsets.symmetric(vertical: PantasSpace.s10),
              ),
            ],
            if (_tag == MistakeTag.other) ...[
              const SizedBox(height: PantasSpace.s8),
              TextField(
                controller: _text, // ds-raw: board draws no field label
                focusNode: _focus,
                enabled: !_busy,
                minLines: 1,
                maxLines: 4,
                style: PantasType.phoneCallout.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'In your own words',
                  filled: true,
                  fillColor: colors.fill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s14,
                    vertical: PantasSpace.s14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PantasRadius.md),
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
            const SizedBox(height: PantasSpace.s20),
            if (_failed)
              saveFailureLine(() {
                final retry = _retry;
                if (retry != null) unawaited(_write(retry.$1, retry.$2));
              }),
            ButtonPair(
              secondary: PantasButton(
                label: 'Cancel',
                variant: PantasButtonVariant.neutral,
                height: PantasSize.btn,
                radius: PantasRadius.full,
                fontSize: PantasType.webButton.fontSize,
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
                                colors.textDisabled,
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
                  height: PantasSize.btn,
                  radius: PantasRadius.full,
                  fontSize: PantasType.webButton.fontSize,
                  busy: _busy,
                  disabledForeground: colors.textDisabled,
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
            right: 18,
            width: removeWidth,
            height: PantasSize.btn,
            child: PantasButton(
              label: 'Remove',
              kind: PantasButtonKind.tertiary,
              tone: PantasButtonTone.critical,
              height: PantasSize.btn,
              onPressed: _busy ? null : () => unawaited(_write(null, null)),
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
                radius: PantasRadius.r2xl,
                inset: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(PantasRadius.r2xl),
                  ),
                  child: form,
                ),
              )
            : form,
      ),
    );
  }
}

/// Board `.btn` and `.btn3`: a primary Button for the solid one, a tertiary
/// one for the rest, critical for Remove.
class _NoteButton extends StatelessWidget {
  const _NoteButton({
    required this.label,
    required this.onPressed,
    this.solid = false,
    this.danger = false,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool solid;
  final bool danger;
  final bool busy;
  @override
  Widget build(BuildContext context) => WebButton(
        label: label,
        onPressed: busy ? null : onPressed,
        busy: busy,
        kind: solid ? PantasButtonKind.primary : PantasButtonKind.tertiary,
        tone: danger ? PantasButtonTone.critical : null,
        size: PantasButtonSize.sm,
      );
}
