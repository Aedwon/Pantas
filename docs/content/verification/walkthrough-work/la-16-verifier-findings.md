# LA 16 verifier findings (5 Filipino, 11 English)

Policy commit read: origin/main 5810f9bd6 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Read-only run; no lesson edited. Paths below are under content/lessons/language-proficiency/language-application/.

Checked for all 16: no em or en dashes, no `\frac`, no ALL-CAPS emphasis, no stock AI phrasing, every `:::pair` has a citation entry, every cited wrong choice exists exactly in the cited question, that question's `lesson:` is the lesson, and the choice is not the correct one. All 16 lessons pass the citation check (details per lesson).

Cross-cutting Minor: option lines "(A) ... (B) ..." sit on consecutive lines with no blank line in pagkakasunod-at-sanhi, details-and-supported-inferences, main-ideas-and-details, openings-and-reference-links. Markdown joins them into one paragraph unless the app keeps single line breaks. The other lessons use blank lines. Confirm in the importer render. Counted once, under pagkakasunod-at-sanhi.

## Filipino 5 (never verified before)

### kayarian-at-sugnay.md
- Major | kayarian-at-sugnay.md:125 | Example #2 Check says the two remaining clauses stay whole, "kaya bitin ang inalis". That does not follow: removing an independent clause leaves the same result. The check proves nothing (P2) | Test the removed clause alone: "Nang matapos ang pulong." Bitin ito, kailangan pa ng karugtong.
- Minor | kayarian-at-sugnay.md:147 | Checklist line is hard to read: "may bitin na sugnay ring may habang, kapag, o dahil" | "Dalawang buong diwa at isang sugnay na may habang, kapag, o dahil: bilangin ang lahat. Langkapan ito, hindi tambalan."
- Minor | kayarian-at-sugnay.md:79 | Pair note has 3 sentences (limit 2) | Cut "Kung isang buong diwa lamang ang bibilangin, hugnayan ang lalabas."
- Minor | kayarian-at-sugnay.md:127 | Example #3 heading "Pangungusap na May Pang-ugnay" names the cue the try needs (rule 5b) | Neutral heading.
- Citations: all pass. parirala-hindi-sugnay: 0025 "sa loob ng bagong tanggapan" OK. bilangin-ang-lahat-ng-sugnay: 0026 "Tambalan dahil walang sugnay na di-makapag-iisa." OK (Wrong line shows it). Second entry "Hugnayan dahil iisa ang sugnay na makapag-iisa." exists and is wrong, but only the pair note shows it (acceptable). Both pairs have entries.

### pagkakasunod-at-sanhi.md
- Major | pagkakasunod-at-sanhi.md:136,145 | Example #3 try accepts more than one order (P3). "Dahil dito" in (A) could follow (C) as well as (B). The answer's reason ("kinabukasan, kaya sumunod sa pagpapaskil") does not follow: "kinabukasan" says only a later day, not later than the notice | Make (C) name the notice: "Kinabukasan, nabasa ng mga drayber ang abiso at nakadaan na ulit ang mga traysikel." Then B, A, C is the only order.
- Minor | pagkakasunod-at-sanhi.md:48-50,98-101,118-119,134-136 | Options on consecutive lines (see cross-cutting note) | Add blank lines.
- Minor | pagkakasunod-at-sanhi.md:67,145 | Order answers end at a number or letter string, not the finished text (P2) | Add the paragraph in order in one line.
- Citations: all pass. ito-ay-may-naunang-binanggit: 0017 "1, 2, 4, 3" OK (Wrong line puts "reklamong ito" before the complaint); "2, 3, 1, 4" exists and is wrong, not shown in the Wrong line. bunga-hindi-sanhi: 0025 "Humingi siya ng bagong kopya ng listahan." OK (effect named as cause). Checklist slug #sanhi-at-bunga matches the ### heading. Both pairs have entries.

