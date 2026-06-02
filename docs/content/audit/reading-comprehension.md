# Reading Comprehension — Audit Findings

Lessons read: 13 across comprehension-skills (8), text-types (5). Passage
presentation is generally strong (e.g. `main-idea.md` has a clear
supporting-detail placeholder and well-built passages).

## Illustration gaps

### READ-TXT-001 [important, prioritize] visual-media.md — images are load-bearing but mostly absent
Evidence: `text-types/visual-media.md` teaches interpreting comic strips,
editorial cartoons, and graphs, yet carries only 1 placeholder for 4
figure-based examples (#1 comic strip, #2 editorial cartoon, #3 bar graph,
#4 misleading graph scale). The examples substitute a prose description of
the visual, which partly defeats the skill being taught — a student should
read the visual itself, not a paragraph about it.
Fix: add a placeholder per example (the comic strip, the cartoon, both
graphs). This is the single most image-dependent lesson in the corpus;
treat it first in the illustration phase. Consider marking the style guide
exception that here the image is legitimately load-bearing.

## Coverage vs benchmarks
Complete for CET reading skills. comprehension-skills covers main idea,
title, details, inference, fact vs. opinion, author's purpose/tone/POV,
context clues in passages, and sequencing. text-types covers essays/
editorials/articles, short stories/novels, poetry, speeches, and visual
media. No missing CET-tested reading skill.

### READ-TXT-002 [important] no Filipino passage in text-types
Evidence: all five text-types lessons use English passages only. UPCAT and
USTET present Filipino reading passages. Confirms OUTLINE-002.
Fix: add at least one Filipino passage example (e.g. a short talata under
essays or short-stories) so the student practices Filipino comprehension.

## Template fit — proposal for Reading Comprehension
Reading lessons do not compute, so "Speed Tricks & Shortcuts" reads as
"reading strategies" — which is fine and genuinely useful here (e.g.
"underline time-signal words as you read"). Recommend the style guide allow
the title **"Reading Strategies"** as an alias so the section name matches
its content. No structural problem otherwise; passages + questions +
strategies + traps is a good shape for this subject.

## Dismissed sweep lines
- `DEVICE blocker … sequencing-of-events.md:64` — "Underline every
  time-signal word first" is a study instruction telling the student to
  underline as they read; it does not reference an underlined word in a
  question. False positive.
- `ILLUS … fact-vs-opinion.md:41` — the example is a single prose sentence
  about a stadium's cost; no figure is needed. False positive.
- `ILLUS … essays-editorials-articles.md:53` — two short prose passages
  compared as text; no figure needed. False positive.
