# Lesson-fit read: new PSHS-NCE questions

Read-only. Read `docs/content/question-style-guide.md`, then the packet named in your task (the lesson plus its full question file). For each question check: it tests only what the lesson teaches; the key is the one right answer and no other choice is defensible; the explanation is correct, Grade 5 English, and explains only the right answer; every wrong choice is a real mistake with an accurate rationale; the correct answer is not the longest choice; no clue gives the answer away; no claim about the PSHS-NCE beyond "the official sample has items like this".

Severity Blocker (wrong or ambiguous key, false statement), Major (tests something the lesson does not teach, wrong explanation or rationale, giveaway), Minor. Output only JSON as your final message:
{"file": "<path>", "findings": [{"questionId": "<id>", "severity": "Blocker|Major|Minor", "problem": "<what and why>", "fix": "<suggested fix>"}]}
