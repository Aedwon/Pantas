---
_id: "lesson-chemistry-quantum-number-ranges-and-orbitals"
title: "Quantum Number Ranges and Orbitals"
summary: "Find allowed values for the four quantum numbers."
subject: "subject-science"
topic: "topic-chemistry"
isActive: true
part: 1
partCount: 3
ordering: 0
keyPoints:
  - "Find allowed values for the four quantum numbers."
  - "Distinguish an orbital from a subshell and find its electron capacity."
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

<!-- FIGURE: {"kind":"chemistry-diagram","type":"orbital-shapes","illustrationKey":"science/chemistry/quantum-numbers-electron-configuration#1","orbitals":[{"label":"s","shape":"sphere","capacity":2},{"label":"p","shape":"dumbbell","capacity":6},{"label":"d","shape":"four-lobed cloverleaf","capacity":10}]} -->

## Examples

### #1: Allowed Quantum Numbers

For an electron in a $3p$ subshell:

1. $n=3$.
2. $p$ means $\ell=1$.
3. Therefore $m_\ell=-1,0,+1$ are the possible orbital labels.
4. For each orbital, $m_s=+\tfrac12$ or $-\tfrac12$.

## Speed Tricks & Shortcuts

Never say "$p$ orbital holds six electrons." Say **$p$ subshell = three orbitals = six electrons maximum**.

Use the quantum-number ranges mechanically:

$$\ell=0,1,\ldots,n-1$$

$$m_\ell=-\ell,\ldots,+\ell$$

$$m_s=\pm\frac12$$

## Traps to Watch For

### #1: Confusing an Orbital with a Subshell

> Every single orbital holds at most two electrons.

The capacities $2,6,10,14$ belong to entire $s,p,d,f$ **subshells**.
