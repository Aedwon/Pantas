---
_id: "lesson-physics-electricity-and-magnetism"
title: "Electricity and Magnetism"
summary: "Coulomb's law, Ohm's law, how series and parallel resistor circuits behave, and the basics of magnetism and induction."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

### Coulomb's Law and Electric Fields

For two stationary point charges, the magnitude of the electric force is

$$F = k\dfrac{|q_1q_2|}{r^2}$$

where $q_1$ and $q_2$ are the charges, $r$ is the distance between them, and $k$ is Coulomb's constant. The force acts along the line joining the charges. Like charges repel; opposite charges attract.

An **electric field** is defined by the force per unit positive test charge:

$$\vec E=\dfrac{\vec F}{q}$$

Field lines point away from positive charges and toward negative charges. The field is a physical vector field, not a material substance surrounding the charge.

<!-- ILLUSTRATION: two diagrams, one showing two positive charges with field lines pointing away from each and a repelling force arrow, one showing a positive and negative charge with field lines connecting them and an attracting force arrow -->

### Ohm's Law

For an **ohmic** component under conditions where its resistance can be treated as constant,

$$V=IR$$

where $V$ is the potential difference across the component, $I$ is current through it, and $R$ is resistance.

Ohm's law is an empirical linear relationship, not a universal law obeyed by every electrical device. Diodes, lamps whose resistance changes strongly with temperature, and many semiconductor devices can be non-ohmic.

### Electric Circuits

For ideal resistors connected **in series**, the same current passes through each resistor and the equivalent resistance is

$$R_{eq}=R_1+R_2+\cdots$$

The source voltage equals the sum of the potential drops around the loop.

For ideal resistors connected **in parallel**, each branch has the same potential difference across it and

$$\frac{1}{R_{eq}}=\frac{1}{R_1}+\frac{1}{R_2}+\cdots$$

The total current equals the sum of branch currents. Kirchhoff's junction and loop rules generalize these ideas to more complicated circuits.

<!-- ILLUSTRATION: two simple circuit diagrams side by side, a series circuit showing a battery connected to two bulbs in a single loop one after another, and a parallel circuit showing a battery connected to two bulbs on separate side-by-side branches -->

If a series component fails **open**, it breaks the only path and stops current everywhere. If one branch of a parallel circuit fails open, current can still flow through other complete branches. Real bulbs and devices are not always ideal resistors, so their brightness and current behavior can depend on source resistance and device characteristics.

### Magnetism and Electromagnetism

Magnets have north and south poles. Like poles repel and unlike poles attract, but magnetic poles are not simply electric charges with different names: isolated magnetic monopoles have not been observed, and ordinary magnetic field lines form closed loops.

Electric current produces magnetic fields. For a long straight wire, the magnetic field circles the wire; point your right thumb along **conventional current**, and your curled fingers show the magnetic-field direction.

A changing **magnetic flux** through a circuit induces an electromotive force (emf), described by Faraday's law:

$$\mathcal{E}=-\dfrac{d\Phi_B}{dt}$$

The minus sign represents **Lenz's law**: the induced emf drives current, when a closed conducting path exists, in a direction whose magnetic effect opposes the change in flux that produced it. A changing magnetic field therefore induces an electric field even if no conducting loop is present; current requires a conducting path.

## Examples

### #1: Applying Coulomb's Law Conceptually

Two point charges are moved to twice their original separation while their charges stay unchanged. By what factor does the force magnitude change?

**Solution:**

Because $F\propto1/r^2$,

$$F_{new}=\frac{F_{old}}{2^2}=\frac14F_{old}$$

### #2: Applying Ohm's Law

An ohmic resistor has resistance $10\ \Omega$ and carries a current of $2\text{ A}$. Find the potential difference across it.

<!-- ILLUSTRATION: a simple circuit with a battery, a 10 ohm resistor, and a 2 A current arrow, with the voltage across the battery marked "?" -->

**Solution:**

$$V=IR=(2)(10)=20\text{ V}$$

### #3: Series vs. Parallel Behavior

Assume each bulb acts as a circuit element that fails by becoming an open circuit. In a two-bulb series circuit, one bulb fails. In a separate two-branch parallel circuit, one bulb fails. What happens to the other bulb?

<!-- ILLUSTRATION: two circuits side by side: a series circuit with two bulbs on one loop (one burned out, the other goes dark) and a parallel circuit with two bulbs on separate branches (one burned out, the other stays lit) -->

**Solution:**

1. **Series:** the failed bulb opens the only current path, so both bulbs go out.
2. **Parallel:** only one branch is opened; the other complete branch can still carry current, so its bulb can remain lit.

### #4: Predicting Magnetic Field Direction

A long straight wire carries conventional current upward. Describe the magnetic-field direction using the right-hand rule.

**Solution:**

1. Point your right thumb upward, along the conventional current.
2. Your fingers curl in the direction of the magnetic field around the wire.
3. Viewed from above, looking toward the wire with the current pointing toward you, the field circles counterclockwise.

### #5: Changing Magnetic Flux

A bar magnet is pushed toward a conducting loop, increasing the magnetic flux through the loop. Why is an emf induced?

**Solution:**

1. The magnetic flux through the loop is changing with time.
2. Faraday's law says a changing flux induces an emf.
3. If the loop is closed, that emf can drive a current.
4. By Lenz's law, the induced current's magnetic field opposes the **change** in flux, not necessarily the original magnetic field itself.

## Speed Tricks & Shortcuts

For Coulomb-law distance changes, use the inverse-square rule only when the charges stay fixed and the point-charge approximation applies.

Use $V=IR$ only after identifying the component as ohmic or being told to treat $R$ as constant.

For resistor networks: series means same current; parallel means same voltage. For circuits that cannot be reduced cleanly to series/parallel combinations, use Kirchhoff's rules.

For induction, remember: Faraday tells you **how much emf** comes from changing flux; Lenz tells you the **direction**.

## Traps to Watch For

### #1: Dropping Direction from Coulomb's Law

> $k|q_1q_2|/r^2$ gives force magnitude; attraction or repulsion supplies the direction.

If using signed charges algebraically, a negative scalar result should not be confused with a negative force magnitude.

### #2: Treating Ohm's Law as Universal

> Only ohmic components have a linear $V$-$I$ relationship with constant $R$ over the relevant conditions.

Many real devices are non-ohmic, especially when temperature or semiconductor behavior matters.

### #3: Mixing Up Series and Parallel Resistor Rules

> Series: same current, resistances add. Parallel: same voltage, reciprocals of resistance add.

The simple rules assume components are actually connected in those topologies.

### #4: Saying Every Changing Magnetic Field "Creates Current"

> A changing magnetic flux induces an emf/electric field; current flows only if a suitable conducting path exists.

An open loop can have an induced emf without a sustained conduction current around the loop.

### #5: Saying Lenz's Law Opposes the Magnetic Field

> The induced effect opposes the **change in magnetic flux**.

If flux is decreasing, the induced field can point in the same direction as the original field in an attempt to oppose that decrease.
