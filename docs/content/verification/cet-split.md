# CET bite-sized split: independent re-solve evidence

Date: November 19, 2026. Lead: CET finish lead. Plan: `docs/superpowers/plans/2026-11-19-cet-bite-sized-finish.md` on main.

Every question below sits in a CET topic that was split into parts (plus the PSHS-NCE and CET Algebra questions that share those topics). Each was solved blind by a separate Codex GPT 6.2 Sol run, which saw only the stem, the choices and the passage, never the key. The run's answer and confidence were compared with the key by `tools/content_rewrite/question_check/merge_solves.py`: every compared question matched with no low-confidence answer (2,570 solved, 0 mismatches). Questions whose text equals the earlier CSE blind-solve commit were skipped by the tool and rely on that earlier solve.

The new pool-gap questions were written by GPT 6.2 Sol and solved by a separate run in the same pass. Their authors did not solve them.

The Algebra word-problems file changed only in its exam tags (ustet removed); it stays covered by its earlier Algebra solve (`docs/content/verification/algebra.md`) and by ruling R2.

Not yet done: the independent sample audit by a separate Sol run, listed in the plan. Approval here means a key matched a blind solve, not that an audit passed.

| Topic | Questions approved |
|---|---|
| mathematics/algebra | 173 |
| mathematics/arithmetic-number-sense | 41 |
| mathematics/geometry | 208 |
| mathematics/precalculus-basic-calculus | 84 |
| mathematics/statistics-and-probability | 114 |
| mathematics/trigonometry | 174 |
| reading-comprehension/text-types | 61 |
| reasoning/mechanical-technical-reasoning | 118 |
| reasoning/spatial-abstract-reasoning | 27 |
| science/biology | 300 |
| science/chemistry | 434 |
| science/earth-science-astronomy | 291 |
| science/physics | 408 |
| Total | 2433 |

## Audit fixes (November 20, 2026)

After the independent Sol audit, fixes changed 77 questions. All 1,097 questions in the fixed files were solved blind again by a separate GPT 6.2 Sol run (1,097 matches, 0 mismatches, 0 low confidence). The 77 changed questions are re-approved on that solve.

## Re-check fix (November 20, 2026)

The independent re-check changed one question's wording (q-chemistry-stoichiometry-0004, "molar mass" for a g/mol value). The file was solved blind again by a separate GPT 6.2 Sol run (24 of 24 matched, 0 low confidence). The question is re-approved on that solve.

## ACET verbal logic pool (November 20, 2026)

GPT 6.2 Sol wrote 26 new questions (ids 0029 to 0054 in `reasoning/verbal-logic/assumptions-and-conclusions.yaml`) so the pool reaches 54 for the 45 ACET slots. A separate GPT 6.2 Sol run solved the file blind: 34 of 34 solved questions matched, including all 26 new ones, 0 mismatches, 0 low confidence. The 26 are approved on that solve.

## Normal-curve lesson, pool gaps, mocks (November 20, 2026)

GPT 6.2 Sol wrote 10 questions for the new normal-curve lesson (DCAT only) and 7 gap questions in six older lessons whose pools fell short after the audit fixes. A separate GPT 6.2 Sol run solved the files blind: 10 of 10 for the normal-curve file and 118 of 118 for the five gap files, 0 mismatches, 0 low confidence. The 17 new questions are approved on those solves.

## November 20 CET completeness sweep

A separate solver saw only the shuffled stems, choices, and passages. The question-check pipeline matched all 15 answers. There were zero mismatches and no low-confidence answers. These questions previously passed the gate on the frozen ledger with their YAML approval flag set to false.

- `q-text-types-essays-editorials-articles-0016`: B. The byline identifies Rosa as an individual author, and she argues for a policy change.
- `q-text-types-essays-editorials-articles-0017`: C. The byline and personal-capacity label identify the views as Rosa's.
- `q-text-types-essays-editorials-articles-0018`: D. The blocked view is the reason the writer gives for moving pickup away from the crossing.
- `q-text-types-essays-editorials-articles-0019`: A. She addresses residents' concern and proposes observing a trial before deciding.
- `q-text-types-essays-editorials-articles-0020`: B. Attribution makes Rosa the source of the proposal, and reporting responses covers how others reacted.
- `q-text-types-visual-media-0011`: A. February is at 70 thousand pesos, below only April's 90 thousand.
- `q-text-types-visual-media-0012`: A. The truncated baseline makes the change look large relative to the displayed bar lengths.
- `q-text-types-visual-media-0013`: C. Sales fall from 70 to 60 in March and climb to 90 in April.
- `q-text-types-visual-media-0014`: B. The labeled axis makes changes across the plotted months easier to see.
- `q-text-types-visual-media-0015`: D. The same values appear against two different baselines, changing how large the gap looks.
- `q-text-types-visual-media-0016`: B. Gio needs the timetable after his posting helped start the crowding that hid it.
- `q-text-types-visual-media-0017`: C. The earlier panels show the actions that caused the problem Gio faces in the last panel.
- `q-text-types-visual-media-0018`: C. The larger headline attracts attention that the smaller timetable text is less likely to get.
- `q-text-types-visual-media-0019`: D. Gio makes an exception and others add posters until the timetable is hidden.
- `q-text-types-visual-media-0020`: D. Pointing to the pile shows what happened to the timetable and answers Gio without words.

