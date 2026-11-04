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

Protons carry positive charge. Electrons carry negative charge. Like charges repel and opposite charges attract.

An object with equal positive and negative charge is **neutral**.

Total charge is conserved: charge moves from place to place, but the total stays the same. The unit is the coulomb ($\mathrm{C}$).

In a **conductor**, such as metal, charge moves easily. In an **insulator**, such as rubber, it does not.

An object can be charged in three ways. In ordinary solids, the electrons move, because the protons stay fixed in the atoms.

- **Friction:** rubbing moves electrons from one material to the other. The material that gains electrons becomes negative. The other becomes positive.
- **Contact:** a charged object touches a neutral one and shares its charge. Both end with the same sign.
- **Induction:** a charged rod comes near a neutral conductor without touching. While the rod is near, the conductor must be able to send electrons to or from another conductor. That other conductor can be the ground (the Earth, which can take or give many electrons), or a second neutral conductor that touches it and is then separated.

Here is how charging by induction works. Say a negative rod comes near a neutral metal ball. Electrons in the ball are pushed away to the far side, so the near side is positive.

Now touch the ball to the ground. Electrons flow away from the ball into the ground. Remove the ground connection first, then the rod. The ball is left with a net positive charge, the opposite of the rod's charge.

You can also use two neutral metal spheres that touch. The negative rod pushes electrons to the far sphere.

Separate the spheres while the rod is still near, then remove the rod. The near sphere is left positive and the far sphere negative.

If a single ball has no path for electrons to leave, it only shifts its charges. This is called polarization. The ball is still neutral overall, but its near side is closer to the rod, so the rod attracts it.

This is why a charged rod can pick up bits of neutral paper. Paper is an insulator, but its atoms still shift.

### Coulomb's Law and Electric Fields

For two point charges (charges so small that their size does not matter), the size of the electric force is

$$F=k\dfrac{|q_1q_2|}{r^2}$$

Here $r$ is the distance between the charges, and $k\approx9\times10^{9}\ \mathrm{N\cdot m^2/C^2}$ in air or empty space. The bars $|\ |$ mean we use the size of each charge, not its sign. The signs only tell if the force is a push or a pull.

Double the distance and the force becomes one fourth.

An **electric field** is the force on each unit of a tiny positive test charge:

$$E=\dfrac{F}{q}$$

Its unit is $\mathrm{N/C}$, where the newton ($\mathrm{N}$) is the unit of force. It points the way a positive charge would be pushed: away from positive charges and toward negative ones. A point charge $Q$ makes a field $E=k\dfrac{|Q|}{r^2}$.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"electric-field-pairs","illustrationKey":"science/physics/electricity-and-magnetism#1","cases":[{"charges":["positive","positive"],"fieldLines":"point away from each","force":"repel"},{"charges":["positive","negative"],"fieldLines":"connect positive to negative","force":"attract"}]} -->

### Current, Voltage, and Resistance

**Current** is the flow of charge. For a steady flow, it is the charge $Q$ that passes a point each second: $I=\dfrac{Q}{t}$. Its unit is the ampere, $1\ \mathrm{A}=1\ \mathrm{C/s}$.

By convention, current points the way positive charge would flow, from the positive terminal (where a wire joins the battery) around the circuit to the negative one. This is called **conventional current**. In a metal wire, the electrons really move the other way.

**Voltage**, or potential difference, is the energy for each coulomb of charge: $V=\dfrac{W}{q}$. Its unit is the volt, $1\ \mathrm{V}=1\ \mathrm{J/C}$, where the joule ($\mathrm{J}$) is the unit of energy.

A battery gives each coulomb energy, so the battery supplies voltage. Here, a battery keeps the same voltage whatever the current. A resistor changes that energy to heat or light, so the voltage drops across it.

**Resistance** $R$ measures how strongly a part opposes current. Its unit is the ohm ($\Omega$). For an **ohmic** part, whose resistance stays constant, **Ohm's law** applies:

$$V=IR$$

Ohm's law is not true for every device. A diode or a bulb filament whose resistance changes with temperature is not ohmic.

### Series and Parallel Circuits

The **equivalent resistance** $R_{eq}$ is the one resistance that could replace the whole set. It would draw the same current from the same voltage.

Parts in **series** are in one loop, one after another. The same current passes through each part. The voltages add up to the source voltage, and the resistances add:

$$R_{eq}=R_1+R_2+\cdots$$

Parts in **parallel** are on separate branches. Each branch has the same voltage. The branch currents add up to the total current, and the resistances combine like this:

