// Material component themes in the system's look. A raw Material control left
// anywhere in the app (the `design_raw_controls` check keeps them out of
// `lib/` outside `lib/core/ui/`) draws these values, never Flutter's own
// defaults: rounded rectangles, never a stadium or a circle highlight, the
// `opacity-hover` wash of the foreground, and no ink splash.
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// Every fallback theme, ready to pass to `ThemeData`.
class PantasComponentThemes {
  PantasComponentThemes(this.colors, this.brightness)
      : shadows = brightness == Brightness.dark
            ? PantasShadow.dark
            : PantasShadow.light;

  final PantasColors colors;
  final Brightness brightness;
  final PantasShadow shadows;

  static const _md = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(PantasRadius.md)),
  );
  static const _sm = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(PantasRadius.sm)),
  );
  static const _lg = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(PantasRadius.lg)),
  );

  /// The `opacity-hover` wash of [foreground] (Button, IconButton READMEs).
  Color _wash(Color foreground) =>
      foreground.withValues(alpha: PantasOpacity.hover);

  Color _disabled(Color color) =>
      color.withValues(alpha: PantasOpacity.disabled);

  /// Hover draws the wash. A press adds nothing: the system presses with a
  /// scale, which a raw control cannot do. Keyboard focus draws the ring.
  WidgetStateProperty<Color?> _washOverlay(Color foreground) =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) &&
            !states.contains(WidgetState.disabled)) {
          return _wash(foreground);
        }
        return Colors.transparent;
      });

  /// Keyboard-only focus ring, or [rest] when there is none.
  WidgetStateProperty<BorderSide?> _side(BorderSide? rest) =>
      WidgetStateProperty.resolveWith(
        (states) => webFocusRing(states, colors.accent) ?? rest,
      );

  ButtonStyle _button({
    required Color foreground,
    Color? background,
    Color? hoverBackground,
    BorderSide? ring,
    Color? wash,
    TextStyle? textStyle,
  }) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_md),
      splashFactory: NoSplash.splashFactory,
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      minimumSize: const WidgetStatePropertyAll(Size(0, PantasSize.btn)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: PantasSpace.s20),
      ),
      textStyle: WidgetStatePropertyAll(textStyle ?? PantasType.webButton),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colors.disabledActionLabel
            : foreground,
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return background == null ? Colors.transparent : colors.fill;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return hoverBackground ?? background ?? Colors.transparent;
        }
        return background ?? Colors.transparent;
      }),
      overlayColor: _washOverlay(wash ?? foreground),
      side: _side(ring),
    );
  }

  TextButtonThemeData get textButton => TextButtonThemeData(
        style: _button(foreground: colors.accent),
      );

  FilledButtonThemeData get filledButton => FilledButtonThemeData(
        style: _button(
          foreground: colors.onAccent,
          background: colors.accentFill,
          hoverBackground: colors.accentFillHover,
          wash: Colors.transparent,
        ),
      );

  ElevatedButtonThemeData get elevatedButton => ElevatedButtonThemeData(
        style: _button(
          foreground: colors.label,
          background: colors.fill,
        ),
      );

  OutlinedButtonThemeData get outlinedButton => OutlinedButtonThemeData(
        style: _button(
          foreground: colors.label,
          ring: BorderSide(
            color: colors.controlOutline,
            width: PantasBorder.ringStrong,
          ),
        ),
      );

  IconButtonThemeData get iconButton => IconButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(_md),
          splashFactory: NoSplash.splashFactory,
          minimumSize: const WidgetStatePropertyAll(
            Size.square(PantasSize.iconBtn),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.disabledActionLabel;
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return colors.label;
            }
            return colors.secondaryLabel;
          }),
          overlayColor: _washOverlay(colors.secondaryLabel),
          side: _side(null),
        ),
      );

  InputDecorationTheme get inputDecoration {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(PantasRadius.md)),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationTheme(
      // Unfilled and unconstrained, so a bare field set inside a system
      // component (search, report) keeps the size and ground it draws itself.
      filled: false,
      hoverColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PantasSpace.s14,
        vertical: PantasSpace.s12,
      ),
      labelStyle: PantasType.webFieldLabel.copyWith(
        color: colors.secondaryLabel,
      ),
      floatingLabelStyle: PantasType.webFieldLabel.copyWith(
        color: colors.secondaryLabel,
      ),
      hintStyle: PantasType.webBody.copyWith(color: colors.secondaryLabel),
      helperStyle: PantasType.webSmall.copyWith(color: colors.secondaryLabel),
      errorStyle: PantasType.webSmall.copyWith(color: colors.dangerText),
      prefixIconColor: colors.secondaryLabel,
      suffixIconColor: colors.secondaryLabel,
      // One state-resolved border and no per-state borders: a field that sets
      // `border: InputBorder.none` because its frame is drawn around it (the
      // search field) then draws no second outline. Per-state theme borders
      // would fill `enabledBorder` and win over the field's `none`.
      border: WidgetStateInputBorder.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return border(colors.fill, PantasBorder.ring);
        }
        if (states.contains(WidgetState.error)) {
          return border(colors.danger, PantasBorder.ringSelected);
        }
        if (states.contains(WidgetState.focused)) {
          return border(colors.accent, PantasBorder.ringSelected);
        }
        return border(colors.controlOutline, PantasBorder.ring);
      }),
    );
  }

  TooltipThemeData get tooltip => TooltipThemeData(
        waitDuration: PantasDurations.tooltip,
        preferBelow: false,
        // Touch never shows a tooltip; the control keeps its own label.
        triggerMode: TooltipTriggerMode.manual,
        constraints: const BoxConstraints(maxWidth: PantasSize.tooltipMax),
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s8,
          vertical: PantasSpace.s4,
        ),
        decoration: BoxDecoration(
          color: colors.toastBackground,
          borderRadius:
              const BorderRadius.all(Radius.circular(PantasRadius.sm)),
          boxShadow: shadows.toast,
        ),
        textStyle: PantasType.webCaption.copyWith(color: colors.onToast),
      );

  SnackBarThemeData get snackBar => SnackBarThemeData(
        backgroundColor: colors.toastBackground,
        contentTextStyle:
            PantasType.webRowValue.copyWith(color: colors.onToast),
        actionTextColor: colors.toastAction,
        disabledActionTextColor: _disabled(colors.toastAction),
        elevation: 0,
        shape: _lg,
        behavior: SnackBarBehavior.floating,
      );

  ListTileThemeData get listTile => ListTileThemeData(
        shape: const RoundedRectangleBorder(),
        tileColor: Colors.transparent,
        selectedTileColor: colors.accentTint,
        selectedColor: colors.accentTintText,
        iconColor: colors.accent,
        textColor: colors.label,
        titleTextStyle: PantasType.webRowTitle.copyWith(color: colors.label),
        subtitleTextStyle:
            PantasType.webRowSub.copyWith(color: colors.secondaryLabel),
        leadingAndTrailingTextStyle:
            PantasType.webRowValue.copyWith(color: colors.secondaryLabel),
        contentPadding: const EdgeInsets.symmetric(horizontal: PantasSpace.s20),
        horizontalTitleGap: PantasSpace.s16,
        minTileHeight: PantasSize.rowMinPhone,
      );

  ProgressIndicatorThemeData get progressIndicator =>
      ProgressIndicatorThemeData(
        // The Spinner README's arc: `accent` at `border-ring-current`. Raw
        // linear bars share this one color slot; the shared ProgressBar sets
        // its own `accent-fill`.
        color: colors.accent,
        linearTrackColor: colors.fill,
        circularTrackColor: colors.fill,
        linearMinHeight: PantasSize.accuracyBar,
        strokeWidth: PantasBorder.ringCurrent,
        borderRadius:
            const BorderRadius.all(Radius.circular(PantasRadius.full)),
      );

  WidgetStateProperty<Color?> get _selectedFill =>
      WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        final base = selected ? colors.accentFill : Colors.transparent;
        if (states.contains(WidgetState.disabled)) return _disabled(base);
        if (selected &&
            (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed))) {
          return colors.accentFillHover;
        }
        return base;
      });

  WidgetStateProperty<Color?> get _wellOverlay =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return colors.surfaceHover;
        }
        return Colors.transparent;
      });

  CheckboxThemeData get checkbox => CheckboxThemeData(
        shape: _sm,
        fillColor: _selectedFill,
        checkColor: WidgetStatePropertyAll(colors.onAccent),
        overlayColor: _wellOverlay,
        splashRadius: PantasSpace.s0,
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return BorderSide.none;
          final ring = states.contains(WidgetState.disabled)
              ? _disabled(colors.controlOutline)
              : colors.controlOutline;
          return BorderSide(color: ring, width: PantasBorder.ringStrong);
        }),
      );

  RadioThemeData get radio => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? colors.accentFill
              : colors.controlOutline;
          return states.contains(WidgetState.disabled)
              ? _disabled(color)
              : color;
        }),
        overlayColor: _wellOverlay,
        splashRadius: PantasSpace.s0,
      );

  SwitchThemeData get switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? _disabled(colors.switchThumb)
              : colors.switchThumb,
        ),
        trackColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          final hovered = states.contains(WidgetState.hovered);
          final color = selected
              ? (hovered ? colors.accentFillHover : colors.accentFill)
              : (hovered ? colors.dividerStrong : colors.switchOff);
          return states.contains(WidgetState.disabled)
              ? _disabled(color)
              : color;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return states.contains(WidgetState.disabled)
              ? _disabled(colors.controlOutline)
              : colors.controlOutline;
        }),
        trackOutlineWidth:
            const WidgetStatePropertyAll(PantasBorder.ringStrong),
        overlayColor: _wellOverlay,
        splashRadius: PantasSpace.s0,
      );

  SliderThemeData get slider => SliderThemeData(
        trackHeight: PantasSize.sliderTrack,
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.fill,
        disabledActiveTrackColor: _disabled(colors.accent),
        disabledInactiveTrackColor: _disabled(colors.fill),
        thumbColor: colors.switchThumb,
        disabledThumbColor: _disabled(colors.switchThumb),
        overlayColor: _wash(colors.accent),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: PantasSize.sliderThumb / 2,
          elevation: 0,
          pressedElevation: 0,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
        tickMarkShape: SliderTickMarkShape.noTickMark,
      );

  ChipThemeData get chip => ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(PantasRadius.sm)),
          side: BorderSide(color: colors.controlOutline),
        ),
        side: BorderSide(color: colors.controlOutline),
        backgroundColor: Colors.transparent,
        selectedColor: colors.accentTint,
        disabledColor: colors.fill,
        surfaceTintColor: Colors.transparent,
        labelStyle: PantasType.webLabel.copyWith(color: colors.label),
        secondaryLabelStyle:
            PantasType.webLabel.copyWith(color: colors.accentTintText),
        checkmarkColor: colors.accentTintText,
        iconTheme: IconThemeData(color: colors.secondaryLabel),
        elevation: 0,
        pressElevation: 0,
      );

  PopupMenuThemeData get popupMenu => PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow,
        elevation: 0,
        shape: _lg,
        menuPadding: const EdgeInsets.all(PantasSpace.s6),
        textStyle: PantasType.webBody.copyWith(color: colors.label),
        labelTextStyle: WidgetStatePropertyAll(
          PantasType.webBody.copyWith(color: colors.label),
        ),
      );

  BottomSheetThemeData get bottomSheet => BottomSheetThemeData(
        backgroundColor: colors.surfaceModal,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.surfaceModal,
        modalBarrierColor: colors.scrim,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PantasRadius.lg),
          ),
        ),
      );

  static const _r2xl = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(PantasRadius.r2xl)),
  );

  /// AlertDialog and SimpleDialog (Dialog README): `surface-modal`,
  /// `radius-2xl`, a 20/700 title and a 16 body in `text-secondary`.
  DialogThemeData get dialog => DialogThemeData(
        backgroundColor: colors.surfaceModal,
        surfaceTintColor: Colors.transparent,
        barrierColor: colors.scrim,
        shape: _r2xl,
        titleTextStyle: PantasType.webH3.copyWith(color: colors.label),
        contentTextStyle:
            PantasType.webBody.copyWith(color: colors.secondaryLabel),
      );

  /// A raw FloatingActionButton: flat, a rounded rectangle, the accent fill
  /// and its hover. The system has no floating circle.
  FloatingActionButtonThemeData get floatingActionButton =>
      FloatingActionButtonThemeData(
        backgroundColor: colors.accentFill,
        foregroundColor: colors.onAccent,
        hoverColor: colors.accentFillHover,
        focusColor: colors.accentFillHover,
        splashColor: Colors.transparent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        shape: _lg,
        extendedTextStyle: PantasType.webButton,
      );

  MenuStyle get _menuStyle => MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(colors.shadow),
        elevation: const WidgetStatePropertyAll(0),
        shape: const WidgetStatePropertyAll(_lg),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.all(PantasSpace.s6),
        ),
      );

  /// A raw DropdownMenu opens a Popover surface.
  DropdownMenuThemeData get dropdownMenu => DropdownMenuThemeData(
        menuStyle: _menuStyle,
        textStyle: PantasType.webBody.copyWith(color: colors.label),
      );

  /// A raw MenuAnchor or MenuBar opens a Popover surface.
  MenuThemeData get menu => MenuThemeData(style: _menuStyle);

  /// A raw menu item is a radius-md row with the hover wash.
  MenuButtonThemeData get menuButton => MenuButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(_md),
          splashFactory: NoSplash.splashFactory,
          foregroundColor: WidgetStatePropertyAll(colors.label),
          textStyle: const WidgetStatePropertyAll(PantasType.webBody),
          overlayColor: _washOverlay(colors.label),
        ),
      );
}