### PSHS-NCE spatial reasoning pools

A separate solver answered the 12 new questions from shuffled blind packets. All 12 matched at high confidence. Each of the six parts tests key point 1 with two questions. The items use self-contained spatial inference and require no image.

- `q-spatial-abstract-reasoning-dots-on-shape-boundaries-0001`: C. The first center lies inside the triangle. The second center lies on the side.
- `q-spatial-abstract-reasoning-dots-on-shape-boundaries-0002`: B. The 5 cm distance exceeds the inner radius and equals the outer radius.
- `q-spatial-abstract-reasoning-labeling-overlap-regions-0001`: D. The midpoint is 3 cm from each center, which puts it inside each 5 cm radius.
- `q-spatial-abstract-reasoning-labeling-overlap-regions-0002`: A. Position 6 lies within the span of R only, and the height of 1 lies between 0 and 3.
- `q-spatial-abstract-reasoning-labeling-three-shape-regions-0001`: C. The distance of 4 cm is greater than the radius of A and less than the radii of B and C.
- `q-spatial-abstract-reasoning-labeling-three-shape-regions-0002`: C. Position 3 lies within A and B and to the left of C. The height of 2 fits both A and B.
- `q-spatial-abstract-reasoning-matching-dot-placement-0001`: C. The circle center lies inside the circle. The whole circle lies inside the square.
- `q-spatial-abstract-reasoning-matching-dot-placement-0002`: B. Every square side is 5 cm from the center. The circle extends only 4 cm from that center.
- `q-spatial-abstract-reasoning-matching-dots-outside-a-shape-0001`: C. The gap between the outlines lies outside A and inside B.
- `q-spatial-abstract-reasoning-matching-dots-outside-a-shape-0002`: C. The distance must exceed 6 cm and be below 8 cm. The choice 7 cm fits.
- `q-spatial-abstract-reasoning-matching-two-dots-0001`: C. The part of A beyond B fits P. The overlap fits Q. The frame encloses both regions.
- `q-spatial-abstract-reasoning-matching-two-dots-0002`: D. Two crossing circles each have a region outside the other circle, so both placements fit.

## Text Types split re-approval (November 20, 2026)

Policy revision: `546613581`. Three independent solvers received shuffled passages, stems, and choices without keys or explanations. All 100 existing questions matched. The solution rationale for each question follows. The items retain their original wording.

