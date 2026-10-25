## How to judge

Work through the rules in the table below, one at a time, against the lesson
between the `LESSON START` and `LESSON END` markers.

1. **Read the lesson in full first**, then its brief, then any prerequisite lessons given.
2. **Give every rule in the form a verdict:** `pass`, `fail`, or
   `not_applicable`. Rule L11 is the one exception: use `needs_source_check` if
   the lesson contains Filipino text, or `not_applicable` if it does not. You
   cannot confirm Filipino spelling against the official source from here.
3. **A fail needs evidence.** Each finding has a `quote` copied exactly from the
   lesson (at least 8 characters, from between the markers, no paraphrase and no
   ellipsis) and a `problem` saying what breaks the rule and why. When something
   is missing, quote the place where it was needed.
4. **A pass on a Blocker or Major rule needs proof.** In `checked`, list what
   you checked in this lesson, concretely. For L17, name each formula an example
   uses and where Core Concept introduces it. For B02, give your own answer to
   each worked example. "Looks fine" is not proof.
5. **`not_applicable` needs a `note`** saying why the rule cannot apply here.
6. **Solve before you read.** For B02, work each example from its question
   alone, then compare with the lesson's solution.
7. **Explanation reuse (L25, L26, L27).** A term, concept, or condition counts
   as explained if this lesson explains it, if a prerequisite lesson given
   teaches it and this lesson gives a short reminder or reference, or if this
   lesson clearly points to its own later section and gives enough meaning to
   follow until then. A mere earlier mention is not an explanation.
8. **Brief items.** The brief lists what the rewrite had to fix or add. Give
   every brief item a status in `brief_items` (see "Brief items" below).
9. **Script candidates.** If the form includes B07, B08, B09, B10, L13, or L16,
   a script flagged lines for you under "Script candidates". Decide which
   flagged lines truly break the rule. Subject-matter uses do not: "marks" as
   punctuation, a playing card, the stability of an atom.
10. **Judge the rule as written.** Do not invent stricter rules, and do not
    excuse a clear breach. If you are unsure, say so in the `problem` or the
    `checked` text and choose the verdict the evidence supports best.

### Illustration review

Separately from the rules, judge the lesson's illustrations. Add one entry to
`illustrations` for each case:

- `missing`: a figure would improve understanding and none is there.
- `insufficient`: a placeholder or figure exists but does not do the job.
- `unneeded_existing`: an existing figure or placeholder is decorative.

For each entry give `position_quote` (exact lesson text at the spot),
`description` (one line an artist could draw from), `why` (how it helps the
student), `priority` (`high`, `medium`, `low`), `method` (`code` for a figure
that can be drawn in code, `library` for a public-domain or open-licensed image,
`table_or_formula` when a table or formula would serve better than an image),
and `kind` (`exact_exam_figure` when the figure is what an exam question shows,
`concept` otherwise). Do not recommend decoration. An empty list is a valid
answer.

### Accuracy concerns

If you notice a fact or an answer that looks wrong, also add it to
`accuracy_concerns` with an exact `quote` and what looks wrong. An empty list is
a valid answer.

### Brief items

The brief for this lesson lists items the rewrite had to fix ("Fix these"),
teaching it had to add ("CSE teaching to add"), and optional items. The form's
`brief_items` object has one entry for each brief item id, already listed with an
empty status. For each entry:

- `status`: `fixed` if the lesson as rewritten no longer has the problem, or now
  teaches the missing idea. Otherwise `not_fixed`.
- `quote`: exact text from the rewritten lesson, at least 8 characters. For
  `fixed`, quote the text that shows the fix (for a removal, the text next to
  it). For `not_fixed`, quote the text that still has the problem, or the place
  where the missing teaching should be.
- `note`: at least 20 characters. Say what you checked. For `not_fixed`, say what
  is still wrong.

An optional item that the rewrite left alone is `not_fixed`. That is allowed. Do
not mark an item `fixed` unless you checked it in the rewritten text.
