# Astra audit brief: Algebra parts (math for the question generator)

You are auditing exam-review content for the Pantas app (students preparing for the Civil Service Exam and for UPCAT, DCAT, USTET and ACET in the Philippines). You are read-only. You change no file. Other models wrote and checked this content; your job is to find what they missed.

Repository: the current directory, branch `content/math-for-generator-r1`. Read for context: `docs/content/rewrite/cet/reader-rules.md` (rulings that bind readers, including L18 for CETs) and, from `git show origin/main:docs/content/content-checklist.md`, the rule ids and severities.

The task names one family: a retired parent lesson and the part lessons that replaced it. The parts are live. Audit the parts only.

1. Read every part file in full. Check every fact against standard sources (OpenStax, standard school texts). Test every general statement ("only", "always", "never", "every", "all", "must", each stated rule) against boundary values and known exceptions. Solve every worked example yourself from its question alone and compare the answer and each step.
2. If the task says the parent has a CET rewrite: the parent file holds a later, longer rewrite of the same topic that went through several error-finding reads. Compare. Report as a finding every error that the rewrite corrected but a part still carries (quote the part). Separately, list CET-level skills or methods the rewrite teaches that no part teaches, as `gaps`. A gap is not a finding.
3. Report only real errors:
   - Blocker: a false fact, a wrong worked answer, a false general statement a student would apply.
   - Major: a worked step or figure marker before a solution that gives away the answer; a term or method a worked example needs that the part never teaches or points to.
   - Do not report style, length, wording preferences or Minors.
4. Each finding quotes the part file exactly (at least 8 characters, copied character for character) and names a source.

Output only this JSON as your final message, nothing else:

{"family": "<parent id>", "auditor": "astra", "findings": [{"file": "<part path>", "severity": "Blocker|Major", "quote": "<exact text>", "problem": "<what is wrong and why>", "source": "<source>"}], "gaps": [{"skill": "<skill or method>", "rewriteQuote": "<exact text from the parent>", "nearestPart": "<part path or empty>"}], "partsRead": <integer>, "examplesSolved": <integer>}

Empty findings and gaps lists are valid.
