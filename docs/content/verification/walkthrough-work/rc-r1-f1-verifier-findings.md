# RC round 1, chunk F1: verifier findings (11 lessons)

Verifier: Claude review sub-agent. Policy read: `origin/main` `cc6e90e94` (AGENTS.md, WORKFLOW.md, SUBAGENTS.md read; the briefs name `3fd9fdf0e`). Branch `content/lesson-walkthrough-cse-r1`, lessons as on disk (uncommitted). Read-only.

**Verdict: FAIL.** 4 Blockers (answer given away), many Majors. Evidence citations all resolve (every cited wrong choice exists exactly in a question whose `lesson:` is the cited lesson, and is a non-correct choice). The lesson text of 21 of 23 pairs does not use the cited slip on the lesson's own passage. Illustrations: all three SVGs match their markers and the surrounding text.

Paths are under `content/lessons/reading-comprehension/comprehension-skills/`. Pair fixes keep the cited mistake. The "Right" line is already on the lesson's passage unless I name it.

## Pattern findings that repeat (each instance is also listed per lesson)

- **A. Pair lines from quiz passages (Major).** All pairs except visual-data-conclusions' two. Fix lines are given per lesson.
- **B. Solutions with no lead-in (Major).** One line each is listed per lesson.
- **C. Surface-form eliminations (Major).** Wrong choices carry words the lesson just taught as red flags (*only*, *always*, *every*, *lahat*, *laging*, *bawat*, *best*, *should*), or are absurd, or the right choice is the only one that repeats a passage phrase. Fix: write each wrong choice as a plausible reading slip of the same length and shape.
- **D. Binary or open tries (Major).** The stem names the criterion and offers two options (or one option copies a passage sentence). Fix: four full choices with one defensible answer, stem neutral.
- **E. Filipino answers end at a letter (Major, P2).** "Ang sagot ay **A**." Fix: end at the finished statement, for example "Pangunahing ideya: ...".

## 1. main-point-and-topic-sentence (about 950 pre-tap words, over 900)

- Major | :33-36 | Wrong "Community trust and financial discipline help stores survive." is a quiz line from a passage the student has not seen. | Wrong: `Supporting detail: The public market gets ready for rainy days in several ways.` Keep the note about summing up the whole passage.
- Major | :72-75 | Wrong is quiz Filipino text in an English lesson. | Wrong: `Topic sentence: Passengers at the corner stop waited more than an hour.` Note: "It names only the first part of the problem. The topic sentence covers all the others."
- Major | :110, :126 | Solutions have no lead-in. | `Let's test each choice against the barangay hall notice:` and `Let's find the sentence that covers the repairs in the tricycle paragraph:`.
- Major | :122-137 | Example 2 shows no choices, the try offers two sentences, and the stem says "covers all the repairs" while the other option is plainly what passengers say. The chain never ends at a "Main idea:" line. | Give four choices (one repair detail, one passenger report, one unstated, one covering sentence) and end `Main idea: He takes good care of the tricycle he drives every day.`
- Minor | :31 | Check restates the definitions rather than testing the answer another way. | `Drop "hands out plastic sheets": the first sentence still fits the other two actions.`
- Minor | :72-92 | Pair #problem-only sits right above the check whose choice A is the problem-only sentence. | Move the pair after the check.
- Size | cut about 55 words: :31 last two sentences (13), :57 last two sentences (14), :36 second sentence (10), :75 rewrite shorter (about 15), :118 second sentence (5).

## 2. implied-main-point (about 855, OK)

