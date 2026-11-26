# LA 16 re-verification findings (5 Filipino, 11 English)

Policy commit read: origin/main 5810f9bd6 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Read-only run; no lesson edited. Fix commit 02f318869, diffed against 1f5cea752. Paths are under content/lessons/language-proficiency/language-application/.

Pairs: no Right or Wrong line changed in any of the 16 lessons (diff has 0 changed Right/Wrong lines), and no question file changed. All citations from la-16-verifier-findings.md still stand (choice exists exactly, not the correct choice, lesson matches).

Checked in all 16: no em or en dashes, no `\frac`, no ALL-CAPS emphasis, no stock AI phrasing. Every Check and try ends at the finished sentence or text except the Minors named below.

## Earlier findings: closed or open

kayarian-at-sugnay
- Example 2 Check proves nothing: CLOSED (now tests the removed clause alone).
- Checklist line hard to read: CLOSED.
- Pair note 3 sentences: CLOSED (2).
- Example 3 heading: CLOSED ("Pagsusuri ng Maikling Pangungusap").

pagkakasunod-at-sanhi
- Example 3 try accepts more than one order (P3): CLOSED. (C) now names the notice, so only B, A, C works.
- Options on consecutive lines: CLOSED if the renderer keeps two-space hard breaks (see Minor below).
- Order answers end at a number string (P2): CLOSED (check and try show the ordered text).

pagkumpleto-ng-pangungusap
- Three Quick Check answers end short (P2): CLOSED.
- Example 2 never shows the *kaya* sentence: CLOSED (step 3 has it).
- "nakababasa" wording: CLOSED ("hindi dahilan ng pagkabasa ng papel").
- Example 3 heading: CLOSED ("Pagpuno sa Pangungusap").

paksa-at-balangkas
- Open tasks lack a property line (P3): CLOSED for Checks 2 and 3 ("Anumang ... ay tama. Halimbawa").
- Missing glosses: CLOSED (pangunahing ideya, salitang susi).
- "Nakakatulong": CLOSED (now "Tumutulong").

wastong-gamit-at-panahon
- Check 1 answered from the printed list (P1): CLOSED (*siguro* is not in the list; the list says "gaya ng").
- Check answers end at a word (P2): CLOSED.
- *pang-uri* gloss: CLOSED.
- Example 4 heading and answer: CLOSED.
- No blank line before "### #2": CLOSED.

cause-and-effect-order
- Headings name the answer (P1): CLOSED ("Words That Point Back", "Phrases That Point Back").
- Check answers end at "B → A" (P2): CLOSED.
- Try by elimination: left as accepted.

completion-articles-and-lists
- Check answers (P2): CLOSED. "cannot take *the*" (P4): CLOSED. Example 1 vague Check: CLOSED (names one swap).

completion-meaning-clues
- Check answers (P2): CLOSED. "denies the blank": CLOSED.

completion-natural-phrases
- Check 1 answer: CLOSED.

completion-past-time
- Headings (P1): CLOSED (neutral). Check 1 "On Monday" (P3, P4): CLOSED ("Last Monday"). Check 2 second answer: CLOSED ("had to stop halfway"). Check answers (P2): CLOSED. Checklist slug matches the new heading.

completion-word-forms
- Check answers (P2): CLOSED.
- Example 2 distractor set copy of quiz 0021: CLOSED. Example 3 option order: CLOSED (shuffled, one answer, D).
- decide and avoid tension (rule 5a): STILL OPEN. See Major below.

details-and-supported-inferences
- :::why too absolute: CLOSED ("usually", "well"). "swim practice": CLOSED.

main-ideas-and-details
- No earlier findings.

openings-and-reference-links
- Agreement "points": CLOSED. Checklist item 1 absolute (P4, P5): CLOSED ("usually"). Example 2 second order: CLOSED ((C) now says "that shelf", which only (A) names). Chains end at letter strings: OPEN, optional, not counted.

time-and-step-order
- "happens because of": CLOSED. Check answers (P2): CLOSED (full text added). Example chains end at letter strings: OPEN, optional, not counted.

transition-links
- Check 3 and heading gave the answer (P1): CLOSED (new heading, new ordering check).
- Try accepts B, C, A (P3): CLOSED ((C) now says "these workers").
- Check 1 and 2 answers (P2): CLOSED.
- "answers an idea": CLOSED at line 36 but restated at line 139 (see Minor).

## New findings

Major | completion-word-forms.md:69,71,87-90,138,153-158 | Rule 5a and rule 5: the core names *hope*, *decide* and *avoid* with their patterns ("Verbs such as hope and decide work the same way"; "as with avoid"). Check 3 tests *decided* and the try tests *avoid*, so the answer is stated above the test. The core also says "Learn these patterns with the first verb", so the lesson teaches no class a reader could extend | Cut "Verbs such as *hope* and *decide* work the same way." and "as with *avoid*" from the core (keep *want* and *enjoy* as the worked verbs). Then *decide*, *hope* and *avoid* are fresh instances the reader must know. Net words go down.

