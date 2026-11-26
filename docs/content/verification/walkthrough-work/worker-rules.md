# Worker rules: CSE lesson walk-through rewrite (lead: Claude lesson lead, E-198)

Startup: Work on `Aedwon/Pantas`. Retrieve `AGENTS.md`, `WORKFLOW.md` and `SUBAGENTS.md` from the current GitHub `main` branch (`git fetch origin -q; git show origin/main:<path>`) and follow them, regardless of the code branch. These shared rules supersede older project workflow instructions. Policy commit read by the lead: `a5888282f` (session 2, Nov 26 5:25 PM Manila). Record the policy commit you read in your report.

Worktree (shared with the lead and one other worker; touch ONLY your assigned files):
`/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1` (branch `content/lesson-walkthrough-cse-r1`).

## Hard limits

- Do not start subagents; do the work yourself.
- Change files only with the Edit or Write tool. Write any scratch file with the Write tool too.
- Bash only for plain read-only commands: grep, ls, cat, git show, git diff, git status, git log, date. No `>` or `>>` redirection (not even into scratch folders), no pipes into files, no sh, zsh, python, perl, awk or sed scripts, no zsh array or loop tricks, no heredocs. Any of these makes Aedwon approve a prompt, and a worker once sat 40 minutes on one (Nov 26). No git add, commit, push, stash, checkout or reset: the lead commits. Do not run the importer or count words; the lead runs both after you report.
- Edit only the lesson files assigned to you. Never edit question files (`content/questions/**`), never edit retired files, never touch non-CSE CET lessons.
- Never change the `:::` block syntax (agreed with the UX lead). Fences: `:::check` / `:::answer` / `:::`, `:::try` / `:::answer` / `:::`, `:::why`, `:::pair #slug` (lines `Right:`, `Wrong:`, then a 1 to 2 sentence note), `:::checklist` with only item lines `- Cue: right move {#slug}`. At most 3 pairs and 3 checklist items per lesson. Every checklist item ends with `{#slug}` naming a pair id or a `###` heading slug. Only `:::check` and `:::try` contain `:::answer`; nothing else nests.
- Do not change front matter except where the brief says so.
- Option lists (`A)` / `(A)` lines, and any lines meant to show on separate rows): put a blank line between them. The app's converters join a paragraph's lines with spaces, so lines that end in two trailing spaces still run together on screen. Remove trailing double spaces wherever you see them.

## The standard (read in full before editing)

- Spec: `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`, Part B "Authoring rules".
- Approved samples (the reference shape): `git show origin/tools/walkthrough-checks-r1:docs/content/walkthrough-samples/<name>.md` for `substituting-negative-numbers`, `signed-integer-operations`, `discounted-prices`, `finding-subjects-and-matching-verbs`.
- Process entry: `git show origin/main:docs/workflow/process-improvement.md`, entry "Walk-through examples still show math without saying where it comes from (Nov 26, repeat)" and the cut-pass line in "Wordy UI on a board again".

Aedwon's words on examples, in order: "notice what's missing here? there was not enough context given here. where's the expression from? ... the lessons should be clearly assisting the user to understand logic" / "for example: you could say, Let's substitute x=-2 to the terms 3x x^2 and 12/x, and that would be clearer" / "no that's too wordy now, you just made it wordy. i wanted you to connect things better, not explain with more words. those are entirely different asks" / on this target: "yes that's it!":

```
Let's substitute $x = -2$ into $3x$, $x^2$ and $\dfrac{12}{x}$:
$$3x = 3(-2) = -6$$
$$x^2 = (-2)^2 = 4$$
$$\dfrac{12}{x} = \dfrac{12}{-2} = -6$$
```

So:
1. Each worked example opens with ONE short lead-in that says what we are doing and to what. Every chain starts from its expression (or sentence) and ends at its value (or final sentence).
2. Connection, not more words. No added narration. A lesson's pre-tap word count must not grow (cut elsewhere if a lead-in adds words). Cut any line the reader would not miss.
3. Non-math lessons: the same with sentences. Name the sentence being worked on, show each move on its own line, end at the finished sentence.
4. Every `:::pair` must match a real wrong choice in the quiz bank for that lesson: a non-correct choice, quoted exactly, from a question whose `lesson:` is this lesson. The pair's Wrong line shows that mistake. Record each citation (question id, exact wrong choice text, one-line mistake note) in your report.
5. A `:::try` or a later step must never give away the answer the reader is asked to find. The try's `**Check:**` sits inside its `:::answer`.
5a. Every `:::check` and every `:::try` uses a fresh instance of a rule the lesson already taught: never a word, sentence, number set or passage line already worked or stated earlier in the lesson (core lines, pairs, why blocks, earlier checks, visible steps, headings). The approved sample teaches "The dog barks" and checks "My sister *(teach / teaches)* in Cebu". A try must never test something the lesson has not taught.
6. Lesson prose: plain English a Grade 5 student can follow. American spelling. No em or en dashes. `\dfrac`, never top-level `\frac`. Math between single dollars. No ALL-CAPS emphasis. No "crucial", "delve", "it's important to note", "furthermore", "moreover", "not just X but Y".
5b. Example headings are neutral: a heading never names the label, form or reason the try asks for.
7. Never state a rule more broadly than it holds. A list of affixes, markers or uses is marked as examples ("halimbawa", "karaniwan", "such as") unless it is complete. A rule with real exceptions names its scope. Every rule you state must be true. For grammar and usage, check against a standard reference (Cambridge Grammar, British Council, Purdue OWL, Merriam-Webster) when in doubt, and do not overstate a rule as universal.

## Filipino lessons

Rules: `git show origin/main:docs/content/lesson-style-guide.md`, section "Filipino-language lessons". Key points:
- Teaching prose in simple Filipino at the Grade 5 standard. Examples and in-lesson quiz items in Filipino. No Taglish in teaching prose.
- **Aedwon's Oct 4 decision (option 1): a hard grammar term gets a short English gloss the first time it appears, `**pang-abay** (adverb)`, then the Filipino term alone.** An earlier audit wrongly asked for all glosses to be removed and they were stripped. Restore a first-use gloss for each hard grammar term (pokus, tagaganap, layon, panghalip, pandiwa, sugnay, hugnayan, langkapan, unlapi, gitlapi, hulapi, kabilaan, laguhan, and the like), once per lesson, at its first use in teaching prose. Do not gloss common words, and do not gloss a second time. Do not gloss a term whose English gloss would only repeat an obvious cognate (aspekto/aspect, pokus/focus, kontemplatibo/contemplated); give the meaning instead where one helps (kontemplatibo: "not yet begun"), or leave the Filipino description to carry it. Do not add glosses inside headings, quiz stems or example sentences.
- Spelling and usage follow the Komisyon sa Wikang Filipino (KWF) and the Ortograpiyang Pambansa (2013). For ng/nang, din/rin, raw/daw, affixes: follow KWF.

## Checks

Workers run no checks. After you report, the lead runs the importer parser (the app's real lesson parser), the pre-tap word count (words outside `:::answer`, `:::why` and HTML comments) and `lesson_checks.dart` on your files, and sends back anything that fails. So keep the structure exact by reading, and keep word growth near zero: when you add a lead-in or a scope word, cut a line the reader would not miss in the same lesson, and list what you added and cut.

## Report (short)

Pass or fail per lesson; for each finding you were given: fixed how (one line) or why not. Citations for any pair you added or changed. Words added and cut per lesson. Files touched. Anything you could not resolve goes to the lead; do not guess.
