# Your record, Your tendencies, How you work: what the app shows today

**Date:** 1 October 2026
**Purpose:** reference for the UI round (Claude Design), which merges "How you work" into "Your
tendencies" and redesigns both entry rows under "More about you" on Home.
**Read from:** `web/roadmap-engine-r1` at 18871bb0, **updated for the fixes at 3b90fb7a** (Section 5). Every label below is the exact string in the
code today. Visual details in the code (faint bars, ink and rust colors, type sizes) are Ink and
Rule and are not binding (`AGENTS.md`, Visual direction).

Shared terms:
- **Completed session:** a finished quiz session of any kind (daily sitting, practice, retake,
  lesson quiz, assessment) or a submitted mock, for the selected exam.
- **Prep window:** every completed session since the student started. The code has a start-date
  parameter for a narrower window, but no screen passes one, so it is all time.
- **14-session floor:** every tendency, the profile label and "When you work" stay empty until
  the student has **14 completed sessions** in the prep window. This is on top of each item's
  own condition below.

---

## 1. Your record

Free and Pro see all of it (Gate: none; "nothing the student produced is ever paywalled").
Today it is reached from Progress, "Go deeper", row "Your record", whose subtitle is
"{n} days active" ("1 day active") plus ". Best mock {n}%" once a mock exists.

### Section "Since you started"

| Label | Figure | Computed from | Empty or hidden |
|---|---|---|---|
| weeks in | whole number | Days since the earliest activity (first quiz attempt started, first lesson read, or first mock started), divided by 7, rounded up, minimum 1 | 0 before any activity |
| day streak | whole number | The streak counter (Section 4) | 0 when no streak |
| since {date, e.g. "Oct 2, 2026"} | date only, no figure | Last active day minus (streak length minus 1) days | Hidden unless the student's own history has a completed daily sitting on every calendar day of the streak (so hidden with rest days or a used freeze) |

### Section "Your totals"

| Label | Figure | Computed from | Empty or hidden |
|---|---|---|---|
| questions answered | whole number | Every answered item in every finished or unfinished quiz attempt, plus each completed mock's question total (mock answers are counted once) | 0 |
| time in sessions | "{n}m" | Sum of start-to-finish time of completed quiz attempts, plus elapsed time of submitted mocks. Reading time is not tracked | "0m" |
| lessons read | whole number | Lessons marked read (reached the end, at least 15 seconds) | 0 |
| days active | whole number | Distinct local days with a quiz attempt, a lesson read, or a mock started | 0 |
| longest streak | whole number | Highest streak ever reached | 0 |
| best mock | "{n}%" | Highest completed mock score, points over total | Row hidden until a mock is completed |

### Section "Accuracy across your prep"

A line, one point per calendar week (Monday start): correct over answered that week, from quiz
attempts. **Empty until there are at least two weeks with answers** (one point is not a trend).
No axis labels or figures are printed by the code today beyond the line.

### Section "Your mocks"

One row per completed mock, newest first: the mock's name, the date taken (e.g. "Oct 2, 2026"),
and "{n}%". **Whole section hidden until a mock is completed.** Forfeited, timed-out and
discarded mocks are not listed.

---

## 2. Your tendencies (Home panel today)

Heading "Your tendencies". Four cards in a swipeable row with page dots. Action link: Pro "See
full details" (to Progress), Free "Unlock with Pro" (to the paywall). Cards with data come first
in a fixed order (Under pressure, Stamina, How you answer, How you study), then cards without
data in the same order.

**Free:** each card shows its heading and both comparison labels; the figures and sentence are
withheld (Gate 1). **Pro:** heading, both labels with figures, and the sentence. **Pro without
enough data:** heading, both labels, "Not enough data yet" and the unlock line.

