# Fable audit, Language Application, round 2

Auditor: Claude Fable 5.2, read-only. Target: `content/lesson-walkthrough-cse-r1` at 2985cdcd9. Topic: the 24 active Language Application lessons with `:::` blocks (retired error-identification.md, paragraph-organization.md and sentence-completion.md skipped). Policy commit read: origin/main 2681b2b95.

Read in full: the brief, AGENTS.md, WORKFLOW.md and docs/workflow/process-improvement.md (origin/main), the walk-through spec (Part A and B), the lesson style guide, worker-rules, pattern-checklist, the approved sample, the round 1 report, the diff e2e1e1c6b..2985cdcd9 for this topic, all 24 lessons, all three question files, and the Language Application block of `content/walkthrough-trap-evidence.json`. I also read the app's converter on the renderer branch (`origin/ux/walkthrough-renderer-r1:lib/core/content/remote/lesson_markdown.dart`) to judge two layout questions.

Not run: dart, flutter, the parser, word counts (the lead's results are taken as given). Nothing was rendered.

Paths are under `content/lessons/language-proficiency/language-application/`.

## Round 1 findings still open

- Round 1 Major 3, the ":43" part | openings-and-reference-links.md:29, :42 | The "Which sentence opens?" chain and check still end at a letter. The other two places of that Major (:71, :134) are fixed. Counted below as a Minor.
- Carried in round 1 as accepted and not counted, unchanged: pronoun-reference-checks.md Example 2 keeps quiz 0015's choice pattern; word-meaning-checks.md Example 1 keeps quiz 0030's stem frame; step 1 of each three-sentence try places one sentence. Not counted again.

Every other round 1 finding is closed at 2985cdcd9. The three lead rulings (checks on *decide* and *avoid*; tested word partners named in the "such as" list; Speed Tricks optional) are respected. I found no student harm they miss.

## Citations

59 pairs in 24 lessons, 2 or 3 per lesson. Every pair has an entry in `content/walkthrough-trap-evidence.json`. For every entry: the wrong choice text exists exactly in the cited question, the choice is not the correct one, the question's `lesson:` is the lesson, and the pair's Wrong line shows that mistake. The six Filipino and English pairs that got new sentences in 2985cdcd9 still show their cited mistake. No citation finding.

## Findings

### Blockers (0)

### Majors (0)

### Minors (11)

modal-meaning-checks.md
- Minor | :47 | `(*She **must register***, not *must registers*)` nests bold inside italics. The app's converter (`_inlineSpans`) pairs single stars first, so the line shows stray asterisks ("must register*", "must registers*") and italics on the wrong words. Read from the converter source, not rendered. The line predates round 1 | Write it without nesting: `(*She must register*, not *must registers*)`.

openings-and-reference-links.md
- Minor | :29, :42 | The "Which sentence opens?" chain and check end at a letter ("(B) opens, and (A) follows"; "The answer is (B)"). The two sentences are short and on screen, so this is a Minor | End each with the two sentences in order, as :71 does. Both additions can sit after the reason; :42 is behind the tap.
- Minor | :65 | After the trim, the pair note "*The study* is a link even without *this* or *it*" no longer names the slip, and "link" is not the lesson's term ("points back") | "*The study* points back to *a study*, so it comes second."
- Minor | :18-19 | The fix pass removed the blank line, so the definition of paragraph organization and the opening-sentence rule now run together as one four-sentence paragraph | Put the blank line back.

past-time-checks.md
- Minor | :20 | "passive *was* or *were* plus the *-ed* form" now reads as the whole rule, but irregular verbs do not end in *-ed* (*were sent*, *was written*; the lesson's own Example 2 uses *taken*). This wording came from my round 1 suggested fix | "plus a verb form that usually ends in *-ed*".

pronoun-reference-checks.md
- Minor | :34 | "leave out *you and*" names words from a phrase the reader has not seen yet: "between you and I" appears only in the hidden Why above and in the pair below | Name the phrase first: 'To test "between you and I", leave out *you and*: "between I" fails, "between me" works.'

time-and-step-order.md
- Minor | :110, :112 | The trim cut the clue from each step: "(B) is the earliest time" and "(A) is the latest time" no longer say which words show it. The core chain at :28-30 names the clue | '(B) has "At opening time," the earliest time.' and '(A) has "By noon," the latest time.'

pagkakasunod-at-sanhi.md
- Minor | :109-111 | The trimmed steps lost their links. In step 1, "ito ang tinutukoy ng *ito* sa (C)" now says sentence (B) is what *ito* points to; it is the *liham*. Steps 2 and 3 no longer say what ties (C) to (B) or (D) to (C) | "1. (B): may *una*, at ang *liham* nito ang tinutukoy ng *ito* sa (C)." "3. (D): ang *pagwawasto* ay ang pagtatama sa (C), kaya kasunod ito."
- Minor | :133 | The Check lost its lead-in. It is now a bare sentence and "Pareho ang diwa," with nothing saying what the sentence is | "Gamit ang *kaya*: ..." (two words).

paksa-at-balangkas.md
- Minor | :58, :60 | *taga-nayon* has a hyphen. KWF usage hyphenates *taga-* only before a proper noun (*taga-Maynila*); with a common noun it is one word. Confidence fairly high, not checked against a printed copy in this run. The line predates round 1 | *taganayon*.

Cross-cutting
- Minor | wastong-gamit-at-panahon.md:71; pagkumpleto-ng-pangungusap.md:158 | The answer opens with a reason and gives the result later. The spec says a check or try answer starts with the result, and the reader bolds the first sentence, so the bold line is not the answer | Open with the result: "*Natakot si Ben sa kulog.* Damdamin ang naranasan ni Ben. ..." and "Ang sagot ay **(A)**: ... Ang *malakas na ngiti* ay hindi nakapagpapawala ng kuryente."

## Notes, not findings

- In openings-and-reference-links.md (:59-60, :93-94, :112-113), time-and-step-order.md (:30-31, :58-59) and transition-links.md (:45-46), the ordered text sits on the line right after the last numbered step with no blank line. The app's converter starts a new paragraph there, so the reader sees it correctly. A standard Markdown preview would join it to the step. A blank line would make both agree; the Examples in time-and-step-order.md already have one.
- pagkakasunod-at-sanhi.md:40-41 has the same shape (a paragraph, then "1." on the next line). The converter handles it.

## Lessons with no finding (15)

cause-and-effect-order, clause-punctuation-checks, completion-articles-and-lists, completion-meaning-clues, completion-natural-phrases, completion-past-time, completion-word-forms, details-and-supported-inferences, main-ideas-and-details, modifiers-and-matching-forms, phrases-and-sentence-types, subject-and-verb-checks, transition-links, word-meaning-checks, kayarian-at-sugnay.

## Checks that passed in all 24

- No false rule or answer found. The three round 1 Majors are fixed: *that of* / *those of* now go by the noun replaced, the *kapag* sentence is standard, and the openings check and try show the ordered text.
- Every check and try uses a sentence not worked earlier in its lesson, tests a rule the lesson taught, and has one defensible answer (open rewrites state what any correct answer must do and give a model). No heading, visible step or printed list gives a try's answer away, apart from the named word partners the lead ruled on.
- Every try's `**Check:**` is inside its `:::answer`. Every ordering chain, check and try ends at the ordered text, except the two lines listed above.
- 2 or 3 pairs and 2 or 3 checklist items per lesson; every checklist slug matches a pair id or a `###` heading.
- No em or en dash, no trailing double spaces, American spelling. Option lists have blank lines between rows.
- Filipino lessons: simple Filipino, no Taglish, a first-use gloss for each hard term in teaching prose only. *din/rin* and *ng/nang* follow KWF in every line I read.

## Totals

Blockers 0. Majors 0. Minors 11.

Most common classes:
1. A trim in the fix pass cut a connecting clue or lead-in (5 Minors: openings :65, pronoun :34, time-and-step :110, pagkakasunod :109 and :133).
2. An answer or chain that ends or opens in the wrong place: ends at a letter, or opens with the reason (2 Minors, 3 lessons).
3. Wording and markup slips: a rule with an unstated exception, a KWF spelling, nested emphasis, a lost blank line (4 Minors).

VERDICT: PASS

STAGE-DONE
