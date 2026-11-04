---
_id: "lesson-physics-light-and-optics"
title: "Light: Reflection, Refraction and the Electromagnetic Spectrum"
summary: "How light reflects and refracts, when it is trapped inside a material, and how the electromagnetic spectrum is ordered."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 15
isActive: true
---
## Core Concept

**Optics** is the part of physics that studies light and how it acts when it meets matter. This lesson uses **geometric optics**, where light is drawn as straight lines called **rays**. That drawing works well when the objects and openings are much larger than the wavelength of the light.

A **medium** is the material light travels through, such as air, water, or glass. A **boundary** is the surface where one medium meets another.

You will use the **sine** of an angle. For angles from $0^\circ$ to $90^\circ$, the sine is a number from $0$ to $1$, and a bigger angle has a bigger sine. To get an angle back from its sine, use the inverse sine key on a calculator, written $\sin^{-1}$.

### Reflection

**Reflection** is light bouncing off a surface. The **normal** is an imaginary line at $90^\circ$ to the surface, drawn at the point where the ray lands.

The **angle of incidence** $\theta_i$ is the angle between the incoming ray and the normal. The **angle of reflection** $\theta_r$ is the angle between the bounced ray and the normal.

The **law of reflection** says the two angles are equal. The incoming ray, the reflected ray and the normal all lie in one flat plane.

$$\theta_i=\theta_r$$

<!-- FIGURE: {"kind": "concept-diagram", "type": "ray-reflection", "labels": ["Incident ray", "Normal line", "Reflected ray"], "angles": ["Angle of incidence", "Angle of reflection"], "semanticsLabel": "A flat mirror with a normal line showing an incoming incident ray and an outgoing reflected ray at equal angles."} -->

A smooth flat surface, such as a plane mirror, sends parallel rays out in one direction. A rough surface, such as paper, sends them in many directions, and each tiny part of it still obeys the law of reflection. Curved mirrors are taught in the Mirrors and Lenses lesson.

A flat (plane) mirror makes an image that is upright and the same size as the object. The image looks as far behind the mirror as the object is in front. It is a **virtual image**, explained in the Mirrors and Lenses lesson.

### Refraction

**Refraction** is the bending of light, a change in its direction, as it passes from one medium into another. It is caused by the change in the speed of light at the boundary. If the ray meets the boundary at a slant, the change in speed turns the ray. A ray along the normal changes speed but does not bend. The **angle of incidence** and the **angle of refraction** are again measured from the normal.

The **index of refraction** $n$ of a material tells how much it slows light. Here $c$ is the speed of light in vacuum, about $3.00\times10^{8}$ m/s, and $v$ is the speed in the material.

$$n=\dfrac{c}{v}$$

Vacuum has $n=1$, and air is very close to $1$. A bigger $n$ means slower light. This lesson uses about $1.33$ for water and $1.50$ for glass.

**Snell's law** links the angles on the two sides. Medium $1$ is where the ray comes from. Medium $2$ is where it goes.

$$n_1\sin\theta_1=n_2\sin\theta_2$$

Use Snell's law to find the direction:

- If $n_2>n_1$, the light slows down and bends **toward the normal**.
- If $n_2<n_1$, the light speeds up and bends **away from the normal**.
- If $n_2=n_1$, or the ray travels along the normal ($\theta_1=0$), the direction does not change. The speed still changes if $n_2\ne n_1$.

A wave has a **frequency** $f$, the number of wave crests that pass a point each second, measured in hertz (Hz). It also has a **wavelength** $\lambda$, the distance between two neighboring crests, measured in meters or nanometers (nm, where $1$ nm $=10^{-9}$ m). Wave speed, frequency and wavelength are linked by $v=f\lambda$, from the waves and sound lesson. In the Mirrors and Lenses lesson, $f$ also stands for focal length, so check which one is meant.

When light crosses a boundary, its frequency stays the same. The speed changes, so the wavelength changes too. In a material, the wavelength is

$$\lambda=\dfrac{\lambda_0}{n}$$

where $\lambda_0$ is the wavelength in vacuum.

At a real boundary, part of the light usually reflects and part refracts at the same time.

### Critical Angle and Total Internal Reflection

Take light going from a higher-$n$ medium to a lower-$n$ medium, such as glass to air. It bends away from the normal. If you raise the angle of incidence, the refracted ray leans over more and more.

At one special angle, the refracted ray skims along the boundary at $90^\circ$. This is the **critical angle** $\theta_c$. Put $\theta_2=90^\circ$ in Snell's law:

$$\sin\theta_c=\dfrac{n_2}{n_1}$$

If the angle of incidence is bigger than $\theta_c$, no light passes out. All of it reflects back into the first medium by the law of reflection. This is **total internal reflection**.

Two conditions must both hold. The light must start in the medium with the larger $n$ ($n_1>n_2$), and the angle of incidence must be bigger than $\theta_c$. If $n_1<n_2$, there is no critical angle, because the sine in the formula would be bigger than $1$.

