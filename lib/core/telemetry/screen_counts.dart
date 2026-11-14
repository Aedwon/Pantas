/// Whether the speed and error report carries screen counts.
///
/// Off. Usage telemetry step 2
/// (`docs/superpowers/plans/usage-telemetry/step2-spec.md`) is built behind
/// this switch and waits for Aedwon's sign-off of the notice wording and the
/// under-18 option (`step2-legal-draft.md`). Turning it on is a code change
/// made only after that sign-off, together with the notice text.
///
/// While it is off nothing is counted and the report holds exactly what it
/// held before: no `screens` key.
const bool screenCountsInClientReports = false;