### pagkumpleto-ng-pangungusap.md
- Major | pagkumpleto-ng-pangungusap.md:41,69,92 | All three Quick Check answers end at a word or phrase plus a reason, never the finished sentence (P2) | End each answer with the full sentence, e.g. "Bukas, ibabalik ni Ben ang kuwaderno."
- Major | pagkumpleto-ng-pangungusap.md:137-139 | Example #2 never shows the finished sentence with *kaya*. The chain ends at "Piliin ang (B)", and the Check shows only the *dahil* rewrite (P2) | Add "Malakas ang ulan, kaya ipinagpaliban ang programa." before "Piliin".
- Minor | pagkumpleto-ng-pangungusap.md:86 | "hindi nakababasa ng papel ang tulong": without a stress mark *nakababasa* reads as "able to read", not "wets" | "hindi dahilan ng pagkabasa ng papel ang tulong".
- Minor | pagkumpleto-ng-pangungusap.md:141 | Example #3 heading "Pariralang Bagay sa Pangungusap" points at what the try asks (5b) | Neutral heading.
- Citations: all pass. anyo-ayon-sa-panahon: 0027 "ipapadala" OK. pang-ugnay-ng-pagsalungat: 0028 "kaya" OK. likas-at-akma-sa-kahulugan: 0029 "matinding tulong" OK. All 3 pairs have entries.

### paksa-at-balangkas.md
- Minor | paksa-at-balangkas.md:57-61,80-84 | Two open tasks (own-words rewrite, outline). Check 2 gives "Halimbawa" plus a property; Check 3 gives one outline and no property (P3) | Add "Anumang balangkas na galing lamang sa talata ay tama. Halimbawa:".
- Minor | paksa-at-balangkas.md:19 | *pangunahing ideya* and *salitang susi* have no first-use gloss | "pangunahing ideya (main idea)", "salitang susi (key words)".
- Minor | paksa-at-balangkas.md:98 | "Nakakatulong" (also in 0026 stem); dictionary standard is *nakatutulong*. I am not certain the 2013 orthography rules on it | Use *nakatutulong* or confirm with KWF.
- Citations: all pass. sobra-ang-ideya: 0026 "Karatula lamang ang kailangan sa bawat tanggapan." OK. dagdag-sa-paliwanag: 0026 "Hindi na kailangan ang mga kawani sa tamang pila." OK (adds a claim). detalye-mula-sa-talata: 0027 "Silbi ng talaan: halaga ng gamit at gastos sa pagkukumpuni." OK. All 3 pairs have entries.

### wastong-gamit-at-panahon.md
- Major | wastong-gamit-at-panahon.md:40-42 | Check 1 (P1): the lesson printed *maaari* at line 25. Only the option with *maaaring* has a printed word, and the other option is plainly past. The reader answers from the list | Use a new sentence where the possibility word is not in the printed list (for example *siguro*), or have the reader find the word in a fresh sentence.
- Major | wastong-gamit-at-panahon.md:42,57,71,99 | Check answers end at a word plus reason, not the finished sentence (P2) | End each with the full sentence.
- Minor | wastong-gamit-at-panahon.md:21 | *pang-uri* has no first-use gloss (pang-abay, pandiwa, pangngalan, panghalip do) | "pang-uri (adjective)".
- Minor | wastong-gamit-at-panahon.md:156,175 | Example #4 heading "Magkapareho ang Diwa" names what the try asks (5b); the try answer ends at "(A) masaya" before the sentence | Neutral heading; put the swapped sentence in the answer line.
- Minor | wastong-gamit-at-panahon.md:124-125 | No blank line before "### #2" | Add one.
- Citations: all pass. posibilidad-hindi-panahon: 0027 "bukas" OK. panahon-ng-karanasan: 0028 "matutuwa" OK. Both pairs have entries; checklist slug #salitang-akma-sa-gamit matches the heading.

## English 11 (re-verified; earlier findings from la-en11-verifier-findings.md)

All 25 earlier findings are closed (checked line by line). New findings below are mostly the five patterns. All citation entries pass (25 of 25 exact, correct lesson, wrong choice).