- Major | :33-36 | Wrong "She rejected the original proposals because of severe budget limitations." is a quiz line. | Wrong: `Lani works hard because she wants to open a bigger shop.`
- Major | :39-42 | Wrong "She favors youth athletic activities over local agricultural projects." is a quiz line. | Wrong: `Lani cares most about baking pandesal.`
- Major | :108, :124 | No lead-in. | `Let's test each choice against what the family did before the typhoon season:` and `Let's find the idea suggested by the clinic passage:`.
- Major | :45-59 | Check B, C and D are implausible (B is contradicted by "asked neighbors to help"), so A wins by form. | Make the others plausible slips: `Ate Grace likes to be the center of attention.`, `The barangay road is unsafe.`, `Candy wrappers are the main problem on the road.`
- Major | :96-106 | Example 1 wrong choices use *only*, *always* and *every* and read as absurd (B "the only person who works at home"). | Use plausible slips: `Mang Tonyo worries more than his family does.`, `The family expects the school hall to flood.`, `Storing water is the only preparation that matters.`
- Major | :129-135 | The try offers two statements, one with "always", and the Check repeats the answer's reasoning. | Four choices; Check: `Swap in "Nena is always the first in line": no sentence says who else came.`

## 3. main-idea-scope (about 930, over 900)

- Major | :34-37 | Wrong "Cleaning Plastic: The Project's Only Environmental Goal" is a quiz title. | Wrong: `Title: Reading Aloud Is the Hour's Only Activity`
- Major | :72-75 | Wrong "The Complete History of Quezon Fishpond Construction" is a quiz title. | Wrong: `Title: The Complete History of Bakeries in the Philippines`
- Major | :110, :136 | No lead-in. | `Let's test each choice against the passage about the night market:` and `Let's test each title against the passage about the classroom chart:`.
- Major | :78-92 | Check B "Schools should share all news publicly." carries *should* and *all*, which the lesson taught as red flags. | `Schools post news so that pupils can plan their week.` (too broad) is still wrong but plausible.
- Major | :120 | Check repeats step 5. | `Cover the band: C still names food and goods, but the sentence about music has no home. Every part of C comes from the passage.`
- Blocker | :141-147 | The try's stem names the answer ("without going past the classroom"), and only B repeats "Classroom"; C ends "Everywhere". Steps 1-2 already remove A and D. | Stem: `Finish the last step: which title fits the whole passage?` Make C a plausible too-broad title without "Everywhere", for example `Chores in Every Grade 5 Room`.
- Minor | :152-154 | Third checklist item does not match its slug. | Point it at the pair or heading that teaches it.
- Size | cut about 40 words: :20 sentences two and three (28), :58 last sentence (7), :37 and :75 second sentences (18, rewritten).
- Figure | :18 marker; `main-idea-scope/01-a-box-labeled-main-idea.svg` shows one main box and three detail boxes; the text beneath it uses three details. OK.

## 4. main-idea-across-paragraphs (about 920, over 900)

- Major | :34-37 | Wrong "Safe nearby recreation was a need identified by the youth." is a quiz line, and the note describes that passage. | Wrong: `Residents lost furniture when the canal flooded.` Note: "The wrong choice is one detail from one paragraph. The main idea must cover both."
- Major | :76-79 | Wrong "Weekly wholesale buying is the only requirement for survival." is a quiz line. | Wrong: `Families buy fish only at the morning market.`
- Major | :118, :136 | No lead-in. | `Let's test each choice against the passage about the bus route:` and `Let's find the main idea of the passage about the market trash:`.
- Blocker | :58-60, :82-98 | Heading and rule ("two sides ... keeps both") name the answer; A is the only choice with both sides. | Neutral heading, for example `Passages That Turn`. Add a plausible two-sided wrong choice: `Online classes cost less than face-to-face classes, but fewer pupils use them.`
- Major | :110-116 | Example 1: C and D carry *only* and *best prices in the province*. | Plausible slips: `Pupils and farmers travel to town at the same time.`, `The new route was built for the market.`
- Major | :141-147 | The try offers two statements, one copied from the passage, and the stem says "covers both paragraphs". | Four choices; stem: `Finish the last step: which statement is the main idea?`
- Minor | :60, :154 | "the main idea keeps both" is stated without a scope word. | `usually keeps both`.
- Size | cut about 25 words: :60 second sentence (15), :79 second sentence (11).

## 5. paragraph-links-and-patterns (about 830, OK)

