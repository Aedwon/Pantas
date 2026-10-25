---
_id: "lesson-statistics-and-probability-data-analysis-graphs"
title: "Data Analysis and Graph Interpretation (Pie Charts, Bar Graphs, Scatter Plots)"
summary: "How to read pie charts, bar graphs, scatter plots, and graph scales and compute values from them."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 13
isActive: true
---
## Core Concept

Graph questions mix careful reading with arithmetic. Before calculating, check what each axis, label, scale, or sector means.

**Pie charts** show parts of a whole. A full circle is $360^\circ$ and represents $100\%$ of the total.

$$\text{percent of total}=\dfrac{\text{sector angle}}{360^\circ}\times100\%$$

$$\text{sector angle}=\text{proportion of whole}\times360^\circ$$

A sector of $90^\circ$ is one quarter of the whole. A sector of $180^\circ$ is one half.

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Food (90°)", "Rent (126°)", "Transport (72°)", "Savings (72°)"], "values": [90, 126, 72, 72], "semanticsLabel": "A pie chart of a monthly budget with food at 90 degrees, rent at 126 degrees, transport at 72 degrees, and savings at 72 degrees."} -->

**Bar graphs** compare values by bar height or length. Read the axis labels, units, and tick marks before reading a bar.

To find the value of one small step on an axis, find the difference between two labeled values and divide by the number of equal spaces between them.

A **truncated axis** is an axis that leaves out part of the scale, often by starting above $0$. This can make two bars look more different than their numbers really are. Read the numbers, not only the bar heights.

The **mean** is the sum of the values divided by the number of values.

$$\text{mean}=\dfrac{\text{sum of values}}{\text{number of values}}$$

For percent change, compare the change with the original value.

$$\text{percent change}=\dfrac{\text{new value}-\text{original value}}{\text{original value}}\times100\%$$

For a percent increase, the new value is larger than the original value. The original value stays in the denominator.

**Scatter plots** show pairs of numbers as dots. A roughly straight pattern is called a **linear association**.

- An upward straight pattern shows a **positive linear association**.
- A downward straight pattern shows a **negative linear association**.
- If there is no clear straight pattern, there may be little or no linear association.

The dots can still make a clear curved pattern even when there is little straight-line pattern. Look at the whole shape before saying there is no relationship.

<!-- FIGURE: {"kind": "chart", "type": "scatter", "plots": ["upward", "downward", "random"], "semanticsLabel": "Three scatter plots side by side showing an upward linear trend, a downward linear trend, and a random cloud of points."} -->

**Correlation** means two values show a pattern together. **Causation** means a change in one thing causes a change in another. A scatter plot by itself can show a pattern, but it does not prove cause.

## Examples

### #1: Pie Chart, Angle to Pesos

A family's monthly budget of $12{,}000$ pesos is shown in a pie chart. The food sector has a central angle of $90^\circ$. How much goes to food?

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Food (90°)", "Other (270°)"], "values": [90, 270], "semanticsLabel": "A pie chart of a monthly budget with the food sector marked as a 90-degree slice."} -->

**Solution:**
1. Find the fraction of the circle.

$$\dfrac{90}{360}=\dfrac14$$

2. Apply that fraction to the total budget.

$$\dfrac14(12000)=3000$$

3. The family spends $3{,}000$ pesos on food.

### #2: Pie Chart, Percent to Angle

A survey shows that $35\%$ of students walk to school. In a pie chart of the survey, what central angle represents the walkers?

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Walkers (35%, ?°)", "Other (65%)"], "values": [35, 65], "semanticsLabel": "A pie chart with the walkers sector labeled 35 percent and its central angle marked with a question mark."} -->

**Solution:**
1. Change $35\%$ to $0.35$ and multiply by a full circle.

$$0.35(360^\circ)=126^\circ$$

2. The sector measures $126^\circ$.

### #3: Bar Graph Comparison

A bar graph shows a store's weekly sales: Monday $40$, Tuesday $55$, Wednesday $35$, Thursday $60$, and Friday $85$, in thousands of pesos. By how much do Friday's sales exceed the mean of the other four days?