Total internal reflection is how an optical fiber works. Light stays inside the glass core because the core has a higher $n$ than the layer around it, and the light hits the wall at large angles.

<!-- ILLUSTRATION: three ray diagrams of a ray going from glass (n = 1.50) up into air at a flat boundary with a normal line: incidence 30 degrees refracts away from the normal with a weak reflected ray, incidence 41.8 degrees refracts along the boundary, incidence 50 degrees reflects fully with equal angles -->

### The Electromagnetic Spectrum

Light is an **electromagnetic wave**: a transverse wave that needs no medium and can cross a vacuum. Sound is not an electromagnetic wave and cannot cross a vacuum.

The **electromagnetic spectrum** is the whole family of these waves. In vacuum they all travel at the same speed $c$, and they differ in frequency $f$ and wavelength $\lambda$:

$$c=f\lambda$$

In vacuum, a higher frequency means a shorter wavelength. From longest wavelength to shortest, the usual order is:

**radio → microwave → infrared → visible → ultraviolet → X-ray → gamma**

Neighboring kinds overlap a little at their edges.

Visible light covers roughly $400$ nm to $700$ nm. Red light has the longest wavelength in this range and violet the shortest. Frequency runs in the opposite order, from radio (lowest) to gamma (highest).

## Examples

### #1: Applying the Law of Reflection

A light ray hits a flat mirror at an angle of incidence of $40^\circ$. Find (a) the angle of reflection, (b) the angle between the incident ray and the mirror surface, and (c) the angle between the incident and reflected rays.

<!-- FIGURE: {"kind": "concept-diagram", "type": "ray-reflection", "labels": ["Incident ray", "Normal line", "Reflected ray"], "angles": ["40°", "?"], "semanticsLabel": "A flat mirror with a normal line. The incident ray makes 40 degrees with the normal. The angle of the reflected ray is not given and is marked with a question mark."} -->

**Solution:**

1. The angle of reflection equals the angle of incidence:

$$\theta_r=40^\circ$$

2. The normal is $90^\circ$ from the surface, so the ray makes this angle with the surface:

$$90^\circ-40^\circ=50^\circ$$

3. The two rays lie on opposite sides of the normal, so their angle is the sum:

$$40^\circ+40^\circ=80^\circ$$

### #2: Bending Into a Slower Medium

A ray in air ($n=1.00$) strikes glass ($n=1.50$) at an angle of incidence of $30^\circ$. Find the angle of refraction.

<!-- ILLUSTRATION: ray going from air (n = 1.00) into glass (n = 1.50) at a flat boundary, normal drawn, incident angle 30 degrees in air, the angle in the glass marked with a question mark -->

**Solution:**

1. Write Snell's law and solve for $\sin\theta_2$:

$$\sin\theta_2=\dfrac{n_1\sin\theta_1}{n_2}=\dfrac{1.00\times\sin30^\circ}{1.50}$$

2. Put in $\sin30^\circ=0.5$:

$$\sin\theta_2=\dfrac{0.5}{1.50}=0.333$$

3. Take the inverse sine:

$$\theta_2=\sin^{-1}(0.333)\approx19.5^\circ$$

The ray bends toward the normal, as expected for entering a larger $n$.

### #3: Bending Into a Faster Medium

A ray in glass ($n=1.50$) meets a glass-air boundary at $20^\circ$ from the normal. Find the angle of refraction in air ($n=1.00$).

<!-- ILLUSTRATION: ray going from glass (n = 1.50) up into air (n = 1.00) at a flat boundary, normal drawn, incident angle 20 degrees in glass, the angle in the air marked with a question mark -->

**Solution:**

1. Solve Snell's law for $\sin\theta_2$:

$$\sin\theta_2=\dfrac{1.50\times\sin20^\circ}{1.00}$$

2. Put in $\sin20^\circ\approx0.342$:

$$\sin\theta_2\approx0.513$$

3. Take the inverse sine:

$$\theta_2\approx30.9^\circ$$

The ray bends away from the normal, as expected for entering a smaller $n$.

### #4: Speed and Wavelength in Glass

Light has a wavelength of $600$ nm in vacuum. It enters glass with $n=1.50$. Find its speed, wavelength and frequency in the glass.

**Solution:**

1. Find the speed from the index of refraction:

$$v=\dfrac{c}{n}=\dfrac{3.00\times10^{8}}{1.50}=2.00\times10^{8}\text{ m/s}$$

2. Find the wavelength:

$$\lambda=\dfrac{\lambda_0}{n}=\dfrac{600\text{ nm}}{1.50}=400\text{ nm}$$

3. The frequency does not change on crossing the boundary. Find it from the vacuum values:

