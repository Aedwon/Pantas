---
_id: "lesson-physics-electricity-and-magnetism"
title: "Electricity and Magnetism"
summary: "Electric charge, Coulomb's law, current, voltage, Ohm's law, series and parallel circuits, electric power, magnetism, and electromagnetic induction."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 15
isActive: true
---
## Core Concept

### Electric Charge

Protons carry positive charge. Electrons carry negative charge. Like charges repel and opposite charges attract. Charge is never created or destroyed, only moved. The unit is the coulomb ($\mathrm{C}$).

In a **conductor**, such as metal, charge moves easily. In an **insulator**, such as rubber, it does not.

An object can be charged in three ways:

- **Friction:** rubbing moves electrons from one material to the other. The material that gains electrons becomes negative. The other becomes positive.
- **Contact:** a charged object touches a neutral one and shares its charge. Both end with the same sign.
- **Induction:** a charged object comes near a neutral conductor without touching. Charges in the conductor shift, and the near side gets the opposite sign. That is why a charged rod attracts a neutral object.

### Coulomb's Law and Electric Fields

For two small charges, the size of the electric force is

$$F=k\dfrac{|q_1q_2|}{r^2}$$

Here $r$ is the distance between the charges, and $k\approx9\times10^{9}\ \mathrm{N\cdot m^2/C^2}$. Double the distance and the force becomes one fourth.

An **electric field** is the force on each unit of positive test charge:

$$E=\dfrac{F}{q}$$

Its unit is $\mathrm{N/C}$. It points the way a positive charge would be pushed: away from positive charges and toward negative ones. A point charge $Q$ makes a field $E=k\dfrac{|Q|}{r^2}$.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"electric-field-pairs","illustrationKey":"science/physics/electricity-and-magnetism#1","cases":[{"charges":["positive","positive"],"fieldLines":"point away from each","force":"repel"},{"charges":["positive","negative"],"fieldLines":"connect positive to negative","force":"attract"}]} -->

### Current, Voltage, and Resistance

**Current** is the flow of charge: $I=\dfrac{Q}{t}$. Its unit is the ampere, $1\ \mathrm{A}=1\ \mathrm{C/s}$. By convention, current points the way positive charge would flow, from the positive terminal around the circuit to the negative one.

**Voltage**, or potential difference, is the energy given to each coulomb of charge: $V=\dfrac{W}{q}$. Its unit is the volt, $1\ \mathrm{V}=1\ \mathrm{J/C}$. A battery supplies voltage. A resistor uses it up.

**Resistance** $R$ measures how strongly a part opposes current. Its unit is the ohm ($\Omega$). For an **ohmic** part, whose resistance stays constant, **Ohm's law** applies:

$$V=IR$$

Ohm's law is not true for every device. A diode or a bulb filament whose resistance changes with temperature is not ohmic.

### Series and Parallel Circuits

Parts in **series** are in one loop, one after another. The same current passes through each part. The voltages add up to the source voltage, and the resistances add:

$$R_{eq}=R_1+R_2+\cdots$$

Parts in **parallel** are on separate branches. Each branch has the same voltage. The branch currents add up to the total current, and the resistances combine like this:

$$\dfrac{1}{R_{eq}}=\dfrac{1}{R_1}+\dfrac{1}{R_2}+\cdots$$

The equivalent resistance of a parallel set is smaller than the smallest branch.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"series-parallel-circuit","illustrationKey":"science/physics/electricity-and-magnetism#2","bulbsPerCircuit":2,"seriesPath":"single loop one after another","parallelPath":"separate side-by-side branches","batteryShown":true} -->

If one part of a series circuit fails open, the only path is broken and current stops everywhere. If one branch of a parallel circuit fails open, the other branches still work.

### Electric Power, Energy, and Safety

**Power** is energy used per second, in watts ($\mathrm{W}$):

$$P=IV$$

Energy is $E=Pt$. Utility bills use the kilowatt-hour ($\mathrm{kWh}$), the energy used by $1$ kW in $1$ hour. **Efficiency** is the useful energy out divided by the energy in, times $100\%$.

