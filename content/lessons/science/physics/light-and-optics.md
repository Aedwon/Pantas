---
_id: "lesson-physics-light-and-optics"
title: "Light and Optics (Reflection, Refraction, Mirrors, Lenses, Electromagnetic Spectrum)"
summary: "How light reflects and refracts, how mirrors and lenses form images, and how the electromagnetic spectrum is organized."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 12
isActive: true
---
## Core Concept

**Optics** is the branch of physics that studies light and its interaction with matter. This lesson mainly uses **geometric optics**, where light is modeled as rays; that approximation works best when the objects and openings involved are much larger than the light's wavelength.

### Reflection

The **law of reflection** says that the angle of incidence equals the angle of reflection, with both angles measured from the **normal** (a line perpendicular to the surface at the point of incidence):

$$\theta_i=\theta_r$$

<!-- FIGURE: {"kind": "concept-diagram", "type": "ray-reflection", "labels": ["Incident ray", "Normal line", "Reflected ray"], "angles": ["Angle of incidence", "Angle of reflection"], "semanticsLabel": "A flat mirror with a normal line showing an incoming incident ray and an outgoing reflected ray at equal angles."} -->

### Refraction

**Refraction** is a change in a light ray's direction when it crosses a boundary where its propagation speed changes. The **index of refraction** is

$$n=\frac{c}{v}$$

where $c$ is the speed of light in vacuum and $v$ is its speed in the material. **Snell's law** relates the incident and refracted angles:

$$n_1\sin\theta_1=n_2\sin\theta_2$$

When light enters a medium with a higher refractive index, it slows and bends **toward the normal** (except at normal incidence, where it does not change direction). When it enters a lower-index medium, it bends **away from the normal**. The frequency set by the source remains unchanged across the boundary, while the wavelength changes because the speed changes.

If light travels from a higher-index medium to a lower-index one and the incident angle exceeds the **critical angle**, it undergoes **total internal reflection** instead of refracting out.

### Mirrors

For ideal spherical mirrors under the usual paraxial-ray approximation:

- A **concave mirror** is converging for rays parallel and close to its principal axis.
- A **convex mirror** is diverging.

The type and orientation of the image formed by a concave mirror depend on the object's position relative to the focal point. Convex mirrors form upright, reduced, virtual images for real objects in the ordinary setup.

### Lenses

Lenses form images by refraction. For a typical glass or plastic lens **in air**, where the lens has a higher refractive index than its surroundings:

- A **convex lens** (thicker at the center) is converging.
- A **concave lens** (thinner at the center) is diverging.

<!-- ILLUSTRATION: side-by-side comparison of a convex lens bending parallel light rays inward to a single focus point, and a concave lens spreading parallel light rays outward -->

This shape rule is not universal for every surrounding medium: changing the relative refractive indices can change a lens's optical power and even reverse whether it converges or diverges.

In vision correction, converging lenses are commonly used for hyperopia (farsightedness), while diverging lenses are commonly used for myopia (nearsightedness).

### The Electromagnetic Spectrum

The **electromagnetic spectrum** includes radio waves, microwaves, infrared, visible light, ultraviolet, X-rays, and gamma rays. In vacuum, all electromagnetic waves travel at the same speed $c$, but they differ in frequency and wavelength:

$$c=f\lambda$$

From longest wavelength to shortest: **radio → microwave → infrared → visible → ultraviolet → X-ray → gamma**. Within visible light, red has the longest wavelength and violet the shortest.

## Examples

### #1: Applying the Law of Reflection

A light ray hits a flat mirror at an angle of incidence of $40°$ measured from the normal. Find the angle of reflection.

<!-- FIGURE: {"kind": "concept-diagram", "type": "ray-reflection", "incidentAngle": 40, "reflectedAngle": 40, "labels": ["40°", "40°"], "semanticsLabel": "A light ray striking a flat mirror at 40 degrees from the normal line and reflecting off at 40 degrees."} -->

**Solution:**

$$\theta_r=\theta_i=40°$$

### #2: Converging or Diverging?

Assume ordinary glass optical elements in air. Classify: (a) a concave mirror; (b) a convex lens; (c) a convex mirror.

**Solution:**

1. Concave mirror: **converging** for paraxial rays.
2. Convex lens in air: **converging**.
3. Convex mirror: **diverging**.

### #3: Ordering the Electromagnetic Spectrum

Arrange X-rays, radio waves, visible light, and gamma rays from longest to shortest wavelength.

**Solution:**

**Radio waves → visible light → X-rays → gamma rays.**

### #4: Explaining Refraction with a Straw in Water

A straw partly submerged in water appears displaced or "bent" when viewed from the side. Explain why.

**Solution:**

1. Light from the underwater part of the straw travels from water into air.
2. Because the refractive indices differ, the light changes speed and direction at the boundary according to Snell's law.
3. Your visual system traces the emerging rays approximately backward along straight lines, so the submerged part appears at a shifted apparent position.

## Speed Tricks & Shortcuts

For reflection, measure angles from the **normal**, not from the mirror surface.

For refraction, compare refractive indices: entering higher $n$ bends toward the normal; entering lower $n$ bends away, assuming nonzero incidence angle.

For mirrors and lenses, keep the device types separate. In air: concave mirror converges, convex mirror diverges; convex lens converges, concave lens diverges.

For electromagnetic waves in vacuum, remember that higher frequency means shorter wavelength because $c=f\lambda$.

## Traps to Watch For

### #1: Measuring Reflection Angles from the Surface

> Incidence and reflection angles are measured from the normal.

A ray $20°$ above a flat mirror surface is $70°$ from the normal, not $20°$.

### #2: Saying Light Always Bends When It Enters a New Medium

> A speed change can occur without a directional bend when the ray hits the boundary along the normal.

Refraction refers to the change associated with entering a different optical medium; the ray's direction changes only when the geometry requires it.

### #3: Treating Lens Shape Alone as Universal

> Whether a lens converges depends on both its shape and its refractive index relative to the surrounding medium.

The familiar "convex converges, concave diverges" rule assumes an ordinary higher-index lens in a lower-index surrounding medium such as air.

### #4: Confusing Reflection and Refraction

> Reflection returns light into the incident medium; refraction transmits light into another medium with a change governed by Snell's law.

At a real boundary, both reflection and refraction can occur at the same time.

### #5: Assuming Visible Light Is Most of the Electromagnetic Spectrum

> Visible light is only a narrow range of electromagnetic wavelengths detectable by human eyes.

Radio, infrared, ultraviolet, X-ray, gamma, and other electromagnetic radiation are still forms of light in the broader physics sense.