- `rc-tt-eea-0001` C. The report gives the inauguration details and attributes information to officials and records.
- `rc-tt-eea-0002` A. The lead identifies the agency press release as its source.
- `rc-tt-eea-0003` A. The report names its sources and describes the plans in a neutral voice.
- `rc-tt-eea-0004` C. Paragraph two names Engineer Cruz and the municipal disaster office records.
- `rc-tt-eea-0005` D. The paragraph reports plans for a second phase pending clearance.
- `rc-tt-eea-0006` D. The passage explicitly presents the fictional newspaper editorial board's position.
- `rc-tt-eea-0007` B. The opening identifies the criticism as the board's own position.
- `rc-tt-eea-0008` C. The board calls for fertilizer subsidies and floor prices for palay.
- `rc-tt-eea-0009` A. The board directly judges the policy and argues for changes.
- `rc-tt-eea-0010` D. The band-aid comparison expresses the board's judgment about emergency aid.
- `rc-tt-eea-0011` C. The narrator connects a childhood memory to a lesson for adult life.
- `rc-tt-eea-0012` C. The narrator recalls learning the craft and reflects on its lasting value.
- `rc-tt-eea-0013` B. The patience learned from weaving helps the narrator approach university deadlines.
- `rc-tt-eea-0014` B. The grandfather calmly undoes the work and models the patience he teaches.
- `rc-tt-eea-0015` A. The essay reflects on a personal lesson, while the editorial calls for policy changes.
- `q-text-types-essays-editorials-articles-0016` B. Rosa Manuel is named and presents a proposal in her personal capacity.
- `q-text-types-essays-editorials-articles-0017` C. The byline identifies Rosa as the person making the argument.
- `q-text-types-essays-editorials-articles-0018` D. Blocked sightlines give Rosa a reason to move the pickup area.
- `q-text-types-essays-editorials-articles-0019` A. Rosa proposes a trial with observation and addresses the concern about walking farther.
- `q-text-types-essays-editorials-articles-0020` B. Attributing the proposal to Rosa and reporting responses would turn the proposal into the subject of the report.
- `rc-tt-po-0001` A. Shore rhymes with oar, and gray rhymes with day.
- `rc-tt-po-0002` B. The line uses like to compare the sea to a mother.
- `rc-tt-po-0003` D. The ocean is said to whisper, a human action.
- `rc-tt-po-0004` B. The gold imagery and the bountiful reward suggest appreciation.
- `rc-tt-po-0005` A. The rising sunlight makes the sea look gold.
- `rc-tt-po-0006` A. Like makes the comparison between flowing threads and a mountain stream explicit.
- `rc-tt-po-0007` D. The shuttle is said to dance, a human action.
- `rc-tt-po-0008` C. Room rhymes with bloom, and hour rhymes with power.
- `rc-tt-po-0009` C. The image suggests the weaver carries forward skills from earlier generations.
- `rc-tt-po-0010` D. The floral pattern shows simple cotton becoming a work of art.
- `rc-tt-po-0011` A. Like makes the comparison between the rain and a silver cloak explicit.
- `rc-tt-po-0012` B. The steady beat describes the sound of the rain.
- `rc-tt-po-0013` A. Heavy clouds open the poem, and sunlight and hope close it.
- `rc-tt-po-0014` D. The image describes rainwater shining as it runs over the pavement.
- `rc-tt-po-0015` D. The clearing skies accompany a shift from worry to hope.
- `q-text-types-poetry-0016` A. Each repetition asks people to make way for others using the market.
- `q-text-types-poetry-0017` D. As means when or while here and signals when to leave room.
- `q-text-types-poetry-0018` B. The line endings follow no fixed rhyme pattern.
- `q-text-types-poetry-0019` C. The smell of ginger adds a sensory detail to the market scene.
- `q-text-types-poetry-0020` C. All of them refers to the market users just listed, and the final line calls for an open passage.
- `rc-tt-sn-0001` D. Pride makes Mateo swing too fast for the work.
- `rc-tt-sn-0002` A. The crack ends his attempt and prompts Tomas to step in.
- `rc-tt-sn-0003` D. Tomas uses the broken blade to teach patience.
- `rc-tt-sn-0004` D. Tomas brings fresh steel and tells Mateo to heat it.
- `rc-tt-sn-0005` A. Tomas's advice connects patience with learning the craft.
- `rc-tt-sn-0006` A. The rules call for action, but the wet ladder makes reaching the latch dangerous.
- `rc-tt-sn-0007` B. Rain, darkness, and slick surfaces make the task hazardous.
- `rc-tt-sn-0008` B. Securing the harness shows that he is getting ready to climb.
- `rc-tt-sn-0009` D. He takes steps to secure the latch despite the storm.
- `rc-tt-sn-0010` B. The excerpt ends before he reaches or secures the latch.
- `q-text-types-short-stories-and-novels-0011` C. Her hesitation over the chair shows her struggle to acknowledge Noel's absence.
- `q-text-types-short-stories-and-novels-0012` D. She makes space for the empty chair and starts dialing Noel's number.
- `q-text-types-short-stories-and-novels-0013` A. Her hesitation shows mixed feelings, and her decision to call shows change.
- `q-text-types-short-stories-and-novels-0014` A. Lina sees that her accounts are correct and that her words still caused hurt.
- `q-text-types-short-stories-and-novels-0015` A. She starts dialing, and the excerpt ends before any response.
- `q-text-types-short-stories-and-novels-0016` C. Water entering the shop shows the immediate flood threat.
- `q-text-types-short-stories-and-novels-0017` A. The photo reminds him that his father owned the shop and why finishing matters to him.
- `q-text-types-short-stories-and-novels-0018` A. The narration follows Ben and tells us how leaving a job unfinished feels to him.
- `q-text-types-short-stories-and-novels-0019` D. He leaves for safety even though he wants to finish the repair.
- `q-text-types-short-stories-and-novels-0020` C. He looks back and can still picture the flood line as he leaves.
- `rc-tt-sp-0001` C. Three clauses start with “We” and follow the same pattern.
- `rc-tt-sp-0002` D. The direct address makes the graduates part of the call to serve.
- `rc-tt-sp-0003` C. Firsthand care for injured neighbors establishes credibility.
- `rc-tt-sp-0004` A. The speaker urges graduates to serve their communities and lead the country.
- `rc-tt-sp-0005` C. The graduates' past effort shows what they can carry into future work.
- `rc-tt-sp-0006` B. Repeating “Together we” makes restoration a shared responsibility.
- `rc-tt-sp-0007` B. The greeting identifies the listeners and places the speaker in their community.
- `rc-tt-sp-0008` B. Thirty-five years of fishing gives the speaker firsthand knowledge of the bay.
- `rc-tt-sp-0009` B. The reference to children draws on concern for future generations.
- `rc-tt-sp-0010` C. The speaker addresses listeners directly and asks them to act together.
- `q-text-types-speeches-0011` C. The speech opens the archive and asks visitors to share what they know.
- `q-text-types-speeches-0012` B. Working as the school librarian gives the speaker relevant experience with records.
- `q-text-types-speeches-0013` D. The repetition thanks those who helped and asks listeners to keep sharing.
- `q-text-types-speeches-0014` A. The archive labels details that are uncertain.
- `q-text-types-speeches-0015` A. The speech welcomes visitors, explains the archive, and asks for contributions.
- `q-text-types-speeches-0016` C. The speaker asks for a trial of separate pickup times for packed lunches.
- `q-text-types-speeches-0017` D. The speaker reasons that separating ready orders could ease congestion at the main counter.
- `q-text-types-speeches-0018` A. The question underlines the need to check whether the trial helps.
- `q-text-types-speeches-0019` C. A student rushing through a meal shows what waiting costs a person.
- `q-text-types-speeches-0020` B. The speaker makes any continuation depend on the trial results.
- `rc-tt-vm-0001` A. Ten of twenty entries are uncovered water drums, the largest count.
- `rc-tt-vm-0002` B. The icons show concrete actions people can take to prevent dengue.
- `rc-tt-vm-0003` A. Yellow contrasts with the blue background and draws attention to the warning.
- `rc-tt-vm-0004` A. The headline urges prevention and the icons show how to act.
- `rc-tt-vm-0005` D. The bottom banner names the school health desk.
- `rc-tt-vm-0006` D. The boulder is labeled as fuel price increases and burdens the driver.
- `rc-tt-vm-0007` B. The importers watch calmly from the safety of the mountaintop.
- `rc-tt-vm-0008` D. The huge cost boulder and tiny empty purse show costs overwhelming earnings.
- `rc-tt-vm-0009` C. The clouds above the commuter skyline suggest commuters also face trouble.
- `rc-tt-vm-0010` C. The sign points away from the uphill route the driver is taking.
- `q-text-types-visual-media-0011` A. February's seventy is below April's ninety and above March's sixty and January's fifty.
- `q-text-types-visual-media-0012` A. Starting the bars at forty makes the gap take up more of their visible lengths.
- `q-text-types-visual-media-0013` C. Sales fall from seventy in February to sixty in March, then reach ninety in April.
- `q-text-types-visual-media-0014` B. The clearly labeled nonzero axis helps emphasize changes over time.
- `q-text-types-visual-media-0015` D. Showing the same figures at different scales reveals how scale changes the visual comparison.
- `q-text-types-visual-media-0016` B. Gio needs the timetable after his club poster helped set off the crowding that hid it. Wording flag: B says “his posters,” but the passage only confirms Gio fastens one poster. B is still the single best answer.
- `q-text-types-visual-media-0017` C. The earlier panels show the decisions that lead to Gio's embarrassment.
- `q-text-types-visual-media-0018` C. The poster's larger lettering pulls attention away from the timetable.
- `q-text-types-visual-media-0019` D. Students each add a poster until the official timetable is hidden.
- `q-text-types-visual-media-0020` D. The pile of posters visibly answers where the timetable went.

