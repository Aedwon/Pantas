---
_id: "lesson-chemistry-quantum-numbers-electron-configuration"
title: "Quantum Numbers and Electron Configuration"
summary: "How quantum numbers label atomic orbitals and electrons, how subshells differ from orbitals, and how ground-state electron configurations are built."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 14
isActive: true
---
## Core Concept

The quantum-mechanical atom does not place electrons on fixed classical paths. **Atomic orbitals** are quantum states described by wavefunctions and associated probability distributions. Orbitals are grouped into **subshells**, and electron configurations record how electrons occupy those subshells.

### The Four Quantum Numbers

An electron in an atom is described by four quantum numbers.

1. **Principal quantum number, $n$**: positive integers $1,2,3,\ldots$. It identifies the principal shell and is strongly related to orbital size and energy.
2. **Angular-momentum quantum number, $\ell$**: integer values from $0$ to $n-1$. It identifies the subshell type:
   - $\ell=0$: $s$
   - $\ell=1$: $p$
   - $\ell=2$: $d$
   - $\ell=3$: $f$
3. **Magnetic quantum number, $m_\ell$**: integers from $-\ell$ through $+\ell$. These values label the individual orbitals within a subshell.
4. **Spin quantum number, $m_s$**: $+\tfrac12$ or $-\tfrac12$.

The **Pauli exclusion principle** says no two electrons in one atom can have the same set of all four quantum numbers. Consequently, one orbital can hold at most **two electrons**, with opposite spin quantum numbers.

### Orbitals vs. Subshells

This distinction is essential:

| Subshell | $\ell$ | Number of orbitals | Maximum electrons |
| --- | ---: | ---: | ---: |
| $s$ | 0 | 1 | 2 |
| $p$ | 1 | 3 | 6 |
| $d$ | 2 | 5 | 10 |
| $f$ | 3 | 7 | 14 |

So a **$p$ subshell** can contain six electrons, but each of its **three $p$ orbitals** can contain only two.

<!-- ILLUSTRATION: one s orbital, three p orbitals, five d orbitals, and seven f orbitals grouped by subshell, each orbital represented as a box able to hold two opposite-spin arrows -->

### Ground-State Filling Rules

**Aufbau principle:** construct approximate ground-state configurations by placing electrons into available lower-energy subshells first.

A commonly used order begins:

$$1s,\ 2s,\ 2p,\ 3s,\ 3p,\ 4s,\ 3d,\ 4p,\ 5s,\ 4d,\ldots$$

This is a practical pattern, not a statement that subshell energies are fixed independently of electron occupancy and atomic number. There are well-known exceptions to the simplest predicted configurations, such as chromium and copper.

**Hund's rule:** within a set of degenerate orbitals, the lowest-energy arrangement places electrons singly with parallel spins before pairing them.

**Pauli exclusion principle:** an orbital contains at most two electrons, and paired electrons have opposite $m_s$ values.

### Electron Configuration

An expression such as

$$1s^2\,2s^2\,2p^4$$

means two electrons in the $1s$ subshell, two in $2s$, and four distributed among the three $2p$ orbitals according to Pauli and Hund rules.

The superscript is the number of electrons in the **subshell**, not one orbital.

## Examples

### #1: Nitrogen

Neutral nitrogen has $7$ electrons.

$$1s^2\,2s^2\,2p^3$$

The three $2p$ electrons occupy the three degenerate $p$ orbitals singly with parallel spins in the ground-state orbital diagram.

### #2: Allowed Quantum Numbers

For an electron in a $3p$ subshell:

1. $n=3$.
2. $p$ means $\ell=1$.
3. Therefore $m_\ell=-1,0,+1$ are the possible orbital labels.
4. For each orbital, $m_s=+\tfrac12$ or $-\tfrac12$.

### #3: Chlorine from a Configuration

$$1s^2\,2s^2\,2p^6\,3s^2\,3p^5$$

1. Total electrons: $2+2+6+2+5=17$.
2. For a neutral atom, $Z=17$: chlorine.
3. The highest principal shell is $n=3$, containing $3s^2+3p^5=7$ electrons.

For a main-group atom such as chlorine, these are its outer-shell valence electrons.

### #4: Why Potassium Uses $4s$ Before $3d$

Neutral potassium's observed ground-state configuration is

$$[Ar]4s^1.$$

The empirical/quantum-mechanical subshell-energy ordering for potassium places $4s$ below $3d$ when that electron is added. However, after $3d$ orbitals become occupied in transition metals, relative energies shift; this helps explain why transition-metal cations commonly lose $4s$ electrons before $3d$ electrons.

## Speed Tricks & Shortcuts

Never say "$p$ orbital holds six electrons." Say **$p$ subshell = three orbitals = six electrons maximum**.

Use the quantum-number ranges mechanically:

$$\ell=0,1,\ldots,n-1$$

$$m_\ell=-\ell,\ldots,+\ell$$

$$m_s=\pm\frac12$$

Add configuration superscripts to check total electron count.

Use the diagonal/Aufbau order for introductory configurations, but remember that actual ground-state data contain exceptions and ionization order can differ from naive filling order.

## Traps to Watch For

### #1: Confusing an Orbital with a Subshell

> Every single orbital holds at most two electrons.

The capacities $2,6,10,14$ belong to entire $s,p,d,f$ **subshells**.

### #2: Saying Electron Configuration Fully Specifies "Where an Electron Sits"

> Electron configurations specify subshell occupations; quantum mechanics does not assign electrons fixed classical locations or paths.

An orbital is a quantum state/probability distribution.

### #3: Treating Aufbau Order as Exceptionless

> Chromium, copper, and several heavier elements differ from the simplest predicted filling pattern.

Use observed ground-state configurations when exact data are required.

### #4: Removing Electrons from Transition-Metal Ions in the Wrong Order

> Although $4s$ is filled before $3d$ for potassium and calcium, transition-metal cations generally lose the highest-$n$ $4s$ electrons before $3d$ electrons.

Filling order and ionization order are not identical rules.