- Major | :31-34 | Wrong "Visits to collect a completed sample; comparison of two services." is a quiz line. | Wrong: `"These delays" = the workers who missed the first shift.` Note: "The wrong choice points to words that come after. A pointing word usually looks back."
- Major | :115-118 | Wrong "Visits made after revision of the instructions; cause and effect." is a quiz line. | Wrong: `Cause and effect`. Note: "Forgetting caused hunger, but the whole passage is a difficulty and a response."
- Major | :115-121 | The pair sits between the Solution and the Check, so the example does not end on its Check. | Move the pair above `### #1` or into the core.
- Major | :107, :129 | No lead-in. | `Let's find what "This habit" points to and how the lunch money passage is organized:` and the same for "These long queues".
- Major | :136-142 | The try offers two patterns, "As a result" is printed in the passage, and the Check repeats the answer line. | Four patterns; Check: `Reorder the first two sentences: "As a result" no longer fits, so the order matters because one event causes the next.`
- Minor | :18, :55 | "Referential cohesion" is not Grade 5; "each paragraph has a job" while every passage is one paragraph. | `Pointing words`; "each part".

## 6. visual-data-conclusions (about 800, OK)

- Major | :150 | Example 2 Solution has no lead-in. | `Let's read each bar against the line at 25:`
- Major | :142 | Check repeats step 3 backwards ($30\div2=15$). | `Count the squares in the figure: Tuesday's bar has 6, Wednesday's has 3.`
- Major | :155-158 | The stem tells the reader to take the day after Tuesday, which is the whole task. | `Finish the last step: which morning had an extra window?`
- Minor | :114-120 | The table repeats every bar value, so the figure is not needed. | Keep only if the table is the accessible copy. State that in the lead-in.
- Minor | :83-106 | Pair is named "same-morning" but the next check uses a same-morning rule. | Rename the pair id and note, or reword the check.
- Pairs OK (:46-50, :83-87 use the lesson's own data and match cited choices). Figures: both SVGs show 20, 30, 15 and the line at 25; the text agrees.

## 7. paksa-at-pangunahing-ideya (about 860, OK)

- Major | :29-32 | Right/Wrong from the quiz gulayan passage. | Right: `Paksa: ang aklatan ng barangay.` Wrong: `Paksa: Bukas ang aklatan ng barangay tuwing Sabado at nagpapahiram ng aklat.` Note: "Pangalan lamang ang hinihingi. Ang maling sagot ay buong pahayag, kaya pangunahing ideya na ito."
- Major | :63-66 | Right/Wrong from the quiz hardin passage. | Right: `Pangunahing ideya: Naging mas malinis ang estero dahil sa gawain ng mga residente ng Purok 3.` Wrong: `Pangunahing ideya: Nagtayo ng bakod na gawa sa lumang gulong ang mga residente.` Note: "Isa lamang sa mga ginawa ang bakod. Sakop ng pangunahing ideya ang buong talata."
- Major | :91, :117, :141 | No lead-in under Solution (Example 1 has one above the passage only). | `Hanapin natin ang paksa at pangunahing ideya ng talata tungkol sa gulay:` and equivalents.
- Major | :109-115, :133-139 (pattern C) | Wrong choices carry *lahat*, *Dapat*, *sa bansa*. | Plausible slips such as `Dumami ang pasyente dahil sa bagong upuan.` and `Nagtipid ang mga magulang sa pagkain.`
- Major | :35-47, :69-81 (pattern C) | A is the only choice that repeats passage wording ("palengke sa aming bayan", "dalawang hanay at bantay"). | Reword A with a paraphrase and give each wrong choice a passage phrase.
- Major | :146-152 (pattern E) | Try answer ends at "A". | End `Pangunahing ideya: Nagsama-sama ang mga magulang upang parangalan ang magreretirong guro.`
- Minor | :103 | English heading text "Health Center". | `Sentro ng Kalusugan`.

## 8. balangkas-at-ugnayan (about 870, borderline)

- Major | :35-38 | Right and Wrong both from the quiz pisara passage; the student has not seen it. | Right: `Mas ligtas ang tawiran: guhit na tawiran at bantay.` Wrong: `Guhit na tawiran: mas ligtas na tawiran at bantay.`
- Major | :79-82 | Right and Wrong describe a quiz sentence. | Right: `Ang "Dahil dito, halos wala nang nahuhuling pumasok" ay bunga ng kampana.` Wrong: `Ang "Dahil dito, halos wala nang nahuhuling pumasok" ay sanhi ng pagkahuli ng mga mag-aaral.`
- Major | :85-88 | Right and Wrong describe a quiz sentence. | Right: `Ang A ay huli sa talata, dahil bunga ito ng kampana.` Wrong: `Ang A ay unang nangyari, kaya ito ang una sa talata.`
- Major | :125, :149 | No lead-in. | `Hanapin natin ang pinakamahusay na balangkas ng talata tungkol sa palaro:` and `Hanapin natin ang papel ng huling pangungusap sa talata tungkol sa kanal:`.
- Blocker | :63, :91-107 | The rule above ("Unahin ang pangungusap na nagpapakilala ng paksa") picks B; options 2 and 3 begin with *Halimbawa* or *Bukod dito* and cannot start a paragraph. | Test the order of C and A: choices `B, C, A`, `B, A, C`, `C, B, A`, `A, B, C`, and move the rule line so it does not name the first sentence.
- Blocker | :154-160 | The core list (:57-61) maps *Ngunit* to opposition and B, C, D to *Halimbawa*, *Dahil*, *Kaya*; the stem quotes *Ngunit*, and A is the only choice with "kahit". The answer ends at "A". | Replace the stem with the full last sentence and give four options that each fit a different pointing word; end `Ipinapakita ng huling pangungusap ang suliraning natira kahit may ginawa na.`
- Major | :159 | Check repeats the answer reason. | `Alisin ang "Ngunit": nawawala ang pagsalungat.`
- Major | :111-123 | C and D invent content ("pagbili ng gamit", "Pagbabawal sa kalsada"). | Use slips built from the passage: `Habulan at taguan: mga palaro at paligsahan sa plasa.` already covers B; replace C with `Mga bata sa purok: habulan, taguan at kalsada.`
- Minor | :41-51 | The check has 3 choices and C is absurd. | Four plausible choices.
- Minor | :63 | "Ang dito at ito tumuturo sa nauna" has no scope word. | Add "karaniwang".

## 9. hinuha-mula-sa-detalye (about 720, OK)

- Major | :29-32 | Right/Wrong from the quiz staff-and-signs passage. | Right: `Hinuha: Giniginaw si Gina.` Wrong: `Hinuha: Galit si Gina sa mga kasama niya sa bahay.` Note: "Walang detalyeng nagsasabi ng galit. Dapat may pahiwatig sa teksto ang hinuha."
- Major | :35-38 | Right/Wrong from the quiz passage. | Right: `Hinuha: Giniginaw si Gina ngayon.` Wrong: `Hinuha: Hindi na kailanman giginawin si Gina.`
- Major | :67-70 | Right/Wrong from the quiz passage. | Right: `Pangunahing diwa: Nagmamalasakit ang mga tao sa purok sa mga hayop.` Wrong: `Pangunahing diwa: Pinapainom ng mga kapitbahay ang mga aso sa gripo.` Note: "Tama ang detalye, pero isa lamang ito."
- Major | :93, :116 | No lead-in. | `Hanapin natin ang hinuha tungkol kay Nena:` and `Hanapin natin ang pangunahing diwa ng talata tungkol sa palengke:`.
- Major | :87-100 | The question has no choices, and the answer adds "mga kalahok", which the passage never says, against the lesson's own rule. | Give four choices; answer: `Naghahanda si Nena para sa pagdating ng iba.`
- Major | :87, :102 | Headings name the label asked ("Hinuha", "Pangunahing Diwa"). | `Si Nena sa Silid`, `Talata Tungkol sa Palengke`.
- Major | :121-127 (patterns C, E) | C carries "lahat ng plastik sa bansa"; answer ends at "A". | Plausible slips; end `Pangunahing diwa: Kumikilos ang komunidad upang bawasan ang paggamit at basura ng plastik.`
- Major | :41-51, :73-83 | Three choices, two absurd or single-detail. | Four plausible choices.
- Minor | :42-44 | Mud, spade and a *sako ng buto* in hand could mean "papunta" as well as "galing". | `Naghahanda si Ben na magtanim.`

## 10. paghatol-at-ebidensya (about 810, OK)

- Major | :30-33 | Right/Wrong from the quiz kawani passage. | Right: `Kulang ang batayan para sa lahat ng araw.` Wrong: `Napatunayang laging mauubos ang ulam sa bagong menu.` Note about one tested day.
- Major | :36-39 | Right/Wrong from the quiz passage. | Right: `Hindi pa masasabi ang resulta sa ibang araw.` Wrong: `Napatunayang hindi mauubos ang ulam sa ibang araw.` Also change "Walang tala ay hindi masamang tala" (:39) to "Ang kawalan ng tala ay hindi patunay na masama ang resulta."
- Major | :68-71 | Right/Wrong from the quiz passage, and the note names that passage. | Right: `Maaaring may ambag din ang tutor.` Wrong: `Ang bagong tutor lamang ang dahilan ng mas mataas na marka.`
- Major | :94, :118 | No lead-in. | `Hatulan natin ang pahayag tungkol sa bagong sistema ng pila:` and `Hatulan natin ang mga pahayag tungkol sa mga ilaw-poste:`.
- Major | :42-52 | B has *lahat*, which :18 names as a red flag; C is absurd. | `Mas kaunti ang nagkakasalubong sa buong paaralan.` and `Mas marami ang nagkakasalubong sa ibang baitang.`
- Major | :74-84 | B is the only hedged sentence under a heading and a rule that call for hedging. | Add a hedged wrong choice: `Maaaring may ambag ang piyesta, kaya walang epekto ang menu.`
- Major | :88 | Heading "Isang Araw ng Pagsubok" names the reason. | `Bagong Sistema ng Pila`.
- Major | :123-129 (patterns C, D, E) | The stem says "hindi lumalampas"; B and C carry *bawat* and *lamang*; the Check repeats the answer; answer ends at "A". | Neutral stem; plausible wrong choices; Check: `Palitan ang "Purok 2" ng "lahat ng purok" sa A: lalampas na ito sa tala.` End at the statement.
- Minor | :90-102 | Example 1 repeats the core's one-day frame. | New frame (two tested groups).

## 11. filipino-meaning-clues (about 730, OK)

- Major | :29-32 | Right line and the Wrong "mahigpit sa paniningil ng utang" are from the quiz Ruel passage. | Right: `Kahulugan: handang magbigay sa iba.` Wrong: `Kahulugan: mahilig magtinda ng ulam.` Note: "Ibinabahagi ni Aling Nena ang ulam, hindi niya ito ibinebenta. Huwag magdagdag ng ugaling hindi ipinakita."
- Major | :86-89 | Right/Wrong are from the quiz sobre and suyod passage. | Right: `Ang "lumilipad ang isip" ay malayo ang iniisip.` Wrong: `Tunay na lumilipad palabas ng bintana ang isip ni Ana.`
- Major | :112, :127, :150 | No lead-in. | `Hanapin natin ang kahulugan ng "matamlay" sa talata:` and equivalents.
- Blocker | :72-102 | The heading and :74 name the nonliteral reading and B is the only literal choice. | Neutral heading, for example `Mga Parirala sa Talata`; make two choices plausible readings of the phrase.
- Major | :155-161 (patterns C, E) | The stem says "pagsasamahin ang dalawang suliranin"; B is literal, C absurd; answer ends at "A". | Neutral stem; end `Kahulugan: Mabigat ang pasanin niya sa buhay.`
- Major | :134 | Check repeats the step above. | `Ipalit ang "mahinahon": hindi na bagay ang "Ngunit".`
- Minor | :121 | Heading "Salitang May Pagbabago" names the clue. | `Si Liza at ang Pinto`.
- Minor | :167 | "hanapin ang kabaligtaran" has no scope word. | Add "karaniwan".
- Minor | :35-45 | A is the only choice that repeats a passage phrase ("kahit", "tuloy pa rin"). | Paraphrase.
