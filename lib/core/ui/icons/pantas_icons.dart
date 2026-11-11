import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/own/own_icons.dart';

abstract final class PantasIcons {
  // Constants, never built from a variable codepoint, so the web build can
  // still tree shake the icon fonts.
  static const IconData flagFill = IconData(0xe244, fontFamily: 'PhosphorFill');
  static const IconData bookmarkFill =
      IconData(0xe0ea, fontFamily: 'PhosphorFill');
  static const IconData backBold = IconData(0xe138, fontFamily: 'PhosphorBold');
  static const IconData nextBold = IconData(0xe13a, fontFamily: 'PhosphorBold');
  static const IconData counterBold =
      IconData(0xe136, fontFamily: 'PhosphorBold');
  static const IconData arrowRightBold =
      IconData(0xe06c, fontFamily: 'PhosphorBold');

  /// The Fill weight of a Regular glyph: the on state of a toggled
  /// IconButton or Flag button (D190 item 10). A glyph with no Fill constant
  /// above stays Regular.
  static IconData fill(IconData regular) => switch (regular.codePoint) {
        0xe244 => flagFill,
        0xe0ea => bookmarkFill,
        _ => regular,
      };

  /// The Bold weight of a Regular glyph: 14 to 16px chevrons and arrows. A
  /// glyph with no Bold constant above stays Regular.
  static IconData bold(IconData regular) => switch (regular.codePoint) {
        0xe138 => backBold,
        0xe13a => nextBold,
        0xe136 => counterBold,
        0xe06c => arrowRightBold,
        _ => regular,
      };

  static IconData get unlimitedMocks =>
      const IconData(0xe634, fontFamily: 'Phosphor');
  static IconData get answerNotes =>
      const IconData(0xe34c, fontFamily: 'Phosphor');
  static IconData get studyHabits =>
      const IconData(0xe156, fontFamily: 'Phosphor');
  static IconData get proBackup =>
      const IconData(0xe1ae, fontFamily: 'Phosphor');
  static IconData get topicResults =>
      const IconData(0xeadc, fontFamily: 'Phosphor');
  static IconData get copy => const IconData(0xe1ca, fontFamily: 'Phosphor');
  static IconData get cloudSlash =>
      const IconData(0xe1b6, fontFamily: 'Phosphor');
  static IconData get phoneSlash =>
      const IconData(0xee46, fontFamily: 'Phosphor');
  static IconData get homeTab => const IconData(0xe2c2, fontFamily: 'Phosphor');
  static IconData get studyTab =>
      const IconData(0xe0e6, fontFamily: 'Phosphor');
  static IconData get quizTab => const IconData(0xe184, fontFamily: 'Phosphor');
  static IconData get settingsTab =>
      const IconData(0xe272, fontFamily: 'Phosphor');

  /// Phosphor calendar-blank (Regular), the exam date field's calendar button.
  /// Codepoint 0xe10a from phosphor_flutter 2.1.0, whose Regular font is
  /// byte-identical to assets/fonts/phosphor/Phosphor.ttf.
  static IconData get calendarBlank =>
      const IconData(0xe10a, fontFamily: 'Phosphor');

  /// Phosphor plus and minus (Regular), the age stepper's buttons. Codepoints
  /// 0xe3d4 and 0xe32a from phosphor_flutter 2.1.0.
  static IconData get plus => const IconData(0xe3d4, fontFamily: 'Phosphor');
  static IconData get minus => const IconData(0xe32a, fontFamily: 'Phosphor');
  static IconData get back => const IconData(0xe138, fontFamily: 'Phosphor');
  static IconData get next => const IconData(0xe13a, fontFamily: 'Phosphor');
  static IconData get close => const IconData(0xe4f6, fontFamily: 'Phosphor');
  static IconData get counter => const IconData(0xe136, fontFamily: 'Phosphor');
  static IconData get toTop => const IconData(0xe08e, fontFamily: 'Phosphor');
  static IconData get expandFigure =>
      const IconData(0xe0a6, fontFamily: 'Phosphor');

