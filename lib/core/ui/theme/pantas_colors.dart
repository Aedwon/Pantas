import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';

@immutable
class PantasColors extends AppColors {
  const PantasColors({
    required this.background,
    required this.surface,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.separator,
    required this.fill,
    required this.skeleton,
    required this.chevron,
    required this.accent,
    required this.accentFill,
    required this.accentTint,
    required this.destructive,
    required this.wrongTint,
    required this.wrongText,
    required this.pro,
    required this.liquidStart,
    required this.liquidEnd,
    required this.controlOutline,
    required this.pickerBackground,
    required this.warningText,
    required this.choiceOutline,
    required this.toastBackground,
    required this.toastAction,
    required this.onToast,
    required this.shadow,
    required this.transparent,
    required this.onAccent,
    required this.onDestructive,
    required this.figureBackground,
    required this.figureViewerBackground,
    required this.onFigureViewer,
    required this.floatingRight,
    required this.floatingWrong,
    required this.inactiveDateLabel,
    required this.searchPlaceholder,
    required this.pendingMark,
    required this.switchThumb,
    required this.switchThumbShadow,
    required this.segmentedShadow,
  });

  @override
  final Color background;
  @override
  final Color surface;
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color separator;
  final Color fill;
  final Color skeleton;
  final Color chevron;
  final Color accent;
  final Color accentFill;
  final Color accentTint;
  final Color destructive;
  final Color wrongTint;
  final Color wrongText;
  final Color pro;
  final Color liquidStart;
  final Color liquidEnd;
  // Task8b ruling7: meaningful unchecked control boundaries.
  final Color controlOutline;
  // QZ_Picker lesson band; dark uses inset gray next to the group surface.
  final Color pickerBackground;
  // QZ_Picker Unread; dark retains the existing high-contrast amber.
  final Color warningText;
  // QV_Answer empty letter-circle outline.
  final Color choiceOutline;
  // QV_Flag inverted toast, both themes.
  final Color toastBackground;
  // QV_Flag Undo.
  final Color toastAction;
  // QV_Flag message.
  final Color onToast;
  // QV_Flag, QV_Leave, QV_Answer and RD_Figure shadows and washes.
  final Color shadow;
  // Board states with no fill or border.
  final Color transparent;
  // Filled accent marks and actions; dark retains the readable surface foreground.
  final Color onAccent;
  // MK_Discard and QV_MissPro filled red action/mark.
  final Color onDestructive;
  // QV_Figure and RD_Figure retain white backing in dark mode.
  final Color figureBackground;
  // RD_Figure expanded viewer.
  final Color figureViewerBackground;
  // RD_Figure viewer controls.
  final Color onFigureViewer;
  // QV_Answer floating correct surface.
  final Color floatingRight;
  // QV_MissPro floating wrong surface.
  final Color floatingWrong;
  // HP_Free day-off dates, Aedwon decision Oct10.
  final Color inactiveDateLabel;
  // ST_Search inactive placeholder, Aedwon decision Oct10.
  final Color searchPlaceholder;
  // L_Restore pending dot.
  final Color pendingMark;
  // ST_Root and ST_DarkRoot white switch knob.
  final Color switchThumb;
  // ST_Root switch knob shadow.
  final Color switchThumbShadow;
  // DT_TopicsA selected segment shadow.
  final Color segmentedShadow;

  static const light = PantasColors(
    background: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    label: Color(0xFF1D1D1F),
    secondaryLabel: Color(0xFF6E6E73),
    tertiaryLabel: Color(0xFFAEAEB2),
    separator: Color(0xFFE3E3E8),
    fill: Color(0xFFEDEDF0),
    skeleton: Color(0xFFE6E6EA),
    chevron: Color(0xFFC7C7CC),
    accent: Color(0xFF0B7A68),
    accentFill: Color(0xFF0B7A68),
    accentTint: Color(0xFFE4F1EE),
    destructive: Color(0xFFD70015),
    wrongTint: Color(0xFFFDECEE),
    wrongText: Color(0xFFD70015),
    pro: Color(0xFFD9A400),
    liquidStart: Color(0xFF14937D),
    liquidEnd: Color(0xFF0B7A68),
    controlOutline: Color(0xFF8A8A8E),
    pickerBackground: Color(0xFFFBFBFC),
    warningText: Color(0xFFB25000),
    choiceOutline: Color(0xFFD1D1D6),
    toastBackground: Color(0xFF1D1D1F),
    toastAction: Color(0xFF7FD4C4),
    onToast: Color(0xFFFFFFFF),
    shadow: Color(0xFF000000),
    transparent: Color(0x00000000),
    onAccent: Color(0xFFFFFFFF),
    onDestructive: Color(0xFFFFFFFF),
    figureBackground: Color(0xFFFFFFFF),
    figureViewerBackground: Color(0xFF000000),
    onFigureViewer: Color(0xFFFFFFFF),
    floatingRight: Color(0xFFEFF7F5),
    floatingWrong: Color(0xFFFFF3F4),
    inactiveDateLabel: Color(0xFFC7C7CC),
    searchPlaceholder: Color(0xFF8E8E93),
    pendingMark: Color(0xFFD1D1D6),
    switchThumb: Color(0xFFFFFFFF),
    switchThumbShadow: Color(0x33000000),
    segmentedShadow: Color(0x1A000000),
  );

