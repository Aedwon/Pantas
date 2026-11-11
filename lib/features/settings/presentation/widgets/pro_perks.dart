import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';

/// The five Pantas Pro benefits, in order, with the icon each one carries. The
/// phone list and the wide hero both read this, so they cannot drift.
final List<(IconData, String)> proPerks = [
  (PantasIcons.unlimitedMocks, 'Unlimited mock exams'),
  (PantasIcons.answerNotes, 'Notes on why your answer was wrong'),
  (PantasIcons.studyHabits, 'The figures behind your study habits'),
  (PantasIcons.proBackup, "Progress that's always backed up"),
  (PantasIcons.topicResults, 'Results by topic and lesson'),
];
