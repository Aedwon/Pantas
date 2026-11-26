# Grammar G2 verifier findings (13 English lessons, sweep b9c489fb2)

Policy: fetched origin/main is now `17f4c74ee` (lead read `a7dc213c0`). Gap in my reading: I read WORKFLOW only to its line 150 and only the opening of AGENTS and SUBAGENTS (files are 34 KB); the three briefs plus rules, pattern checklist and r5 rows were read in full. Read-only; no dart or flutter run.

Severity scheme: a `:::check` or `:::try` that copies a quiz sentence = Major. An Example that copies a quiz sentence = Minor (the approved finding-subjects sample does the same with quiz 0003). Any pre-tap growth is Major (rule 2 of worker-rules), except finding-subjects (approved sample).

## 1. Round 5 and open round 4 rows

- agreement:37 | CLOSED (line 37 says "a common formal convention"; speed trick and checklist agree)
- apostrophes:110-124 | CLOSED (stem asks "completes the sentence"; Their no longer named as ruled out). Residual Minor below
- apostrophes:131 | CLOSED ("For a choice between its and it's", ownership cue added)
- capital:53,67-69 | CLOSED (rule says "ordinary word"; check now uses fresh word "garden")
- capital:84-90,120 | CLOSED (Ex 1 ends at the full sentence; Ex 3 check tests the title only)
- changing-voice:28 | CLOSED (doer becomes subject, active verb rebuilt in same tense and aspect)
- clear-pronoun:81-83,119-124 | CLOSED (both prompts are now fixed choices with one answer)
- commas-with-openings:19,122 | CLOSED ("Usually" in the core line and the shortcut)
- complex:18,36-39,42,60-63 | CLOSED (checks now ask for counts). Headings still announce the counts: Minor below
- complex:46-52,101-108 | CLOSED (marked sentence at 52; Ex 2 steps return to full sentences)
- connectors:25 | CLOSED ("Keep one connector for the link", both versions shown)
- connectors:75-77 | CLOSED (answer ends at "If the records are accurate, the totals will match.")
- connectors:39-53,128 | CLOSED ("Usually" in rule, pair note, check answer, checklist)
- dangling:19-23,52,116 | CLOSED (line 19 and shortcut ask which person the opener describes)
- editing-negative-concord:34-37,62-65 | CLOSED (both checks fix one slot, one answer)
- english-word-jobs:110-115 | CLOSED (fresh "Luckily" sentence, one step)
- Round 4 commas-in-lists:60,128 | CLOSED (pair note and checklist scoped to plain statements; short-pair exception kept)
- Round 4 complex:28,75-76 | CLOSED (illustration brackets the when-clause inside the if-clause; pair test scoped "in these examples")
- Round 4 finding-subjects:44,145 | CLOSED (consonant condition at 44; checklist names the third-person ending)

## 2. Pairs checked against content/walkthrough-trap-evidence.json

All 38 pairs pass: the cited wrong choice exists verbatim in the cited question, is not the correct choice, the question's `lesson:` is the lesson, and the Wrong line shows that mistake. Quoted exactly: apostrophes (0010, 0011, 0002), capital (0004, 0017, 0018, 0013), commas-in-lists (0005, 0006), commas-with-openings (0007, 0008, 0014), complex (0003, 0015, 0004, 0018), connectors (0005, 0006, 0009, 0010, 0015), dangling (0002, 0007, 0014, 0009, 0020), editing (0002, 0006, 0014), changing-voice (0004, 0007, 0019), clear-pronoun (0014, 0003, 0004, 0017, 0016, 0009), agreement (0011, 0012, 0020, 0017), english-word-jobs (0004, 0017, 0009, 0018), finding-subjects (0001, 0003, 0004, 0014). Paraphrased Wrong lines (clear-pronoun 0014/0016/0009, connectors 0006/0009/0010, changing-voice 0019) keep the same mistake. No pair findings.

## 3. Findings

