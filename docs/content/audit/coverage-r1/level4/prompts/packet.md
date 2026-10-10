# Pantas Level 4 lesson audit, packet {{PACKET}}

## Your job

You audit one lesson of the Pantas exam review app against its lesson standards.
You report findings. You change nothing.

- This packet holds everything you need: the rules, the standards text, the
  lesson, and the lessons it depends on.
- Judge the lesson only from this packet. Do not open any other file, packet,
  issue, or pull request in any repository, apart from the relay instructions
  your assignment names. Another reader is checking the same lesson separately,
  and the audit depends on the two of you not seeing each other's work.
- Every verdict is yours. Do not ask the user anything.
- You finish by handing in one form. Your chat reply is not read by anyone.

## How to judge

Work through the rules in the table below, one at a time, against the lesson
between the `LESSON START` and `LESSON END` markers.

1. **Read the lesson in full first**, then the prerequisite lessons.
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
   as explained if this lesson explains it, if a prerequisite lesson below
   teaches it and this lesson gives a short reminder or reference, or if this
   lesson clearly points to its own later section and gives enough meaning to
   follow until then. A mere earlier mention is not an explanation.
8. **Learning goal (L01).** The goal is in the Level 3 record below. Judge
   whether the lesson serves it.
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

## How to hand in

Your assignment gives your role (`A`, `B`, or `D`) and your attempt number. Put
the role in the form's `role` field. Wherever `ROLE` or `ATTEMPT` appears in the
two requests below, replace it with your role and your attempt number, exactly.

The form travels as one JSON string inside the request body. Every backslash in
it must be doubled and every double quote escaped. Lessons are full of LaTeX
backslashes, so do not write that string by hand. Build the form as an object
and serialize it with a JSON encoder, then put the result in `content`.

Step 1. Save your form. Create one Issue in `Aedwon/chatgpt-terminal-relay`
titled `[relay] {{TOKEN}} hand-in` with this body, where `content` is your whole
form as one JSON string:

```json
{"relay_version": 2, "action": "workspace_write_file", "workspace": "{{WORKSPACE}}", "path": "{{INBOX}}/{{PACKET}}-ROLE-ATTEMPT.json", "content": "<your form>"}
```

Step 2. Have it checked. Create one Issue titled `[relay] {{TOKEN}} hand-in`
with this body:

```json
{"relay_version": 2, "action": "workspace_exec", "workspace": "{{WORKSPACE}}", "argv": ["python3", "{{HANDIN}}", "{{PACKET}}", "ROLE", "ATTEMPT"], "timeout_seconds": 120}
```

Step 3. Read the result comment on the second Issue.

- `ACCEPTED`: you are done. Publish your completed worker event. Its `summary`
  says only "form accepted" and nothing about the lesson or your verdicts.
- `REJECTED`: the comment lists numbered reasons. Fix exactly those in your
  form, then repeat steps 1 and 2 with the corrected form. You get one retry
  after a rejection.
- `HELD` or `STOPPED`: stop. Publish a blocked worker event with the word from
  the comment as the blocker. Do not hand in again.
- `BAD REQUEST`: the check did not recognize your hand-in, or found no saved
  form. Do not guess and do not try again with other values. Stop and publish a
  blocked worker event with `BAD REQUEST` as the blocker.

What the check enforces:

- At most one retry after a rejection. A form that is not valid JSON gets a few
  more tries, because that is a transport slip.
- Every quote is at least 8 characters, is copied exactly from the lesson, and is
  not a bare heading.
- Every `problem` and every accuracy `concern` is at least 20 characters.
- Every `note` and every `checked` item that counts as proof is at least 15
  characters.
- `not_applicable` is allowed only on L03, L14, L21, L23, and L08 to L12.
- Empty values are `[]` and `""`, never `null`.
- A rule that passes or is not applicable has no findings.
- Do not reuse one `checked` text across several rules. Say what you checked for
  each rule.

Make no other relay request. Do not edit, create, or delete any other file.

## The form

Fill this in. Keep every key. Do not add or remove rules.

```json
{{FORM}}
```

## The rules on this form

Severity: a Blocker is a wrong fact, a wrong or ambiguous answer, or required
content missing. A Major breaks a rule in a way that hurts learning. A Minor is
style or formatting.

{{RULES}}

## Standards text: lesson style guide

{{GUIDE}}

## Standards text: expected knowledge in example questions (rule L05)

{{EXPECTED}}

## Standards text: voice and math rules

{{VOICE}}

## Level 3 record for this lesson

{{LEVEL3}}

## Script candidates

{{CANDIDATES}}

## Prerequisite lessons

These are context for L25 to L27 only. Do not audit them.

{{PREREQUISITES}}

## The lesson to audit

{{LESSON}}
