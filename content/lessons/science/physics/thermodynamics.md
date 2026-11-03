---
_id: "lesson-physics-thermodynamics"
title: "Thermodynamics (Heat Transfer Mechanisms, Laws of Thermodynamics, Specific Heat Capacity)"
summary: "How heat moves by conduction, convection and radiation, what the four laws of thermodynamics say, and how to find the heat needed to change temperature or phase."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 15
isActive: true
---
## Core Concept

**Thermodynamics** studies energy, heat, work, and temperature in everyday-size systems. A **system** is the object or group of objects we choose to study. The **surroundings** are everything else.

Three ideas are easy to mix up. Keep them apart.

**Temperature** tells how hot or cold something is. It is related to the average motion energy of its particles.

**Internal energy** ($U$) is the total energy of the particles inside an object: their motion energy and the energy in the bonds and forces between them. An object has internal energy.

**Heat** ($Q$) is energy that moves from one object to another because of a temperature difference. Heat is energy in transit, not something an object holds. Heat and energy are measured in joules ($\text{J}$).

Heat flows from the higher temperature to the lower temperature. It does not depend on which object has more internal energy. A bathtub of warm water has far more internal energy than a hot cup of tea, yet heat flows from the tea to the bath water if they touch.

Temperature differences are the same in degrees Celsius and in kelvin ($\text{K}$), because $T_K=T_C+273.15$. So $\Delta T$ may be used in either unit. The kelvin scale starts at **absolute zero**, the lowest possible temperature.

### Heat Transfer Mechanisms

Heat can move in three main ways. Real situations often mix them.

**Conduction**: energy passes from particle to particle inside matter, or between objects that touch, with no bulk movement of the material. A metal spoon gets hot in soup. Metals conduct heat well. Air and wool conduct it poorly.

**Convection**: energy is carried by the bulk movement of a fluid. A **fluid** is a liquid or a gas, so convection happens in fluids and not in solids. In **natural convection**, a heated fluid expands, becomes less dense, and usually rises while cooler, denser fluid sinks. In **forced convection**, a fan or pump moves the fluid.

**Radiation**: energy travels as electromagnetic waves, so no matter is needed between the objects. Sunlight reaches Earth this way across empty space. Objects at ordinary temperatures also give off radiation, and hotter objects give off more.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"heat-transfer-triptych","illustrationKey":"science/physics/thermodynamics#1","panels":[{"name":"conduction","scene":"heat through solid metal rod held over flame"},{"name":"convection","scene":"warm fluid rises and cool fluid sinks in heated water"},{"name":"radiation","scene":"wavy arrows from Sun through empty space to Earth"}]} -->

### Laws of Thermodynamics

**Thermal equilibrium** means two objects in contact have the same temperature, so no net heat flows between them.

**Zeroth Law**: if A is in thermal equilibrium with C, and B is also in thermal equilibrium with C, then A and B are in thermal equilibrium with each other. This is why a thermometer works. The thermometer is C. It tells us whether A and B share a temperature without putting them together.

**First Law**: energy is conserved. The internal energy of a system changes by the heat added to it minus the work it does. **Work** ($W$) is energy transferred when the system pushes on its surroundings, such as a gas pushing a piston outward.

Our sign convention: $Q>0$ when heat is added to the system, and $W>0$ when the system does work on its surroundings. Then

$$\Delta U = Q - W$$

where $\Delta U$ is the change in internal energy. If heat leaves the system, $Q<0$. If the surroundings do work on the system, such as squeezing a gas, $W<0$. Some books define $W$ as work done on the system and write $\Delta U=Q+W$. Always check which convention a question uses.

<!-- ILLUSTRATION: gas in a cylinder with a movable piston, an arrow labeled "Q in" at the base and an arrow labeled "W out" at the piston, labeled "ΔU = Q − W" -->

**Second Law**: natural processes have a preferred direction. Heat flows by itself from a hotter body to a colder one, never the other way. A refrigerator does move heat from cold to hot, but it needs outside work to do so.

