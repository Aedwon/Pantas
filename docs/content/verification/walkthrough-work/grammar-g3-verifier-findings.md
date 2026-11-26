# Grammar chunk 3 verifier findings (13 English lessons, swept at 3cb95fbaa)

Policy: read `origin/main` at `355fab361` (fetched at start; the lead read `2681b2b95`). AGENTS.md and WORKFLOW.md read in full. SUBAGENTS.md: read Part 7b (verifier tier) and searched the rest; I did not read every part.
Method: read every lesson in full, its quiz questions (`lesson:` grep under `content/questions/language-proficiency/grammar-and-structure/`), and every pair against `content/walkthrough-trap-evidence.json`. No file other than this one was written. Importer not run.

## 1. Round 5 and open round 4 rows

- finite-verbs R5 Blocker 93-104 (open try accepts any subject): CLOSED. Subject fixed, `(is / was)` slot, "right now" anchor, answer ends at the full sentence.
- finite-verbs R5 Blocker 41,57-60 (heading names the answer): CLOSED. Check offers two fresh strings.
- groups R5 Major 71 (none): CLOSED. "Either verb can occur ... formal style may prefer singular" matches Cambridge.
- independent R4 Blocker 19,59,126 (tense test, "not a clause here"): CLOSED. "often shows tense or agreement", "compares finite clauses", shortcut starts "For finite clauses".
- independent R5 Blocker 17,29-32 (check names its heading): CLOSED. Check is two fresh groups, "which can stand alone".
- infinitive R5 Blocker 93-103 (steps eliminate to one candidate): CLOSED. Step 1 only lists the two action words; the label is hidden.
- infinitive R5 Blocker 44,59-62 (heading supplies "No"): CLOSED. Heading is neutral, check asks which word carries tense.
- joining R4 Major 67-69,93-96 (clause boundary): CLOSED. "After the meeting ended" and "before it rained" shown as the full clause.
- joining R4 Blocker 45-49 (clause definition, *before leaving*): CLOSED. "In this lesson ... verb that shows tense"; "before leaving has no tense; another lesson covers it".
- keeping R5 Blocker 55-57,88-99 (prompts ask whether *again* stays): CLOSED. Check asks what *again* marks; try asks for the shorter request. (Two new issues below, K1 and K2.)
- matching R4 Major 25,104 (checklist forces matching with a clause): CLOSED. "usually avoid"; the report clause is named.
- matching R5 Blocker 38 ("no longer enjoys"): CLOSED. "The sentence now says she swims, without saying whether she enjoys it."
- misplaced R5 Blocker 33-36,98-103 (open rewrites): CLOSED. Check and try now give two complete options with one attachment.
- misplaced R5 Major 79-87 (scene shift, ends at "the second sentence"): CLOSED. Same scene both options; step 3 ends at the full sentence.
- modals-ability R5 Major 25,127 ("directly" / "only"): CLOSED at 25 and 127. One leftover "directly" at 36 (Minor MA1).
- modals-req R5 Blocker 43,58-61,64-81 (checks name the answer): CLOSED. Weather check asks what *may* says; *must* check asks for the clue. (Minor MR2 below.)
- modals-req R5 Major 111-122 (notice split, "has to be" claim): CLOSED. Lead-in names both phrases, labels precede sentences, check is `is probably closed`.
- parallel R4 Major 19,36-38,123 (*either* blamed): CLOSED. Noun phrase named as the mismatch; moving *either* is a clarity option at 27, 38, 122.
- parallel R5 Blocker 107-112 (open rewrite): CLOSED. A/B options, one defensible answer.
- parallel R5 Major 30-32 (festival ends at replacement word): CLOSED. Right line shows the full corrected sentence.
- past-events R4 Major 58-70 (one tense whenever same timeline): CLOSED. "Usually", "parallel completed actions", at 58, 70, 125.
- past-events R4 Blocker 45-47 (*will* always future): CLOSED. "Here, *tomorrow* shows future meaning" at 47.
- past-perfect R5 Major 67-75 (no base verb): CLOSED. "(buy)" supplied.
- past-perfect R5 Major 58-60,98 (check credits simple past; "always valid"): CLOSED. Check asks which event came first and which word shows it; shortcut says "often".

## 2. Pair checks against the evidence file