A **fuse** or circuit breaker opens the circuit when the current is too large. A **short circuit** is a path with very low resistance, so the current is very large. A ground wire gives stray current a safe path.

### Magnetism and Electromagnetism

Magnets have north and south poles. Like poles repel and unlike poles attract. A pole cannot be cut off alone, because a broken magnet gives two magnets, each with two poles.

A current makes a magnetic field. Around a long straight wire, point your right thumb along the conventional current. Your curled fingers show the field direction. A wire carrying current in a magnetic field feels a force. A **motor** uses this force to turn.

**Magnetic flux** is the amount of magnetic field passing through a loop:

$$\Phi=BA\cos\theta$$

Here $B$ is the field strength, $A$ is the loop area, and $\theta$ is the angle between the field and the line perpendicular to the loop. The unit is the weber ($\mathrm{Wb}$).

**Faraday's law** says a change in flux over time induces an emf, a voltage, in a loop of $N$ turns:

$$\mathcal{E}=-N\dfrac{\Delta\Phi}{\Delta t}$$

**Lenz's law** gives the sign. The induced current makes a magnetic field that opposes the **change** in flux. Current flows only if the loop is a closed conductor. A **generator** turns a coil in a magnetic field. The flux keeps changing, so it makes an emf.

## Examples

### #1: Coulomb's Law

Charges $+3.0\times10^{-6}\ \mathrm{C}$ and $-2.0\times10^{-6}\ \mathrm{C}$ are $0.30$ m apart. Find the force. Then find it if the distance is doubled.

**Solution:**

1. The charges are opposite, so the force is attraction.
2. The size is:

$$F=\dfrac{(9\times10^{9})(3.0\times10^{-6})(2.0\times10^{-6})}{0.30^2}=0.60\ \mathrm{N}$$

3. At $0.60$ m the force is one fourth: $0.15$ N.

### #2: Electric Field

A positive test charge of $2.0\times10^{-6}\ \mathrm{C}$ feels a force of $0.010$ N east. Find the field.

**Solution:**

$$E=\dfrac{F}{q}=\dfrac{0.010}{2.0\times10^{-6}}=5.0\times10^{3}\ \mathrm{N/C}$$

The field points east, the same way as the force on a positive charge.

### #3: Charging

A rubber rod rubbed with wool becomes negative. What charge does the wool have? The rod then touches a neutral metal ball. What charge does the ball get?

**Solution:**

1. Electrons moved from the wool to the rod, so the wool is positive.
2. Contact shares charge, so the ball becomes negative.

### #4: Current, Voltage, and Energy

A charge of $12$ C passes a point in $4.0$ s. A $12$ V battery moves $12$ C through a lamp. Find the current and the energy the battery gives.

**Solution:**

1. Current: $I=\dfrac{12}{4.0}=3.0$ A.
2. From $V=\dfrac{W}{q}$, the energy is $W=qV=(12)(12)=144$ J.

### #5: Ohm's Law

An ohmic resistor has resistance $10\ \Omega$ and carries a current of $2$ A. Find the voltage across it.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"ohms-law-circuit","illustrationKey":"science/physics/electricity-and-magnetism#3","resistanceOhms":10,"currentAmps":2,"voltageLabel":"?"} -->

**Solution:**

$$V=IR=(2)(10)=20\ \mathrm{V}$$

### #6: Series Circuit

A $12$ V battery is connected to a $2\ \Omega$ and a $4\ \Omega$ resistor in series. Find the current and the voltage across each resistor.

**Solution:**

1. $R_{eq}=2+4=6\ \Omega$.
2. $I=\dfrac{12}{6}=2$ A in both resistors.
3. Across the $2\ \Omega$ resistor: $(2)(2)=4$ V. Across the $4\ \Omega$ resistor: $(2)(4)=8$ V. The sum is $12$ V.

### #7: Parallel Circuit

A $12$ V battery is connected to a $6\ \Omega$ and a $12\ \Omega$ resistor in parallel. Find the total current.

**Solution:**

