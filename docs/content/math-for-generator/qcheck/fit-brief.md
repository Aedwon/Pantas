# Lesson-fit read: CET math questions against their current lessons

Read-only. You change no file. Read `docs/content/question-style-guide.md`, then the question file named in your task, in full.

Algebra question files: each question has a `lesson:` field naming a part lesson. Find that part under content/lessons/mathematics/algebra (search for its `_id`) and read it. Other files: the lesson is the file with the same path under content/lessons with `.md`.

For each question, solve it yourself before looking at the key. Then check: it tests only what its lesson teaches (or a part the lesson names as a prerequisite); the marked key is the one right answer and no other choice is defensible; the explanation is correct and explains only the right answer; each wrong-choice rationale is accurate; the correct answer is not the longest choice; no clue gives the answer away.

Report only Blocker (wrong or ambiguous key, false statement) and Major (tests a skill its lesson does not teach or point to, wrong explanation or rationale, a giveaway). No Minors.

Output only JSON as your final message:
{"file": "<path>", "questionsRead": <n>, "findings": [{"questionId": "<id>", "severity": "Blocker|Major", "problem": "<what and why>", "fix": "<suggested fix>"}]}
