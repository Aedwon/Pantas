---
_id: "lesson-statistics-and-probability-data-analysis-graphs"
title: "Data Analysis and Graph Interpretation (Pie Charts, Bar Graphs, Scatter Plots)"
summary: "How to read pie charts, bar graphs, and scatter plots and compute values from them."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 11
isActive: true
---
## Core Concept

Graph questions combine careful reading with arithmetic. Before calculating, identify what each axis, label, scale, or sector represents.

**Pie charts** show parts of a whole. The full circle is $360^\circ$ and represents $100\%$ of the total.

$$\text{percent of total}=\dfrac{\text{sector angle}}{360^\circ}\times100\%$$

$$\text{sector angle}=\text{proportion of whole}\times360^\circ$$

A sector of $90^\circ$ is one quarter of the whole; $180^\circ$ is one half.

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Food (90°)", "Rent (126°)", "Transport (72°)", "Savings (72°)"], "values": [90, 126, 72, 72], "semanticsLabel": "A pie chart of a monthly budget with food at 90 degrees, rent at 126 degrees, transport at 72 degrees, and savings at 72 degrees."} -->

**Bar graphs** compare values across categories using bar lengths or heights. Read the values against the axis scale and units. A truncated axis can make visual differences look larger, but it is not automatically invalid; judge whether the scale and labels allow an accurate interpretation.

**Scatter plots** display paired numerical observations. When the points follow a roughly straight trend:

- upward from left to right suggests **positive linear association**;
- downward suggests **negative linear association**;
- no clear straight-line trend suggests little or no **linear** correlation.

A scatter plot can still contain a nonlinear relationship even when its linear correlation is weak or zero, so inspect the shape instead of assuming that "no linear correlation" means "no relationship of any kind."

<!-- FIGURE: {"kind": "chart", "type": "scatter", "plots": ["upward", "downward", "random"], "semanticsLabel": "Three scatter plots side by side showing an upward linear trend, a downward linear trend, and a random cloud of points."} -->

**Correlation does not imply causation.** An observed association does not by itself establish that changing one variable causes the other to change; a third variable or another explanation may account for the pattern.

## Examples

### #1: Pie Chart, Angle to Pesos

A family's monthly budget of $12{,}000$ pesos is shown in a pie chart. The food sector has a central angle of $90^\circ$. How much goes to food?

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Food (90°)", "Other (270°)"], "values": [90, 270], "semanticsLabel": "A pie chart of a monthly budget with the food sector marked as a 90-degree slice."} -->


**Solution:**
1. Fraction of the circle:

$$\dfrac{90}{360}=\dfrac14$$

2. Apply that fraction to the total budget.

$$\dfrac14(12000)=3000$$

3. The family spends $3{,}000$ pesos on food.

### #2: Pie Chart, Percent to Angle

A survey shows $35\%$ of students walk to school. In a pie chart of the survey, what central angle represents the walkers?

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Walkers (35%, ?°)", "Other (65%)"], "values": [35, 65], "semanticsLabel": "A pie chart with the walkers sector labeled 35 percent and its central angle marked with a question mark."} -->


**Solution:**
1. Convert $35\%$ to $0.35$ and multiply by a full turn.

$$0.35(360^\circ)=126^\circ$$

2. The sector measures $126^\circ$.

### #3: Bar Graph Comparison

A bar graph shows a store's weekly sales: Monday $40$, Tuesday $55$, Wednesday $35$, Thursday $60$, Friday $85$ (in thousands of pesos). By how much do Friday's sales exceed the mean of the other four days?

<!-- FIGURE: {"kind": "chart", "type": "bar", "labels": ["Mon", "Tue", "Wed", "Thu", "Fri"], "values": [40, 55, 35, 60, 85], "yAxis": {"label": "Sales (thousands of pesos)", "min": 0}, "semanticsLabel": "A bar graph of weekly sales with bars for Monday at 40, Tuesday at 55, Wednesday at 35, Thursday at 60, and Friday at 85."} -->


**Solution:**
1. Mean of Monday through Thursday:

$$\dfrac{40+55+35+60}{4}=47.5$$

2. Subtract from Friday:

$$85-47.5=37.5$$

3. Because the graph's units are thousands of pesos, Friday exceeds the four-day mean by $37{,}500$ pesos.

### #4: Reading a Scatter Plot

A scatter plot pairs each student's hours of sleep with their mistake count on a quiz. The dots show a roughly straight downward trend from upper left to lower right. What association is shown, and what can be concluded?

<!-- FIGURE: {"kind": "chart", "type": "scatter", "trend": "downward", "xLabel": "Hours of sleep", "yLabel": "Mistakes", "semanticsLabel": "A scatter plot showing hours of sleep against mistakes with points trending downward from left to right."} -->


**Solution:**
1. A downward linear trend indicates a negative linear association: students with more sleep tended to have fewer mistakes in this data set.
2. The plot alone does not establish that more sleep **caused** the reduction in mistakes. Other variables may be involved, and causation requires stronger study design than an observed association.

### #5: Percent Change from a Graph

A bar graph shows a school's enrollment: $1{,}500$ students in $2023$ and $1{,}800$ students in $2024$. Find the percent increase.

<!-- FIGURE: {"kind": "chart", "type": "bar", "labels": ["2023", "2024"], "values": [1500, 1800], "yAxis": {"label": "Enrollment", "min": 0}, "semanticsLabel": "A bar graph comparing 2023 enrollment of 1,500 with 2024 enrollment of 1,800 on a zero-based axis."} -->


**Solution:**
Percent increase uses the starting value as the denominator.

1. Change:

$$1800-1500=300$$

2. Divide by the original value:

$$\dfrac{300}{1500}=0.20$$

3. The enrollment increased by $20\%$.

## Speed Tricks & Shortcuts

Useful pie-chart anchors include $36^\circ=10\%$, $90^\circ=25\%$, $120^\circ=\frac13$ of a circle, and $180^\circ=50\%$.

For graph questions, read the prompt first so you know which categories, years, axes, or sectors matter. Then record the relevant values and units before calculating.

When a scatter plot is involved, distinguish three questions: Is there a visible association? Is it roughly linear? And does the study design justify a causal conclusion? Those are not the same question.

## Traps to Watch For

### #1: Percent of the Wrong Whole

> Pie-chart percentages are percentages of the whole represented by the chart.

If one sector is $25\%$ and another is $35\%$, the second is $10$ percentage points larger, but it is $40\%$ larger relative to the first sector. Percentage points and percent change are different comparisons.

### #2: Truncated Axes

> A nonzero axis baseline can visually magnify differences, so read the numerical scale instead of judging only by bar height.

A truncated axis is not automatically deceptive; it can be useful when clearly labeled. The issue is whether the presentation obscures or exaggerates the numerical comparison.

### #3: Correlation and Causation

> An association in a scatter plot does not by itself prove causation.

Use language such as "is associated with" or "tends to" unless the study design supports a causal conclusion.

### #4: Nonlinear Relationships

> Little or no linear correlation does not necessarily mean there is no relationship.

A curved pattern can be strongly structured while having weak linear correlation. Inspect the scatter plot's shape.

### #5: Percent Change Uses the Starting Value

> Divide the change by the original value.

Going from $1500$ to $1800$ is a $20\%$ increase. The reverse change uses a different starting value, so the percentage decrease is not also $20\%$.
