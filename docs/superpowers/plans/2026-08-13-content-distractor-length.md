# The correct answer is too often the longest one

> **How to work this plan.** One file at a time. Commit after each file.
>
> **Required reading before you start:** `AGENTS.md` in full.
>
> **Follow the plan. Do not redesign.** If a question cannot be fixed under
> these rules, **skip it and list it in your report.**

**Goal:** Make the length of a choice stop giving the answer away.

**The measurement, from `tools/audit/sweep_questions.py`:** in **403 questions**
the correct choice is more than half again longer than the longest wrong one. A
student can score above chance by picking the longest without reading the
question, which measures nothing and teaches nothing.

| Subject | Flagged | Of |
|---|---|---|
| Science | 193 | 777 |
| Language Proficiency | 104 | 319 |
| Reasoning | 82 | 244 |
| Mathematics | 24 | 713 |
| **Reading Comprehension** | **0** | 192 |
| **General Information** | **0** | 156 |

**Reading Comprehension is zero because it was already fixed** in the revision
pass of 4 August, by lengthening the distractors. **That is the remedy. It
works, and it has been applied to one subject out of six.**

---

## The rule that decides every edit here

**Lengthen the distractors. Do not shorten the correct answer.**

An explanation that has to be short stops explaining. The correct choice usually
earns its length by being precise, and cutting it makes the question worse in
order to make a number smaller.

A worked example, from Modifiers:

> Correct: *"Covered in cheese is misplaced, making it sound like the customer
> is covered in cheese; it should read The waiter served the customer the pasta
> covered in cheese."* (150 characters)
>
> Distractors: *"There is no error in this sentence."*, *"Served should be
> changed to serves."* (30 to 40 characters)

The fix is three fuller distractors, each a plausible wrong diagnosis stated at
the same level of detail as the right one.

---

## What happened on the first attempt, 13 August

**A Pro run did 39 files and every one was thrown away.** It lengthened the
distractors by stuffing adverbs into them:

> "Yes: the time variable formally does not actually mathematically affect the
> final calculated power value in any given physical situation."
>
> "No: but this is functionally exclusively only because Machine B actually
> technically performed much more total mechanical work."

**That is worse than the problem.** A student spots the padded option instantly,
so the tell moves from length to noise. The plan already banned it, in the rule
below that says padding is worse than leaving it short, and the run did it
anyway.

**So the rule needs teeth: a lengthened distractor has to carry a new idea.** Not
new words. If you cannot name what the student who picks it believes, you cannot
lengthen it, and it stays short and gets reported.

**Read your own output aloud.** If it does not sound like the correct answer's
register, it is padding.

## The rules

1. **A distractor has to stay wrong.** This is the whole risk in this plan. A
   distractor lengthened carelessly becomes a second correct answer.
2. **A distractor has to stay plausible.** Padding it with filler is worse than
   leaving it short, because now it is long *and* obviously wrong.
3. **Never touch the correct choice.**
4. **Never touch the stem, the explanation or any rationale.**
5. **Aim for every wrong choice to be at least two thirds the length of the
   correct one.** That is what clears the sweep. Do not pad to hit a number: if
   a distractor cannot carry more content honestly, leave it and report it.
6. **Grade-5-simple English, American spelling, no em dashes.**
7. **Never invent a figure.**

---

## The check you must run

```bash
python3 tools/audit/sweep_questions.py | grep QLONGEST | grep <your-subject>
```

Run it before you start, to see your list, and after each file. **The count for
a file you finished must be zero, or the questions you left must be in your
report with a reason.**

Never run `flutter test` with no arguments, `flutter analyze`, or
`dart run build_runner`.

---

## Scope

**Your subject is named in the dispatch prompt.** Do that subject and stop.

- [ ] **Step 1: List the flagged questions in one file.**
- [ ] **Step 2: For each, rewrite the wrong choices only.**
- [ ] **Step 3: Re-run the sweep for that file.**
- [ ] **Step 4: Commit that file alone**, naming the file and the count fixed.

---

## What to report

- Files finished, and how many questions each cleared.
- **Every question you left flagged, with the reason.**
- **Any distractor you were tempted to make correct.** That is a question with a
  weak answer key and it is worth more than the length fix.
- The sweep output after your last commit.
