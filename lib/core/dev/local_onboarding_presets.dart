import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';

/// Answers the local test panel hands to an onboarding step, so the step opens
/// in a state that would otherwise take several taps to reach.
///
/// The panel's onboarding cards (`tools/local/panel/index.html`) store a
/// preset id. After a fresh start, `applyOnboardingPreset` in
/// `lib/app/local_onboarding_preset_apply.dart` writes the earlier answers
/// through the application actions and then sets [localPresetSeed] for the one
/// step it opens. That step reads the seed once, when it is built.
///
/// Nothing sets the seed in a normal build, and [takeLocalPresetSeed] returns
/// null there whatever the notifier holds.
class LocalPresetSeed {
  const LocalPresetSeed({
    this.birthYearText,
    this.customName,
    this.submit = false,
    this.differentDate,
    this.year,
    this.month,
    this.day,
    this.studyDays,
  });

  /// The age step's year field.
  final String? birthYearText;

  /// The custom exam name step's text.
  final String? customName;

  /// When true, the age step or the custom name step runs its own Continue
  /// path on the seeded text once it has drawn.
  final bool submit;

  /// The date step: true opens the picker as if "Different Date" was tapped.
  final bool? differentDate;

  /// The date step's picked year, month and day.
  final int? year;
  final int? month;
  final int? day;

  /// The study days step's picked weekdays, Monday 1 to Sunday 7.
  final Set<int>? studyDays;

  /// The date the picker opens on, or null to keep its own default.
  MonthFirstDate? get pickedDate =>
      year == null ? null : MonthFirstDate(year: year!, month: month, day: day);
}

/// Set by the onboarding presets and read once by a step. Local runs only.
final ValueNotifier<LocalPresetSeed?> localPresetSeed =
    ValueNotifier<LocalPresetSeed?>(null);

bool _allowedInTests = false;

/// Lets a test read the seed. The real guard is a compile-time constant that
/// is false in tests, so a test cannot reach the seed without this.
@visibleForTesting
void allowLocalPresetSeedForTest({required bool allowed}) =>
    _allowedInTests = allowed;

/// Returns the seed if a step wants it, and clears it so no later step sees
/// it. Returns null in every build that is not a local run in a browser.
///
/// [wanted] says whether the seed holds an answer for the calling step.
LocalPresetSeed? takeLocalPresetSeed(bool Function(LocalPresetSeed) wanted) {
  // Both are compile-time constants: normal builds drop everything below.
  if (!(localEmulators && kIsWeb) && !_allowedInTests) return null;
  final seed = localPresetSeed.value;
  if (seed == null || !wanted(seed)) return null;
  localPresetSeed.value = null;
  return seed;
}

/// The age step's seeded year. [submit] runs the step's own Continue after the
/// first frame when the seed asks for it.
int? takeSeededBirthYear(VoidCallback submit) {
  final seed = takeLocalPresetSeed((s) => s.birthYearText != null);
  if (seed == null) return null;
  if (seed.submit) {
    WidgetsBinding.instance.addPostFrameCallback((_) => submit());
  }
  return int.tryParse(seed.birthYearText!);
}

/// The custom exam name step's seeded text, with [submit] as above.
String? takeSeededCustomName(VoidCallback submit) {
  final seed = takeLocalPresetSeed((s) => s.customName != null);
  if (seed == null) return null;
  if (seed.submit) {
    WidgetsBinding.instance.addPostFrameCallback((_) => submit());
  }
  return seed.customName;
}

/// The study days step's seeded weekdays.
Set<int>? takeSeededStudyDays() =>
    takeLocalPresetSeed((s) => s.studyDays != null)?.studyDays;

/// The date step's seed: picker mode, year, month and day.
LocalPresetSeed? takeSeededExamDate() => takeLocalPresetSeed(
      (s) => s.differentDate != null || s.year != null,
    );
