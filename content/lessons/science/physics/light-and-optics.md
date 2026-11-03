---
_id: "lesson-physics-light-and-optics"
title: "Light and Optics (Reflection, Refraction, Mirrors, Lenses, Electromagnetic Spectrum)"
summary: "How light reflects and refracts, when it is trapped inside a material, how mirrors, lenses and simple instruments form images, and how the electromagnetic spectrum is ordered."
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

**Reflection** is light bouncing off a surface. The **normal** is an imaginary line at $90^\circ$ to the surface, drawn at the point where the ray lands. The **angle of incidence** $\theta_i$ is the angle between the incoming ray and the normal. The **angle of reflection** $\theta_r$ is the angle between the bounced ray and the normal.

The **law of reflection** says the two angles are equal. The incoming ray, the reflected ray and the normal all lie in one flat plane.

$$\theta_i=\theta_r$$

<!-- FIGURE: {"kind": "concept-diagram", "type": "ray-reflection", "labels": ["Incident ray", "Normal line", "Reflected ray"], "angles": ["Angle of incidence", "Angle of reflection"], "semanticsLabel": "A flat mirror with a normal line showing an incoming incident ray and an outgoing reflected ray at equal angles."} -->

A smooth surface, such as a mirror, sends parallel rays out in one direction. A rough surface, such as paper, sends them in many directions. Each tiny part of the rough surface still obeys the law of reflection.

A flat (plane) mirror makes an image that is upright and the same size as the object. The image looks as far behind the mirror as the object is in front. It is a **virtual image**, explained in the mirrors section.

### Refraction

**Refraction** is a change in the speed of light when it crosses a boundary. If the ray meets the boundary at a slant, the change in speed also turns the ray. The **angle of incidence** and the **angle of refraction** are again measured from the normal.

The **index of refraction** $n$ of a material tells how much it slows light. Here $c$ is the speed of light in vacuum, about $3.00\times10^{8}$ m/s, and $v$ is the speed in the material.

$$n=\dfrac{c}{v}$$

Vacuum has $n=1$, and air is very close to $1$. A bigger $n$ means slower light. This lesson uses about $1.33$ for water and $1.50$ for glass.

**Snell's law** links the angles on the two sides. Medium $1$ is where the ray comes from. Medium $2$ is where it goes.

$$n_1\sin\theta_1=n_2\sin\theta_2$$

Use Snell's law to find the direction:

- If $n_2>n_1$, the light slows down and bends **toward the normal**.
- If $n_2<n_1$, the light speeds up and bends **away from the normal**.
- If $n_2=n_1$, or the ray travels along the normal ($\theta_1=0$), the direction does not change. The speed still changes if $n_2\ne n_1$.

When light crosses a boundary, its frequency stays the same. The speed changes, so the wavelength changes too. Since $v=f\lambda$, the wavelength in a material is

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

### Mirrors

A **mirror** forms images by reflection. We use **spherical mirrors**, which are a part of the inside or outside of a sphere. These words describe the picture:

- The **principal axis** is the line through the middle of the mirror and its center of curvature.
- The **center of curvature** $C$ is the center of the sphere. The **radius of curvature** $R$ is the distance from the mirror to $C$.
- The **focal point** $F$ is where rays that arrive parallel to the axis meet after reflection (for a convex mirror, where they seem to come from). The **focal length** $f$ is its distance from the mirror.

For a spherical mirror with rays close to the axis, the focal length is half the radius:

$$f=\dfrac{R}{2}$$

A **concave mirror** curves inward like the inside of a bowl. It is converging: parallel rays meet at $F$. A **convex mirror** curves outward. It is diverging: parallel rays spread out as if they came from a point $F$ behind the mirror.

A **real image** is made where light rays really meet. It can be shown on a screen. A **virtual image** is made where rays only seem to come from. No light is there, so a screen cannot show it.

### Lenses

A **lens** forms images by refraction. A **convex lens** is thicker in the middle. A **concave lens** is thinner in the middle.

For a glass or plastic lens in air, a convex lens is converging and a concave lens is diverging. A lens has a focal length $f$ too. A thin lens has a focal point on each side. We take the object on the left and the light moving to the right.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"lens-comparison","illustrationKey":"science/physics/light-and-optics#2","convexBehavior":"parallel rays bend inward to one focus point","concaveBehavior":"parallel rays spread outward"} -->

This rule depends on the lens being denser than its surroundings. A convex-shaped lens made of a material with a lower $n$ than the medium around it diverges light instead. An air bubble shaped like a convex lens inside water is one case.

