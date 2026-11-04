---
_id: "lesson-physics-mirrors-and-lenses"
title: "Mirrors and Lenses (Image Formation and Optical Instruments)"
summary: "How mirrors and lenses form images, how to find an image with the sign convention and equations, and how simple optical instruments use them."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 15
isActive: true
---
## Core Concept

This lesson shows how mirrors and lenses form images, and how simple instruments use them. It uses **geometric optics**, where light is drawn as straight lines called **rays**. A **medium** is the material light travels through, such as air or glass.

Read the lesson "Light: Reflection, Refraction and the Electromagnetic Spectrum" first. It teaches the law of reflection, the index of refraction $n$ and how light bends at a boundary. This lesson uses all three.

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

This rule depends on the lens having a larger $n$ than its surroundings. Here "denser" means optically denser (larger $n$), not heavier. A convex-shaped lens made of a material with a lower $n$ than the medium around it diverges light instead. An air bubble shaped like a convex lens inside water is one case.

### Finding the Image: Sign Convention and Equations

Let $d_o$ be the distance from the object to the mirror or lens. Let $d_i$ be the distance from the image. Let $h_o$ and $h_i$ be the object and image heights. We use one **sign convention** for mirrors and lenses:

- $d_o$ is positive for a real object.
- $d_i$ is positive for a **real** image and negative for a **virtual** image.
- $f$ is positive for a concave mirror and a convex lens. $f$ is negative for a convex mirror and a concave lens.

For a spherical mirror or a thin lens, with the usual close-to-axis rays:

$$\dfrac{1}{f}=\dfrac{1}{d_o}+\dfrac{1}{d_i}$$

$$m=\dfrac{h_i}{h_o}=-\dfrac{d_i}{d_o}$$

The **magnification** $m$ tells the size and direction of the image. If $m$ is negative, the image is **inverted** (upside down).

If $m$ is positive, it is **upright**. If $|m|>1$, the image is bigger than the object.

You can also find an image by drawing two or three rays from the top of the object. For a converging device in air, these three rays work:

- A ray parallel to the axis goes through $F$ after reflecting. After a lens, it goes through the focal point on the far side.
- A ray that goes through $F$ comes out parallel to the axis. For a lens, this is the focal point on the object's side. If the object is inside $f$, aim the ray along the line that would pass through that point.
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
- A **compound microscope** has two convex lenses. The first (the objective) makes an enlarged real image of a tiny object. The second (the eyepiece) works as a magnifying glass on that image. A simple microscope is just one convex lens, like a magnifying glass.
- A simple **refracting telescope** of the common (Keplerian) kind also has two convex lenses. The objective makes a real image of a faraway object. The eyepiece magnifies that image. Galileo's telescope used a concave eyepiece instead.

Eyeglasses fix focus problems. In **myopia** (nearsightedness), distant objects focus in front of the retina, and a diverging (concave) lens moves the focus back. In **hyperopia** (farsightedness), near objects would focus behind the retina, and a converging (convex) lens brings it forward.

## Examples

### #1: Concave Mirror, Object Beyond $2f$

A concave mirror has a radius of curvature of $20$ cm. An object stands $30$ cm in front of it. Find the image distance and magnification, and describe the image.

**Solution:**

1. Find the focal length:

$$f=\dfrac{R}{2}=10\text{ cm}$$

2. Use the mirror equation:

$$\dfrac{1}{d_i}=\dfrac{1}{10}-\dfrac{1}{30}=\dfrac{2}{30}$$

3. So $d_i=15$ cm. Find the magnification:

$$m=-\dfrac{15}{30}=-0.5$$

The image is real ($d_i>0$), inverted ($m<0$) and half the size.

### #2: Concave Mirror, Object Inside the Focal Point

A concave mirror has $f=10$ cm. An object stands $4$ cm in front of it, as in a shaving mirror. Describe the image.

**Solution:**

1. Use the mirror equation:

$$\dfrac{1}{d_i}=\dfrac{1}{10}-\dfrac{1}{4}=-\dfrac{3}{20}$$

2. So $d_i\approx-6.7$ cm. Find the magnification:

$$m=-\dfrac{-6.7}{4}\approx+1.7$$

The image is virtual ($d_i<0$), behind the mirror, upright ($m>0$) and about $1.7$ times larger.

### #3: Convex Mirror

A convex mirror has a focal length of $12$ cm. An object stands $24$ cm in front of it. Describe the image.

**Solution:**

1. A convex mirror has $f=-12$ cm. Use the mirror equation:

$$\dfrac{1}{d_i}=-\dfrac{1}{12}-\dfrac{1}{24}=-\dfrac{3}{24}$$

2. So $d_i=-8$ cm. Find the magnification:

$$m=-\dfrac{-8}{24}=+\dfrac{1}{3}$$

The image is virtual, upright and one third the size.

### #4: Convex Lens Making a Real Image

A convex lens in air has $f=15$ cm. A slide is $20$ cm from the lens. Find the image distance and magnification, and describe the image.

**Solution:**

1. Use the lens equation:

$$\dfrac{1}{d_i}=\dfrac{1}{15}-\dfrac{1}{20}=\dfrac{1}{60}$$

2. So $d_i=60$ cm. Find the magnification:

$$m=-\dfrac{60}{20}=-3$$

The object is between $f$ and $2f$. The image is real, inverted and three times larger, as a projector does.

### #5: A Magnifying Glass and a Concave Lens

(a) A magnifying glass is a convex lens with $f=5$ cm. A small insect is $4$ cm from it. Find $m$ and describe the image. (b) A concave lens has $f=-10$ cm. An object is $30$ cm from it. Find $d_i$ and $m$.

**Solution:**

1. For part (a), find the image distance:

$$\dfrac{1}{d_i}=\dfrac{1}{5}-\dfrac{1}{4}=-\dfrac{1}{20}$$

2. So $d_i=-20$ cm. Find the magnification:

$$m=-\dfrac{-20}{4}=+5$$

The image is virtual, upright and five times larger, because the object is inside $f$.
3. For part (b), use the lens equation:

$$\dfrac{1}{d_i}=-\dfrac{1}{10}-\dfrac{1}{30}=-\dfrac{4}{30}$$

4. So $d_i=-7.5$ cm. Find the magnification:

$$m=-\dfrac{-7.5}{30}=+0.25$$

The image is virtual, upright and one quarter the size.

## Speed Tricks & Shortcuts

For a converging mirror or lens, an object beyond $f$ gives a real, inverted image, and an object inside $f$ gives a virtual, upright one. A diverging mirror or lens with a real object always gives a virtual, upright, smaller image.

Read the signs of your answers. A negative $d_i$ means virtual. A negative $m$ means inverted.

## Traps to Watch For

### #1: Assuming a Concave Mirror Always Makes an Inverted Image

> The image from a concave mirror depends on where the object is.

Beyond $f$, the image is real and inverted.

Inside $f$, it is virtual, upright and larger. At $f$, no image forms. A convex mirror with a real object never makes a real or inverted image.

### #2: Dropping the Signs

> A negative $d_i$ or $f$ is not an error. It carries meaning.

Using $f=+12$ cm for a convex mirror changes the answer completely. With this lesson's convention, $f$ is negative for convex mirrors and concave lenses.

### #3: Treating Lens Shape Alone as Universal

> Whether a lens converges depends on its shape and on its $n$ compared with the surroundings.

The familiar "convex converges, concave diverges" rule is for a lens with a larger $n$ than the medium around it, such as glass in air.
