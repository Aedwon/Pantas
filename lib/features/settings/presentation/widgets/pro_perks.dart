import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';

/// The five Pantas Pro benefits, in order, with the icon each one carries. The
/// words are Aedwon's own (Nov 26) and match the website's Pro list. The phone
/// list and the wide hero both read this, so they cannot drift.
final List<(IconData, String)> proPerks = [
  (PantasIcons.calendarBlank, 'Full adaptive plan, tailored for you'),
  (PantasIcons.unlimitedMocks, 'Unlimited mock exams'),
  (PantasIcons.answerNotes, 'Detailed explanations'),
  (PantasIcons.topicResults, 'Concept-specific results'),
  (PantasIcons.tendencies, 'Your tendencies as a test-taker'),
];