### cause-and-effect-order.md
Earlier: Minor ("so") closed.
- Major | cause-and-effect-order.md:16,42 | P1: headings "Cause Then Effect" and "Effect Then Cause" sit above checks whose answer is that order. Both checks (B then A) are decided by the heading | Neutral headings naming the cues: "Words That Point Back" and "Phrases That Point Back to an Effect".
- Minor | cause-and-effect-order.md:39,65 | Check answers end at "B → A" plus a reason (P2) | End with the ordered text.
- Minor | cause-and-effect-order.md:121 | Try: (A) is placed by step 1, so only B and C remain (elimination) | Accept, or leave step 1 out.
- Citations: pass. resulting-before-cause 0011 "1, 3, 2, 4"; cause-first-forced 0018 "2, 4, 3, 1" (matches: cause forced first on a result-first narrative).

### completion-articles-and-lists.md
Earlier: Example 2 and 3 copies, "Each word", padding all closed.
- Major | completion-articles-and-lists.md:42,65,89 | Check answers end at the answer word(s) plus reason, never the finished sentence (P2) | End each with the full sentence.
- Minor | completion-articles-and-lists.md:134 | "it cannot take *the*" is too strong (P4): a known unit test could take *the* | "so it takes *a* here."
- Minor | completion-articles-and-lists.md:113 | Check restates the step above and "the other choices do not sound right" is vague | Name one swap: "responsible to updating" is wrong.
- Citations: pass. article-by-spelling 0023 "the, a"; preposition-pattern 0016 "on"; mixed-list-form 0024 "to notify".

### completion-meaning-clues.md
Earlier: Check ambiguity, heading, relief/relieved, step 2 all closed.
- Major | completion-meaning-clues.md:43,68 | Check answers end at the word(s) plus reason (P2) | End with the full sentence.
- Minor | completion-meaning-clues.md:37 | "*Far from being* denies the blank" is unclear for Grade 5 | "says the cashier was not like that."
- Citations: pass. synonym-after-far-from 0014 "poised"; one-blank-only 0003 "orthodox ... hostility".

### completion-natural-phrases.md
Earlier: Example 2 copy, "general action word", "hold" all closed.
- Minor | completion-natural-phrases.md:37 | Check 1 answer ends at "pay" plus a phrase, not the finished sentence (P2) | End with "The pilot asked everyone to pay attention to the safety video."
- Citations: pass. wrong-partner 0017 "do"; idiom-by-parts 0025 "turn a blind eye to".
- Otherwise OK.

### completion-past-time.md
Earlier: all 5 closed.
- Major | completion-past-time.md:16,40,64 | P1: the three headings (finished, ongoing, earlier past action) name the answer to the check under each. Checklist slug at :158 uses the third heading | Neutral headings and update the slug.
- Major | completion-past-time.md:35-37 | Check 1 (P3, P4): "On Monday" is not a past clue; "On Monday, the driver delivers the package" is a correct habitual sentence. Two answers | "Last Monday".
- Major | completion-past-time.md:59-61 | Check 2 (P3): "While the technician repaired the printer, the lights went out" is also grammatical | Add that the repair was left unfinished, for example "... and he had to stop halfway."
- Major | completion-past-time.md:37,61,81 | Check answers end at the form plus a reason, not the finished sentence (P2) | End with the full sentence.
- Citations: pass. present-for-past 0018 "finds"; had-for-unfinished 0026 "had checked".

### completion-word-forms.md
Earlier: all 5 closed.
- Major | completion-word-forms.md:42,65,90 | Check answers end at the word plus reason (P2) | End with the full sentence.
- Minor | completion-word-forms.md:70,72,88,154-157 | The core states *decide* and *avoid* with their patterns, and Check 3 and the try test those same verbs (rule 5a tension). The rule is a word list, so some overlap may be unavoidable | Keep, or test a second verb of the same group (*plan*, *finish*) that the core also names.
- Minor | completion-word-forms.md:118-126 | Example 2 has the same frame and distractor shape as quiz 0021 (checks, check, checking, is checking) | Change the distractor set.
- Minor | completion-word-forms.md:139-147 | Example 3 keeps the option shape of quiz 0022 (earlier finding on nouns and verbs is closed) | Optional: reorder the pairs.
- Citations: pass. wrong-job 0010 "eloquent"; plural-subject-s 0021 "sorts"; verb-pattern 0022 "learning ... organizing".

