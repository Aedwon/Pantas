---
_id: "lesson-statistics-and-probability-data-analysis-graphs"
title: "Data Analysis and Graph Interpretation (Pie Charts, Bar Graphs, Scatter Plots)"
summary: "How to read pie charts, bar graphs, scatter plots, and graph scales and compute values from them."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 15
isActive: true
---
## Core Concept

Graph questions mix careful reading with arithmetic. Check the title, labels, units, and scale before calculating.

### Pie Charts

**Pie charts** show parts of a whole. A **sector** is one slice. The full circle is $360^\circ$ and represents $100\%$ of the total.

Let $a$ be the sector angle in degrees. Let $p$ be its share written as a decimal, such as $0.25$ for $25\%$.

$$p=\dfrac{a}{360^\circ}$$

$$\text{percent}=p\times100\%$$

$$a=p\times360^\circ$$

To find the amount in a sector, multiply its share by the whole amount.

$$\text{amount}=p\times\text{total}$$

A sector of $90^\circ$ is one quarter of the whole. A sector of $180^\circ$ is one half.

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Food (90°)", "Rent (126°)", "Transport (72°)", "Savings (72°)"], "values": [90, 126, 72, 72], "semanticsLabel": "A pie chart of a monthly budget with food at 90 degrees, rent at 126 degrees, transport at 72 degrees, and savings at 72 degrees."} -->

### Bar Graphs and Scales

**Bar graphs** compare values by bar height or length. An **axis** is a numbered line along a graph. Its tick marks divide the scale into steps.

To find one small step, subtract two labeled values. Divide that difference by the number of equal spaces between them.

$$\text{step size}=\dfrac{\text{difference}}{\text{spaces}}$$

A **truncated axis** leaves out part of the scale, often by starting above $0$. This can make bars look more different than their values are. Read the numbers as well as the heights.

The **mean** is the average. Add the values, then divide by how many values there are.

$$\text{mean}=\dfrac{\text{sum of values}}{\text{number of values}}$$

For **percent change**, compare the change with the starting value. Let $N$ be the new value and $S$ be the starting value.

$$\text{change}=N-S$$

$$\text{percent change}=\dfrac{N-S}{S}\times100\%$$

The starting value must be greater than $0$ for the usual percent-change comparison. A positive result shows an increase. A negative result shows a decrease.

### Scatter Plots

**Scatter plots** show pairs of numbers as dots. Each dot gives both values for one person or item. A roughly straight pattern is called a **linear association**.

- An upward straight pattern shows a **positive linear association**: larger values of one tend to go with larger values of the other.
- A downward straight pattern shows a **negative linear association**: larger values of one tend to go with smaller values of the other.
- No clear straight pattern may mean little or no linear association.

Dots may still form a clear curve when they do not follow a straight line. Look at the whole shape before saying there is no relationship.

<!-- FIGURE: {"kind": "chart", "type": "scatter", "plots": ["upward", "downward", "random"], "semanticsLabel": "Three scatter plots side by side showing an upward linear trend, a downward linear trend, and a random cloud of points."} -->

**Correlation** means two values show a pattern together. **Causation** means a change in one thing causes a change in another. A scatter plot alone does not prove cause.

## Examples

### #1: Pie Chart, Angle to Pesos

A family's monthly budget of $12{,}000$ pesos is shown in a pie chart. The food sector has a central angle of $90^\circ$. How much goes to food?

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Food (90°)", "Other (270°)"], "values": [90, 270], "semanticsLabel": "A pie chart of a monthly budget with the food sector marked as a 90-degree slice."} -->

**Solution:**
1. Find food's share of the circle.

$$p=\dfrac{90}{360}=\dfrac14$$

2. Multiply by the total budget.

$$\dfrac14(12000)=3000$$

3. The family spends $3{,}000$ pesos on food.

### #2: Pie Chart, Percent to Angle

A survey shows that $35\%$ of students walk to school. In a pie chart of the survey, what central angle represents the walkers?

<!-- FIGURE: {"kind": "chart", "type": "pie", "labels": ["Walkers (35%, ?°)", "Other (65%)"], "values": [35, 65], "semanticsLabel": "A pie chart with the walkers sector labeled 35 percent and its central angle marked with a question mark."} -->

**Solution:**
1. Write $35\%$ as the decimal $0.35$.
2. Multiply by the angle of a full circle.

$$0.35(360^\circ)=126^\circ$$

3. The sector measures $126^\circ$.

### #3: Bar Graph Comparison

A bar graph shows a store's weekly sales: Monday $40$, Tuesday $55$, Wednesday $35$, Thursday $60$, and Friday $85$, in thousands of pesos. By how much do Friday's sales exceed the mean of the other four days?

<!-- FIGURE: {"kind": "chart", "type": "bar", "labels": ["Mon", "Tue", "Wed", "Thu", "Fri"], "values": [40, 55, 35, 60, 85], "yAxis": {"label": "Sales (thousands of pesos)", "min": 0}, "semanticsLabel": "A bar graph of weekly sales with bars for Monday at 40, Tuesday at 55, Wednesday at 35, Thursday at 60, and Friday at 85."} -->

