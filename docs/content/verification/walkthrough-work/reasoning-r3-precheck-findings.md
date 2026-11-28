# Blind pre-check and recompute, R3 clerical filing (E-216, step 3)

Worktree commit: bd5a48b3a ("R3 round B: five numeric and date filing lessons slimmed to one Quick Check and one try").
Policy read from origin/main (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Briefs: reasoning-r3-precheck-brief.md over reasoning-r1-precheck-brief.md.
Lessons: 9 under `content/lessons/reasoning/clerical-ability/`. Questions read: `alphabetic-filing-rules.yaml`, `numeric-and-chronological-filing.yaml`.
Every lesson has exactly one `:::check` and one `:::try`. No pictures. No em dashes.

Recompute result: every demo, pair, example, check, try and checklist line was re-sorted unit by unit. All keys are correct. Only the findings below were found.

Format: Severity | file:line | item | what is wrong | suggested fix

## Findings

Blocker | oldest-and-newest-date-order.md:45 | Core Concept rule on month-and-year records | "Records that show only a month and year, such as 'May 2025,' cannot be ordered against each other until their day dates are known." As written this is false: "May 2025" and "July 2025" order correctly with no day. It is true only for two records in the same month and year. | Write: "Two records that show the same month and year, such as two 'May 2025' records, cannot be ordered against each other until their day dates are known."

Major | filing-patterns-and-surname-particles.md:116 | checklist line {#drop-particle} | "Surname with particles (De, Del, De la): keep them in the surname unit." Stated as true everywhere. The lesson body says "Registries differ on how to file them, so follow the rule the task states." Under a rule that drops or separates particles, the line is wrong. | "Surname with particles, when the task keeps them in one unit: keep them in the surname unit."

Major | personal-name-filing-units.md:103 (stem), key at :114 | Example #3 and its try: Ana before Anabel depends on the shorter-unit-first rule, which the stem does not state. The stem says only "sorted by surname, given name, then middle initial." The rule sits at line 48, far above. Another order a reader could defend if the rule is missed: Anabel before the two Ana entries. | Add to the stem: "A shorter complete unit comes first." (Example #2 and the real questions already say it.)

Major | suffixes-titles-and-filing-ties.md:24 (demo stem), :36 (pair #suffix-too-early) | The demo and the pair depend on "Leo ends where Leon continues, so Leo comes first." Lesson 3 never states the shorter-unit-first rule anywhere, and the demo stem omits it. A reader of this lesson alone has an undefined unit comparison. Real question 0010 states it in its stem. | State the rule once in the demo stem: "A shorter complete name unit comes first."

Minor | character-string-filing.md:80-81 | Example #1 ends its numbered list and "### #2" follows with no blank line (block spacing). | Add a blank line before "### #2".

Minor | character-string-filing.md:101 | checklist {#whole-number-in-string}: "Multi-digit numbers in a code ... compare one digit at a time." Unscoped. Under an integer-subcode rule (lesson 5) $\text{A-10}$ comes after $\text{A-2}$. The body scopes it with "Under a character-string rule." | Start the line with "Under a character-string rule,".

Minor | integer-subcode-filing.md:106-107 | checklist {#early-prefix-carry}: drops the stated conditions (fixed prefix, count up by 1). A system that carries into the prefix would break it. | Add "with a fixed prefix" to the line.

Minor | integer-subcode-filing.md:97-100 (try), answer :101-102 | The try is one choice between two printed codes, and the stem lists them in filing order ($41\text{-}960$ then $42\text{-}015$). The answer is the later one, decided by the visible "$41 < 42$". Not copyable (two choices fit), but weak practice. | Optional: give three before-codes, or ask for the code after the new one.

Minor | suffixes-titles-and-filing-ties.md:113-114 | checklist lines 1 and 2 say "compare a suffix after earlier units tie" and "compare it after the name units tie" with no "when the stated rule places it there." | Add the condition, as the body does.

Minor | filing-patterns-and-surname-particles.md:31 | pair #wrong-convention, Right line: "file Reyes, Alma, Santos, Belen, Santos, Cora, and Reyes, Zoe last" reads as if all four go last. The meaning is the given-name-first order, with Zoe last. | "Right: under a given-name-first rule, the order is Reyes, Alma; Santos, Belen; Santos, Cora; Reyes, Zoe, so Reyes, Zoe is last."

Minor | terminal-digit-filing-order.md:69-78 | Example #1 reuses $\text{01-99-02}$ and $\text{12-44-03}$ from the Core Concept demo (lines 23-27), and its answer again puts $\text{01-99-02}$ first for the same reason. Partial reuse. | Change two of the four codes.

Minor | year-first-and-stated-date-formats.md:78-84 | Example #1 reuses $2024\text{-}02\text{-}11$ from the Core Concept demo. Partial reuse. | Change that date.

Minor | year-first-and-stated-date-formats.md (pair #swap-month-day, Wrong line) | "comes right before $2024\text{-}05\text{-}03$ because you read $03\text{-}05$ as May $3$" is muddled. Reading $03\text{-}05$ as May 3 would make the two dates equal, not adjacent. | "Wrong: read $2024\text{-}03\text{-}05$ as May $3$ and file it with $2024\text{-}05\text{-}03$."

## Step 3: CSE question conflicts

All 44 CSE Sub questions were scanned against the lesson rules. No question breaks a lesson rule once the Blocker and Major scoping above are fixed. Question stems for subcodes, character strings, terminal digits, decimals, dates and particles state the rule they need.

## Counts

| Lesson | Blocker | Major | Minor |
|---|---|---|---|
| personal-name-filing-units | 0 | 1 | 0 |
| filing-patterns-and-surname-particles | 0 | 1 | 1 |
| suffixes-titles-and-filing-ties | 0 | 1 | 1 |
| character-string-filing | 0 | 0 | 2 |
| integer-subcode-filing | 0 | 0 | 2 |
| terminal-digit-filing-order | 0 | 0 | 1 |
| whole-number-and-decimal-filing | 0 | 0 | 0 |
| oldest-and-newest-date-order | 1 | 0 | 0 |
| year-first-and-stated-date-formats | 0 | 0 | 2 |

## Blind answers (answers covered, solved from the lesson text)

Checks:
1. personal-name-filing-units: Garcia, Beth Zamora; Garcia, Nico Mendoza; Garcia, Nico Perez. Matches key.
2. filing-patterns: Delos Angeles, Pia; De los Reyes, Ana; De los Santos, Rey (keys delosangeles, delosreyes, delossantos; letter 6 a, r, s). Matches key.
3. suffixes-titles: Tan, Mark, Jr., Aklan; Tan, Mark, Jr., Iloilo; Tan, Mark, Sr., Bacolod. Matches key.
4. character-string: KB-7, KD-59, KD-6, KD-60. Matches key.
5. integer-subcode: 8.4.9, 8.04.12, 8.4.100. Matches key.
6. terminal-digit: 90-25-33, 05-60-33, 18-60-33, 02-70-34. Matches key.
7. whole-number-and-decimal: 9.75, 15.08, 15.9. Matches key.
8. oldest-and-newest: Sep 21 2024; Sep 14 2024; Sep 4 2024; Dec 2 2023. Matches key.
9. year-first: 03/14/2025, 03/09/2025, 11/02/2024. Matches key.

Tries:
1. Reyes, Alma Z.; Reyes, Ana M.; Reyes, Ana R.; Reyes, Anabel B.
2. Abad, Hugo; Dizon, Ian; Ong, Ian; Dizon, Mara.
3. De la Rosa, Joy P., Naga.
4. T-17, T-185, T-186, T-2.
5. 42-015.
6. 06-70-15, 06-85-15, 11-05-15, 02-01-16.
7. 8.3, 8.305, 8.35, 8.4.
8. File 18 2024-12-03; File 18 2024-11-25; File 21 2025-02-10; File 21 2024-11-19.
9. 2025-01-12, 2024-09-04, 2024-04-09.

All 9 checks and 9 tries match their keys. No answer is printed in a visible line above its item. No second defensible answer except the two shorter-unit-first cases flagged as Major.

## Verdict

FAIL (1 Blocker: oldest-and-newest-date-order.md:45, a one-sentence fix). 3 Majors, 9 Minors.