### agreement-with-joined-subjects.md
Major | agreement-with-joined-subjects.md:whole | Pre-tap grew +4 | Cut line 61 first sentence "Do not repeat *were* in the second clause." (8 words); net -4.
Minor | agreement-with-joined-subjects.md:83-93 | Example 2 repeats pair #split-clause-agreement sentence for sentence and is quiz 0017's correct answer | Use a fresh pair (for example *the drivers* and *the passenger*) or drop the example.
Minor | agreement-with-joined-subjects.md:49 | Pair note "Match the nearer subject" lost the scope the core (line 37) and checklist now carry (P5) | "Under the formal convention, match the nearer subject."
OK: checks 1, 2 and Example 3 try have one answer; P1 to P3 and P4 ok; pairs ok; no nearer-subject universal left.

### apostrophes-for-ownership-and-contractions.md
Major | apostrophes-for-ownership-and-contractions.md:112-115 | Example 3 options (A) to (D) sit on adjacent lines (no blank lines); the app joins them into one run-on line (worker rule, hard-break check) | Put a blank line between each option.
Major | apostrophes-for-ownership-and-contractions.md:whole | Pre-tap grew +19 | See cuts.
Minor | apostrophes-for-ownership-and-contractions.md:95-106 | Example 2 repeats core line 47 verbatim and is quiz 0015 verbatim | Use a fresh sentence (*It's been a long day*) or cut the core's second sentence at 47.
Minor | apostrophes-for-ownership-and-contractions.md:108-127 | Example 3 reskins quiz 0002 (same four choices, same "one organization" frame, noun swapped) | Change the choice set (for example drop *Their*) or the frame.
Minor | apostrophes-for-ownership-and-contractions.md:119 | Step 1 still hands over the ownership cue ("blank comes before the noun") that the try should find | Say only "*The school* is one organization" and leave the noun cue in the answer.
OK: P2 ends at the finished sentence; checks 1 to 3 fresh, one answer; pairs ok; shortcut scoped.

### capital-letters-in-names-titles-and-quotes.md
Major | capital-letters-in-names-titles-and-quotes.md:107-123 | Example 3 try is quiz 0020 with *Cruz* swapped for *Lim* (same errors, same answer) | Use a fresh sentence with a different set of errors.
Major | capital-letters-in-names-titles-and-quotes.md:whole | Pre-tap grew +6 | See cuts.
Minor | capital-letters-in-names-titles-and-quotes.md:74-92,94-105 | Example 1 uses quiz 0004's correct and wrong choices verbatim; Example 2 uses the wrong choices of quiz 0013 and 0018 as its text | Fresh sentences.
Minor | capital-letters-in-names-titles-and-quotes.md:109 | Prompt says "Use the before-name title rule", which names the rule the try tests (P1) | "Fix every error in:".
Minor | capital-letters-in-names-titles-and-quotes.md:34,40 | "Use lowercase for a generic job role" and the pair note carry no style scope; some styles capitalize "the President" (P4) | "In this lesson's style, a generic role stays lowercase."
Minor | capital-letters-in-names-titles-and-quotes.md:92 | Ex 1 Check restates step 3 (P2) | Cut (also saves 12 words).
OK: checks 1 to 3 fresh, one answer; pairs ok; Ex 1 ends at the sentence.

### changing-voice-and-get-passives.md
Major | changing-voice-and-get-passives.md:55-59 | Check 2 ("Change to passive voice in past time") accepts "The forms were checked." as well as "...by the clerk"; the lesson itself says add *by* "if needed" (P3) | "Keep *the clerk* in the sentence." and state it in the answer.
Major | changing-voice-and-get-passives.md:whole | Pre-tap grew +13 | See cuts.
Minor | changing-voice-and-get-passives.md:87-112 | Examples 1 and 2 repeat the core pair and bullets (lines 23-26, 46) and are quiz 0004 and 0007 verbatim | Fresh sentences, or delete core lines 23-26.
Minor | changing-voice-and-get-passives.md:123-129 | Try is an open rewrite; "The typhoon damaged the wooden fence." is also formal (P3 weak, the Check does state the property) | "Replace only *got*."
OK: line 28 true and scoped; P1, P4, P5 ok; pairs ok.

### clear-pronoun-reference-and-singular-they.md
Major | clear-pronoun-reference-and-singular-they.md:80-84 | Check 3 is quiz 0019 verbatim: same stem fact, same wrong sentence, same correct sentence | Fresh instance (another pronoun with two possible names).
Major | clear-pronoun-reference-and-singular-they.md:41-45 | Check 2 reskins quiz 0004 ("Somebody left ___ umbrella in the classroom", room for classroom) | Fresh noun and sentence.
Major | clear-pronoun-reference-and-singular-they.md:whole | Pre-tap grew +18 | See cuts.
Minor | clear-pronoun-reference-and-singular-they.md:88-128 | Examples 1 to 3 are quiz 0002, 0003, 0017 and 0009 sentences | Fresh sentences.
Minor | clear-pronoun-reference-and-singular-they.md:26 | Check 1 reskins quiz 0001 | Fresh.
Minor | clear-pronoun-reference-and-singular-they.md:55 | Why says "*they* always pairs with *are*" (present tense only; *were* in past) (P4) | "*they* pairs with *are* in the present."
OK: both Ex 3 options give one answer; P2 ends at the sentence; pairs ok.

### commas-in-lists-and-joined-clauses.md
Major | commas-in-lists-and-joined-clauses.md:115-121 | Try answer begins "(D) Both (A) and (C)" and never shows the two correct sentences (P2) | Show (A) and (C) in full inside the answer.
Major | commas-in-lists-and-joined-clauses.md:whole | Pre-tap grew +16 | See cuts.
OK: no quiz copies; checks 1 and 2 one answer; round 4 rows closed; pairs ok.

### commas-with-openings-and-extra-information.md
Minor | commas-with-openings-and-extra-information.md:28 | Pair note "Any comma belongs after the whole opening group" overreaches: Example 2 has more commas (P4) | "The opening comma belongs after the whole opening group."
OK: pre-tap went down; checks fresh, one answer; Ex 3 try ok; pairs ok.

### complex-and-compound-complex-sentences.md
Major | complex-and-compound-complex-sentences.md:60-64 | Check 2 is quiz 0008 verbatim | Fresh compound-complex sentence.
Major | complex-and-compound-complex-sentences.md:79-83 | Check 3 is quiz 0007 verbatim | Fresh sentence with another clue word.
Major | complex-and-compound-complex-sentences.md:whole | Pre-tap grew +53 | See cuts.
Minor | complex-and-compound-complex-sentences.md:87-127 | Examples 1 to 3 are quiz 0014, 0018 and 0016 verbatim | Fresh sentences.
Minor | complex-and-compound-complex-sentences.md:18,42 | Headings still say "One Main Clause Plus Dependent Clauses" and "Two or More Main Clauses Plus Dependent Clauses" over counting checks (P1, weak) | Neutral headings (rule 5b).
OK: line 28 bracket fixed; pair note scoped; Ex 2 ends at full sentences; pairs ok.

### connectors-for-reason-and-contrast.md
Major | connectors-for-reason-and-contrast.md:74-78 | Check 4 is quiz 0018 verbatim (same stem, both choices) | Fresh opening clause and two choices.
Major | connectors-for-reason-and-contrast.md:whole | Pre-tap grew +12 | See cuts.
Minor | connectors-for-reason-and-contrast.md:25,31-35 | Check 1 stem spells out both fixes and line 25 now models both; the answer is a fill-in (P1) | Cut the line 25 model sentences (also saves words).
Minor | connectors-for-reason-and-contrast.md:82-103 | Example 1 is quiz 0015's stem; Example 2 is quiz 0009 and 0010 verbatim | Fresh sentences.
OK: Ex 3 try one answer, ends at the sentence; "usually" carried everywhere; pairs ok.

### dangling-modifiers-and-their-subjects.md
Major | dangling-modifiers-and-their-subjects.md:whole | Pre-tap grew +23 | See cuts.
Minor | dangling-modifiers-and-their-subjects.md:72-93 | Example 1 is quiz 0012 verbatim; Example 2 is quiz 0006 verbatim | Fresh sentences.
OK: rule at 19 and 23 true and scoped; checks fresh, one answer; Ex 3 try ok, options on separate lines; pairs ok.

### editing-negative-concord.md
Major | editing-negative-concord.md:whole | Pre-tap grew +2 | See cuts.
Minor | editing-negative-concord.md:69-91 | Example 1 is quiz 0002 and Example 2 is quiz 0006 verbatim | Fresh sentences.
OK: both checks fix a slot, one answer, end at the sentence; Ex 3 one answer; pairs ok.

### english-word-jobs.md
Minor | english-word-jobs.md:96-106 | Example 2 repeats the core's three *light* sentences (lines 44-48) and quiz 0009 to 0011; Examples/pairs reuse quiz 0004, 0017, 0018 sentences | Fresh sentences, or drop Example 2.
Minor | english-word-jobs.md:62-79 | Check 3 sits under "Checking the Job, Not the Ending" and the pair just above is the adjective *friendly*; heading hints the answer (P1) | Neutral heading, for example "Words Ending in -ly".
OK: pre-tap went down; Ex 3 closed; checks 1 and 2 one answer; pairs ok.

### finding-subjects-and-matching-verbs.md (approved sample)
Minor | finding-subjects-and-matching-verbs.md:145 | Pre-tap +11; the checklist parenthetical is the only cuttable text inside changed lines | Cut "(*-s*, *-es*, or *y* to *ies*)" (6 words). Line 44 "after a consonant" is the fix; keep.
OK: both r4 blockers closed; rules true and scoped; Ex 3 try ok; pairs ok.

## 4. Cut suggestions (word counts approximate; lead re-counts)

- agreement (+4): line 61 "Do not repeat *were* in the second clause." (-8) = -4.
- apostrophes (+19): core line 47 second sentence `In "It's been raining since dawn," "It has been raining" fits, while "It is been raining" does not.` (about -17), duplicated by Example 2; Ex 1 Check "Each ending matches its owner: ..." (about -14). Total about -31 = -12.
- capital-letters (+6): Ex 2 Check "Read each quote alone: a full sentence starts with a capital, one ordinary word stays lowercase." (-16) = -10; or Ex 1 Check (-12) = -6.
- changing-voice (+13): Ex 1 Check "Turn it back: *the novel* becomes the subject and *wrote* becomes *was written*." (-13) = 0; also pair note line 52 "Simple past stays simple past (...), not *-ing* or present." (-13) = -13.
- clear-pronoun (+18): Ex 1 Check "Plural *girls* pairs with *their*. *Each of the students* is one unspecified person, so singular *their* fits." (-17) and Ex 2 Check "Test each clause: ..." (-10) = -9.
- commas-in-lists (+16): pair note line 60 second sentence "A comma between *she* and *passed* has no job here." (-10) and Ex 2 Check "Both work, so a comma belongs here." (-7) = -1.
- complex (+53): delete core items 1 to 3 at lines 48-50 (-32) and turn the lead-in into "Mark the clauses in ...:" (the marked sentence at 52 then carries the labels); cut the line 52 closing "Two independent clauses plus one dependent clause make it compound-complex." (-10, repeats line 44); Ex 1 step 3 "So it has one independent clause and one dependent clause." (-10); Ex 3 step 4 repeat "adds its own subject and verb as" (-7); shorten both check stems to "Count the independent and dependent clauses in" (-6). Total about -65 = -12.
- connectors (+12): line 25 after "Keep one connector for the link:" delete the two model sentences (about -13); the check answer already shows both versions. Net -1.
- dangling (+23): delete line 52 (`*While* or *after* before an *-ing* word dangles unless ...`, about -22; the pair note at 61 says it) and Ex 1 Check "Ask who studied all night: the sentence never says." (-9) = -8.
- editing-negative-concord (+2): Ex 1 Check "One negative (*doesn't*), the same refusal, and present tense unchanged." (-10) = -8.
- finding-subjects (+11, sample): only the checklist parenthetical (-6); line 44 stays.

VERDICT: FAIL (0 Blockers, 19 Majors, 24 Minors)
