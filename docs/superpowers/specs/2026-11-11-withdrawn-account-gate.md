# Withdrawn account gate

Approved scope: Aedwon's Nov 11 dispatch to `web/withdrawn-gate-r1` fixes the two
unapplied findings in the launch log's privacy merge entry. A withdrawn consent
or any durable account deletion task must immediately refuse the student's own
Firestore, Storage and callable access, even if Auth disabling or revocation fails.
Normal accounts, including accounts without consent records, retain existing access.
Admin SDK deletion and guardian token-based management/retries must keep working.

The app treats withdrawal and the server's structured account-closed refusal as
final, signs out, and displays the existing withdrawal end state and wording.
It must never replace that result with a confirmed offline cache or offer resend.
No new design, dependency, price, Firebase project change, push or deployment.

Acceptance: failing-first emulator rules and callable tests, a failing-first Dart
reaction test, followed by npm test in functions, dart format, flutter analyze lib
test and relevant Flutter folders, serialized. Lead owns hosted CI and integration.