All 36 pairs checked. Every cited wrong choice exists exactly in a question whose `lesson:` is that lesson, is not the correct choice, and its mistake shows in the Wrong line: finite-verbs 2/2 (q0021 preparing, to submit, closing; q0007 three finite or phrase labels), groups 3/3 (q0005 Have, q0006 Are; q0008 Seem, q0007 Are; q0010 Is, q0009 Have), independent 3/3 (q0002/q0003 Prepositional phrase, Dependent clause; q0004/q0008 Independent clause; q0017 After the bus trip, During the bus journey), infinitive 2/2 (q0022, q0023), joining 3/3 (q0006 Adverb; q0007 Preposition, Adverb; q0019 Preposition), keeping 2/2 (q0013, q0021), matching 3/3 (q0005, q0010, q0009), misplaced 2/2 (q0001, q0013), modals-ability 3/3 (q0021, q0028, q0029), modals-req 3/3 (q0030, q0031, q0024), parallel 3/3 (q0002, q0017, q0008), past-events 3/3 (q0001, q0015 Present perfect, q0006), past-perfect 2/2 (q0005, q0014). No citation mismatch.

## 3. Findings

Severity | file:line | problem | fix

### finite-verbs-and-ing-groups.md
Major | :73 | Example 1 chain ends at "The second entry is the complete formal sentence" (P2: ends at a label, not the sentence). | End step 3 with "Lia was running quickly through the park."
Minor | :67,:79 (also core :19,:45,:52) | Worked examples copy quiz sentences (q0007 "running quickly through the park", q0021 "The assistant is preparing ..."). | Use fresh sentences in the two worked examples.

### groups-and-indefinite-pronouns.md
Major | :34 | Check 1 copies q0006 (family, one unit, American English, "planning a trip ... this summer"). | Use a fresh group noun and scene, for example a staff or a class with a different verb.
Minor | :89,:96,:102 (also core :43-44) | Worked examples copy q0005, q0015, q0016 (committee, team "among themselves", "Everybody have their own opinion"). | Fresh sentences in the worked examples.
Minor | :36,:61,:82 | Checks end at one word ("The answer is **Is**") with no finished sentence (P2). | Restate the full sentence in the answer, as the other lessons now do.

### independent-and-dependent-clauses.md
Major | :104 | Example 2 Check repeats step 2 ("The road flooded stands on its own") (P2). | Different test, for example: add *Because* back and the group leaves you waiting for a main clause.
Minor | :82-92 (also core :21) | Example 1 copies q0002 ("the cat slept"); core copies q0003. | Fresh short clause.

### infinitive-phrases-and-nonfinite-clauses.md
Major | :33,:39,:93 | Bold inside an italic quote (`*"... **to obtain ...** ..."*`). The worker rule bans nesting; the converter leaves stray stars. | Drop the italics around the quoted sentence or end the italic span before the bold group. Rerun the emphasis check.
Minor | :21,:81-87 | Core and Example 2 copy q0022 and q0023 sentences. | Fresh sentences in Example 2.
Minor | :39 | Check 1 asks the label the pair above just printed; only "infinitive phrase" is taught for basic grammar, so there is no decision (P1). | Ask which word carries tense, or give two labels to choose from.

### joining-words-phrases-and-clauses.md
Major | :108-114 | Example 3 try copies q0020 (full sentence and the "(4) before" question). | Fresh sentence for the try.
Major | whole lesson | Pre-tap words +18 over budget. | See cuts, section 4.
Minor | :21,:23,:61,:76 | Core and Example 1 copy q0006, q0008, q0019, q0007 sentences. | Optional.

### keeping-needed-repetition.md
Major | :84 | Example 2 Check ("Two readings came before this request") repeats step 1 (P2). | Different test: the request asks for a third saying.
Major | :110 | Checklist says "keep *again*" without scope. Core :21 and the Speed Trick :104 say *again* "can" mark a repeat and that some guides call it redundant in both cases (P4/P5). | "Request after an earlier repeat: *again* can stay because it marks a further repeat ..."
Minor | :95 | Try is an open rewrite; the answer does not say what any correct version must do (P3). | Add "Delete one word." to the stem.
Minor | :64,:49-50 (also core :20,:21) | Example 1 copies q0013; core copies q0021. | Optional.

### matching-forms-in-lists.md
Minor | :68 (also core :20-22,:36) | Example 2 copies the q0019 stem and answer ("repairing the roof"). | Fresh sentence.
Minor | :103 | Checklist 3 says "match the noun phrases" with no "usually" (core :25 says "usually avoid"). | "usually match".
Minor | :48 | Check answer ends at the word, not the sentence (P2). | State the full sentence.