$$\dfrac{1}{R_{eq}}=\dfrac{1}{R_1}+\dfrac{1}{R_2}+\cdots$$

With two or more branches that all have resistance above $0$, the equivalent resistance of a parallel set is smaller than the smallest branch. More branches give the current more paths.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"series-parallel-circuit","illustrationKey":"science/physics/electricity-and-magnetism#2","bulbsPerCircuit":2,"seriesPath":"single loop one after another","parallelPath":"separate side-by-side branches","batteryShown":true} -->

If one part of a series circuit fails open (breaks, leaving a gap), the only path is broken and current stops everywhere. If one branch of a parallel circuit fails open, the other branches still work, because each has its own path to the source.

### Electric Power, Energy, and Safety

**Power** is energy used per second, in watts ($\mathrm{W}$):

$$P=IV$$

For steady power, the energy used is $W=Pt$. Utility bills use the kilowatt-hour ($\mathrm{kWh}$), the energy used by $1$ kW in $1$ hour. One kilowatt is $1{,}000$ W. **Efficiency** is the useful energy out divided by the energy in, times $100\%$.

A large current heats the wires, and hot wires can start a fire. A **fuse** or circuit breaker opens the circuit when the current is too large.

The appliances in a home are in parallel on the same line. When they are on, adding appliances adds their currents.

A **short circuit** is a path with very low resistance, so the current is very large. A ground wire gives stray current a safe path.

### Magnetism and Electromagnetism

Magnets have north and south poles. Like poles repel and unlike poles attract. Breaking a magnet does not give a single pole. Each piece has two poles.

A current makes a **magnetic field**, the space where magnets and currents feel forces. Around a long straight wire, point your right thumb along the conventional current. Your curled fingers show the field direction.

A coil of wire (a loop) uses the same hand in a different way. Curl your right fingers around the loop the way the current goes. Your thumb shows the way the field points through the loop.

The face of the loop where the field comes out acts as a north pole. The other face acts as a south pole.

The field strength is $B$. Its unit is the tesla ($\mathrm{T}$). One tesla pushes with $1$ N on each meter of wire that carries $1$ A at a right angle to the field: $1\ \mathrm{T}=1\ \mathrm{N/(A\cdot m)}$.

**Magnetic flux** is the amount of magnetic field passing through a loop:

$$\Phi=BA\cos\theta$$

Here $A$ is the loop area. The angle $\theta$ is between the field and the line perpendicular (at a right angle) to the loop. The unit is the weber, and $1\ \mathrm{Wb}=1\ \mathrm{T\cdot m^2}$.

This works for a flat loop in an even field. Flux is largest when the field is perpendicular to the loop ($\theta=0^\circ$). It is zero when the field runs along the loop ($\theta=90^\circ$).

The **cosine** ($\cos$) of an angle is a number that depends on the angle. From $0^\circ$ to $90^\circ$, it falls from $\cos0^\circ=1$ to $\cos90^\circ=0$. At $\theta=0^\circ$, then, $\Phi=BA$.

An **emf** (electromotive force) is a voltage made by a source, in volts. A battery has an emf.

Another way to make an emf is to change the flux through a loop. We say the emf is **induced**, which means it is made by the changing flux. This is not the charging by induction above.

**Faraday's law** says a change in flux over time induces an emf in a loop of $N$ turns (the wire goes around $N$ times):

$$\mathcal{E}=-N\dfrac{\Delta\Phi}{\Delta t}$$

This gives the average emf over the time $\Delta t$. The flux can change if $B$, $A$ or $\theta$ changes.

**Lenz's law** gives the sign. The induced current makes a magnetic field that opposes the change in flux.

If the flux grows, the induced field points against the original field. If the flux shrinks, it points the same way.

An emf appears even in an open loop. Current flows only if the loop is a closed conductor.

A wire with current in a magnetic field feels a force. The force is greatest when the wire is perpendicular to the field. It is zero when the wire is parallel to the field.

A **motor** uses this force to turn. A coil sits in a magnetic field. The current goes opposite ways in the two sides of the coil, so the two forces are opposite and the coil turns.

A motor changes electrical energy mostly to motion, and some to heat. A simple direct-current motor must reverse the current every half turn to keep the coil turning the same way.

A **generator** does the reverse. Something turns a coil in a magnetic field, about an axis across the field. The angle $\theta$ keeps changing, so the flux keeps changing and the coil makes an emf.

A generator changes motion to electrical energy.

## Examples

### #1: Coulomb's Law

