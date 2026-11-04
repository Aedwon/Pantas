---
_id: "lesson-physics-interference-diffraction-and-doppler"
title: "Interference, Diffraction and the Doppler Effect"
summary: "How overlapping waves add or cancel, how waves spread at edges and openings, and why a moving source or listener changes the pitch you hear."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 9
isActive: true
---
## Core Concept

Waves can overlap, spread out, and change pitch when something moves. This lesson covers **interference**, **diffraction** and the **Doppler effect**.

This lesson uses wavelength, frequency, wave speed and $v=f\lambda$. Read the Waves and Sound lesson first.

### Interference and Diffraction

Two waves can pass through each other. While they overlap, their displacements add. This adding is **interference**.

If two waves are **in phase** (at the same stage of the cycle at that point), crest meets crest and they make a bigger wave. This is **constructive interference**. If they are exactly opposite, crest meets trough, and they weaken or cancel each other. This is **destructive interference**. Two equal waves that are exactly opposite cancel completely.

For two matching sources that are in phase, the path difference at a listener decides which happens. The **path difference** is how much farther the listener is from one source than from the other. A path difference of $0$, $\lambda$, $2\lambda$, and so on gives constructive interference. A path difference of $\dfrac{\lambda}{2}$, $\dfrac{3\lambda}{2}$, and so on gives destructive interference.

**Diffraction** is the spreading of a wave as it passes an edge or through an opening. The spreading is strong when the opening is about as wide as the wavelength or narrower. It is weak when the opening is much wider than the wavelength.

This is why you hear a person talking around a corner but cannot see them. Speech wavelengths run from about $0.1\text{ m}$ to several meters, close to a doorway's width. Visible light has wavelengths of less than a millionth of a meter, so it hardly bends around the doorway.

Light shows both interference and diffraction, which is evidence that light behaves as a wave.

<!-- ILLUSTRATION: two panels of overlapping waves. Left panel, two identical waves in phase adding to a wave of double height, labeled "Constructive". Right panel, two identical waves exactly opposite adding to a flat line, labeled "Destructive". Below, a wave arriving at a wide gap passes mostly straight, and at a narrow gap about one wavelength wide it spreads out in a half circle, labeled "Diffraction" -->

### The Doppler Effect

The **Doppler effect** is a change in the frequency an observer receives because the source and the observer move relative to each other. The siren itself does not change its pitch. The listener hears a different pitch.

If the source and observer move toward each other, the observer hears a higher frequency. If they move apart, the observer hears a lower frequency.

Here is why a moving source changes the pitch. Each crest, once sent out, travels away at the speed of sound in the air. The source then moves a little before it sends the next crest.

In front of an approaching source, the crests are packed closer together, so the wavelength is shorter. Behind it, they are stretched, so the wavelength is longer.

The speed of sound in air does not change. So a shorter wavelength means a higher frequency at the listener, and a longer wavelength means a lower one.

Now take a source with frequency $f$ moving at speed $v_s$, with a listener at rest in still air. Let $v$ be the speed of sound in that air. In one period $T$, the source moves $v_sT$ toward the listener, so the wavelength in front is $\lambda'=(v-v_s)T=\dfrac{v-v_s}{f}$. The listener hears $f'=\dfrac{v}{\lambda'}$. This gives:

$$f'=\dfrac{v}{v-v_s}\,f\quad\text{(source approaching)}$$

$$f'=\dfrac{v}{v+v_s}\,f\quad\text{(source receding)}$$

These two formulas need the listener at rest in the air, the source moving straight toward or straight away from the listener, and $v_s<v$.

If the listener moves and the source is at rest, the wavelength in the air does not change. The listener meets crests faster when moving toward the source, so the pitch rises. Moving away, the pitch falls.

The Doppler effect also happens with light. This lesson uses the sound formulas above.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"doppler-ambulance","illustrationKey":"science/physics/waves-and-sound#4","source":"moving ambulance","ahead":{"wavelength":"shorter","pitch":"higher"},"behind":{"wavelength":"longer","pitch":"lower"}} -->

## Examples

### #1: Interference of Two Speakers

Two speakers, in phase, play the same $343\text{ Hz}$ tone in air where sound travels at $343\text{ m/s}$. A listener is $5.0\text{ m}$ from speaker A. Describe the sound if the listener is $5.5\text{ m}$ from speaker B, and then if the listener is $6.0\text{ m}$ from speaker B. Treat the room as open space.

**Solution:**

1. Find the wavelength:

$$\lambda=\dfrac{343}{343}=1.00\text{ m}$$

2. At $5.5\text{ m}$, the path difference is $5.5-5.0=0.5\text{ m}$, which is $\dfrac{\lambda}{2}$. A crest from one speaker meets a trough from the other, so the sound is quiet: **destructive**.

3. At $6.0\text{ m}$, the path difference is $6.0-5.0=1.0\text{ m}$, which is $\lambda$. Crest meets crest, so the sound is louder: **constructive**.

### #2: Diffraction Around an Opening

Sound of wavelength $1\text{ m}$ and light of wavelength $5\times10^{-7}\text{ m}$ both reach a doorway $1\text{ m}$ wide. Which wave spreads out more after the doorway?

<!-- ILLUSTRATION: top view of a doorway 1 m wide in a wall, with a wave source on each side of the wall: one labeled "sound, wavelength 1 m" and one labeled "light, wavelength 5 x 10^-7 m". Draw only the wall, the doorway and the labels, with no wave pattern beyond the doorway -->

**Solution:**

1. Compare the wavelength with the opening. The sound wavelength is about as wide as the doorway, so it spreads strongly.
2. The light wavelength is far smaller than the doorway, so it spreads very little and mostly goes straight.

The **sound** spreads more.

### #3: Doppler Effect Qualitatively

An ambulance siren sounds higher in pitch while approaching a stationary observer and lower after passing and moving away. Explain why.

**Solution:**

1. A moving source sends each crest from a new position.
2. In front of the approaching source, the crests are closer together, so the wavelength is shorter. The observer meets crests more often.
3. Behind the receding source, the crests are farther apart, so the observer meets them less often.
4. The observed frequency is higher during approach and lower during recession. The siren itself has not changed pitch, and the speed of sound in the air has not changed.

### #4: Doppler Frequency Calculation

A siren of frequency $700\text{ Hz}$ is on an ambulance moving at $20\text{ m/s}$ in still air where sound travels at $343\text{ m/s}$. A stationary observer is on the road ahead of the ambulance, then behind it. Find the frequency heard in each case.

**Solution:**

1. Approaching:

$$f'=\dfrac{v}{v-v_s}\,f=\dfrac{343}{343-20}(700)=\dfrac{343}{323}(700)\approx743\text{ Hz}$$

2. Receding:

$$f'=\dfrac{v}{v+v_s}\,f=\dfrac{343}{343+20}(700)=\dfrac{343}{363}(700)\approx661\text{ Hz}$$

3. The pitch is about $743\text{ Hz}$ on approach and about $661\text{ Hz}$ on recession. Both differ from $700\text{ Hz}$.

## Speed Tricks & Shortcuts

For a Doppler question, first find who is moving. Approach gives a higher heard frequency, and separation gives a lower one. This direction check holds for source motion and for observer motion. Use the source-motion formulas only when the listener is at rest in the air and the source moves along the line to the listener.

## Traps to Watch For

### #1: Saying the Doppler Effect Changes the Siren or the Speed of Sound

> The source keeps its own frequency. The speed of sound in the air stays the same. What changes is the frequency the observer receives.

A person riding in the ambulance moves with the siren and hears its own pitch. Your pitch differs because the crests reach you more or less often.
