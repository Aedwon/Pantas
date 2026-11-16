# Fix brief: CET math question check findings

Read `docs/content/math-for-generator/qcheck/rulings.md`, then every result file in `docs/content/math-for-generator/qcheck/results/`. Apply the ruling for each finding. Only the question files and lesson files the rulings name may change. Never change a key. Keep the lesson voice (Grade 5 plain English, short sentences, `\dfrac`, no em dashes, American spelling). LaTeX in YAML goes in single quotes or block scalars.

Append one line per finding to `docs/content/math-for-generator/qcheck/fixes.jsonl` as you go: {"questionId": "<id>", "ruling": <1-6>, "file": "<path changed or empty>", "action": "<one sentence>"}.

Then run `dart run tools/import_questions/import_questions.dart --root content/questions/mathematics >/dev/null 2>&1; echo "exit: $?"` and fix until it is 0. Final message: findings handled per ruling, the validator exit code you read, and anything you could not do.
