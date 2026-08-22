---
_id: "lesson-mechanical-technical-reasoning-fluid-pressure"
title: "Fluid Pressure in Pipes and Containers"
summary: "Learn how fluid pressure changes with depth and pipe width, and how to predict flow behavior in connected containers."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 9
isActive: true
---
## Core Concept

**Fluid pressure** (the force fluid exerts per unit area) follows a few key mechanical reasoning rules that frequently appear in technical reasoning questions, building on ideas from fluid mechanics.

**Pressure increases with depth.** The deeper a point is within a fluid, the more fluid is pushing down from above, so pressure at the bottom of a container is always greater than pressure near the top, regardless of the container's shape or width.

**Connected containers settle at the same fluid level.** If two or more open containers are connected at the bottom (like a U-shaped tube), the fluid will settle so that the surface level is the same in every connected container, regardless of each container's width or shape: this is sometimes summarized as "water finds its own level."

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "connected", "columns": 2, "semanticsLabel": "A U-shaped tube with two containers of different widths connected at the bottom, with water surface level exactly equal in both."} -->

**Narrower sections mean faster flow (for the same total amount of fluid moving through).** When a fluid flows through a pipe that narrows, the fluid must speed up to keep the same volume of fluid moving through per second (since less cross-sectional area is available): this is why water speeds up when a hose nozzle is squeezed narrower.

**Pressure and pipe width in flowing fluid**: in a narrower section where the fluid moves faster, the pressure is typically lower (connecting back to Bernoulli's principle: faster-moving fluid exerts less pressure).

## Examples

### #1: Comparing Pressure at Different Depths

A container is filled with water. Point A is near the surface, and Point B is near the bottom. Which point experiences greater pressure?

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "column", "points": ["A", "B"], "semanticsLabel": "A water-filled container with Point A marked near the surface and Point B near the bottom, where deeper Point B experiences greater pressure."} -->


**Solution:**
1. Pressure increases with depth, since more fluid is stacked above deeper points.
2. Point B (near the bottom) has more fluid above it than Point A (near the surface).
3. Point B experiences greater pressure.

### #2: Connected Containers of Different Widths

A wide container and a narrow container are connected at the bottom by a tube, forming a U-shape, both open to the air at the top. Water is poured in until it settles. Which container has the higher water level?

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "connected", "columns": 2, "semanticsLabel": "A U-shaped tube with a wide arm and a narrow arm, both open at the top, with water settled at the same level in both arms."} -->


**Solution:**
1. Connected open containers always settle to the same fluid level, regardless of their width.
2. Neither container will have a higher level than the other: they will be equal.
3. The water levels are the same in both the wide and narrow containers.

### #3: Predicting Flow Speed Through a Narrowing Pipe

Water flows steadily through a pipe that narrows from a wide section to a narrow section. Compared to the wide section, how does the water's speed change in the narrow section?

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "pipe", "widths": [3, 1], "semanticsLabel": "A pipe narrowing from a wide section to a narrow section with fluid flowing through, moving slower in the wide section and faster in the narrow section."} -->


**Solution:**
1. The same volume of water must pass through both sections per second (water is not created or destroyed along the pipe).
2. Since the narrow section has less cross-sectional area, the water must move faster through it to maintain the same volume flow rate.
3. The water speeds up in the narrow section.

### #4: Connecting Flow Speed to Pressure

Using the same narrowing pipe from Example 3, how does the pressure in the narrow section compare to the pressure in the wide section?

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "pipe", "widths": [3, 1], "semanticsLabel": "A narrowing pipe with higher pressure in the wide slow section and lower pressure in the narrow fast section."} -->


**Solution:**
1. The water moves faster in the narrow section (as established in Example 3).
2. By the relationship between fluid speed and pressure (faster flow means lower pressure), the pressure in the faster-moving narrow section should be lower.
3. The pressure is lower in the narrow section compared to the wider section.

## Speed Tricks & Shortcuts

**Remember "deeper means more pressure"** as the single most reliable rule for comparing pressure at different points within the same connected body of fluid.

**Remember "connected containers always level out equally"**: container width or shape never affects the final settled water level in an open, connected system.

**For flow-through-pipes questions, remember the paired rule: Narrower means faster flow, and faster flow means lower pressure.** These two facts always travel together in fluid-flow reasoning questions.

## Traps to Watch For

### #1: Assuming a Wider Container Holds Water at a Different Level

> Connected, open containers always settle at the same fluid level, no matter how different their widths or shapes are.

A wider container does not settle at a lower level just because it "holds more water" overall: the surface level still equalizes with any connected narrower container, since pressure at the connecting point must balance out equally on both sides.

### #2: Assuming Narrower Pipes Slow Down Flow

> A narrower section of pipe causes the fluid to speed up, not slow down, in order to maintain the same overall flow volume passing through per second.

Confusing this with everyday intuition (like assuming a "tighter squeeze" naturally slows things down) leads to the opposite, incorrect prediction: the fluid actually accelerates through a narrower opening.

### #3: Forgetting That Faster Flow Means Lower Pressure, Not Higher

> In flowing fluid, sections with faster movement (like narrow pipe sections) have lower pressure, following the same relationship as Bernoulli's principle in fluid mechanics.

Assuming a narrow, fast-flowing section must have higher pressure (since it "feels more forceful" intuitively) reverses the correct relationship between fluid speed and pressure.
