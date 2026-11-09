# Astra audit brief (P8)

You are auditing exam-review content for the Pantas app (students preparing for UPCAT, DCAT, USTET and ACET in the Philippines). You are read-only. You change no file. Another vendor's models wrote and read this content; your job is to find what they missed.

Repository: the current directory, branch `content/cet-finish-r1`. Read for context: `docs/content/rewrite/cet/reader-rules.md` (rulings that bind readers, including L18 for CETs and evidence classes) and, from `git show origin/main:docs/content/content-checklist.md`, the rule ids and severities.

For the one lesson named in the task:

1. Read the lesson file in full. Check every fact against what you know from standard sources (OpenStax, IUPAC, BIPM, NASA, standard school texts). Test every general statement ("only", "always", "never", "every", "all", "must", "the exception", each stated rule) against boundary values and known exceptions. Solve every worked example yourself from its question alone and compare the answer and each step.
2. For each question id listed in the task, in the lesson's question file: solve it yourself from the stem and choices before you look at which choice is marked `correct: true`. Then check that the marked key is the one right answer, that no other choice is also defensible, that the explanation is correct, and that each wrong-choice rationale is accurate.
3. Report only real errors:
   - Blocker: a false fact, a wrong worked answer, a wrong or ambiguous answer key, a false general statement a student would apply.
   - Major: a worked step or figure marker before a solution that gives away the answer; a term or method a worked example needs that the lesson never teaches or points to; a wrong explanation or wrong-choice rationale.
   - Do not report style, length, paragraph size, wording preferences or Minors.
4. Each finding quotes the file exactly (at least 8 characters, copied character for character) and names a source.

Output only this JSON as your final message, nothing else:

{"lesson": "<lesson id>", "auditor": "astra", "findings": [{"file": "<path>", "questionId": "<id or empty>", "severity": "Blocker|Major", "quote": "<exact text>", "problem": "<what is wrong and why>", "source": "<source>"}], "questionsChecked": <integer>, "examplesSolved": <integer>}

An empty findings list is a valid result.