### Text Types pool-gap questions

A separate solver received only the 23 new questions with shuffled choices. `merge_solves.py` recorded 23 matches, zero mismatches, and zero low-confidence answers.

- `q-text-types-essays-editorials-articles-0021` C. Iniuulat nito ang araw at lugar ng paligsahan batay sa abiso ng paaralan.
- `q-text-types-essays-editorials-articles-0022` D. Tahasang sinabi ni Ana Cruz na dapat sana ay may bubong.
- `q-text-types-poetry-0021` B. The first two lines say when and where the speaker left the key.
- `q-text-types-poetry-0022` C. “Light” and “bright” rhyme within the first line.
- `q-text-types-poetry-0023` A. “Blue,” “beads,” and “brushed” all start with the consonant sound /b/.
- `q-text-types-short-stories-and-novels-0021` A. The narrator tells what Mina is sure of and shows Joel through his outward actions.
- `q-text-types-short-stories-and-novels-0022` B. Short sentences isolate the two clicks and build tension around the unexplained sound.
- `q-text-types-speeches-0021` C. A radio station sends the bulletin to a listening audience.
- `q-text-types-speeches-0022` D. Lito and Tess talk directly to one another.
- `q-text-types-speeches-0023` B. The student asks a clerk for help in a polite two-way exchange.
- `q-text-types-speeches-0024` D. The speaker prepares the main points and decides how to phrase them during delivery.
- `q-text-types-speeches-0025` C. The host uses a polite question to ask the front row to move.
- `q-text-types-speeches-0026` A. The brother commits to driving Tess when she is ready.
- `q-text-types-speeches-0027` A. A survey on bus colors gives no evidence about how far students walk.
- `q-text-types-speeches-0028` C. The documented fall can evoke concern and the inspection gives evidence about the rail.
- `q-text-types-speeches-0029` D. The memory helps the crowd honor the player during the tribute.
- `q-text-types-speeches-0030` C. Familiar words and an example give the listener the meaning she is missing.
- `q-text-types-speeches-0031` C. Restoring the sound and repeating the time supplies what the audience missed.
- `q-text-types-visual-media-0021` C. The “Paperless Office” label sets an expectation that the pile of printed forms contradicts.
- `q-text-types-visual-media-0022` C. The number rose from 10,000 on Monday to 12,000 on Wednesday.
- `q-text-types-visual-media-0023` B. Ninety degrees is one quarter of the circle, and one quarter of 80 is 20.
- `q-text-types-visual-media-0024` B. West went from 27 on Tuesday to 24 on Wednesday, a drop of three.
- `q-text-types-visual-media-0025` B. The afternoon entry for Garden B is 18, and the unit in the heading is liters.