<!-- FIGURE: {"kind": "chart", "type": "bar", "labels": ["Mon", "Tue", "Wed", "Thu", "Fri"], "values": [40, 55, 35, 60, 85], "yAxis": {"label": "Sales (thousands of pesos)", "min": 0}, "semanticsLabel": "A bar graph of weekly sales with bars for Monday at 40, Tuesday at 55, Wednesday at 35, Thursday at 60, and Friday at 85."} -->

**Solution:**
1. Find the mean of Monday through Thursday.

$$\dfrac{40+55+35+60}{4}=47.5$$

2. Subtract the mean from Friday's value.

$$85-47.5=37.5$$

3. The graph uses thousands of pesos, so the difference is $37{,}500$ pesos.

### #4: Read an Axis Scale

A bar graph has labeled y-axis values at $0,10,20,30,$ and $40$. There is one small tick halfway between each pair of labeled values.

A bar reaches the small tick between $20$ and $30$. What value does the bar show?

<!-- ILLUSTRATION: bar graph with y-axis labels 0, 10, 20, 30, and 40, one halfway tick between each pair, and one unlabeled bar reaching the halfway tick between 20 and 30 -->

**Solution:**
1. From $20$ to $30$ is a difference of $10$. One halfway tick makes $2$ equal spaces.

$$\dfrac{10}{2}=5$$

2. Each small step is $5$. The halfway tick above $20$ is:

$$20+5=25$$

3. The bar shows $25$.

### #5: Reading a Scatter Plot

A scatter plot pairs each student's hours of sleep with the number of mistakes on a quiz. The dots make a roughly straight downward pattern from upper left to lower right. What association is shown, and what can be concluded?

<!-- FIGURE: {"kind": "chart", "type": "scatter", "trend": "downward", "xLabel": "Hours of sleep", "yLabel": "Mistakes", "semanticsLabel": "A scatter plot showing hours of sleep against mistakes with points trending downward from left to right."} -->

**Solution:**
1. The downward straight pattern shows a negative linear association. In this data set, students with more sleep tended to make fewer mistakes.
2. The graph does not prove that more sleep caused fewer mistakes. Something else could affect both sleep and mistakes.

### #6: Percent Change from a Graph

A bar graph shows a school's enrollment: $1{,}500$ students in $2023$ and $1{,}800$ students in $2024$. Find the percent increase.

<!-- FIGURE: {"kind": "chart", "type": "bar", "labels": ["2023", "2024"], "values": [1500, 1800], "yAxis": {"label": "Enrollment", "min": 0}, "semanticsLabel": "A bar graph comparing 2023 enrollment of 1,500 with 2024 enrollment of 1,800 on a zero-based axis."} -->

**Solution:**
1. Find the increase.

$$1800-1500=300$$

2. Divide the increase by the original value.

$$\dfrac{300}{1500}=0.20$$

3. Change the decimal to a percent. The enrollment increased by $20\%$.

## Speed Tricks & Shortcuts

Useful pie-chart anchors are $36^\circ=10\%$, $90^\circ=25\%$, $120^\circ=\dfrac13$ of a circle, and $180^\circ=50\%$.

For graph questions, read the prompt first. Then record the needed values and units before calculating.

On an axis, count spaces, not tick marks. Equal spaces represent equal changes in value.

For a scatter plot, ask whether there is a pattern and whether it is roughly straight. Then ask whether the graph alone proves that one thing caused the other. These are different questions.

## Traps to Watch For

### #1: Percent of the Wrong Whole

> A pie-chart percent is a percent of the whole chart.

If one sector is $25\%$ and another is $35\%$, the second is $10$ percentage points larger. It is $40\%$ larger compared with the first sector, which is a different question.

### #2: Truncated Axes

> An axis that starts above $0$ can make differences look larger.

A truncated axis is not always wrong. Check whether the labels and scale let you read the values correctly.

### #3: Correlation and Causation

> A pattern in a scatter plot does not by itself prove cause.

Use words such as "tends to" when the graph only shows a pattern. Do not say one thing caused another unless the problem gives enough evidence.

### #4: Curved Patterns

> No straight-line pattern does not always mean no relationship.

The dots may follow a curve. Look at the shape of the points before deciding there is no pattern.

### #5: Percent Change Uses the Starting Value

> Divide the change by the original value.

Going from $1500$ to $1800$ is a $20\%$ increase. Going back uses $1800$ as the starting value, so the percent decrease is different.
