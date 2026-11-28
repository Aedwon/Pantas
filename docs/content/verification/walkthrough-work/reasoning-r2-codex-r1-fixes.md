# R2: Codex read 1 and the lead's fixes (E-216)

Read 1 (GPT 6.2 Sol high, account b, Nov 28 08:23 to about 08:27 UTC, target `7ea6b5850`): FAIL, 5 Blockers, 15 Majors,
2 Minors (`codex-reasoning-r2-read1.md`). All fixed once by the lead except where ruled below.

Blockers fixed:
- invalid-conditional-forms Why: the door picture became an entry-log rule (missing from the log means not door P;
  skipping door P can still leave a name in the log).
- invalid-conditional-forms Example 3: the guard's claim is now "Everyone allowed to board has a stamped pass" ($Q \to P$),
  so Option 4 (allowed, unstamped) breaks it with no unstated fact.
- truth-tables-and-connectives: "the row that must change" became "the missing pair", replacing either repeated row.
- conditional-truth-values try: now a comparison (which days the rule and its reverse disagree; key Days 2 and 3), with
  every value shown in the steps, so no printed value answers it.
- combined-truth-values: the negation scope rule now covers stacked negations and groups.

Majors fixed: lemon pair Wrong line names both mistakes; bird and alarm picture labels match the text; pump pair states its
conclusion; the 0013 citation removed from `real-world-doubt` (0005 kept) in `content/walkthrough-trap-evidence.json`; the
parcel chain's backward steps on two lines; the reverse-chain note; "the original document" throughout its pair; the
rain pair note; the counterexample shortcut wording; truth-table Example 1 framed as assembling the rule results; its try
hides only the comparison; combined-values steps split into inner and outer moves; the 0012 pair note names the moved
parentheses; the medal example heading. Minor fixed: Example 3 of combined values uses new inputs.

Not changed (Minor): ordered truth-value pairs in Example 1's closing line are already in inline math.

Checks after fixes: main's `lesson_checks.dart` exit 0; main's export exit 0; SVG preflight only the 2 known failures in
`docs/content/rewrite/figure-style/`; parser 6 of 6; words 719 to 830, all under 900.