### Grid polygon figures

Policy and content tools `fd6789a45314d18dbfd62e265691368c970e3779`. Content base `b85c6fcda339d0c821773f278c067cb2a0fb7bd8`. Renderer `a0dad3cfbafdb740f4a71150a7e99f826c5b13b4`.

A separate solver received only the four stems, shuffled choices, and proposed figure data. The packet used `render_packet` and `shuffled_order` from `tools/content_rewrite/question_check/build_packets.py`. Packet SHA-256 `b3d8a49b5112728066ef03c8d77a9eb7877405141c0e6864029f058fb0519a0d`. `merge_solves.py` recorded 4 matches, 0 mismatches, 0 low-confidence answers, and 0 missing or invalid answers. Letters below follow the shuffled packet.

- `q-geometry-practical-measurement-0006` E. The rectangle and triangle give 20 + 6 = 26 square units.
- `q-geometry-practical-measurement-0012` A. Subtract the corner triangle from the surrounding rectangle to get 30 − 3 = 27 square units.
- `q-geometry-practical-measurement-0016` E. P has area 24 − 4 = 20. Q has area 25 − 5 = 20. The figure remains pending because PR #77 scales the two grids independently. At 358 logical pixels of available width, P uses about 25.83 per cell and Q uses 31. The stem says the grids have the same unit spacing.
- `q-arithmetic-number-sense-counting-and-digit-patterns-0014` A. Removing the corner breaks one square of each size. The complete grid has 30, leaving 26.

`tool/content/approve.dart` exited 0 for 0006, 0012, and the counting question 0014. `lesson_checks.dart`, `content_gate.dart`, and main's question validator each exited 0. The content patch SHA-256 from `git diff --binary -- content` is `bc2ca1cfe53086956a5b1ff8a96ef8f8f95ec089167d2845336b9e8f0e11e1c5`. The export SHA-256 is `2c058a7d1037e324d0557a6d1eb80bfd89e9194cc2b096ad56e96b37da206b51`.

The main export gained exactly the three reapproved IDs and lost none. The validator, export, seed SQLite database, and offline upload files preserved the three specs as structured data. The export and seed omit 0016. The offline uploader still includes its existing slug-only row because it reads question YAML directly. Check logs and the blind packet are in `/private/tmp/cet-grid-figures.aR9VC6`.
