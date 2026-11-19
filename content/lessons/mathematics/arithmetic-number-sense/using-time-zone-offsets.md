---
_id: "lesson-arithmetic-number-sense-using-time-zone-offsets"
title: "Using Time-Zone Offsets"
summary: "Find the time and day in another place using a given offset."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 5
partCount: 5
ordering: 46
keyPoints:
  - "Use the given time-zone offset and check the day."
---
## Core Concept

### Using a Time-Zone Offset

A **time-zone offset** is a stated difference between the clocks in two places at the same moment. If the destination is ahead, its clock shows a later time. Add the given offset.

If it is behind, its clock shows an earlier time. Subtract the offset.

$$\text{later clock}=\text{earlier clock}+\text{offset}$$

$$\text{earlier clock}=\text{later clock}-\text{offset}$$

Use the offset given in the question. Check which place is ahead before choosing an operation.

Moving forward past midnight gives the next day. Moving backward past midnight gives the previous day.

## Examples

### #1: A Place Behind the Given Time

At the same moment, the clock in Town B is $5$ hours $45$ minutes behind the clock in Town A. It is $3{:}20$ am on Tuesday in Town A. What time and day is it in Town B?

**Solution:**

1. Town B is behind Town A. Subtract $5$ hours $45$ minutes from $03{:}20$.

2. Subtracting the offset crosses midnight. Add $24$ hours to the starting value for the calculation.

$$3+24=27$$

We will place the result on the previous day because the actual starting time was early Tuesday.

3. The starting minutes are less than $45$. Borrow $1$ hour.

$$27\text{ h }20\text{ min}=26\text{ h }80\text{ min}$$

4. Subtract minutes and hours.

$$80-45=35\text{ minutes}$$

$$26-5=21\text{ hours}$$

Town B's clock reads $21{:}35$, or $9{:}35$ pm on Monday.

5. Check forward from Town B. From $9{:}35$ pm Monday to midnight is $2$ hours $25$ minutes.

   From midnight to $3{:}20$ am Tuesday is $3$ hours $20$ minutes. Their sum is the given offset of $5$ hours $45$ minutes.

### #2: A Place Ahead of the Given Time

Town D is $4$ hours $50$ minutes ahead of Town C. It is $8{:}35$ pm on Wednesday in Town C. What time and day is it in Town D?

**Solution:**

1. Town D is ahead. Add the offset to Town C's time. Change $8{:}35$ pm to $20{:}35$.

2. Add the minutes and regroup.

$$35+50=85\text{ minutes}$$

$$85\text{ minutes}=1\text{ h }25\text{ min}$$

3. Add the hours, including the extra hour.

$$20+4+1=25$$

4. The hour has passed midnight. Subtract $24$ and move forward one day.

$$25-24=1$$

Town D's time is $01{:}25$, or $1{:}25$ am on Thursday.

## Speed Tricks & Shortcuts

### Check by Reversing the Work

For a time-zone subtraction, add the offset back to your answer. It should reach the given time and day.

## Traps to Watch For

### #1: Reversing the Offset

> Name the place whose clock you need before adding or subtracting.

If the requested place is behind, subtract. If it is ahead, add. The same stated difference can require either operation when the question switches which place's time is given.

### #2: Dropping the Day

> Crossing midnight changes the day.

A time without its day can leave a time-zone answer incomplete. In Example #1, Town B is still on Monday when Town A has reached Tuesday. Track the day with the hours and minutes.
