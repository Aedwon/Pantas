---
_id: "lesson-statistics-and-probability-data-analysis-graphs"
title: "Data Analysis and Graph Interpretation (Pie Charts, Bar Graphs, Scatter Plots)"
summary: "How to read pie charts, bar graphs, and scatter plots and how to compute values from them."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 11
isActive: true
---
## Core Concept

Graph questions are gift questions: the data is handed to you in a picture, and you only need to read it correctly and do light arithmetic.

**Pie charts** show parts of a whole. The full circle is $360^\circ$ and represents $100\%$ of the total. The two conversion facts:

$$\text{percent of total} = \dfrac{\text{sector angle}}{360} \times 100\%$$

$$\text{sector angle} = \text{percent} \times 360^\circ$$

A sector of $90^\circ$ is a quarter of the pie; $180^\circ$ is half.

<!-- ILLUSTRATION: pie chart of a monthly budget with four labeled sectors, food 90 degrees, rent 126 degrees, transport 72 degrees, savings 72 degrees -->

**Bar graphs** compare amounts across categories with bar heights. Read the height of each bar against the axis scale. Watch the scale: each gridline might mean $5$, $10$, or $500$.

**Scatter plots** show pairs of values as dots, one dot per item. The overall drift of the dots is the **correlation**:

- Dots rising to the right: **positive correlation** (more study hours, higher scores).
- Dots falling to the right: **negative correlation** (more absences, lower grades).
- A shapeless cloud: **no correlation**.

<!-- ILLUSTRATION: three small scatter plots side by side showing an upward trend, a downward trend, and a random cloud -->

Correlation is not causation: ice cream sales and drowning rise together because of summer, not because ice cream causes drowning. CETs test that exact idea in words.

## Examples

### #1: Pie Chart, Angle to Pesos

A family's monthly budget of $12{,}000$ pesos is shown in a pie chart. The food sector has a central angle of $90^\circ$. How much goes to food?

<!-- ILLUSTRATION: a pie chart of a monthly budget with the food sector marked as a 90° slice (one quarter of the circle) -->


**Solution:**
Convert the angle to a fraction of the whole.

1. Fraction of the circle.

$$\dfrac{90}{360} = \dfrac{1}{4}$$

2. Take that fraction of the budget.

$$\dfrac{1}{4} \times 12000 = 3000$$

3. The family spends $3{,}000$ pesos on food.

### #2: Pie Chart, Percent to Angle

A survey shows $35\%$ of students walk to school. In a pie chart of the survey, what central angle represents the walkers?

<!-- ILLUSTRATION: a pie chart with the "walkers" sector labeled 35% and its central angle marked "?" (out of 360°) -->


**Solution:**
Percent times $360^\circ$.

1. Convert the percent to a decimal and multiply.

$$0.35 \times 360 = 126$$

2. The walking sector measures $126^\circ$.

### #3: Bar Graph Comparison

A bar graph shows a store's weekly sales: Monday $40$, Tuesday $55$, Wednesday $35$, Thursday $60$, Friday $85$ (in thousands of pesos). By how much do Friday's sales exceed the average of the other four days?

<!-- ILLUSTRATION: a bar graph of weekly sales (thousands of pesos) with bars Mon 40, Tue 55, Wed 35, Thu 60, Fri 85; a y-axis starting at 0 -->


**Solution:**
Two reads and a subtraction, but the average comes first.

1. Average of Monday through Thursday.

$$\dfrac{40 + 55 + 35 + 60}{4} = \dfrac{190}{4} = 47.5$$

2. Subtract from Friday.

$$85 - 47.5 = 37.5$$

3. Friday exceeds the four-day average by $37{,}500$ pesos. Note the trap dodged: the question asked for the average of the other days, not all five.

### #4: Reading a Scatter Plot

A scatter plot pairs each student's hours of sleep with their mistake count on a quiz. The dots slope downward from upper left to lower right. What correlation is shown, and what does it mean?

<!-- ILLUSTRATION: a scatter plot with hours of sleep on the x-axis and mistake count on the y-axis, dots trending downward from upper-left to lower-right (negative correlation) -->


**Solution:**
Downward drift means the two variables move in opposite directions.

1. As sleep hours increase, mistakes decrease: a negative correlation.
2. Meaning in words: students who slept more tended to make fewer mistakes.
3. Careful: the plot alone does not prove sleep causes fewer mistakes; it only shows the two travel together.

### #5: Percent Change from a Graph (Exam Level)

A bar graph shows a school's enrollment: $1{,}500$ students in $2023$ and $1{,}800$ students in $2024$. Find the percent increase.

<!-- ILLUSTRATION: a bar graph with two bars, 2023 enrollment 1,500 and 2024 enrollment 1,800, y-axis starting at 0 -->


**Solution:**
Percent change always divides by the original value.

1. The increase.

$$1800 - 1500 = 300$$

2. Divide by the original ($2023$) value.

$$\dfrac{300}{1500} = 0.20$$

3. The enrollment increased by $20\%$. Dividing by the new value $1800$ gives about $16.7\%$, a planted wrong choice.

## Speed Tricks & Shortcuts

Memorize the pie-chart angle anchors: $36^\circ$ is $10\%$, $90^\circ$ is $25\%$, $120^\circ$ is a third, $180^\circ$ is half. Most exam sectors are built from these, so you can convert by eye.

In bar graph questions, read the question first, then the graph. Usually only two or three bars matter; reading every bar wastes a minute per question.

For any multi-part graph question, write the numbers you pull from the graph before computing. Transcribe once, compute once. Most graph errors are reading errors, not math errors.

## Traps to Watch For

### #1: Percent of the Wrong Whole

> Pie chart percents are percents of the total shown, not of another sector.

If food is $25\%$ and rent is $35\%$, rent is not $35\%$ of the leftover, and comparing them needs care: rent is $10$ percentage points more than food, but $40\%$ larger relative to food. Distinguish "percentage points" from "percent more".

### #2: The Truncated Axis

> A bar graph whose scale starts above zero exaggerates differences.

If the axis runs from $80$ to $100$, a bar of $95$ looks twice as tall as a bar of $88$, though the real difference is small. When a question asks whether a graph is misleading, check the axis start first: that is almost always the trick.

### #3: Correlation Means Causation

> A scatter plot trend never proves that one variable causes the other.

Statements like "the plot proves studying causes higher grades" are wrong choices; the correct phrasing is "shows a positive correlation" or "students who studied more tended to score higher". Watch for the verbs "causes" and "proves": they mark the bait.

### #4: Percent Change from the New Value

> Divide the change by the original, not the final amount.

Going from $1500$ to $1800$ is a $20\%$ increase, but going back from $1800$ to $1500$ is only about a $16.7\%$ decrease. Both numbers appear in the choices of every percent-change question. Anchor on the starting value every time.
