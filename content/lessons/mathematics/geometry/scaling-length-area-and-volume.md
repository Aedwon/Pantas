---
_id: "lesson-geometry-scaling-length-area-and-volume"
title: "Scaling Length, Area, and Volume"
summary: "Scale lengths, areas, and volumes. Work backward from an area or volume ratio."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 7
partCount: 7
ordering: 0
keyPoints:
  - "Scale lengths, areas, and volumes."
  - "Work backward from an area or volume ratio."
---
## Core Concept

**Similar figures** have the same shape. Each length in one figure is multiplied by the same positive number to get its matching length in the other figure. Their sizes may differ.

A **scale factor** $k$ is the new length divided by its matching old length. These rules apply to similar figures when every length is multiplied by that same number $k$:

$$P_{\text{new}}=kP_{\text{old}}$$

$$A_{\text{new}}=k^2A_{\text{old}}$$

$$V_{\text{new}}=k^3V_{\text{old}}$$

Lengths have one factor of $k$. Area has two length dimensions, so it gets $k\times k=k^2$. Volume has three, so it gets $k\times k\times k=k^3$.

Surface area also scales by $k^2$. To work backward from an area ratio, take its positive square root. For a volume ratio, take its positive cube root.

## Examples

### #1: Scaling a Cube

A cube has an edge of $2$ cm. A larger cube has an edge of $6$ cm. Find the larger cube's volume and surface area.

<!-- ILLUSTRATION: Two cubes with corresponding edges labeled 2 cm and 6 cm. -->

**Solution:**

1. Find the smaller cube's volume and surface area.

$$V=2^3=8\text{ cm}^3$$

$$SA=6(2)^2=24\text{ cm}^2$$

2. Find the length scale factor.

$$k=\dfrac{6}{2}=3$$

3. Volume grows by $k^3$.

$$V_{\text{new}}=3^3(8)=216\text{ cm}^3$$

4. Surface area grows by $k^2$.

$$SA_{\text{new}}=3^2(24)=216\text{ cm}^2$$

### #2: Working Backward from Area

Two similar rectangles have areas of $20\text{ cm}^2$ and $180\text{ cm}^2$. The smaller rectangle has a perimeter of $18$ cm. Find the larger rectangle's perimeter.

<!-- ILLUSTRATION: Two similar rectangles with areas labeled 20 square centimeters and 180 square centimeters; label the smaller perimeter 18 cm and the larger perimeter unknown. -->

**Solution:**

1. The rectangles are similar, so all matching lengths have one scale factor. Their area ratio gives its square.

$$k^2=\dfrac{180}{20}=9$$

2. Take the positive square root.

$$k=3$$

3. Multiply the smaller perimeter by $k$.

$$P_{\text{new}}=3(18)=54\text{ cm}$$

## Speed Tricks & Shortcuts

If all lengths double, perimeter doubles, area becomes $4$ times as large, and volume becomes $8$ times as large. Check that all dimensions use the same scale factor before using these rules.

## Traps to Watch For

### #1: Using the Area Ratio as a Length Ratio

> Area ratios are squares of length ratios.

An area ratio of $9$ gives a length ratio of $3$, not $9$. A volume ratio of $8$ gives a length ratio of $2$. These rules require figures with the same shape and one scale factor for all lengths.
