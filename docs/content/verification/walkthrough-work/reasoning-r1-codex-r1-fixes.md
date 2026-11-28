# R1 pilot: Codex read 1 and the lead's fixes (E-216)

Read 1 (GPT 6.2 Sol high, account b, Nov 28 07:51 to about 07:58 UTC, target `361808152`): FAIL, 2 Blockers, 22 Majors,
5 Minors. Findings copied below the rulings.

## Fixed by the lead (one pass, by pattern)

- Blocker, sequence-moves: the ratio is now defined as the number each term is multiplied by; dividing by 2 is a ratio of 1/2.
- Blocker, sequence-earlier-terms: a recurrence is now any rule that uses earlier terms; the lesson scopes itself to rules
  that look back two or three terms.
- Openings that said only "Check" or "Look at" now name the unknown ("Find the missing term in", "Find the next term in",
  "Find the next letter in"), in all four lessons.
- Tries fade only the last move: sequence-moves shows the next gap (6) and asks to add it; the paired-letter example shows
  the next jump (-4) and asks for the second letter.
- sequence-moves Example 3 checks 27 against the shown 9; the ratio checklist line says to pick the simplest rule that fits
  every shown term.
- sequence-positions: the Quick Check answer separates positions from values; the Why block gives the reason.
- sequence-letter-patterns: the A=0 pair note and the H/J pair note (two moves give H, four give J) are corrected, and the
  checklist cue no longer says "across Z".
- sequence-earlier-terms: the checklist says to verify every shown term the rule can build; the Quick Check reads "double
  the term just before it, then add the term before that".

## Rejected, with reasons (lead rulings)

1. Several differences or ratios on one display line (Majors in all four lessons): listing the gaps between neighbors is
   one move, "find the gaps", and each gap is its own equation on the line. Splitting them would add lines without adding a
   connection (his Nov 26 words: "connect things better, not explain with more words").
2. Closing sentences that restate the answer after the last labeled line (Majors in all four lessons): the line names the
   answer in the form the question asks; the Math lessons that passed two reads use the same close.
3. Double-dollar display math (Minors): the renderer's display format; carried from the Math batches' ruling.
4. sequence-earlier-terms Example 3 states its rule in the stem: the linked exam question
   `q-logical-verbal-reasoning-number-and-letter-sequences-0018` states its rule the same way, so this is exam wording.

Checks after the fixes: main's `lesson_checks.dart` exit 0 on the whole root; parser 4 of 4; words by `wc.dart`: earlier
terms 619, letter patterns 698, moves 638, positions 712 (all under 900).