Charges $+3.0\times10^{-6}\ \mathrm{C}$ and $-2.0\times10^{-6}\ \mathrm{C}$ are $0.30$ m apart. Find the force. Then find it if the distance is doubled.

**Solution:**

1. The charges are opposite, so the force is attraction.
2. The size is:

$$F=\dfrac{(9\times10^{9})(3.0\times10^{-6})(2.0\times10^{-6})}{0.30^2}$$

$$F=0.60\ \mathrm{N}$$

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

### #4: Charging by Induction

A negatively charged rod is brought near a neutral metal ball on an insulating stand. The ball is touched to the ground. The ground connection is removed, then the rod is removed. What is the final charge of the ball? What happens if this single ball is never given any path for electrons to leave?

**Solution:**

1. The negative rod pushes electrons in the ball to the far side. The near side is positive.
2. The ground lets electrons flow out of the ball. The ball now has fewer electrons than protons.
3. Removing the ground first, then the rod, traps this. The ball is left positive, the opposite of the rod.
4. With no path out, no electrons leave. The ball stays neutral overall and is only polarized.

### #5: Current, Voltage, and Energy

A charge of $12$ C passes a point in $4.0$ s. A $12$ V battery moves $12$ C through a lamp. Find the current and the energy the battery gives.

**Solution:**

1. Current:

$$I=\dfrac{12}{4.0}=3.0\ \mathrm{A}$$

2. From $V=\dfrac{W}{q}$, the energy is:

$$W=qV=(12)(12)=144\ \mathrm{J}$$

### #6: Ohm's Law

An ohmic resistor has resistance $10\ \Omega$ and carries a current of $2$ A. Find the voltage across it.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"ohms-law-circuit","illustrationKey":"science/physics/electricity-and-magnetism#3","resistanceOhms":10,"currentAmps":2,"voltageLabel":"?"} -->

**Solution:**

$$V=IR=(2)(10)=20\ \mathrm{V}$$

### #7: Series Circuit

A $12$ V battery is connected to a $2\ \Omega$ and a $4\ \Omega$ resistor in series. Find the current and the voltage across each resistor.

**Solution:**

1. Add the resistances:

$$R_{eq}=2+4=6\ \Omega$$

2. Find the current. It is the same in both resistors:

$$I=\dfrac{12}{6}=2\ \mathrm{A}$$

3. Find each voltage:

$$V_{2}=(2)(2)=4\ \mathrm{V},\quad V_{4}=(2)(4)=8\ \mathrm{V}$$

4. The sum is $4+8=12$ V, the battery voltage.

### #8: Parallel Circuit

A $12$ V battery is connected to a $6\ \Omega$ and a $12\ \Omega$ resistor in parallel. Find the total current.

**Solution:**

1. Combine the reciprocals:

$$\dfrac{1}{R_{eq}}=\dfrac{1}{6}+\dfrac{1}{12}=\dfrac{3}{12}$$

2. So $R_{eq}=4\ \Omega$. This is smaller than $6\ \Omega$, as it should be.
3. Total current:

$$I=\dfrac{12}{4}=3\ \mathrm{A}$$

4. Check by branches: $\dfrac{12}{6}=2$ A and $\dfrac{12}{12}=1$ A. They add to $3$ A.

### #9: Series vs. Parallel Failure

Two bulbs are in series. In a separate circuit, two bulbs are in parallel. One bulb fails open in each circuit. What happens to the other bulb?

**Solution:**

1. Series: the failed bulb breaks the only path, so the other bulb goes dark.
2. Parallel: the other branch is still a complete path, so its bulb stays lit.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"circuit-failure","illustrationKey":"science/physics/electricity-and-magnetism#4","seriesOutcome":"other bulb goes dark","parallelOutcome":"other bulb stays lit","burnedOutBulbsPerCircuit":1} -->

### #10: Power, Energy, and Efficiency

A heater is rated $1{,}100$ W on a $220$ V supply. Find its current and the energy it uses in $3$ hours. Another device takes in $500$ J and gives out $400$ J of useful energy. Find its efficiency.

**Solution:**

1. Current, from $P=IV$:

$$I=\dfrac{P}{V}=\dfrac{1100}{220}=5.0\ \mathrm{A}$$

2. Energy, with $1{,}100$ W $=1.1$ kW:

$$W=Pt=(1.1\ \mathrm{kW})(3\ \mathrm{h})=3.3\ \mathrm{kWh}$$

3. Efficiency:

$$\dfrac{400}{500}\times100\%=80\%$$

### #11: Magnetic Field Direction

A long straight wire carries conventional current upward. Which way does the field go around the wire?