**Entropy** is a measure of how many ways the particles of a system can be arranged and share energy. More spread-out energy and more possible arrangements mean higher entropy. The second law also says that the total entropy of an isolated system does not decrease. An **isolated system** exchanges no heat, work, or matter with its surroundings.

Entropy of one part can still fall if another part gains more. Water freezing in a freezer loses entropy, while the warmer room around the freezer gains more.

**Third Law**: no process can bring a system to absolute zero ($0\text{ K}$) in a finite number of steps. A related statement says the entropy of a perfect crystal of a pure substance approaches zero as its temperature approaches $0\text{ K}$.

### Specific Heat Capacity

**Specific heat capacity** ($c$) is the energy needed to raise the temperature of $1\text{ kg}$ of a substance by $1\text{ °C}$. Its unit is $\text{J/(kg·°C)}$. A larger $c$ means the substance needs more energy per degree. Water has $c\approx 4186\text{ J/(kg·°C)}$, which is high.

When the substance stays in the same phase and $c$ is nearly constant over the temperature range,

$$Q = mc\Delta T$$

where $m$ is mass and $\Delta T=T_f-T_i$ is the final temperature minus the initial temperature. Heating gives $Q>0$. Cooling gives $Q<0$. The formula also gives $\Delta T=\dfrac{Q}{mc}$.

If two objects exchange heat only with each other, the heat lost by the hotter one equals the heat gained by the cooler one. This is the idea behind **calorimetry**, which means measuring heat by the temperature changes of objects in contact.

### Latent Heat

A **phase** is a state of matter: solid, liquid, or gas. During melting, freezing, boiling, or condensing, a pure substance at constant pressure stays at one temperature while it takes in or gives out energy. The energy changes how the particles are held together, not how fast they move.

**Latent heat** ($L$) is the energy per kilogram needed to change phase. For mass $m$,

$$Q = mL$$

Here $L_f$ is the latent heat of **fusion** (melting or freezing), and $L_v$ is the latent heat of **vaporization** (boiling or condensing). For water, $L_f\approx 3.34\times10^{5}\text{ J/kg}$ and $L_v\approx 2.26\times10^{6}\text{ J/kg}$.

Melting and boiling take in energy, so $Q>0$. Freezing and condensing give out the same amount, so $Q<0$. Use $Q=mc\Delta T$ for the parts where the temperature changes, and $Q=mL$ for the part where the phase changes. The two are added.

<!-- ILLUSTRATION: heating curve graph, temperature on the vertical axis from -10 °C to 20 °C, heat added on the horizontal axis; sloped segment from -10 °C to 0 °C labeled "ice warms", flat segment at 0 °C labeled "ice melts", sloped segment from 0 °C to 20 °C labeled "water warms" -->

## Examples

### #1: Identifying the Heat Transfer Mechanism

Identify the main mechanism in each case: (a) the handle of a pan gets hot because of the metal itself; (b) you feel the warmth of the Sun; (c) a fan moves warm air around a room.

**Solution:**

1. (a) Energy moves through the metal with no bulk movement: **conduction**.
2. (b) Energy arrives as electromagnetic waves across space: **radiation**.
3. (c) A fan carries the warm air along: **forced convection**.

Cases (a) to (c) may involve other mechanisms too. Each answer names the main one described.

### #2: Heat, Temperature and Internal Energy

A cup holds $0.2\text{ kg}$ of tea at $90°C$. A bathtub holds $100\text{ kg}$ of water at $40°C$. Which has the higher temperature, which has more internal energy, and which way does heat flow if the tea is poured in?

**Solution:**

1. The tea has the higher temperature: $90°C>40°C$.
2. The bath has far more water, so it has far more internal energy. Compare how much each differs from $0°C$ with $mc\Delta T$. Tea: $0.2\times4186\times90\approx 7.5\times10^{4}\text{ J}$. Bath: $100\times4186\times40\approx 1.7\times10^{7}\text{ J}$.
3. Heat flows from the higher temperature to the lower temperature, so from the tea into the bath water. The bath's larger internal energy does not change this direction.

