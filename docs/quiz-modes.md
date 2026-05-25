# Quiz Modes

Spec 4 adds one quiz engine with four user-facing modes:

- Today's Session: daily personalized practice and the only streak-eligible quiz surface.
- Drill a topic: user-selected topic or subtopic practice.
- Retake Mistakes: recent incorrect answers from the last 30 days.
- Quiz yourself: five-question lesson reinforcement.

## Storage

`content.db` is regenerable content only. It stores exams, topics, lessons,
questions, and optional `subtopicId` metadata from Sanity. It is not synced.

`app.db` stores user data and local quiz state. Durable user progress such as
`quiz_attempts`, FSRS review rows, lesson progress, assessment results, and
synced account preferences belongs here. Active `quiz_sessions` and
`daily_new_card_intro` are local-only app state and are not part of the sync
registry.

## Sync

Completed quiz attempts sync through `quiz_attempts`, including the `origin`
field that records the producing surface. FSRS review rows sync through
`fsrs_cards`. Quiz preferences sync through `account_prefs`.

`quiz_sessions`, `daily_new_card_intro`, streak cache rows, and `content.db`
must remain local-only.

## Out Of Scope

Mock Exam remains a separate Spec 5 flow and does not use these mode routes.
Paywall UI and purchase flows remain out of scope for Spec 4. The quiz engine
must not add free-tier caps, ads, or RevenueCat purchase behavior.