  static const dark = PantasColors(
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    label: Color(0xFFF5F5F7),
    secondaryLabel: Color(0xFF98989D),
    tertiaryLabel: Color(0xFF5A5A5E),
    separator: Color(0xFF38383A),
    fill: Color(0xFF2C2C2E),
    skeleton: Color(0xFF2C2C2E),
    chevron: Color(0xFF48484A),
    accent: Color(0xFF2FB39C),
    accentFill: Color(0xFF1F9C86),
    accentTint: Color(0xFF123F37),
    destructive: Color(0xFFD70015),
    wrongTint: Color(0xFF3A1215),
    wrongText: Color(0xFFFF6961),
    pro: Color(0xFFD9A400),
    liquidStart: Color(0xFF14937D),
    liquidEnd: Color(0xFF0B7A68),
    controlOutline: Color(0xFF8E8E93),
    pickerBackground: Color(0xFF18181A),
    warningText: Color(0xFFD9A400),
    choiceOutline: Color(0xFF48484A),
    toastBackground: Color(0xFF1D1D1F),
    toastAction: Color(0xFF7FD4C4),
    onToast: Color(0xFFFFFFFF),
    shadow: Color(0xFF000000),
    transparent: Color(0x00000000),
    onAccent: Color(0xFF1C1C1E),
    onDestructive: Color(0xFFFFFFFF),
    figureBackground: Color(0xFFFFFFFF),
    figureViewerBackground: Color(0xFF000000),
    onFigureViewer: Color(0xFFFFFFFF),
    floatingRight: Color(0xFF123F37),
    floatingWrong: Color(0xFF3A1215),
    inactiveDateLabel: Color(0xFFC7C7CC),
    searchPlaceholder: Color(0xFF8E8E93),
    pendingMark: Color(0xFF48484A),
    switchThumb: Color(0xFFFFFFFF),
    switchThumbShadow: Color(0x33000000),
    segmentedShadow: Color(0x1A000000),
  );

  /// Board accuracy colors, clamped below 40% and above 80%.
  Color accuracyTint(double accuracy) {
    final t = ((accuracy - .4) / .4).clamp(0.0, 1.0);
    return Color.fromARGB(
      255,
      (207 - 160 * t).round(),
      (232 - 89 * t).round(),
      (226 - 100 * t).round(),
    );
  }

  @override
  Object get type => PantasColors;

  @override
  PantasColors get tokens => this;

  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get ink => label;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get inkMuted => secondaryLabel;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get rule => separator;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get ruleFaint => fill;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get board => accent;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get boardTint => accentTint;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get onBoard => surface;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get rust => destructive;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get amber => pro;

