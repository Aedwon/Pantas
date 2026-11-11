import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/data/custom_subject_tiers.dart';

/// The shipped tier table, read from disk so a widget test never waits on the
/// asset bundle.
///
/// A fixture's made-up topic ids are listed in [studentTopics]. A kept topic
/// the table does not know prices at the top tier, so a fixture that wants
/// Student must place its own topics there.
Override shippedCustomSubjectTiers({
  Iterable<String> studentTopics = const [],
}) =>
    customSubjectTiersProvider.overrideWith((ref) async {
      final json = jsonDecode(
        File('content/exams/custom_subject_tiers.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final loose = Map<String, dynamic>.from(
        json['topicTiers'] as Map<String, dynamic>? ?? const {},
      );
      for (final id in studentTopics) {
        loose[id] = 'Student';
      }
      json['topicTiers'] = loose;
      return CustomSubjectTiers.fromJson(json);
    });
