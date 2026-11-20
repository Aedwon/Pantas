# CET Text Types split

Policy revision: origin/main `546613581`. The requested policy files match the current origin/main copies.
Retired originals: essays-editorials-articles, poetry, short-stories-and-novels, speeches, and visual-media.
Created 31 parts. Teaching-word counts by original and part, in order:

- essays-editorials-articles: news-reports-and-attribution (370), editorials-and-individual-opinions (414), essay-purposes-and-analysis (388), balita-at-opinyon (161).
- poetry: figurative-comparisons-in-poems (353), line-breaks-and-plain-meaning (238), poetry-rhyme-patterns (310), poetry-sound-and-rhythm (266), poetry-images-symbols-and-tone (446).
- short-stories-and-novels: story-plot-and-turning-points (377), story-character-traits-and-change (397), story-conflict-types (437), story-narrator-and-viewpoint (203), story-setting-style-and-mood (241), story-theme-from-text-evidence (189).
- speeches: speech-audience-and-purpose (359), speech-context-types (240), speech-style-and-preparation (447), speech-acts-in-context (201), speech-rhetorical-appeals (437), judging-evidence-in-speeches (406), fair-emotion-in-speeches (251), speech-rhetorical-devices (349), speech-breakdowns-and-repairs (256).
- visual-media: reading-comic-panels (279), interpreting-editorial-cartoons (260), contrast-and-irony-in-cartoons (233), reading-bar-chart-scales (319), reading-line-chart-changes (227), reading-pie-chart-shares (194), matching-table-rows-and-columns (216).

- Preserved all 100 original questions with new lesson and key-point tags. Added 23 pool-gap questions. All 123 blind answers matched and all 123 questions are approved.
- All 31 parts cover every key point and meet quizSize for each exam served by their question file. All targets are 2. Visual Media has no CSE-tagged questions in this branch.
- Moved 11 markers (9 ILLUSTRATION and 2 FIGURE). Copied 9 SVGs byte for byte. The plot and speech FIGURE markers had no files. All 31 parts have zero em dashes.
- Added outline rows and prerequisite links. Five additional helpful links preserve existing wrong-choice feedback routes. All part ordering values are 0 for the lead’s renumbering pass.
- Scoped non-pool lesson check failures: none. `lesson_checks.dart`, `content_gate.dart`, and the question importer exited 0.
- Export and asset export passed with 1,148 links and 204 tags. Functions build, 33 uploader tests, upload dry run, local upload document generation, seed build, and scratch package verification passed.
- Custom tier generation and repository checks passed. SVG preflight found 436 files and zero failures. Seven SVG tool tests passed and 29 bad fixture files failed as expected.
- Exact baseline comparison preserved all CSE question IDs and topic assignments: 1,753 CSE Pro and 1,523 CSE Sub.
- Offline probe: 4,608/4,608 mock papers filled across CSE Pro, CSE Sub, DCAT, USTET, ACET, and UPCAT. All 2,304 native Dart papers matched compiled JS. ACET’s existing blueprint was copied from main only into the scratch probe input.
- Existing wording issue: Visual Media question `q-text-types-visual-media-0016` says “his posters,” but the passage shows Gio putting up one. The best answer is still clear. The character part retains the old “Example 5” reference although its example is now #1.
- Global audit exited 1 on both baseline and candidate. Its fixed marker inventory rejects the copied markers required by the split. Logs are under `/private/tmp/pantas-tt-check`.
- Flutter SVG render and placeholder tests stopped before running: `Failed to create server socket (OS Error: Operation not permitted, errno = 1)`.
- Files touched: 36 in lessons/text-types, 5 in questions/text-types, 9 across 7 illustration folders, 3 in docs/content/bite-sized/cet, 1 verification doc, 1 ledger, 1 prerequisite file, and 1 outline.
```text
Error in reading-comprehension/text-types/contrast-and-irony-in-cartoons: unexpected illustration marker: public service counter with a sign reading "Fast Service"; a long line of tired people waits beside a large snail carrying a stack of forms toward the counter; no other text
Error in reading-comprehension/text-types/contrast-and-irony-in-cartoons: unexpected illustration marker: editorial cartoon with two side-by-side scenes featuring the same fictional official labeled "Official"; left scene shows the official with an extremely large mouth speaking into many microphones beside a sign "Public promises"; right scene shows the official with tiny hands beside a large pile of untouched repair requests and a sign "Public work"; keep the official's face and clothes recognizable in both scenes
Error in reading-comprehension/text-types/interpreting-editorial-cartoons: unexpected illustration marker: editorial cartoon showing a large boulder labeled "taxes" rolling downhill toward a small worried figure labeled "citizens"
Error in reading-comprehension/text-types/matching-table-rows-and-columns: unexpected illustration marker: table titled "Requests Handled" with column headings "Center", "Morning", "Afternoon"; row A has 24 and 30; row B has 18 and 27; row C has 32 and 28; note "All entries are numbers of requests"
Error in reading-comprehension/text-types/reading-bar-chart-scales: unexpected illustration marker: vertical bar chart titled "Monthly Sales"; horizontal labels January, February, March, April; vertical axis labeled "Sales (thousands of pesos)" from 0 to 100 in steps of 10; bars at January 50, February 70, March 60, April 90; no value labels above bars
Error in reading-comprehension/text-types/reading-bar-chart-scales: unexpected illustration marker: two bar charts comparing Brand A at 85 and Brand B at 81; left chart vertical axis runs from 80 to 86 in steps of 1 with bars drawn from 80; right chart shows the same values on a vertical axis from 0 to 90 in steps of 10; label the charts "Starts at 80" and "Starts at zero"
Error in reading-comprehension/text-types/reading-comic-panels: unexpected illustration marker: three-panel comic, panel 1 a man carefully building an elaborate sandcastle, panel 2 the completed castle with the man smiling, panel 3 a wave washing it away while the man watches with a resigned expression; no dialogue
Error in reading-comprehension/text-types/reading-line-chart-changes: unexpected illustration marker: line chart titled "Requests Received"; horizontal axis Monday, Tuesday, Wednesday, Thursday; vertical axis labeled "Requests" from 40 to 65 in steps of 5; points at Monday 50, Tuesday 60, Wednesday 55, Thursday 65 joined in time order
Error in reading-comprehension/text-types/reading-pie-chart-shares: unexpected illustration marker: flat pie chart titled "Ways Requests Were Sent"; sectors labeled "Online 180 degrees", "In person 120 degrees", and "Mail 60 degrees"; note below chart "Total: 120 requests"; sectors share the same radius
Error in reading-comprehension/text-types/speech-breakdowns-and-repairs: expected 0 code FIGURE markers, found 1
Error in reading-comprehension/text-types/story-plot-and-turning-points: expected 0 code FIGURE markers, found 1
```

FAIL for the full check run. The legacy audit and Flutter render/placeholder checks remain open. Text Types lesson, pool, approval, export, and mock checks passed. Topic ordering remains for the lead.
