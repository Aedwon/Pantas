---
_id: "lesson-chemistry-quantum-numbers-electron-configuration"
title: "Quantum Numbers and Electron Configuration"
summary: "This lesson teaches you the rules for arranging electrons into orbitals and how to write an atom's electron configuration."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

Electrons do not just float randomly around the nucleus. They fill specific regions of space called **orbitals**, grouped into energy levels, following a strict set of rules. The full description of WHERE an electron sits is its **electron configuration**.

### Orbital Types

Orbitals come in shapes labeled $s$, $p$, $d$, and $f$, each holding a maximum number of electrons: **s** orbitals hold up to $2$ electrons, **p** orbitals hold up to $6$, **d** orbitals hold up to $10$, and **f** orbitals hold up to $14$.

<!-- ILLUSTRATION: shapes of an s orbital (sphere), a p orbital (dumbbell/figure-eight shape), and a d orbital (four-lobed cloverleaf shape), labeled with their maximum electron capacities of 2, 6, and 10 -->

### Three Rules for Filling Orbitals

**Aufbau Principle**: electrons fill the LOWEST-energy orbitals FIRST, before moving to higher-energy ones. The general filling order is: $1s, 2s, 2p, 3s, 3p, 4s, 3d, 4p, \ldots$ (notice that $4s$ fills BEFORE $3d$, even though the number $3$ is smaller — this is a common surprise).

**Pauli Exclusion Principle**: each orbital can hold AT MOST $2$ electrons, and those two electrons must have OPPOSITE spins.

**Hund's Rule**: when filling a set of same-energy orbitals (like the three $p$ orbitals), electrons fill each one SINGLY first, before any orbital gets a SECOND electron. This is like people boarding a bus and each taking their own row before anyone doubles up.

### Writing Electron Configurations

An electron configuration lists each occupied orbital with the number of electrons it holds, written as a superscript. For example, oxygen (atomic number $8$, so $8$ electrons) is written:

$$1s^2 \, 2s^2 \, 2p^4$$

This means: the $1s$ orbital holds $2$ electrons, the $2s$ orbital holds $2$ electrons, and the $2p$ orbital holds $4$ electrons — adding up to $8$ total electrons.

## Examples

### #1: Writing a Simple Electron Configuration

Write the electron configuration for nitrogen, which has an atomic number of $7$.

**Solution:**
Fill orbitals in order (Aufbau), respecting each orbital's maximum capacity.

1. Nitrogen has $7$ electrons to place.
2. Fill $1s$ first, up to its maximum of $2$: $1s^2$. Remaining: $7 - 2 = 5$.
3. Fill $2s$ next, up to its maximum of $2$: $2s^2$. Remaining: $5 - 2 = 3$.
4. Fill $2p$ with the remaining $3$ electrons (its maximum is $6$, so it is not yet full): $2p^3$.
5. Full configuration: $1s^2 \, 2s^2 \, 2p^3$. Check the total: $2 + 2 + 3 = 7$. Correct.

### #2: Applying Hund's Rule

Three electrons must be placed into a set of three $p$ orbitals (each orbital shown as a box). Using Hund's Rule, show how these three electrons are arranged, and explain why they are NOT all placed into the same single orbital.

**Solution:**
Recall that Hund's Rule requires single occupation first.

1. Hund's Rule says electrons fill EACH available orbital in the set SINGLY before any orbital receives a second electron.
2. With three electrons and three separate $p$ orbitals available, each of the three orbitals gets exactly ONE electron, with all three electrons having the same (parallel) spin direction.
3. Placing all three electrons crammed into a single orbital would violate Hund's Rule (and would actually be a higher-energy, less stable arrangement) — electrons prefer to spread out across empty orbitals of the same energy first.

### #3: Finding an Element from Its Configuration

An atom has the electron configuration $1s^2 \, 2s^2 \, 2p^6 \, 3s^2 \, 3p^5$. Determine its atomic number and identify how many electrons are in its OUTERMOST energy level.

**Solution:**
Add up all the superscripts to find the total electron count, then check the highest energy level number.

1. Add the superscripts: $2 + 2 + 6 + 2 + 5 = 17$.
2. Since this is a neutral atom, the number of electrons equals the atomic number: atomic number $17$ (this is chlorine).
3. The outermost energy level is level $3$ (from $3s$ and $3p$), holding $2 + 5 = 7$ electrons.

### #4: The 4s-Before-3d Surprise

Explain why the electron configuration for potassium (atomic number $19$) fills the $4s$ orbital BEFORE the $3d$ orbital, even though the number $3$ is smaller than $4$.

**Solution:**
Recall that orbital filling order follows ENERGY, not simply the number in front of the letter.

1. The Aufbau principle fills orbitals in order of INCREASING ENERGY, not strictly by increasing principal quantum number.
2. Even though $3d$ has a smaller leading number than $4s$, the $4s$ orbital actually has SLIGHTLY LOWER energy than $3d$ in most atoms at this point in the periodic table.
3. So potassium's configuration is $1s^2 \, 2s^2 \, 2p^6 \, 3s^2 \, 3p^6 \, 4s^1$, filling $4s$ before any electrons go into $3d$, matching the established filling order: $\ldots 3p, 4s, 3d, 4p \ldots$

## Speed Tricks & Shortcuts

Memorize the filling order as one continuous sequence: $1s, 2s, 2p, 3s, 3p, 4s, 3d, 4p, 5s, 4d, 5p, 6s, 4f, 5d, 6p, 7s, 5f, 6d$. Writing this order out once on scratch paper before starting a configuration problem prevents order mistakes.

To quickly check a finished configuration, add up ALL the superscripts — the total must exactly equal the atom's number of electrons (its atomic number, if neutral).

For "how many electrons in the outermost level" questions, look only at the terms with the HIGHEST leading number (like the $3s$ and $3p$ terms when the configuration ends there) and add their superscripts together.

## Traps to Watch For

### #1: Filling Orbitals Out of Energy Order

> Follow the ESTABLISHED filling order ($4s$ before $3d$, for example), not simply increasing principal quantum numbers in strict numerical sequence.

A common mistake writes $3d$ before $4s$ because "$3$ comes before $4$." The actual energy-based filling order places $4s$ before $3d$, as shown by real, tested electron configurations for elements like potassium and calcium.

### #2: Exceeding an Orbital's Maximum Capacity

> $s$ holds at most $2$, $p$ holds at most $6$, $d$ holds at most $10$, $f$ holds at most $14$.

Writing something like $2p^8$ is impossible, since a $p$ subshell can never hold more than $6$ electrons. Always double check that no superscript exceeds its orbital type's known maximum.

### #3: Violating Hund's Rule by Pairing Too Early

> Electrons fill EACH orbital in a same-energy set SINGLY before any orbital gets a second (paired) electron.

For three electrons entering three separate $p$ orbitals, placing two electrons in one orbital and leaving another orbital completely empty violates Hund's Rule. The lowest-energy, correct arrangement spreads single electrons across all available orbitals of that set first.

### #4: Forgetting That Ions Change the Electron Count Before Configuring

> For an ION, add or remove electrons from the NEUTRAL atom's count BEFORE writing the configuration — do not just use the atomic number directly.

A question asking for the electron configuration of $Na^+$ (a sodium ion, not neutral sodium) requires REMOVING one electron from neutral sodium's $11$ electrons, giving only $10$ electrons to place, not the full $11$ used for the neutral atom.
