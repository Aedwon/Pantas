# P6: roadmap links and gap tags for the CET lessons

November 9, 2026. Policy read from origin/main 1f6907c80. Spec: `docs/superpowers/specs/2026-11-03-cet-content-design.md`, P6. Aedwon, through the manager: "for the rest of items, please finish them".

## What

- `content/lesson-prerequisites.json`: add an entry for each of the 77 CET lessons in `final-run.json`. None has one today. The 90 CSE entries stay unchanged.
- `content/question-gap-tags.json`: add tags for wrong choices in those 77 lessons' question files where the mistake is a gap in a linked lesson. Existing tags stay unchanged.

## Rules (from the files' own `rule` text and the roadmap plan, R1-R2 section 1.4)

- **required**: the lesson cannot be followed without an idea the other lesson teaches and this lesson does not. **helpful**: the lesson is easier with it. Authored order is never a reason. Each link has a one-sentence `reason` naming the idea.
- A lesson that now teaches the idea itself, or only names the other lesson as optional review, gets helpful, not required. The rewrites added many local meanings, so recheck every audit link against the current text.
- No self links, no duplicates, no cycles over all links (required and helpful together).
- A required link must not leave an exam: every exam in the dependent lesson's question file `meta.exams` must also be in the target's. A helpful link may leave an exam; the engine ignores it there.
- A link may point to any lesson in the corpus, including CSE lessons.
- Gap tag: `{question id: {exact wrong-choice text: lesson id}}`. Only when the choice's mistake is a gap in that lesson, the lesson is a link target of the question's own lesson, the text matches exactly one choice, and that choice is not the correct one.

## Inputs

- The audit's necessary links: `p6/audit-lesson-prerequisites.json` (from `docs/content-coverage-audit-r1` at ecbfa88b, corpus 765c5dc0). Candidates only.
- Current lesson text, including the lesson's own "see the X lesson" pointers.
- The existing CSE entries, for the style and level of detail.

## Steps

1. Draft (Sonnet), one subject batch at a time: physics and mechanical reasoning (19); chemistry (15); biology (12); earth science and text types (13); mathematics (18). Each batch writes `p6/draft-<batch>.json` with `{"links": {...}, "gapTags": {...}}`. It does not edit the content files.
2. Lead review: every required link against both lessons' text; a sample of helpful links and gap tags.
3. Lead merges the drafts into the two content files, then runs `ruby tools/content_rewrite/check_cet_links.rb`.
4. Record counts in the final report.

## Known before P6

`check_cet_links.rb` on the unchanged files reports 3 errors, all in CSE question `rc-cs-ct-0005` (choosing-a-title): its three tagged choice texts no longer match any choice. That is CSE data, out of scope here; it goes on the final list.

## Result (November 9)

- Five Sonnet drafts, one at a time. Merged into the content files as additions only: the 90 CSE entries and 116 existing CSE tags are unchanged (diff shows only the two `rule` lines changed, to record the CET drafting).
- 77 CET lessons now have entries: 91 links, 8 required and 83 helpful. 27 lessons need no link.
- Required links, each checked by the lead against both lessons' text: friction-tension-and-inclines -> dynamics; mirrors-and-lenses -> light-and-optics; interference-diffraction-and-doppler -> waves-and-sound; stoichiometry -> mole-concept; meiosis-and-genetic-variation -> cellular-reproduction; human-body-control-movement-and-defense -> human-anatomy-physiology; laws-of-sines-and-cosines -> basic-trigonometric-ratios; trigonometric-identities -> basic-trigonometric-ratios. Most audit links became helpful because the rewrites now explain the idea locally.
- Gap tags: 105 drafted, 102 kept. Lead dropped the three acids-bases-ph tags (factor of 10 per pH step), because that lesson teaches the idea itself. Lead sampled the borderline tags (text types, solving right triangles, unit circle, circles); each matches a gap the target lesson teaches.
- `check_cet_links.rb`: no new errors. The only errors are the 3 known CSE `rc-cs-ct-0005` ones. No cycles; no required link leaves an exam.
- Lead error during the merge: a first write re-sorted and reformatted the whole file; a second removed the existing CSE tag `q-text-types-visual-media-0015`. Both were caught in the diff and reverted before commit.
- No reader of these files exists on this branch. The content export on the roadmap lineage validates them when the branches meet.
