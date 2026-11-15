/// Whether the speed and error report carries screen counts.
///
/// Off unless the build says otherwise. Usage telemetry step 2
/// (`docs/superpowers/plans/usage-telemetry/step2-spec.md`) waits for Aedwon's
/// word to ship. A production build leaves it off. A staging build for the
/// proof passes `--dart-define=SCREEN_COUNTS=true`.
///
/// While it is off nothing is counted and the report holds exactly what it
/// held before: no `screens` key. The Home notice and the Settings wording
/// about counts are off with it. When it is on, counting also waits for the
/// learner's switch and for the notice, see `screen_counts_notice.dart`.
const bool screenCountsInClientReports = bool.fromEnvironment('SCREEN_COUNTS');