### details-and-supported-inferences.md
Earlier: Example 1 resemblance, "(the day in that line)" closed.
- Minor | details-and-supported-inferences.md:54 | :::why says two clues that point the same way support an idea; one clue that fits many ideas supports none (P4, too absolute) | "Two clues that point the same way usually support an idea. One clue that fits many ideas supports none of them well."
- Minor | details-and-supported-inferences.md:50-51 | Step 2 says "a lesson or practice", step 3 concludes "swim practice" | Conclude "Mia is going to swim".
- Citations: pass. wrong-day 0023 "Before the counter closes on Monday"; adding-a-guess 0024 "She found that the dispatch log contained an error."

### main-ideas-and-details.md
Earlier: all 3 closed.
- OK
- Citations: pass. widening-the-claim 0021 "Replace all online services with telephone calls."; claim-not-in-text 0022 "The branch has ended all waiting at the counter."

### openings-and-reference-links.md
Earlier: all 5 closed.
- Minor | openings-and-reference-links.md:86,88 | "*These resources* ... points", "*These conflicts* ... points": verb does not agree | "point".
- Minor | openings-and-reference-links.md:136 | Checklist item 1 is absolute, but :31 says a pronoun can open when a title names it (P4, P5) | Add "usually".
- Minor | openings-and-reference-links.md:29,58,89,106 | Chains end at letter strings (P2) | Optional: end with the opening sentence in full.
- Minor | openings-and-reference-links.md:97-106 | Example 2: order B, C, A is also coherent ("it" in C points to B's book) | Link C to A, for example "Hearing this, ..." in (A).
- Citations: pass. reference-before-source 0001 "1, 2, 4, 3" and 0004 "1, 2, 3, 4"; the-noun-link 0012 "2, 4, 3, 1".

### time-and-step-order.md
Earlier: all 3 closed.
- Minor | time-and-step-order.md:105 | "Each event happens because of the one before it" claims cause, but the lesson teaches time order (P4) | "Each event follows the one before it."
- Minor | time-and-step-order.md:29,55,86,103,121 | Chains and the try end at letter strings (P2) | Optional.
- Citations: pass. first-before-next 0002 "1, 2, 4, 3"; prerequisite-step 0016 "1, 2, 4, 3".

### transition-links.md
Earlier: all 6 closed.
- Major | transition-links.md:65,79-83 | P1: heading "Transitions Do Not Fix Position", plus line 67 ("*however* can be the second sentence or the fourth"), gives the answer to Check 3 (yes, a *therefore* sentence can be fourth). The answer is also always "yes" | Neutral heading ("Where a Transition Goes") and a check where the reader must decide from a new sentence.
- Major | transition-links.md:122-124,133 | Try (P3) accepts B, C, A: "Therefore, patients who work during the day can still get care" also follows (B), and (A) then reads as an example | Make (C) point to (A): "Therefore, these workers can still get care."
- Minor | transition-links.md:31,62,45 | Check 1 (fill-in) and Check 2 end at the answer plus reason, not the finished text (P2) | End with the full sentence or order.
- Minor | transition-links.md:36 | "answers an idea before it" is odd for *for example* | "responds to or gives a case of an idea before it".
- Citations: pass. contrast-before-claim 0007 "1, 2, 4, 3"; example-before-idea 0003 "1, 2, 3, 4".

## Totals
Blockers 0. Majors 16 (Filipino 6: kayarian 1, pagkakasunod 1, pagkumpleto 2, paksa 0, wastong 2; English 10: cause-effect 1, articles 1, meaning 1, natural 0, past-time 4, word-forms 1, details 0, main-ideas 0, openings 0, time-step 0, transition 2). Minors 32 (Filipino 13, English 19).

VERDICT: FAIL (0 Blockers, 16 Majors, 32 Minors)