**Solution:**
1. Find the mean of Monday through Thursday.

$$40+55+35+60=190$$

$$\dfrac{190}{4}=47.5$$

2. Subtract that mean from Friday's value.

$$85-47.5=37.5$$

3. The unit is thousands of pesos. The difference is $37{,}500$ pesos.

### #4: Read an Axis Scale

A bar graph shows the number of requests handled by an office. The vertical axis is labeled $0,10,20,30,$ and $40$, with one small tick halfway between each pair of labels. The bar ends at the small tick between $20$ and $30$. How many requests were handled?

<!-- ILLUSTRATION: bar graph titled Requests Handled, vertical axis labeled Requests at 0, 10, 20, 30, and 40 with one halfway tick between each pair, horizontal axis labeled Office with one bar labeled A ending at the halfway tick between 20 and 30, no value printed on the bar -->

**Solution:**
1. The gap from $20$ to $30$ contains $2$ equal spaces.

$$\text{step size}=\dfrac{30-20}{2}=5$$

2. The bar ends one step above $20$.

$$20+5=25$$

3. The office handled $25$ requests.

### #5: Reading a Scatter Plot

A scatter plot pairs each student's hours of sleep with the number of mistakes on a quiz. Its dots form a roughly straight downward pattern from upper left to lower right. What association is shown, and does the graph prove that more sleep causes fewer mistakes?

<!-- FIGURE: {"kind": "chart", "type": "scatter", "trend": "downward", "xLabel": "Hours of sleep", "yLabel": "Mistakes", "semanticsLabel": "A scatter plot showing hours of sleep against mistakes with points trending downward from left to right."} -->

**Solution:**
1. The downward pattern shows a negative linear association. Students with more sleep tended to make fewer mistakes in this data set.
2. The graph does not prove that sleep caused the change. Other things, such as time spent studying, could affect the results.

### #6: Percent Change from a Graph

A bar graph shows a school's enrollment: $1{,}500$ students in $2023$ and $1{,}800$ students in $2024$. Find the percent increase.

<!-- FIGURE: {"kind": "chart", "type": "bar", "labels": ["2023", "2024"], "values": [1500, 1800], "yAxis": {"label": "Enrollment", "min": 0}, "semanticsLabel": "A bar graph comparing 2023 enrollment of 1,500 with 2024 enrollment of 1,800 on a zero-based axis."} -->

**Solution:**
1. Find the increase.

$$1800-1500=300$$

2. Divide by the starting enrollment and change to a percent.

$$\dfrac{300}{1500}\times100\%=20\%$$

3. Enrollment increased by $20\%$.

### #7: The Same Values on Different Scales

Two bar graphs show $100$ requests in April and $110$ in May. Graph A has a vertical axis from $0$ to $120$. Graph B has a vertical axis from $90$ to $120$. Which graph makes the increase look larger, and what is the actual percent increase?

<!-- ILLUSTRATION: two side-by-side bar graphs of Requests with April at 100 and May at 110; Graph A has vertical labels 0 through 120 in steps of 10; Graph B has vertical labels 90, 100, 110, 120 and a clearly shown axis break below 90; print 100 and 110 above their respective bars in both graphs -->

**Solution:**
1. Graph B makes the increase look larger. Above its starting line of $90$, the bars have visible lengths of $10$ and $20$. The second looks twice as long.
2. The request counts are still $100$ and $110$. Find the actual increase.

$$110-100=10$$

3. Compare the increase with April's count.

$$\dfrac{10}{100}\times100\%=10\%$$

4. Both graphs show a $10\%$ increase. Changing the axis does not change the counts.

## Speed Tricks & Shortcuts

Useful pie-chart anchors are $36^\circ=10\%$, $90^\circ=25\%$, and $180^\circ=50\%$. A $120^\circ$ sector is $\dfrac13$ of a circle.

Read the prompt first. Record the needed values and units before calculating.

Count spaces on an axis, not tick marks. Equal spaces represent equal changes in value.

For a scatter plot, check the direction and shape. Then check whether the question asks about a pattern or a cause.

## Traps to Watch For

### #1: Percent of the Wrong Whole

> A pie-chart percent is a percent of the whole chart.

Sectors of $25\%$ and $35\%$ differ by $10$ percentage points. Compared with the smaller sector, the increase is $\dfrac{10}{25}\times100\%=40\%$. These answer different questions.

### #2: Truncated Axes

> An axis starting above $0$ can make differences look larger.

A bar that looks twice as long may not show twice the value. Check the starting label before making that claim.

### #3: Correlation and Causation

> A pattern in a scatter plot does not by itself prove cause.

Use "tends to" when the graph only shows a pattern. A claim that one thing caused another needs more evidence.

### #4: Curved Patterns

> No straight-line pattern does not always mean no relationship.

Dots may follow a curve. Saying "no relationship" without checking the shape can miss that pattern.

### #5: Percent Change Uses the Starting Value

> Divide the change by the original value.

Going from $1500$ to $1800$ is a $20\%$ increase. Going back starts at $1800$, so it gives a different percent decrease.