### #3: Applying the Zeroth Law

A thermometer left in cup A reads $30°C$ once it settles. The same thermometer, left in cup B, also settles at $30°C$. What can be said about cups A and B?

**Solution:**

1. The thermometer is in thermal equilibrium with cup A, so A and the thermometer share a temperature.
2. It is also in thermal equilibrium with cup B.
3. By the zeroth law, A and B are in thermal equilibrium with each other. Both are at $30°C$, and no net heat would flow if they touched.

### #4: Applying the First Law

(a) A gas absorbs $500\text{ J}$ of heat and does $200\text{ J}$ of work on its surroundings. Find the change in its internal energy. (b) A different gas is squeezed by $300\text{ J}$ of work while it loses $100\text{ J}$ of heat. Find its change in internal energy.

**Solution:**

1. (a) Heat is added, so $Q=+500\text{ J}$. The gas does work, so $W=+200\text{ J}$.

$$\Delta U=Q-W=500-200=300\text{ J}$$

2. (b) Heat leaves, so $Q=-100\text{ J}$. The surroundings do work on the gas, so $W=-300\text{ J}$.

$$\Delta U=-100-(-300)=200\text{ J}$$

3. In both cases, internal energy rises: by $300\text{ J}$ in (a) and by $200\text{ J}$ in (b).

### #5: Applying the Second Law and Entropy

A hot cup of coffee sits in a cooler room. (a) Explain what happens by itself. (b) Ice melts in the same warm room. Does the entropy of the ice and its meltwater increase or decrease?

**Solution:**

1. (a) The coffee is hotter than the room, so heat flows from the coffee to the room. The coffee cools toward thermal equilibrium with the room.
2. The reverse, with the coffee warming up by taking heat from the cooler room and nothing else changing, does not happen by itself. The second law forbids it.
3. (b) Melting takes in heat, and the water molecules can be arranged in many more ways than in the ice crystal. The entropy of the ice and meltwater **increases**.
4. The room loses a little entropy, but the total entropy of ice, water, and room still does not decrease.

### #6: The Third Law

A scientist cools a gas in 50 steps and reaches $0.001\text{ K}$. Can the scientist reach exactly $0\text{ K}$ by repeating the cooling steps enough times?

**Solution:**

1. The third law says absolute zero cannot be reached in a finite number of steps.
2. More steps can bring the gas closer to $0\text{ K}$, but the gas never reaches $0\text{ K}$ itself.
3. So the answer is **no**.

### #7: Calculating Heat for a Temperature Change

Find the heat needed to raise the temperature of $2\text{ kg}$ of water by $10°C$. Take $c=4186\text{ J/(kg·°C)}$.

**Solution:**

1. The water stays liquid, so $Q=mc\Delta T$ applies.

$$Q=(2)(4186)(10)=83{,}720\text{ J}$$

### #8: Mixing Two Samples of Water

A calorimeter holds $0.50\text{ kg}$ of water at $20°C$. Then $0.25\text{ kg}$ of water at $80°C$ is added. Assume no heat is lost to the surroundings or the container. Find the final temperature.

**Solution:**

1. Let the final temperature be $T_f$. Heat gained by the cool water equals heat lost by the hot water.
2. Both are liquid water with the same $c$, so $c$ cancels.

$$0.50\,c\,(T_f-20)=0.25\,c\,(80-T_f)$$

3. Simplify and solve.

$$0.50T_f-10=20-0.25T_f$$

$$0.75T_f=30$$

$$T_f=40°C$$

4. Check: the cool water gains $0.50\times4186\times20=41{,}860\text{ J}$. The hot water loses $0.25\times4186\times40=41{,}860\text{ J}$.

### #9: Heat for a Phase Change