Minor | completion-word-forms.md:22-23 | The fix deleted the blank line before "Let's fill the blank". The lead-in now joins the definitions paragraph | Restore the blank line.

Minor | pagkakasunod-at-sanhi.md:48-50,98-101,118-119,134-136 | Options use two trailing spaces for line breaks. They render as separate lines only if the renderer keeps hard breaks, and editors strip trailing spaces. Same in 8 English lessons | Confirm in the importer render. If unsure, use blank lines as the other lessons do.

Minor | pagkakasunod-at-sanhi.md:86-90 | Check 2 accepts "Dahil nabasag ang baso, nagwalis si Ana." as well as the shown answer (P3) | Add "Anumang pangungusap na may dahil sa sanhi ay tama." or fix the slot.

Minor | pagkakasunod-at-sanhi.md:136,145 | *Nabasa* in a flood story can read as "got wet" | "binasa ng mga drayber ang abiso".

Minor | pagkumpleto-ng-pangungusap.md:56 | "Karaniwang humihinto ang pagod" is odd (tiredness does not stop) | "Karaniwang humihinto ang taong pagod".

Minor | pagkumpleto-ng-pangungusap.md:117-118 | The fix deleted the blank line before "### #2" | Restore it.

Minor | paksa-at-balangkas.md:118-121 | The Example 2 try is an open outline with no property line (P3), unlike Check 3 | Add "Anumang detalye na galing sa talata ay tama." or leave as is, since the content is fixed to two details.

Minor | wastong-gamit-at-panahon.md:42 | "Tiyak ang isa pang pahayag" overclaims: "Darating ang inspektor sa Huwebes" is a plain future statement, not certain | "Walang salita ng posibilidad ang isa pang pahayag."

Minor | cause-and-effect-order.md:85-86 | The fix deleted the blank line before "### #2" | Restore it.

Minor | completion-articles-and-lists.md:134 | Example 2 Check repeats steps 1 and 2 (P2) | Test with a swap: "He finished a worksheet" no longer points to the worksheet Ben was given.

Minor | completion-past-time.md:78-82 | Check 3 offers only one past option (*had printed*, *prints*, *will print*). It is answered by elimination and does not test past perfect (P1) | Offer *printed* or *was printing* beside *had printed*, with a clue that makes only one fit.

Minor | completion-past-time.md:151-152 | The fix deleted the blank line before "## Traps to Watch For" | Restore it.

Minor | openings-and-reference-links.md:131-132 | Same deleted blank line before "## Traps to Watch For" | Restore it.

Minor | transition-links.md:114-115 | The fix deleted the blank line before **Check:** in Example 2. It can read as part of list item 3 | Restore it.

Minor | transition-links.md:139 | The Speed Tricks line still says "the idea it answers", while line 36 now says "goes against, or gives a case of" (P5) | "after the idea it goes against or gives a case of".

## Per lesson counts

- kayarian-at-sugnay: OK, 0.
- pagkakasunod-at-sanhi: 0 Major, 3 Minor (includes the cross-cutting hard-break note).
- pagkumpleto-ng-pangungusap: 0 Major, 2 Minor.
- paksa-at-balangkas: 0 Major, 1 Minor.
- wastong-gamit-at-panahon: 0 Major, 1 Minor.
- cause-and-effect-order: 0 Major, 1 Minor.
- completion-articles-and-lists: 0 Major, 1 Minor.
- completion-meaning-clues: OK, 0.
- completion-natural-phrases: OK, 0.
- completion-past-time: 0 Major, 2 Minor.
- completion-word-forms: 1 Major, 1 Minor.
- details-and-supported-inferences: OK, 0.
- main-ideas-and-details: OK, 0.
- openings-and-reference-links: 0 Major, 1 Minor.
- time-and-step-order: OK, 0 (optional letter-string chains left).
- transition-links: 0 Major, 2 Minor.

## Ruling for the lead: completion-word-forms on decide and avoid

Yes, it is a rule 5a reuse, and for the try it is also a rule 5 give-away: the core says "as with *avoid*" and the try asks which form follows *avoid*. The earlier "keep it" view does not hold now, because the core names the verbs. I would cut the naming from the core (hope, decide, avoid) and keep *want* and *enjoy* as the only taught verbs. The checks then test verbs the reader must know, which is what the exam does (quiz 0022). Do not add a second named verb: it still tests a named word. If you rule the reuse acceptable for a word-list rule, this Major drops and the verdict becomes PASS.

## Filipino wording and glosses

New Filipino wording is correct and natural: "Tumutulong ang silid-aklatan", "hindi dahilan ng pagkabasa ng papel", "Siguro ay darating", "Magiting ang bumbero", "Anumang balangkas na galing lamang sa talata ay tama". Only the odd lines in the Minors above need a change. Glosses follow the first-use rule: pangunahing ideya and salitang susi (paksa-at-balangkas) and pang-uri (wastong-gamit) are glossed once at first teaching use, none in headings, stems, examples or Right/Wrong lines.

## Totals

Blockers 0. Majors 1. Minors 15.

VERDICT: FAIL (0 Blockers, 1 Majors, 15 Minors)