### Finding the Image: Sign Convention and Equations

Let $d_o$ be the distance from the object to the mirror or lens. Let $d_i$ be the distance from the image. Let $h_o$ and $h_i$ be the object and image heights. We use one **sign convention** for mirrors and lenses:

- $d_o$ is positive for a real object.
- $d_i$ is positive for a **real** image and negative for a **virtual** image.
- $f$ is positive for a concave mirror and a convex lens. $f$ is negative for a convex mirror and a concave lens.

For a spherical mirror or a thin lens, with the usual close-to-axis rays:

$$\dfrac{1}{f}=\dfrac{1}{d_o}+\dfrac{1}{d_i}$$

$$m=\dfrac{h_i}{h_o}=-\dfrac{d_i}{d_o}$$

The **magnification** $m$ tells the size and direction of the image. If $m$ is negative, the image is **inverted** (upside down). If $m$ is positive, it is **upright**. If $|m|>1$, the image is bigger than the object.

You can also find an image by drawing two or three rays from the top of the object. For a converging device in air, these three rays work:

- A ray parallel to the axis goes through $F$ after reflecting or refracting.
- A ray that goes through $F$ comes out parallel to the axis.
- For a mirror, a ray aimed at $C$ bounces straight back. For a thin lens, a ray through the center goes straight on.

The image sits where the rays meet. For a virtual image, extend the rays backward to find where they seem to meet.

### How the Image Changes with the Object Position

For a **concave mirror** or a **convex lens** (so $f>0$), the object position decides the image:

- Beyond $2f$ ($d_o>2f$): real, inverted, smaller. The image is between $f$ and $2f$.
- At $2f$ ($d_o=2f$): real, inverted, same size, at $2f$.
- Between $f$ and $2f$: real, inverted, larger. The image is beyond $2f$.
- At $f$ ($d_o=f$): no image forms. The reflected or refracted rays are parallel.
- Inside $f$ ($d_o<f$): virtual, upright, larger.

For a **convex mirror** or a **concave lens** ($f<0$) with a real object, the image is always virtual, upright and smaller. This is true at every object distance.

<!-- ILLUSTRATION: ray diagram of a concave mirror, focal point F at 10 cm and center of curvature C at 20 cm on the principal axis, with an arrow object at 30 cm and its real inverted image at 15 cm, three principal rays drawn -->

### Optical Instruments

Simple instruments use the same image rules.

- A **magnifying glass** is a convex lens with the object placed inside $f$. It makes a virtual, upright, larger image.
- A **camera** uses a convex lens to put a real, inverted, smaller image of a faraway scene on a sensor or film.
- A **projector** is the case where the slide is between $f$ and $2f$. It puts a real, inverted, larger image on a screen.
- The **human eye** has a lens that puts a real, inverted image on the retina, the light-sensitive layer at the back. The brain turns it right way up.
- A **microscope** has two convex lenses. The first (the objective) makes an enlarged real image of a tiny object. The second (the eyepiece) works as a magnifying glass on that image.
- A **refracting telescope** also has two convex lenses. The objective makes a real image of a faraway object. The eyepiece magnifies that image.

Eyeglasses fix focus problems. In **myopia** (nearsightedness), distant objects focus in front of the retina, and a diverging (concave) lens moves the focus back. In **hyperopia** (farsightedness), near objects would focus behind the retina, and a converging (convex) lens brings it forward.

### The Electromagnetic Spectrum

Light is an **electromagnetic wave**: a transverse wave that needs no medium and can cross a vacuum. Sound is not an electromagnetic wave and cannot cross a vacuum.

The **electromagnetic spectrum** is the whole family of these waves. In vacuum they all travel at the same speed $c$, and they differ in frequency $f$ and wavelength $\lambda$:

$$c=f\lambda$$

In vacuum, a higher frequency means a shorter wavelength. From longest wavelength to shortest, the usual order is:

**radio → microwave → infrared → visible → ultraviolet → X-ray → gamma**

Neighboring kinds overlap a little at their edges. Visible light covers roughly $400$ nm to $700$ nm. Red light has the longest wavelength in this range and violet the shortest. Frequency runs in the opposite order, from radio (lowest) to gamma (highest).

## Examples

### #1: Applying the Law of Reflection

A light ray hits a flat mirror at an angle of incidence of $40^\circ$. Find (a) the angle of reflection, (b) the angle between the incident ray and the mirror surface, and (c) the angle between the incident and reflected rays.

