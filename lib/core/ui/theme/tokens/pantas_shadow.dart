// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart

import 'package:flutter/material.dart';

/// Elevation shadows per theme. Rings are borders, not shadows.
@immutable
class PantasShadow extends ThemeExtension<PantasShadow> {
  const PantasShadow({
    required this.navActive,
    required this.segment,
    required this.knob,
    required this.thumb,
    required this.popover,
    required this.bar,
    required this.toast,
    required this.drawer,
    required this.modal,
    required this.sheet,
  });

  /// Active sidebar item. Dark alpha .5 (CHANGE: .06 did not show on dark).
  /// Level 1 (control).
  final List<BoxShadow> navActive;

  /// Selected segment thumb. Dark alpha .5 (CHANGE). Level 1 (control).
  final List<BoxShadow> segment;

  /// Switch thumb. Dark alpha .5 (CHANGE). Level 1 (control).
  final List<BoxShadow> knob;

  /// Slider thumb (phone board). Dark alpha chosen. Level 1 (control).
  final List<BoxShadow> thumb;

  /// Popover. Dark edge and alpha are chosen. Level 2 (floating).
  final List<BoxShadow> popover;

  /// Drop of the floating action bar and phone tab bar. The 1px ring is
  /// edge-bar (or a state ring), drawn before it: inset 0 0 0 1px
  /// var(--edge-bar), var(--elev-bar). Folds elev-bar-drop. Level 2
  /// (floating).
  final List<BoxShadow> bar;

  /// Toast. Dark adds a 1px #4A4A4A edge and alpha .6 (CHANGE). Level 2
  /// (floating).
  final List<BoxShadow> toast;

  /// Drawer. Dark alpha is chosen. Level 3 (panel).
  final List<BoxShadow> drawer;

  /// Dialog. Dark edge and alpha are chosen. Level 4 (modal).
  final List<BoxShadow> modal;

  /// Phone sheet, cast upward. Dark alpha is chosen. Level 3 (panel).
  final List<BoxShadow> sheet;

  static const light = PantasShadow(
    navActive: [
      BoxShadow(
        color: Color(0x0F000000),
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
    segment: [
      BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 1),
        blurRadius: 3,
      ),
    ],
    knob: [
      BoxShadow(
        color: Color(0x33000000),
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
    thumb: [
      BoxShadow(
        color: Color(0x38000000),
        offset: Offset(0, 2),
        blurRadius: 6,
      ),
    ],
    popover: [
      BoxShadow(
        color: Color(0x14000000),
        spreadRadius: 0.5,
      ),
      BoxShadow(
        color: Color(0x29000000),
        offset: Offset(0, 14),
        blurRadius: 40,
      ),
    ],
    bar: [
      BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 10),
        blurRadius: 30,
      ),
    ],
    toast: [
      BoxShadow(
        color: Color(0x33000000),
        offset: Offset(0, 10),
        blurRadius: 30,
      ),
    ],
    drawer: [
      BoxShadow(
        color: Color(0x2E000000),
        offset: Offset(-20, 0),
        blurRadius: 60,
      ),
    ],
    modal: [
      BoxShadow(
        color: Color(0x40000000),
        offset: Offset(0, 30),
        blurRadius: 80,
      ),
    ],
    sheet: [
      BoxShadow(
        color: Color(0x14000000),
        offset: Offset(0, -8),
        blurRadius: 30,
      ),
    ],
  );

  static const dark = PantasShadow(
    navActive: [
      BoxShadow(
        color: Color(0x80000000),
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
    segment: [
      BoxShadow(
        color: Color(0x80000000),
        offset: Offset(0, 1),
        blurRadius: 3,
      ),
    ],
    knob: [
      BoxShadow(
        color: Color(0x80000000),
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
    thumb: [
      BoxShadow(
        color: Color(0x80000000),
        offset: Offset(0, 2),
        blurRadius: 6,
      ),
    ],
    popover: [
      BoxShadow(
        color: Color(0xFF2C2C2C),
        spreadRadius: 0.5,
      ),
      BoxShadow(
        color: Color(0x80000000),
        offset: Offset(0, 14),
        blurRadius: 40,
      ),
    ],
    bar: [
      BoxShadow(
        color: Color(0x66000000),
        offset: Offset(0, 10),
        blurRadius: 30,
      ),
    ],
    toast: [
      BoxShadow(
        color: Color(0xFF4A4A4A),
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Color(0x99000000),
        offset: Offset(0, 10),
        blurRadius: 30,
      ),
    ],
    drawer: [
      BoxShadow(
        color: Color(0x80000000),
        offset: Offset(-20, 0),
        blurRadius: 60,
      ),
    ],
    modal: [
      BoxShadow(
        color: Color(0xFF2C2C2C),
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Color(0x99000000),
        offset: Offset(0, 30),
        blurRadius: 80,
      ),
    ],
    sheet: [
      BoxShadow(
        color: Color(0x66000000),
        offset: Offset(0, -8),
        blurRadius: 30,
      ),
    ],
  );

  @override
  PantasShadow copyWith({
    List<BoxShadow>? navActive,
    List<BoxShadow>? segment,
    List<BoxShadow>? knob,
    List<BoxShadow>? thumb,
    List<BoxShadow>? popover,
    List<BoxShadow>? bar,
    List<BoxShadow>? toast,
    List<BoxShadow>? drawer,
    List<BoxShadow>? modal,
    List<BoxShadow>? sheet,
  }) =>
      PantasShadow(
        navActive: navActive ?? this.navActive,
        segment: segment ?? this.segment,
        knob: knob ?? this.knob,
        thumb: thumb ?? this.thumb,
        popover: popover ?? this.popover,
        bar: bar ?? this.bar,
        toast: toast ?? this.toast,
        drawer: drawer ?? this.drawer,
        modal: modal ?? this.modal,
        sheet: sheet ?? this.sheet,
      );

  @override
  PantasShadow lerp(ThemeExtension<PantasShadow>? other, double t) {
    if (other is! PantasShadow) return this;
    return PantasShadow(
      navActive: BoxShadow.lerpList(navActive, other.navActive, t)!,
      segment: BoxShadow.lerpList(segment, other.segment, t)!,
      knob: BoxShadow.lerpList(knob, other.knob, t)!,
      thumb: BoxShadow.lerpList(thumb, other.thumb, t)!,
      popover: BoxShadow.lerpList(popover, other.popover, t)!,
      bar: BoxShadow.lerpList(bar, other.bar, t)!,
      toast: BoxShadow.lerpList(toast, other.toast, t)!,
      drawer: BoxShadow.lerpList(drawer, other.drawer, t)!,
      modal: BoxShadow.lerpList(modal, other.modal, t)!,
      sheet: BoxShadow.lerpList(sheet, other.sheet, t)!,
    );
  }
}