How much heat melts $0.50\text{ kg}$ of ice at $0°C$ into water at $0°C$? Take $L_f=3.34\times10^{5}\text{ J/kg}$.

**Solution:**

1. The temperature does not change, so $Q=mc\Delta T$ would give $0$. Use latent heat.

$$Q=mL_f=(0.50)(3.34\times10^{5})=1.67\times10^{5}\text{ J}$$

### #10: Heating Ice to Warm Water

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

### #11: A Fair Test of Specific Heat

A student heats $0.20\text{ kg}$ of water and $0.20\text{ kg}$ of cooking oil, both starting at $25°C$. Identical heaters run for the same time. The water ends at $32°C$ and the oil at $40°C$. Name the variable the student changes, the variable measured, and two variables kept the same. Which liquid has the larger specific heat?

**Solution:**

1. The student changes the type of liquid. This is the **independent variable**.
2. The student measures the final temperature. This is the **dependent variable**.
3. Mass, starting temperature, heater power, and heating time are kept the same. These are the **controlled variables**.
4. Both liquids receive the same $Q$ and have the same $m$, so $\Delta T=\dfrac{Q}{mc}$ shows that the smaller $c$ gives the larger $\Delta T$.
5. The oil rose $15°C$ and the water rose $7°C$. So the oil has the smaller specific heat, and the water has the larger one.

If the masses were different, $\Delta T$ alone could not compare the specific heats.

## Speed Tricks & Shortcuts

To name a mechanism, ask what carries the energy: touching particles (conduction), moving fluid (convection), or electromagnetic waves (radiation).

Before a first-law problem, write the sign rule: $Q>0$ for heat in, $W>0$ for work done by the system, and $\Delta U=Q-W$. This works when the question uses that convention.

For a temperature change in one phase, use $Q=mc\Delta T$. If the temperature stays constant during a phase change, use $Q=mL$. If both happen, split the problem into stages and add the heats.

To compare materials, ask which variables are the same. If $Q$ and $m$ are equal, the smaller $c$ gives the larger $\Delta T$.

## Traps to Watch For

### #1: Saying an Object "Contains" Heat

> Heat is energy in transit between objects, not something an object stores.

An object has internal energy and a temperature. After heat has flowed in, the object has more internal energy.

### #2: Mixing Up Temperature and Heat

> Heat flow follows the temperature difference, not the amount of internal energy.

A large cool bath has more internal energy than a small hot cup. Heat still flows from the cup to the bath.

### #3: Using $Q=mc\Delta T$ Across a Phase Change

> During melting or boiling, energy goes in while the temperature stays constant.

Use $Q=mL$ for that part. A problem that crosses a phase change needs both formulas.

### #4: Thinking Convection Is Only "Hot Rises"

> Convection is heat carried by moving fluid, whether the fluid moves by density differences or is pushed by a fan or pump.

Natural convection often shows warm fluid rising, but forced convection does not depend on that. Convection does not occur in a solid.

### #5: Mixing Up Heat Flow Direction

> Heat flows by itself from hot to cold. It can be moved from cold to hot only with outside work.

A refrigerator moves heat out of its cold inside into the warmer kitchen, and it uses electrical work to do it.

### #6: Reading the Sign of Work Wrongly

> The sign of $W$ depends on the book's convention.

With $W$ as work done by the system, $\Delta U=Q-W$. With $W$ as work done on the system, $\Delta U=Q+W$. Check the convention before substituting.

### #7: Stating the Third Law as "Entropy Is Zero at $0\text{ K}$ for Everything"

> The zero-entropy statement is for a perfect crystal of a pure substance. The general statement is that $0\text{ K}$ cannot be reached in a finite number of steps.

Some substances can keep a leftover entropy at very low temperature. Do not apply the zero-entropy rule to them.

### #8: Comparing Specific Heats Without Controlling Mass

> Temperature change depends on $\dfrac{Q}{mc}$, not on $c$ alone.

A smaller $c$ gives a larger $\Delta T$ only when the heat and the mass are the same.