### misplaced-modifiers-and-clear-meaning.md
Major | :91-103 | Example 3 draft and try copy q0015 (visitors, bread, napkin; wrong choice 3 is the try's first sentence). | Fresh passage.
Major | :75 | Example 1 Check restates step 3 (P2). | Cut it (counts toward the budget).
Major | whole lesson | Pre-tap words +42 over budget. | See cuts, section 4.
Minor | :67,:79 (also :45) | Examples 1 and 2 copy q0005 and q0017; core :45 already works Example 2's pair. | Fresh sentences, or cut core :45.

### modals-ability-and-permission.md
Major | :107 | Example 2 Check restates steps 1 to 3 (P2). | Cut it. This also fixes the +2 words.
Major | whole lesson | Pre-tap words +2 over budget. | See cuts, section 4.
Minor | :36 | "take the bare base form *answer* directly" repeats the "directly" wording R5 flagged at 25 and 127 (P5). | Drop "directly".
Minor | :22-23,:28,:61-63 | Core examples copy q0021, q0028, q0029. | Optional.

### modals-requirements-and-possibility.md
Major | :94 | Example 1 Check restates step 2 (P2). | Cut it or replace it with a different test.
Minor | :77-79 | "what does *must* express" is printed in the pair Right line just above (P1). | Ask only for the clue.
Minor | :68,:86,:98 | Core and Examples 1 and 2 copy q0024, q0030, q0031. | Optional.

### parallel-pairs-and-comparisons.md
Major | :42 | Italic inside italic: `*"... nor *(offer / offering / offers)* discounts."*`. Rule bans nesting. | Write `"The shop will neither lower prices nor ___ discounts": *(offer / offering / offers)*`.
Major | whole lesson | Pre-tap words +22 over budget. | See cuts, section 4.
Minor | :111 | Try Check repeats the answer line ("rent and rent"). | Cut the first sentence.
Minor | :77,:89 (also core :21,:23,:51) | Examples 1 and 2 copy q0006 and q0011 (near copy). | Optional.

### past-events-and-future-meaning.md
Minor | :83 (also core :24,:40,:61) | Example 1 copies q0001. | Optional.
Minor | :120 | Try Check repeats the answer ("cleaned ... painted ... both past"). | Different test, or cut.

### past-perfect-earlier-completion.md
Minor | :77 | Example 1 Check repeats step 2 (P2). | Cut or replace.
Minor | :21,:44-45 | Core copies q0005 and q0014 sentences. | Optional.

## 4. Cut suggestions (pre-tap, each cut a reader would not miss)

- joining-words (+18): cut line 19 "The remaining three classes in traditional school grammar connect words or express reactions." (13); cut line 84 "**Check:** Drop *Wow!* and the sentence still works." (8); cut line 118 "Alone (*seen it before*), *before* is an adverb." (8). Total 29. No fix is undone; the R4 scope words stay.
- misplaced-modifiers (+42): cut line 87 Example 2 Check "Drop *on a ladder* ... stays on *window*." (18); cut line 75 Example 1 Check (9); cut line 23 "Now *covered in cheese* follows *pasta* directly." (7); cut line 30 last sentence "Put the phrase right beside *pasta*." (6); cut line 108 "Then check what the wording puts beside it." (8). Total 48. Step 3 of Example 2 and the pair Right lines keep the finished sentences.
- parallel-pairs (+22): cut line 53 "*The cost of a bus trip is lower than a taxi* compares a cost with a vehicle. State the cost on both sides." (22; pair 3 note says the same). Margin: cut line 85 Example 1 Check (8) and line 96 Example 2 Check (4).
- modals-ability (+2): cut line 107 Example 2 Check (15).

VERDICT: FAIL (0 Blockers, 16 Majors, 22 Minors)

Counts per lesson (Blockers/Majors/Minors): finite-verbs 0/1/1; groups 0/1/2; independent 0/1/1; infinitive 0/1/2; joining 0/2/1; keeping 0/2/2; matching 0/0/3; misplaced 0/3/1; modals-ability 0/2/2; modals-req 0/1/2; parallel 0/2/2; past-events 0/0/2; past-perfect 0/0/2. Wordiness over budget is counted as one Major each (joining, misplaced, modals-ability, parallel).
