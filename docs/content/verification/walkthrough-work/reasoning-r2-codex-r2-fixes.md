# R2: Codex read 2 (the last) and the lead's Major fixes (E-216)

Read 2 (GPT 6.2 Sol high, account b, Nov 28 08:31 to about 08:37 UTC, target `f2d147248`): FAIL, 2 Blockers, 12 Majors
(`codex-reasoning-r2-read2.md`). Four of read 1's five Blockers closed.

## Result per lesson (plan section 4)

- Pass (0 Blockers): deductive-group-arguments, valid-conditional-forms, invalid-conditional-forms,
  truth-tables-and-connectives, conditional-truth-values. Their Majors are fixed once below.
- Held: combined-truth-values (2 Blockers: the Why block still states the narrow negation-scope rule; the try's last move
  is the same F or T = T printed above). Restored on this branch to the live version from the root
  (`content/cse-math-split-r1` 657f7822c), so the hand-off does not change it. Its walk-through draft is at `f2d147248`.
  It waits for the manager and never moves into another batch (manager ruling, Nov 28).

## Majors fixed once (lead)

- deductive: the "Not all" note now says the premises leave "all" open; the dog argument shows its counter-picture.
- valid: the pump pair's Wrong line names the outside exception it imagines (a working pump and a leak); the shortcut says
  forward, or backward by denying the result.
- invalid: the entry-log rule names Door A and maps $P$ and $Q$.
- truth tables: the row repair is three numbered moves; Example 1 rows name their inputs; Example 3's stem asks for the
  comparison its try completes; the and-checklist cue says "exactly one true input".

## Rejected (lead ruling)

- "Substitution and evaluation on one line" (conditional-truth-values lines 52 to 89; truth tables line 105): a chain that
  starts at the expression and ends at its value on one line is the form his Nov 26 target uses ("3x = 3(-2) = -6").

Checks after fixes: main's `lesson_checks.dart` exit 0; main's export exit 0; parser 5 of 5; words 719 to 847; front
matter equal to the root for all six.
