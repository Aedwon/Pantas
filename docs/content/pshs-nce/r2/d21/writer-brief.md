# Writer brief: seven new PSHS-NCE-only lesson parts (D21)

You write seven new short lesson parts for Pantas, a Philippine exam review app. The student is a Grade 6 applicant (about 11 to 12) preparing for the Philippine Science High School National Competitive Examination (PSHS-NCE). Write only the seven new lesson files. Change no existing file.

Read first, in full: `docs/content/lesson-style-guide.md`; `docs/content/rewrite/cet/writer-rules.md` (CET-specific parts do not apply); the ruling "Nov 21: D21 and D22" in `git show origin/main:docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`; the items below in `docs/content/pshs-nce/reviewer-transcript.md` and their lines in `docs/content/pshs-nce/map-summary.md`; the existing parts in the folder you write into, to match front matter and format (for example `content/lessons/science/chemistry/phase-change-directions.md`); `docs/content/pshs-nce/source.md` (disputed keys).

The seven parts, one idea each:
1. II-10: punctuating interrupted dialogue (a quotation split by a speaker tag), and punctuation inside quotation marks. Folder `content/lessons/language-proficiency/grammar-and-structure/`.
2. II-13: "with" for companionship (doing something together with someone), against similar prepositions. Folder `content/lessons/language-proficiency/language-application/` or grammar-and-structure, whichever holds the preposition parts.
3. II-14: "excited about" and "nervous about": adjectives that take "about", against "excited for", "nervous of" and similar. Same folder choice as 2.
4. II-16: "did not" plus the base verb ("did not want", never "did not wanted"). Folder grammar-and-structure. Teach the rule; do not mention or use the sample item's official key, which is disputed.
5. III-10: reading a phase diagram: the regions for solid, liquid and gas, the lines where two phases exist together, and the point where all three meet, using only the labels printed on the diagram. Folder `content/lessons/science/chemistry/`.
6. III-12: comparing places on a latitude map: places at similar latitude get similar sunlight, so similar climate is likely, while altitude, nearness to the sea and winds still matter. Folder `content/lessons/science/earth-science-astronomy/`.
7. III-15: how mangroves trap sediment and pollutants from land runoff and so help protect coral reefs farther out. Folder `content/lessons/science/biology/`.

Rules:
- Each part stands alone. Front matter like the existing parts (`_id`, title, summary, subject, topic, isActive, keyPoints), but do not set `part` or `partCount`, and set `ordering` to a value no other lesson in that topic uses (check the folder). Do not edit any existing file, including other parts' ordering.
- 1 to 3 key points each. About 200 to 400 teaching words. Sections per the style guide for the subject. At least one fully worked example per key point, built like the sample item type but with new content. Never copy an official item.
- Grade 5 English in teaching prose. Every general statement true at its boundary cases; state the condition when there is one.
- A part about reading a diagram (5, 6, 7) needs its diagram: describe it in words exactly enough to solve each example, and add an ILLUSTRATION marker for it in the style guide's format. Say in your final message which parts need a figure.
- About the exam, say only that the official PSHS sample has items like this. No em dashes. American spelling.

When done, run `python3 tools/audit/run_all.py` and report only the lines naming your files. Fix structure errors in your files, except illustration-inventory messages for new markers.

Final message: each path, its id, word count, key points, and whether it needs a figure.