  /// Phosphor caret-up-down: the count's cue that it opens a list.
  static IconData get caretUpDown =>
      const IconData(0xe140, fontFamily: 'Phosphor');
  static IconData get sort => const IconData(0xe140, fontFamily: 'Phosphor');
  static IconData get contents =>
      const IconData(0xe2f0, fontFamily: 'Phosphor');
  static IconData get flag => const IconData(0xe244, fontFamily: 'Phosphor');
  static Widget get report => const OwnIcon(OwnIconKind.report);
  static Widget get questionsSheet => const OwnIcon(OwnIconKind.questionsSheet);
  static IconData get addNote => const IconData(0xe34a, fontFamily: 'Phosphor');
  static IconData get noted => const IconData(0xe348, fontFamily: 'Phosphor');
  static IconData get check => const IconData(0xe182, fontFamily: 'Phosphor');
  static IconData get pause => const IconData(0xe39e, fontFamily: 'Phosphor');
  static Widget get paused => const OwnIcon(OwnIconKind.paused);
  static IconData get timer => const IconData(0xe492, fontFamily: 'Phosphor');
  static IconData get pendingSend =>
      const IconData(0xe19a, fontFamily: 'Phosphor');
  static IconData get nextMonth =>
      const IconData(0xe13a, fontFamily: 'Phosphor');
  static Widget get streak => const OwnIcon(OwnIconKind.streak);
  static IconData get restDay => const IconData(0xe330, fontFamily: 'Phosphor');
  static IconData get addDate => const IconData(0xe10a, fontFamily: 'Phosphor');
  static IconData get pro => const IconData(0xe6a2, fontFamily: 'Phosphor');
  // SY_Error uses Phosphor's regular warning-circle glyph.
  static IconData get appError =>
      const IconData(0xe4e2, fontFamily: 'Phosphor');
  // ErrorState: Phosphor's regular warning triangle (the system `alert`).
  static IconData get alert => const IconData(0xe4e0, fontFamily: 'Phosphor');
  // Field help line: Phosphor's regular info glyph.
  static IconData get info => const IconData(0xe2ce, fontFamily: 'Phosphor');
  static Widget get progressError => const OwnIcon(OwnIconKind.progressError);
  static IconData get tendencies =>
      const IconData(0xe2dc, fontFamily: 'Phosphor');
  static IconData get answerStreak =>
      const IconData(0xe2de, fontFamily: 'Phosphor');
  static IconData get search => const IconData(0xe30c, fontFamily: 'Phosphor');
  static IconData get bookmark =>
      const IconData(0xe0ea, fontFamily: 'Phosphor');
  static Widget get reorder => const OwnIcon(OwnIconKind.reorder);
  static IconData get imageFailed =>
      const IconData(0xe2ca, fontFamily: 'Phosphor');
  static IconData get edit => const IconData(0xe3b4, fontFamily: 'Phosphor');
  static IconData get share => const IconData(0xeaf0, fontFamily: 'Phosphor');
  static IconData get keyboard =>
      const IconData(0xe2d8, fontFamily: 'Phosphor');
  static IconData get exam => const IconData(0xe47c, fontFamily: 'Phosphor');
  static IconData get practice =>
      const IconData(0xe74e, fontFamily: 'Phosphor');
  static IconData get reminders =>
      const IconData(0xe0ce, fontFamily: 'Phosphor');
  static Widget get appearance => const OwnIcon(OwnIconKind.appearance);
  static Widget get backup => const OwnIcon(OwnIconKind.backup);
  static IconData get feedback =>
      const IconData(0xe218, fontFamily: 'Phosphor');
  static Widget get about => const OwnIcon(OwnIconKind.about);
  static IconData get proSettings =>
      const IconData(0xe6a2, fontFamily: 'Phosphor');
  static IconData get profile => const IconData(0xe4c2, fontFamily: 'Phosphor');
}