| Heading | Left label | Right label | Figures (Pro) | Computed from | Unlocks when (besides the 14-session floor) | Unlock line shown |
|---|---|---|---|---|---|---|
| Under pressure | practicing | under time | "{n}%" and "{n}%" | Accuracy in all quiz attempts (mock answers excluded) vs accuracy in submitted mocks | At least one submitted mock and at least one practice answer | Finish one full length mock |
| Stamina | first half | second half | "{n}%" and "{n}%" | Across submitted mocks: accuracy on the first half of each mock's questions vs the second half (unanswered count as wrong) | At least one submitted mock | Finish one full length mock |
| How you study | read first | answered first | two counts | For each lesson read: was it read before the student's first answer in that topic (read first) or after (answered first) | At least one read lesson in a topic the student has also answered | Read lessons or attempt topics |
| How you answer | when correct | when wrong | "{n}s" and "{n}s" | Average answer time on correct vs wrong answers, timed quizzes only (assessment and mocks excluded) | At least one timed answer | Answer more questions |

Sentence variants (Pro, with data):

- **Under pressure:** "Accuracy drops {n}% under exam pressure." / "Accuracy rises {n}% under
  exam pressure." / "Accuracy stays even under exam pressure."
- **Stamina:** "Accuracy drops {n}% in the second half of a mock." / "Accuracy rises {n}% in the
  second half of a mock." / "Accuracy stays even across both halves."
- **How you study:** "You usually read the lesson first." / "You usually go straight to the
  questions." / "You split about evenly between the two."
- **How you answer:** "You spend {n}s longer on questions you get wrong." / "You answer {n}s
  faster on questions you get wrong." / "Your speed is about the same whether correct or wrong."

The "{n}%" in the accuracy sentences is a difference in percentage points, printed with "%".

---

## 3. How you work (Progress screen today)

Title "How you work". Reached from Progress, "Go deeper", row "How you work", whose subtitle is
the profile label and the "When you work" answers joined by periods, or "Not enough data yet".

### Section "Your profile" (Free and Pro)

- **Name:** the student's name, or the link "Add your name" (opens Settings) when none.
- **Profile label** (archetype) and its **line**. Both hidden when no label applies.

How a label is chosen: every label whose inputs exist is scored; the highest-priority category
wins (Under pressure first, then Pace, Subject, Study habit, Strategy), then the higher score.
Recomputed at most once a day.

| Label | Category | Needs | Chosen when |
|---|---|---|---|
| Game-Day Player | Pressure | a submitted mock | Mock accuracy above practice |
| Pressure Tightener | Pressure | a submitted mock | Mock accuracy below practice |
| Night-Owl Sprinter | Pace | time of day, session length, answer speed | Scores for best hour 6 pm or later, sessions 12 minutes or shorter, answers 12 seconds or faster |
| Early Bird Marathoner | Pace | time of day, session length | Best hour before noon, sessions 25 minutes or longer |
| Numbers Person | Subject | two or more subjects answered | Accuracy differs across subjects and the strongest is math or science |
| Wordsmith | Subject | two or more subjects answered | Accuracy differs across subjects and the strongest is reading or language |
| Generalist | Subject | two or more subjects answered | Accuracy is similar across subjects |
| Scholar | Study habit | read-first counts, coverage | Reads first and has broad coverage |
| Long Memory | Study habit | review history | Few lapses |
| Bookmark Strategist | Strategy | flags revisited, mock pacing | Revisits flagged questions |
| Time Master | Strategy | mock pacing | Finishes mocks with time to spare |
| Closer | Strategy | a submitted mock | Second half of mocks stronger |

Lines (each states what the label is based on, with measured figures only):

- Game-Day Player: "Your mock accuracy runs {points} pts above practice."
- Pressure Tightener: "Your mock accuracy runs {points} pts below practice."
- Night-Owl Sprinter: "Your best hour is {hour} and your sessions average {minutes} minutes."
- Early Bird Marathoner: "You work best at {hour} and sit for {minutes} minutes on average."
- Numbers Person: "Your highest subject accuracy is {percent}% in math or science."
- Wordsmith: "Your highest subject accuracy is {percent}% in reading or language."
- Generalist: "Your subject accuracy ranges from {low}% to {high}%."
- Scholar: "You read first for {reads} of {lessons} lessons and have practiced {coveredTopics}
  of {totalTopics} topics."