  @override
  PantasColors copyWith({
    Color? background,
    Color? surface,
    Color? label,
    Color? secondaryLabel,
    Color? tertiaryLabel,
    Color? separator,
    Color? fill,
    Color? skeleton,
    Color? chevron,
    Color? accent,
    Color? accentFill,
    Color? accentTint,
    Color? destructive,
    Color? wrongTint,
    Color? wrongText,
    Color? pro,
    Color? liquidStart,
    Color? liquidEnd,
    Color? controlOutline,
    Color? pickerBackground,
    Color? warningText,
    Color? choiceOutline,
    Color? toastBackground,
    Color? toastAction,
    Color? onToast,
    Color? shadow,
    Color? transparent,
    Color? onAccent,
    Color? onDestructive,
    Color? figureBackground,
    Color? figureViewerBackground,
    Color? onFigureViewer,
    Color? floatingRight,
    Color? floatingWrong,
    Color? inactiveDateLabel,
    Color? searchPlaceholder,
    Color? pendingMark,
    Color? switchThumb,
    Color? switchThumbShadow,
    Color? segmentedShadow,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? ink,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? inkMuted,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? rule,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? ruleFaint,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? board,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? boardTint,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? onBoard,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? rust,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? amber,
  }) =>
      PantasColors(
        background: background ?? this.background,
        surface: surface ?? onBoard ?? this.surface,
        label: label ?? ink ?? this.label,
        secondaryLabel: secondaryLabel ?? inkMuted ?? this.secondaryLabel,
        tertiaryLabel: tertiaryLabel ?? this.tertiaryLabel,
        separator: separator ?? rule ?? this.separator,
        fill: fill ?? ruleFaint ?? this.fill,
        skeleton: skeleton ?? this.skeleton,
        chevron: chevron ?? this.chevron,
        accent: accent ?? board ?? this.accent,
        accentFill: accentFill ?? this.accentFill,
        accentTint: accentTint ?? boardTint ?? this.accentTint,
        destructive: destructive ?? rust ?? this.destructive,
        wrongTint: wrongTint ?? this.wrongTint,
        wrongText: wrongText ?? this.wrongText,
        pro: pro ?? amber ?? this.pro,
        liquidStart: liquidStart ?? this.liquidStart,
        liquidEnd: liquidEnd ?? this.liquidEnd,
        controlOutline: controlOutline ?? this.controlOutline,
        pickerBackground: pickerBackground ?? this.pickerBackground,
        warningText: warningText ?? this.warningText,
        choiceOutline: choiceOutline ?? this.choiceOutline,
        toastBackground: toastBackground ?? this.toastBackground,
        toastAction: toastAction ?? this.toastAction,
        onToast: onToast ?? this.onToast,
        shadow: shadow ?? this.shadow,
        transparent: transparent ?? this.transparent,
        onAccent: onAccent ?? this.onAccent,
        onDestructive: onDestructive ?? this.onDestructive,
        figureBackground: figureBackground ?? this.figureBackground,
        figureViewerBackground:
            figureViewerBackground ?? this.figureViewerBackground,
        onFigureViewer: onFigureViewer ?? this.onFigureViewer,
        floatingRight: floatingRight ?? this.floatingRight,
        floatingWrong: floatingWrong ?? this.floatingWrong,
        inactiveDateLabel: inactiveDateLabel ?? this.inactiveDateLabel,
        searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
        pendingMark: pendingMark ?? this.pendingMark,
        switchThumb: switchThumb ?? this.switchThumb,
        switchThumbShadow: switchThumbShadow ?? this.switchThumbShadow,
        segmentedShadow: segmentedShadow ?? this.segmentedShadow,
      );

  @override
  PantasColors lerp(covariant PantasColors? other, double t) {
    if (other == null) return this;
    return PantasColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      label: Color.lerp(label, other.label, t)!,
      secondaryLabel: Color.lerp(secondaryLabel, other.secondaryLabel, t)!,
      tertiaryLabel: Color.lerp(tertiaryLabel, other.tertiaryLabel, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
      chevron: Color.lerp(chevron, other.chevron, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentFill: Color.lerp(accentFill, other.accentFill, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      wrongTint: Color.lerp(wrongTint, other.wrongTint, t)!,
      wrongText: Color.lerp(wrongText, other.wrongText, t)!,
      pro: Color.lerp(pro, other.pro, t)!,
      liquidStart: Color.lerp(liquidStart, other.liquidStart, t)!,
      liquidEnd: Color.lerp(liquidEnd, other.liquidEnd, t)!,
      controlOutline: Color.lerp(controlOutline, other.controlOutline, t)!,
      pickerBackground:
          Color.lerp(pickerBackground, other.pickerBackground, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      choiceOutline: Color.lerp(choiceOutline, other.choiceOutline, t)!,
      toastBackground: Color.lerp(toastBackground, other.toastBackground, t)!,
      toastAction: Color.lerp(toastAction, other.toastAction, t)!,
      onToast: Color.lerp(onToast, other.onToast, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      transparent: Color.lerp(transparent, other.transparent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      onDestructive: Color.lerp(onDestructive, other.onDestructive, t)!,
      figureBackground:
          Color.lerp(figureBackground, other.figureBackground, t)!,
      figureViewerBackground:
          Color.lerp(figureViewerBackground, other.figureViewerBackground, t)!,
      onFigureViewer: Color.lerp(onFigureViewer, other.onFigureViewer, t)!,
      floatingRight: Color.lerp(floatingRight, other.floatingRight, t)!,
      floatingWrong: Color.lerp(floatingWrong, other.floatingWrong, t)!,
      inactiveDateLabel:
          Color.lerp(inactiveDateLabel, other.inactiveDateLabel, t)!,
      searchPlaceholder:
          Color.lerp(searchPlaceholder, other.searchPlaceholder, t)!,
      pendingMark: Color.lerp(pendingMark, other.pendingMark, t)!,
      switchThumb: Color.lerp(switchThumb, other.switchThumb, t)!,
      switchThumbShadow:
          Color.lerp(switchThumbShadow, other.switchThumbShadow, t)!,
      segmentedShadow: Color.lerp(segmentedShadow, other.segmentedShadow, t)!,
    );
  }
}