1. $\dfrac{1}{R_{eq}}=\dfrac{1}{6}+\dfrac{1}{12}=\dfrac{3}{12}$, so $R_{eq}=4\ \Omega$.
2. Total current: $\dfrac{12}{4}=3$ A.
3. Check by branches: $\dfrac{12}{6}=2$ A and $\dfrac{12}{12}=1$ A. They add to $3$ A.

### #8: Series vs. Parallel Failure

Two bulbs are in series. In a separate circuit, two bulbs are in parallel. One bulb fails open in each circuit. What happens to the other bulb?

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"circuit-failure","illustrationKey":"science/physics/electricity-and-magnetism#4","seriesOutcome":"other bulb goes dark","parallelOutcome":"other bulb stays lit","burnedOutBulbsPerCircuit":1} -->

**Solution:**

1. Series: the failed bulb breaks the only path, so the other bulb goes dark.
2. Parallel: the other branch is still a complete path, so its bulb stays lit.

### #9: Power, Energy, and Efficiency

A heater is rated $1{,}100$ W on a $220$ V supply. Find its current and the energy it uses in $3$ hours. Another device takes in $500$ J and gives out $400$ J of useful energy. Find its efficiency.

**Solution:**

1. Current: $I=\dfrac{P}{V}=\dfrac{1100}{220}=5.0$ A.
2. Energy: $(1.1\ \mathrm{kW})(3\ \mathrm{h})=3.3\ \mathrm{kWh}$.
3. Efficiency: $\dfrac{400}{500}\times100\%=80\%$.

### #10: Magnetic Field Direction

A long straight wire carries conventional current upward. Which way does the field go around the wire?

**Solution:**

1. Point your right thumb upward.
2. Your fingers curl counterclockwise when you look down from above.

### #11: Flux and Induced emf

A coil of $10$ turns has area $0.20\ \mathrm{m^2}$. A field of $0.50$ T is perpendicular to it. The field drops to zero in $0.020$ s. Find the size of the emf.

**Solution:**

1. Flux at first: $\Phi=BA\cos0^\circ=(0.50)(0.20)=0.10$ Wb.
2. The change in flux is $0.10$ Wb in $0.020$ s.
3. Size of the emf:

$$\mathcal{E}=10\times\dfrac{0.10}{0.020}=50\ \mathrm{V}$$

### #12: Direction by Lenz's Law

The north pole of a bar magnet moves toward a closed loop. Which way does the induced current go, as seen from the magnet's side?

**Solution:**

1. The flux from the north pole through the loop is growing.
2. The loop opposes this by making a field that points back toward the magnet. Its near face acts as a north pole.
3. By the right-hand rule, the current is counterclockwise as seen from the magnet.
4. If the magnet moves away, the flux shrinks, so the current reverses.

### #13: Generator

A coil spins in a magnetic field and lights a bulb. Why is there an emf?

**Solution:**

As the coil turns, its tilt to the field changes, so the flux changes. By Faraday's law, a changing flux induces an emf.

## Speed Tricks & Shortcuts

Series: same current, voltages add. Parallel: same voltage, currents add.

For two equal resistors in parallel, the equivalent resistance is half of one.

Faraday's law gives how big the emf is. Lenz's law gives the direction.

## Traps to Watch For

### #1: Forgetting the Square in Coulomb's Law

> The force depends on $\dfrac{1}{r^2}$, not $\dfrac{1}{r}$.

Doubling the distance cuts the force to one fourth, not one half.

### #2: Treating Ohm's Law as Universal

> Only ohmic parts have a constant $R$.

Many real devices are not ohmic.

### #3: Adding Parallel Resistances Directly

> In parallel, add the reciprocals.

Do not add the resistances. Check that the answer is smaller than the smallest branch.

### #4: Saying Lenz's Law Opposes the Field

> The induced effect opposes the **change** in flux.

If the flux shrinks, the induced field points the same way as the original field.

### #5: Saying Any Changing Field Makes Current

> Changing flux induces an emf. Current needs a closed conducting path.

An open loop has an emf but no steady current.
