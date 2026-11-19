---
_id: "lesson-physics-latent-heat-and-phase-changes"
title: "Latent Heat and Phase Changes"
summary: "Find the energy needed to change phase and to heat a substance in stages."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 8
partCount: 9
ordering: 76
keyPoints:
  - "Use latent heat to calculate energy during a phase change."
  - "Choose the heat equation for each stage of a heating curve."
---
## Core Concept

### Latent Heat

A **phase** is a state of matter: solid, liquid, or gas. During melting, freezing, boiling, or condensing, a pure substance at constant pressure stays at one temperature while it takes in or gives out energy. The energy changes how the particles are held together, not how fast they move.

**Latent heat** ($L$) is the energy per kilogram needed to change phase. For mass $m$,

$$|Q| = mL$$

Here $L_f$ is the latent heat of **fusion** (melting or freezing), and $L_v$ is the latent heat of **vaporization** (boiling or condensing). For water, $L_f\approx 3.34\times10^{5}\text{ J/kg}$ and $L_v\approx 2.26\times10^{6}\text{ J/kg}$.

Melting and boiling take in energy, so $Q>0$. Freezing and condensing give out the same amount, so $Q<0$. Use $Q=mc\Delta T$ for the parts where the temperature changes, and $|Q|=mL$ for the part where the phase changes. Give each stage the right sign before adding.

<!-- ILLUSTRATION: heating curve graph, temperature on the vertical axis from -10 °C to 20 °C, heat added on the horizontal axis; sloped segment from -10 °C to 0 °C labeled "ice warms", flat segment at 0 °C labeled "ice melts", sloped segment from 0 °C to 20 °C labeled "water warms" -->

## Examples

### #1: Heat for a Phase Change

How much heat melts $0.50\text{ kg}$ of ice at $0°C$ into water at $0°C$? Take $L_f=3.34\times10^{5}\text{ J/kg}$.

**Solution:**

1. The temperature does not change, so $Q=mc\Delta T$ would give $0$. Use latent heat.

$$Q=mL_f=(0.50)(3.34\times10^{5})=1.67\times10^{5}\text{ J}$$

### #2: Heating Ice to Warm Water

Find the total heat needed to turn $0.10\text{ kg}$ of ice at $-10°C$ into water at $20°C$. Take $c_{ice}=2090\text{ J/(kg·°C)}$, $c_{water}=4186\text{ J/(kg·°C)}$, and $L_f=3.34\times10^{5}\text{ J/kg}$.

**Solution:**

1. Warm the ice from $-10°C$ to $0°C$.

$$Q_1=(0.10)(2090)(10)=2090\text{ J}$$

2. Melt the ice at $0°C$.

$$Q_2=(0.10)(3.34\times10^{5})=33{,}400\text{ J}$$

3. Warm the water from $0°C$ to $20°C$.

$$Q_3=(0.10)(4186)(20)=8372\text{ J}$$

4. Add the three parts.

$$Q=2090+33{,}400+8372=43{,}862\text{ J}$$

The melting step needs most of the energy, although the temperature does not change during it.

## Speed Tricks & Shortcuts

For a temperature change in one phase, use $Q=mc\Delta T$. If the temperature stays constant during a phase change, use $|Q|=mL$. If both happen, give each stage the right sign before adding.

## Traps to Watch For

### #1: Using $Q=mc\Delta T$ Across a Phase Change

> During melting or boiling, energy goes in while the temperature stays constant.

Use $|Q|=mL$ for that part. Give $Q$ the sign for heat entering or leaving. A problem that crosses a phase change needs both formulas.