$$f=\dfrac{c}{\lambda_0}=\dfrac{3.00\times10^{8}}{600\times10^{-9}}=5.0\times10^{14}\text{ Hz}$$

Check in glass: $\dfrac{2.00\times10^{8}}{400\times10^{-9}}=5.0\times10^{14}$ Hz, the same.

### #5: Critical Angle and Total Internal Reflection

A ray inside glass ($n=1.50$) travels toward a glass-air boundary at an angle of incidence of $45^\circ$. Will it leave the glass?

<!-- ILLUSTRATION: ray in glass (n = 1.50) hitting the glass-air (n = 1.00) boundary at 45 degrees from the normal, normal drawn, what happens to the ray at the boundary marked with a question mark -->

**Solution:**

1. The light goes from the larger $n$ to the smaller $n$, so a critical angle exists. Find it:

$$\sin\theta_c=\dfrac{n_2}{n_1}=\dfrac{1.00}{1.50}=0.667$$

2. Take the inverse sine:

$$\theta_c=\sin^{-1}(0.667)\approx41.8^\circ$$

3. Compare: $45^\circ>41.8^\circ$. The light does not leave. It is totally reflected back into the glass at $45^\circ$ from the normal.

At $30^\circ$, which is below $41.8^\circ$, the light would leave into air, with a small reflected part.

### #6: Explaining Refraction with a Straw in Water

A straw partly in water looks bent where it meets the surface when seen from the side. Explain why.

**Solution:**

1. Light from the underwater part travels from water ($n\approx1.33$) into air ($n\approx1.00$).
2. At the surface, the rays bend away from the normal, as the rule for entering a smaller $n$ says.
3. Your eye traces the rays back along straight lines. The straw seems to be at a shallower, shifted place, so it looks bent.

### #7: Ordering the Electromagnetic Spectrum

Arrange X-rays, radio waves, visible light, and gamma rays from longest to shortest wavelength. Then find the wavelength of a radio wave of frequency $100$ MHz in vacuum.

<!-- ILLUSTRATION: four unordered labels, X-rays, radio waves, visible light and gamma rays, and a separate radio wave of frequency 100 MHz with its wavelength marked with a question mark -->

**Solution:**

1. Use the usual order of the spectrum: radio waves, then visible light, then X-rays, then gamma rays.
2. Change $100$ MHz (megahertz, millions of hertz) to hertz: $100\times10^{6}=1.00\times10^{8}$ Hz.
3. Use $c=f\lambda$ and solve for the wavelength:

$$\lambda=\dfrac{c}{f}=\dfrac{3.00\times10^{8}}{1.00\times10^{8}}=3.00\text{ m}$$

## Speed Tricks & Shortcuts

For reflection, measure angles from the **normal**. If you are given the angle to the surface, subtract it from $90^\circ$.

For refraction, compare $n_1$ and $n_2$. Entering a larger $n$ bends toward the normal. Entering a smaller $n$ bends away. This fails only when the ray travels along the normal or the two $n$ values are equal, because then there is no bend.

In Snell's law, the medium with the larger $n$ has the smaller angle (when the ray is slanted).

For total internal reflection, check two things in order. First, is the light going into a smaller $n$? Then compare the angle of incidence with $\theta_c$. For a material in air, $\sin\theta_c=\dfrac{1}{n}$.

In vacuum, higher frequency means shorter wavelength because $c=f\lambda$.

## Traps to Watch For

### #1: Measuring Reflection Angles from the Surface

> Incidence and reflection angles are measured from the normal, not from the surface.

A ray $20^\circ$ above a flat mirror surface is $70^\circ$ from the normal. Its angle of reflection is $70^\circ$, not $20^\circ$.

### #2: Saying Light Always Bends When It Enters a New Medium

> A ray changes direction only when it meets the boundary at a slant and the two $n$ values differ.

A ray along the normal keeps its direction but still changes speed and wavelength. The toward-normal and away-from-normal rules also apply only when the ray is slanted.

### #3: Using Total Internal Reflection From the Wrong Side

> Total internal reflection needs light going from larger $n$ to smaller $n$, and an angle above $\theta_c$.

Light going from air into glass never has a critical angle. Light in glass at an angle below $\theta_c$ leaves into air, but part of it also reflects. The reflected part grows as the angle nears $\theta_c$.

### #4: Thinking the Frequency Changes in Refraction

> Frequency stays the same across a boundary. Speed and wavelength change.

A student may say the color changes because the wavelength changes in glass. The frequency, which fixes the color, is unchanged.

### #5: Confusing Reflection and Refraction

> Reflection returns light to the first medium. Refraction sends it into the second medium.

Both can happen at once at a boundary. Total internal reflection is the case where only reflection is left.

### #6: Assuming Visible Light Is Most of the Spectrum

> Visible light is a narrow band of electromagnetic waves.

Radio, infrared, ultraviolet, X-rays and gamma rays are the same kind of wave. Human eyes cannot detect them.
