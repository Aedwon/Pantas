import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// The label above a field or a select (`web-field-label`, `text-secondary`),
/// with an optional "(optional)" at weight 400.
class PantasFieldLabel extends StatelessWidget {
  const PantasFieldLabel(this.text, {this.optional = false, super.key});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final style = PantasType.webFieldLabel.copyWith(
      color: context.colors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (optional)
              const TextSpan(
                text: ' (optional)',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
          ],
        ),
        style: style,
      ),
    );
  }
}

/// The help or error line under a field: 13 px, an icon and a 6 px gap. An
/// error is `danger-text` with an alert icon and a sentence that says how to
/// fix it; help is `text-secondary`. Color is never the only cue.
class PantasFieldMessage extends StatelessWidget {
  const PantasFieldMessage(
    this.text, {
    this.error = false,
    this.announce = false,
    super.key,
  });

  final String text;
  final bool error;

  /// Announces the text when it appears (`role="alert"`, on submit only).
  final bool announce;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = error ? colors.dangerText : colors.textSecondary;
    return Semantics(
      liveRegion: error && announce,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: PantasSpace.s2),
              child: ExcludeSemantics(
                child: Icon(
                  error ? PantasIcons.appError : PantasIcons.info,
                  size: PantasSize.icon - PantasSpace.s4,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: PantasSpace.s6),
            Expanded(
              child: Text(
                text,
                style: PantasType.webSmall.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single-line or multi-line text input with a label above, a ring that
/// turns `accent` on focus, and an error state (design system Field).
///
/// A 48 px well (`surface-card`, `radius-md`, 1 px `border-control` ring):
/// hover draws the ring in `text-secondary`, focus a 2 px `accent` ring,
/// invalid a 2 px `danger` ring (and, when focused too, the outer focus
/// outline). Read-only is `surface-inset` with a `divider` ring; disabled is
/// `fill` with `text-disabled`. A tap anywhere in the well focuses the input,
/// so the 44 px touch target is met. [multiline] is a textarea, at least 92.
///
/// The consumer provides the label, the validation and the message text.
class PantasField extends StatefulWidget {
  const PantasField({
    required this.label,
    this.optional = false,
    this.controller,
    this.focusNode,
    this.hint,
    this.helpText,
    this.errorText,
    this.multiline = false,
    this.maxLines,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.action,
    this.announceError = false,
    super.key,
  }) : showLabel = true;

  /// A field with no visible label, for a place where the screen already says
  /// what the field is (a note box under the choice that asked for it).
  /// [semanticLabel] is its name for screen readers and is required, since the
  /// placeholder is never the name (Field README, Accessibility).
  const PantasField.unlabeled({
    required String semanticLabel,
    this.controller,
    this.focusNode,
    this.hint,
    this.helpText,
    this.errorText,
    this.multiline = false,
    this.maxLines,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.action,
    this.announceError = false,
    super.key,
  })  : label = semanticLabel,
        optional = false,
        showLabel = false;

  /// The visible label, or the screen reader name of an unlabeled field.
  final String label;

  /// False for `PantasField.unlabeled`: the label is not drawn.
  final bool showLabel;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;

  /// The help line, shown while there is no error.
  final String? helpText;

  /// The error sentence. A non-null value makes the field invalid.
  final String? errorText;
  final bool optional;
  final bool multiline;

  /// The most lines a [multiline] field grows to; unlimited when null.
  final int? maxLines;
  final bool readOnly;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// One trailing action (a calendar, clear or show-password button) that
  /// pulls 8 px into the padding so its icon lines up with the padding edge.
  final Widget? action;

  /// Announces the error when it appears; set it on submit only.
  final bool announceError;

  @override
  State<PantasField> createState() => _PantasFieldState();
}

class _PantasFieldState extends State<PantasField> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  bool _focused = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(PantasField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_focusChanged);
      _focus.addListener(_focusChanged);
    }
  }

  void _focusChanged() {
    if (_focused != _focus.hasFocus && mounted) {
      setState(() => _focused = _focus.hasFocus);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final invalid = widget.errorText != null;
    final disabled = !widget.enabled;
    final readOnly = widget.readOnly && !disabled;
    final interactive = !disabled && !readOnly;
    final radius = BorderRadius.circular(PantasRadius.md);

    final Color well;
    Color? ring;
    var ringWidth = PantasBorder.ring;
    if (disabled) {
      well = colors.fill;
    } else if (readOnly) {
      well = colors.surfaceInset;
      ring = colors.divider;
    } else {
      well = colors.surfaceCard;
      if (invalid) {
        ring = colors.danger;
        ringWidth = PantasBorder.ringSelected;
      } else if (_focused) {
        ring = colors.accent;
        ringWidth = PantasBorder.ringSelected;
      } else if (_hovered) {
        ring = colors.textSecondary;
      } else {
        ring = colors.borderControl;
      }
    }

    final textStyle = (widget.multiline
            ? PantasType.webBody
            : PantasType.webRowTitleSettings)
        .copyWith(color: disabled ? colors.textDisabled : colors.textPrimary);
    final vertical = widget.multiline ? PantasSpace.s12 : PantasSpace.s0;
    final minHeight = widget.multiline ? PantasSize.textarea : PantasSize.field;

    final input = TextField(
      controller: widget.controller,
      focusNode: _focus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      keyboardType:
          widget.multiline ? TextInputType.multiline : widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      maxLines: widget.multiline ? widget.maxLines : 1,
      minLines: widget.multiline ? 1 : null,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: textStyle,
      cursorColor: colors.accent,
      decoration: InputDecoration(
        isCollapsed: true,
        hintText: widget.hint,
        hintStyle: textStyle.copyWith(
          color: disabled ? colors.textDisabled : colors.textSecondary,
        ),
        border: InputBorder.none,
        counterText: '',
        contentPadding: EdgeInsets.symmetric(
          vertical: widget.multiline ? PantasSpace.s0 : PantasSpace.s12,
        ),
      ),
    );

    final body = Row(
      crossAxisAlignment: widget.multiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Expanded(child: Semantics(label: widget.label, child: input)),
        if (widget.action != null) ...[
          const SizedBox(width: PantasSpace.s8),
          // Pulls 8 px into the padding so the icon lines up with its edge.
          Transform.translate(
            offset: const Offset(PantasSpace.s8, 0),
            child: widget.action,
          ),
        ],
      ],
    );

    final fieldWell = MouseRegion(
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? _focus.requestFocus : null,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: ring ?? Colors.transparent),
          duration: still ? Duration.zero : PantasDurations.short2,
          curve: PantasCurves.fade,
          builder: (context, animated, child) => Container(
            key: const ValueKey('field-well'),
            constraints: BoxConstraints(minHeight: minHeight),
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s14,
              vertical,
              widget.action != null ? PantasSpace.s6 : PantasSpace.s14,
              vertical,
            ),
            decoration: BoxDecoration(color: well, borderRadius: radius),
            foregroundDecoration: ring == null
                ? null
                : BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: animated ?? ring,
                      width: ringWidth,
                    ),
                  ),
            child: child,
          ),
          child: body,
        ),
      ),
    );

    // Read-only and invalid fields add the outer focus outline when focused.
    final needsOuter = readOnly || invalid;
    final message = invalid
        ? PantasFieldMessage(
            widget.errorText!,
            error: true,
            announce: widget.announceError,
          )
        : widget.helpText == null
            ? null
            : PantasFieldMessage(widget.helpText!);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showLabel) ...[
            ExcludeSemantics(
              child: PantasFieldLabel(widget.label, optional: widget.optional),
            ),
            const SizedBox(height: PantasSpace.s6),
          ],
          _FocusOutline(
            show: needsOuter && _focused,
            radius: radius,
            child: fieldWell,
          ),
          if (message != null) ...[
            const SizedBox(height: PantasSpace.s6),
            message,
          ],
        ],
      ),
    );
  }
}

/// The 2 px `accent` outline, offset 2, around a focused read-only or invalid
/// well (R3-A09). Unlike [OffsetFocusRing] it shows for any focus, since the
/// well stays in its own ring color.
class _FocusOutline extends StatelessWidget {
  const _FocusOutline({
    required this.show,
    required this.radius,
    required this.child,
  });

  final bool show;
  final BorderRadius radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const reach = PantasBorder.focus + PantasSpace.s2;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned(
            left: -reach,
            top: -reach,
            right: -reach,
            bottom: -reach,
            child: IgnorePointer(
              child: DecoratedBox(
                key: const ValueKey('field-outline'),
                decoration: BoxDecoration(
                  borderRadius: radius.add(
                    const BorderRadius.all(Radius.circular(reach)),
                  ),
                  border: Border.all(
                    color: context.colors.accent,
                    width: PantasBorder.focus,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