<!-- FIGURE: {"kind": "concept-diagram", "type": "ray-reflection", "incidentAngle": 40, "reflectedAngle": 40, "labels": ["40°", "40°"], "semanticsLabel": "A light ray striking a flat mirror at 40 degrees from the normal line and reflecting off at 40 degrees."} -->

**Solution:**

1. The angle of reflection equals the angle of incidence:

$$\theta_r=40^\circ$$

2. The normal is $90^\circ$ from the surface, so the ray makes this angle with the surface:

$$90^\circ-40^\circ=50^\circ$$

3. The two rays lie on opposite sides of the normal, so their angle is the sum:

$$40^\circ+40^\circ=80^\circ$$

### #2: Bending Into a Slower Medium

A ray in air ($n=1.00$) strikes glass ($n=1.50$) at an angle of incidence of $30^\circ$. Find the angle of refraction.

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

**Solution:**

1. Solve Snell's law for $\sin\theta_2$:

$$\sin\theta_2=\dfrac{1.50\times\sin20^\circ}{1.00}$$

2. Put in $\sin20^\circ\approx0.342$:

$$\sin\theta_2\approx0.513$$

3. Take the inverse sine:

$$\theta_2\approx30.9^\circ$$

The ray bends away from the normal, as expected for entering a smaller $n$.

### #4: Speed and Wavelength in Glass

Red light has a wavelength of $600$ nm in vacuum. It enters glass with $n=1.50$. Find its speed, wavelength and frequency in the glass.

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

**Solution:**

1. The light goes from the larger $n$ to the smaller $n$, so a critical angle exists. Find it:

$$\sin\theta_c=\dfrac{n_2}{n_1}=\dfrac{1.00}{1.50}=0.667$$

2. Take the inverse sine:

$$\theta_c=\sin^{-1}(0.667)\approx41.8^\circ$$

3. Compare: $45^\circ>41.8^\circ$. The light does not leave. It is totally reflected back into the glass at $45^\circ$ from the normal.

At $30^\circ$, which is below $41.8^\circ$, most of the light would leave into air.

### #6: Explaining Refraction with a Straw in Water

A straw partly in water looks bent where it meets the surface when seen from the side. Explain why.

**Solution:**

1. Light from the underwater part travels from water ($n\approx1.33$) into air ($n\approx1.00$).
2. At the surface, the rays bend away from the normal, as the rule for entering a smaller $n$ says.
3. Your eye traces the rays back along straight lines. The straw seems to be at a shallower, shifted place, so it looks bent.

### #7: Concave Mirror, Object Beyond $2f$

A concave mirror has a radius of curvature of $20$ cm. An object stands $30$ cm in front of it. Find the image distance and magnification, and describe the image.

**Solution:**

1. Find the focal length:

$$f=\dfrac{R}{2}=10\text{ cm}$$

2. Use the mirror equation:

$$\dfrac{1}{d_i}=\dfrac{1}{10}-\dfrac{1}{30}=\dfrac{2}{30}$$

3. So $d_i=15$ cm. Find the magnification:

$$m=-\dfrac{15}{30}=-0.5$$

The image is real ($d_i>0$), inverted ($m<0$) and half the size.

### #8: Concave Mirror, Object Inside the Focal Point

A concave mirror has $f=10$ cm. An object stands $4$ cm in front of it, as in a shaving mirror. Describe the image.

**Solution:**

1. Use the mirror equation:

$$\dfrac{1}{d_i}=\dfrac{1}{10}-\dfrac{1}{4}=-\dfrac{3}{20}$$

2. So $d_i\approx-6.7$ cm. Find the magnification:

$$m=-\dfrac{-6.7}{4}\approx+1.7$$

The image is virtual ($d_i<0$), behind the mirror, upright ($m>0$) and about $1.7$ times larger.

### #9: Convex Mirror

A convex mirror has a focal length of $12$ cm. An object stands $24$ cm in front of it. Describe the image.

**Solution:**

1. A convex mirror has $f=-12$ cm. Use the mirror equation:

$$\dfrac{1}{d_i}=-\dfrac{1}{12}-\dfrac{1}{24}=-\dfrac{3}{24}$$

2. So $d_i=-8$ cm. Find the magnification:

$$m=-\dfrac{-8}{24}=+\dfrac{1}{3}$$

The image is virtual, upright and one third the size.

### #10: Convex Lens Making a Real Image

A convex lens in air has $f=15$ cm. A slide is $20$ cm from the lens. Find the image distance and magnification, and describe the image.

**Solution:**

1. Use the lens equation:

$$\dfrac{1}{d_i}=\dfrac{1}{15}-\dfrac{1}{20}=\dfrac{1}{60}$$

2. So $d_i=60$ cm. Find the magnification:

$$m=-\dfrac{60}{20}=-3$$

The object is between $f$ and $2f$. The image is real, inverted and three times larger, as a projector does.

### #11: A Magnifying Glass and a Concave Lens

(a) A magnifying glass is a convex lens with $f=5$ cm. A small insect is $4$ cm from it. Find $m$ and describe the image. (b) A concave lens has $f=-10$ cm. An object is $30$ cm from it. Find $d_i$ and $m$.

**Solution:**

1. For part (a), find the image distance:

$$\dfrac{1}{d_i}=\dfrac{1}{5}-\dfrac{1}{4}=-\dfrac{1}{20}$$

2. So $d_i=-20$ cm and $m=-\dfrac{-20}{4}=+5$. The image is virtual, upright and five times larger, because the object is inside $f$.
3. For part (b), use the lens equation:

$$\dfrac{1}{d_i}=-\dfrac{1}{10}-\dfrac{1}{30}=-\dfrac{4}{30}$$

4. So $d_i=-7.5$ cm and $m=-\dfrac{-7.5}{30}=+0.25$. The image is virtual, upright and one quarter the size.

### #12: Ordering the Electromagnetic Spectrum

Arrange X-rays, radio waves, visible light, and gamma rays from longest to shortest wavelength. Then find the wavelength of a radio wave of frequency $100$ MHz in vacuum.

**Solution:**

1. Use the usual order of the spectrum: radio waves, then visible light, then X-rays, then gamma rays.
2. Change $100$ MHz to hertz: $100\times10^{6}=1.00\times10^{8}$ Hz.
3. Use $c=f\lambda$ and solve for the wavelength:

$$\lambda=\dfrac{c}{f}=\dfrac{3.00\times10^{8}}{1.00\times10^{8}}=3.00\text{ m}$$

## Speed Tricks & Shortcuts

For reflection, measure angles from the **normal**. If you are given the angle to the surface, subtract it from $90^\circ$.

For refraction, compare $n_1$ and $n_2$. Entering a larger $n$ bends toward the normal. Entering a smaller $n$ bends away. This fails only when the ray travels along the normal or the two $n$ values are equal, because then there is no bend.

In Snell's law, the medium with the larger $n$ always has the smaller angle, for angles between $0^\circ$ and $90^\circ$.

For total internal reflection, check two things in order. First, is the light going into a smaller $n$? Then compare the angle of incidence with $\theta_c$. For a material in air, $\sin\theta_c=\dfrac{1}{n}$.

For a converging mirror or lens, an object beyond $f$ gives a real, inverted image, and an object inside $f$ gives a virtual, upright one. A diverging mirror or lens with a real object always gives a virtual, upright, smaller image.

Read the signs of your answers. A negative $d_i$ means virtual. A negative $m$ means inverted.

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

Light going from air into glass never has a critical angle. Light in glass at an angle below $\theta_c$ mostly leaves, with only a weak reflection.

### #4: Thinking the Frequency Changes in Refraction

> Frequency stays the same across a boundary. Speed and wavelength change.

A student may say the color changes because the wavelength changes in glass. The frequency, which fixes the color, is unchanged.

### #5: Assuming a Concave Mirror Always Makes an Inverted Image

> The image from a concave mirror depends on where the object is.

Beyond $f$, the image is real and inverted. Inside $f$, it is virtual, upright and larger. At $f$, no image forms. A convex mirror with a real object never makes a real or inverted image.

### #6: Dropping the Signs

> A negative $d_i$ or $f$ is not an error. It carries meaning.

Using $f=+12$ cm for a convex mirror changes the answer completely. With this lesson's convention, $f$ is negative for convex mirrors and concave lenses.

### #7: Treating Lens Shape Alone as Universal

> Whether a lens converges depends on its shape and on its $n$ compared with the surroundings.

The familiar "convex converges, concave diverges" rule is for a lens with a larger $n$ than the medium around it, such as glass in air.

### #8: Confusing Reflection and Refraction

> Reflection returns light to the first medium. Refraction sends it into the second medium.

Both can happen at once at a boundary. Total internal reflection is the case where only reflection is left.

### #9: Assuming Visible Light Is Most of the Spectrum

> Visible light is a narrow band of electromagnetic waves.

Radio, infrared, ultraviolet, X-rays and gamma rays are the same kind of wave. Human eyes cannot detect them.