- Long Memory: "You forget on {percent}% of your reviews."
- Bookmark Strategist: "You revisit {revisitedCount} of {flaggedCount} questions you flag."
- Time Master: "You finish mocks with {seconds} seconds left on average."
- Closer: "You score higher in the second half of a mock."

### Section: five tendencies (one header each)

The four in Section 2 (same headings, labels, sentences and unlock lines), plus:

| Heading | Left label | Right label | Figures (Pro) | Computed from | Unlock line |
|---|---|---|---|---|---|
| How long you remember | memory holds | lapse rate | "{n}d" and "{n}%" | Average review stability across reviewed questions (days until recall is likely to slip), and lapses over reviews | Review more questions |

Sentence: "what you learn holds about {n in words up to fifteen, else digits} days before you
need it again" (lowercase, no period in the code today).

Each tendency here shows (Pro, with data) a large gap figure ("{n}" points, "{n}s", or "{n}d"),
the sentence, and "{left label} {figure} vs. {right label} {figure}". A gap that is a loss is
marked as a loss (practice above mock, first half above second, any speed difference, lapse
rate above 15 percent).

**Free:** each tendency shows its heading and "{left label} vs. {right label}", figures withheld.
**Pro without data:** "Not enough data yet" and the unlock line.

### Section "When you work" (Pro only, hidden for Free)

Three rows, shown only when time-of-day and session-length data exist:

| Title | Subtext | Answer |
|---|---|---|
| Peak hour | Measured from your highest accuracy | e.g. "9 pm" |
| Session length | Average sit duration | "{n} minutes" |
| Total sits | Completed study sessions | "{n} sessions" |

### Free teaser (Free only, after the last tendency)

"Unlock complete insights into your study habits, pacing, and working hours." and the button
"Unlock with Pro".

Loading and error: a loading state while computed; on failure "Could not load your progress."

---

## 4. The streak: where it appears

- **Counter:** one completed daily sitting (from Today, including advanced work) per local day
  earns a streak day (quiz engine spec D8). Practice, retakes and lesson quizzes do not. Rest
  days are skipped (study days, 1 October). A missed study day uses a freeze if one is left.
- **Shown today in:** Home's "Lately:" line, which rotates short facts and sometimes reads
  "Day {n} streak"; Your record ("day streak", "since {date}", "longest streak"); the "save your
  streak" reminder, and the notification permission screen's description of it.
- **In the redesigned Home** (no streak on the Home row): Your record and the streak reminder
  are the only places left. If the student should see the streak without opening Your record,
  the design must place it.

---

## 5. Defects found while reading (all fixed at 3b90fb7a, except as noted)

1. **"practising"** is British spelling in the "Under pressure" label (both screens). Policy
   requires American spelling: "practicing".
2. **Unlock lines understate the condition.** Every tendency also needs 14 completed sessions;
   "Finish one full length mock" alone does not unlock Under pressure or Stamina.
3. **Numbers Person and Wordsmith score identically** and the tie is broken alphabetically, so
   a student strong in language is labeled Numbers Person and Wordsmith can never appear.
4. **Weekday Warrior** does not look at weekdays; it scores the same for anyone with the inputs.
5. **Tendency card order on Home mixes units:** accuracy gaps are fractions (0 to 1) and speed
   gaps are seconds, so "How you answer" almost always sorts first.
6. **Every label but Game-Day Player** gets the same generic line.
7. **Your record row subtitle** reads "Day {days active}", which looks like a day count of prep
   or a streak but is the number of active days.

Also removed: Self-Aware, which scored the same whenever any difficulty data existed, in the
top-priority category. **Pending (being built):** the tendency unlock rule changes from the
14-session floor to per-tendency confidence states; see
`2026-10-01-tendency-confidence-design.md`. Until that lands, treat the "Unlocks when" column
and unlock lines in Section 2 as superseded by that spec.

Items 3, 4 and 6 bear on the "never invent a figure" rule: a label that does not reflect the
student's data is a claim the app cannot back.
