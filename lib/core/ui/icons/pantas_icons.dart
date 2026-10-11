import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/own/own_icons.dart';

abstract final class PantasIcons {
  static IconData get homeTab => const IconData(0xe2c2, fontFamily: 'Phosphor');
  static IconData get studyTab =>
      const IconData(0xe0e6, fontFamily: 'Phosphor');
  static IconData get quizTab => const IconData(0xe184, fontFamily: 'Phosphor');
  static IconData get settingsTab =>
      const IconData(0xe272, fontFamily: 'Phosphor');
  static IconData get back => const IconData(0xe138, fontFamily: 'Phosphor');
  static IconData get next => const IconData(0xe13a, fontFamily: 'Phosphor');
  static IconData get close => const IconData(0xe4f6, fontFamily: 'Phosphor');
  static IconData get counter => const IconData(0xe136, fontFamily: 'Phosphor');
  static IconData get toTop => const IconData(0xe08e, fontFamily: 'Phosphor');
  static IconData get expandFigure =>
      const IconData(0xe0a6, fontFamily: 'Phosphor');
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