**Solution:**

1. Point your right thumb upward.
2. Your fingers curl counterclockwise when you look down from above.

### #12: Flux and Induced emf

A coil of $10$ turns has area $0.20\ \mathrm{m^2}$. A magnetic field of $0.50$ T (tesla) is perpendicular to it. The field drops to zero in $0.020$ s. Find the size of the emf.

**Solution:**

1. A field perpendicular to the coil means $\theta=0^\circ$. Flux at first:

$$\Phi=BA\cos0^\circ=(0.50)(0.20)=0.10\ \mathrm{Wb}$$

2. The flux falls to zero, so the change is $0.10$ Wb in $0.020$ s.
3. Size of the average emf:

$$\mathcal{E}=10\times\dfrac{0.10}{0.020}=50\ \mathrm{V}$$

### #13: Direction by Lenz's Law

The north pole of a bar magnet moves toward a closed loop. Which way does the induced current go, as seen from the magnet's side?

**Solution:**

1. The flux from the north pole through the loop is growing.
2. The loop opposes this by making a field through it that points back toward the magnet. So the near face acts as a north pole.
3. Use the loop rule. Point your right thumb toward the magnet, which is toward you as you look at the loop. Your fingers curl counterclockwise.
4. So the current is counterclockwise as seen from the magnet.
5. If the magnet moves away, the flux shrinks, so the current reverses to clockwise.

### #14: Generator

A coil spins in a magnetic field and lights a bulb. Why is there an emf?

<!-- ILLUSTRATION: A rectangular coil between a north and a south magnet pole, shown at three angles, 0 degrees, 45 degrees and 90 degrees to the field and a bulb connected to the coil -->

**Solution:**

As the coil turns, the angle $\theta$ between its perpendicular line and the field changes, so $\cos\theta$ and the flux change. By Faraday's law, a changing flux induces an emf.

The motion of the coil supplies the energy that becomes electrical energy.

### #15: Motor

A motor on a $12$ V supply carries $3.0$ A. It gives out $28.8$ W of useful power as motion. Find the electrical power it takes in and its efficiency. What energy change does the motor make?

**Solution:**

1. Power in:

$$P=IV=(3.0)(12)=36\ \mathrm{W}$$

2. Efficiency:

$$\dfrac{28.8}{36}\times100\%=80\%$$

3. The motor changes electrical energy to motion. The rest of the energy leaves as heat.

### #16: Fuse and Overload

A $220$ V line has a $10$ A fuse. A heater of $1{,}100$ W and an iron of $1{,}000$ W run on it together. A kettle of $600$ W is then plugged in. What happens, and why?

**Solution:**

1. The appliances are in parallel, so their currents add. Find the total power:

$$1{,}100+1{,}000=2{,}100\ \mathrm{W}$$

2. Find the current:

$$I=\dfrac{P}{V}=\dfrac{2100}{220}\approx9.5\ \mathrm{A}$$

This is below $10$ A, so the fuse stays closed.
3. With the kettle, the total power is $2{,}700$ W:

$$I=\dfrac{2700}{220}\approx12.3\ \mathrm{A}$$

4. This is more than $10$ A, so the fuse opens and stops the current. This keeps the wires from overheating.

## Speed Tricks & Shortcuts

For a simple series circuit: same current, voltages add. For a simple parallel circuit: same voltage on each branch, currents add.

For two equal resistors in parallel, the equivalent resistance is half of one. For $n$ equal resistors it is one resistor divided by $n$.

Faraday's law gives how big the emf is. Lenz's law gives the direction.

## Traps to Watch For

### #1: Forgetting the Square in Coulomb's Law

> The force depends on $\dfrac{1}{r^2}$, not $\dfrac{1}{r}$.

Doubling the distance cuts the force to one fourth, not one half.

### #2: Treating Ohm's Law as Universal

> Ohm's law with one constant $R$ fits only ohmic parts.

A bulb filament and a diode are examples. For these, $R=\dfrac{V}{I}$ still gives the resistance at one moment, but it changes as the current changes.

### #3: Adding Parallel Resistances Directly

> In parallel, add the reciprocals.

Do not add the resistances. Check that the answer is smaller than the smallest branch.

### #4: Saying Lenz's Law Opposes the Field

> The induced effect opposes the change in flux, not the flux itself.

If the flux shrinks, the induced field points the same way as the original field. If the flux grows, it points the other way.

### #5: Saying Any Changing Field Makes Current

> Changing flux induces an emf. Current needs a closed conducting path.

An open loop has an emf but no current.
