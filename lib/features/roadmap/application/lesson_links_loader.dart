import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';

/// Bootstrap loads the bundled links once at startup on native builds. Until
/// then, and in tests and on web, there are none, so nothing waits on asset
/// I/O while a screen builds.
final lessonLinksProvider = Provider<LessonLinks>((_) => const {});

Future<LessonLinks> loadLessonLinks(AssetBundle bundle) async {
  final String source;
  try {
    source = await bundle.loadString('assets/seed/lesson_links.json');
    // AssetBundle reports missing assets with FlutterError.
    // ignore: avoid_catching_errors
  } on FlutterError {
    return const {};
  }
  if (source.trim().isEmpty) return const {};
  final json = jsonDecode(source) as Map<String, dynamic>;
  return {
    for (final entry in json.entries)
      entry.key: [
        for (final raw in entry.value as List<dynamic>)
          LessonLink(
            lessonId: (raw as Map<String, dynamic>)['lesson'] as String,
            strength: LinkStrength.values.byName(raw['strength'] as String),
          ),
      ],
  };
}
