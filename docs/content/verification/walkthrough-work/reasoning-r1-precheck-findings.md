# R1 pilot: blind pre-check and recompute findings (E-216, step 3)

Worktree commit checked: `ac73a1441` (R1 pilot: four series lessons slimmed to one Quick Check and one try).
Policy read from origin/main: AGENTS.md, SUBAGENTS.md, plan sections 2 and 4. Lessons under
`content/lessons/reasoning/logical-verbal-reasoning/`.

## Blind solves (answer covered, then compared with the key)

| Lesson | Item | My answer | Key | Match | Copyable? | Second defensible answer? |
|---|---|---|---|---|---|---|
| sequence-moves | check: 3, 12, ..., 192 | 48 (ratio 4) | 48 | yes | no | no (a constant difference gives 9 then 90, so it fails) |
| sequence-moves | try: 6, 8, 11, 15, 20 | 26 (gap 6) | 26 | yes | no | no |
| sequence-positions-and-operations | check: 8th term of 20, 2, 18, 5, 16, 8, 14 | 11 (even track +3) | 11 | yes | no | no |
| sequence-positions-and-operations | try: AZ, BY, DW, GT | KP | KP | yes | K is printed in step 2, P is not | no |
| sequence-letter-patterns | check: S, X, C, H with wraparound | M (+5) | M | yes | no | no |
| sequence-letter-patterns | try: X, Z, B, D | F (+2) | F | yes | no | no |
| sequence-earlier-terms | check: 1, 3, 7, 17 (stated rule) | 41 | 41 | yes | no | no (stem rule is checked against the shown terms) |
| sequence-earlier-terms | try: 2, 3, 4, 9, 16 | 29 | 29 | yes | no | no |

## Recompute

Every number, letter position and term was recomputed: Core Concept lines, pairs, Why blocks, examples, answers, checklist
lines and the Speed Trick. No mismatch. Items checked include 31-24-17-10-3, 64-32-16-8-4, 2-6-18-54-162 (gaps 4, 12, 36,
wrong 90), 1-4-9-16-25, 2-3-5-8-12-17 (wrong 16), 3-12-48-192, examples 24, 324, 27, 26; 1-10-3-8-5-6-7 (wrong 4),
4-7-6-9-8-11-10 (wrong 14), 2-5-11-23-47-95 (wrong 94), examples 8, 38, 121, KP, check 11; A-C-E-G-I, U not V (A=1, T=20,
U=21), W-Z-C-F-I, J-F-M-A-M-J-J-A, examples P, N, S, F, check M, anchors E5 J10 O15 T20 Y25; 1-1-2-4-7-13 (wrong 11),
1-1-2-3-5-8-13 (wrong 16 and 21), examples 256, 31, 29, check 41.

## Rule scan

Sentences with every, always, never, only, all, any, none, whenever, must, or a bare "X means Y" were tried against one
counterexample each. None fails as a CSE series rule. Weak wording is listed as Minor below.

## Chains and repeats

All examples end at the term asked for. Ex #3 in sequence-moves shows the ratio at the first and last pair and does not
re-verify 27 to 9, but it ends at the asked term, so it is not a short chain. No example, check or try reuses the numbers or
letters of another instance in its own lesson.

## Findings

Severity | file:line | item | what is wrong | suggested fix

- Major | sequence-positions-and-operations.md:131 | Example #4 lead-in | "Complete the paired sequence using English alphabet positions" does not say what is found (the next pair, two letters). The try then asks to "combine both letters". | Write "Find the next pair of letters in this sequence, using English alphabet positions ($A=1$ through $Z=26$)".
- Minor | sequence-letter-patterns.md:48 | Pair note | "adding an extra step during wraparound overshoots to $J$": moving 3 from $F$ to $I$ crosses no wrap. | Say "adding an extra step overshoots to $J$".
- Minor | sequence-letter-patterns.md:29 | Pair note | "shifts every letter up by 1" is ambiguous in direction (with $A=0$, position 21 names the letter one later, $V$). | Say "makes position 21 land one letter later, on $V$".
- Minor | sequence-letter-patterns.md:134 | Speed Trick | Uses position 16 to P, the same answer as Example #1. Not an example, check or try, so not a reused instance. | Use a different position, for example 12 to L.
- Minor | sequence-moves.md:124 | Example #4 | Gaps $2, 3, 4, 5$ are Pair 3's gaps $1, 2, 3, 4$ moved up by one, and the move is the same (gap grows by 1). Same-kind practice with new values, so allowed. | Optional: make the gap grow by 2 for a different shape.
- Minor | sequence-positions-and-operations.md:27 | Why block | "Almost any list looks neat if you ignore half the terms" overstates. | "A list can look neat if you ignore half the terms".
- Minor | sequence-earlier-terms.md:39 | Check stem | "twice the term before it plus the term before that" can be read as twice the sum. The shown terms settle it (2 x 3 + 1 = 7, not 8), and the key is right. | Write "twice the term before it, plus the term two places before it".

## Per-lesson counts

- sequence-moves: 0 Blockers, 0 Majors, 1 Minor
- sequence-positions-and-operations: 0 Blockers, 1 Major, 1 Minor
- sequence-letter-patterns: 0 Blockers, 0 Majors, 3 Minors
- sequence-earlier-terms: 0 Blockers, 0 Majors, 1 Minor

PRECHECK VERDICT: PASS (0 Blockers, 1 Major)
RECOMPUTE VERDICT: PASS (0 mismatches)
