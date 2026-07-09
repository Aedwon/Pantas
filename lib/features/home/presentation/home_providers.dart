// lib/features/home/presentation/home_providers.dart
import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/features/settings/application/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// Everything the masthead prints, gathered once so the widget reads one
/// provider rather than three repositories.
@immutable
class HomeMastheadData {
  const HomeMastheadData({
    required this.name,
    required this.examShortName,
    required this.examDate,
  });

  /// Null and empty are the same state: no name.
  final String? name;
  final String examShortName;
  final ExamDate? examDate;

  @override
  bool operator ==(Object other) =>
      other is HomeMastheadData &&
      other.name == name &&
      other.examShortName == examShortName &&
      other.examDate == examDate;

  @override
  int get hashCode => Object.hash(name, examShortName, examDate);
}

final homeMastheadProvider = FutureProvider<HomeMastheadData>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final settings = await ref.watch(userSettingsProvider.future);
  final name = settings.name?.trim();
  return HomeMastheadData(
    name: name == null || name.isEmpty ? null : name,
    examShortName: focus.exam?.shortName ?? '',
    examDate: settings.examDate,
  );
});
