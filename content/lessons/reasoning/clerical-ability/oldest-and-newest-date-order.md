---
_id: "lesson-clerical-ability-oldest-and-newest-date-order"
title: "Oldest and Newest Date Order"
summary: "Follow the stated oldest-first or newest-first direction."
subject: "subject-reasoning"
topic: "topic-clerical-ability"
isActive: true
part: 2
partCount: 6
ordering: 5
keyPoints:
  - "Follow the stated oldest-first or newest-first direction."
  - "Compare the year, then the month, then the day."
---
## Core Concept

### Oldest-First vs. Newest-First Direction

**Chronological filing** sorts records by date. A system may ask for either direction:

- **Oldest to newest**: the earliest calendar date goes first.
- **Newest to oldest** (also called **reverse chronological order**): the most recent date goes first, at the top of the folder.

Check which direction the question names before looking at the dates. Do not assume "chronological" always means oldest first.

Order January $3$, $2025$ and December $31$, $2024$ both ways:

- Oldest to newest: December $31$, $2024$, then January $3$, $2025$.
- Reverse chronological (newest to oldest): January $3$, $2025$ on top, then December $31$, $2024$.

:::pair #wrong-date-direction
Right: in reverse chronological order, put the **most recent date** ($2025\text{-}01\text{-}08$) at the top
Wrong: put the **earliest historical date** ($2024\text{-}12\text{-}20$) at the top
"Reverse chronological" starts with the newest record, not the oldest. Check the direction first every time.
:::

:::check
A folder uses reverse chronological order. Which record goes at the top: May $2$, $2024$ or March $18$, $2025$?
:::answer
The answer is **March $18$, $2025$**. Reverse chronological puts the newest date at the top, and $2025$ is newer than $2024$.
:::

### Year, Then Month, Then Day

Compare complete dates in three steps, from largest calendar unit to smallest:

1. Compare the **year** first.
2. If the years match, compare the **month** (January $= 1$ through December $= 12$).
3. Compare the **day** only when both the year and the month match.

If two records show only the same month and year, such as "May $2025$," you cannot order them until you have their complete day dates. If a registry uses another primary key first, such as file number, break ties by date only when that primary key matches.

Sort June $15$, $2025$, July $1$, $2025$, and June $10$, $2025$ from oldest to newest:

- Step $1$ (year): all three are in $2025$ (tie).
- Step $2$ (month): June ($6$) comes before July ($7$), so July $1$, $2025$ is last.
- Step $3$ (day, for the June dates): day $10$ comes before day $15$.
- Order: June $10$, $2025$; June $15$, $2025$; July $1$, $2025$.

:::pair #month-beats-year
Right: in newest-first order, January $3$, $2025$ ($2025\text{-}01\text{-}03$) comes before December $31$, $2024$ ($2024\text{-}12\text{-}31$)
Wrong: December $31$, $2024$ ($2024\text{-}12\text{-}31$) comes first because December is the end of the year
December $31$ is late inside $2024$, but $2025$ is a newer year. Always compare the year before the month or day.
:::

:::pair #day-beats-month
Right: June $10$, $2025$ ($2025\text{-}06\text{-}10$) comes before June $15$, $2025$
Wrong: July $1$, $2025$ ($2025\text{-}07\text{-}01$) comes before June $15$, $2025$ because day $1$ is smaller than day $15$
Day $1$ looks small, but July is later than June. Never compare days until both year and month tie.
:::

:::why
Why does a calendar compare year, then month, then day? One year holds $12$ months, and one month holds up to $31$ days. The larger unit always changes time more than the smaller unit.
:::

:::check
In oldest-to-newest order, which date comes first: August $28$, $2024$ or September $2$, $2024$?
:::answer
The answer is **August $28$, $2024$**. Both dates are in $2024$, and August comes before September.
:::

## Examples

### #1: Oldest to Newest

Arrange these dates from oldest to newest: March $15$, $2024$; January $20$, $2024$; November $5$, $2023$; and February $10$, $2025$.

**Solution:**

1. Compare the years first: $2023$ is earliest, then the two $2024$ dates, then $2025$.
2. Put November $5$, $2023$ first and February $10$, $2025$ last.
3. Compare the months of the $2024$ dates: January comes before March.
4. The order is November $5$, $2023$; January $20$, $2024$; March $15$, $2024$; February $10$, $2025$.

**Check:** Each year steps forward ($2023 \to 2024 \to 2024 \to 2025$), and inside $2024$, January precedes March.

### #2: Reverse Chronological Order

Place these records in reverse chronological order: July $8$, $2024$; July $21$, $2024$; and June $30$, $2024$.

**Solution:**

1. Check the direction: reverse chronological means newest to oldest.
2. Compare the years: all three are $2024$ (tie).
3. Compare the months: July is newer than June, so June $30$, $2024$ goes last.
4. Compare the days inside July: day $21$ is newer than day $8$.
5. The order is July $21$, $2024$; July $8$, $2024$; June $30$, $2024$.

**Check:** Moving from left to right goes backward in time from late July to early July to late June.

### #3: Primary Number First, Date Second

A registry compares integer file number in ascending order, then date in newest-first order when file numbers match. Which record comes first: File $18$, $2024\text{-}12\text{-}20$; File $18$, $2025\text{-}01\text{-}08$; File $21$, $2025\text{-}01\text{-}10$; or File $21$, $2024\text{-}12\text{-}15$?

**Solution:**

1. Compare the primary key (file number) in ascending order: $18 < 21$, so drop both File $21$ records.
2. Both remaining records are File $18$, so move to the secondary date key.

:::try
Finish the last step: compare $2024\text{-}12\text{-}20$ and $2025\text{-}01\text{-}08$ under newest-first order to choose which record comes first.
:::answer
The answer is **File $18$, $2025\text{-}01\text{-}08$**. For newest-first order, year $2025$ is newer than year $2024$.

**Check:** File $21$, $2025\text{-}01\text{-}10$ has the newest date overall, but the primary key (file number $18$ vs. $21$) decides the order before dates are checked; inside File $18$, $2025$ is newer than $2024$.
:::

## Traps to Watch For

:::checklist
- "Reverse chronological" or "newest first": start with the most recent date, not the oldest. {#wrong-date-direction}
- Late month like December vs. early month in the next year: compare the year before the month. {#month-beats-year}
- Small day number in a later month, such as July $1$ vs. June $15$: compare the month before the day. {#day-beats-month}
:::
