PASS

- Issue 8. Added an angle key point to each circle lesson and linked q0009 and q0010 to those key points.
- Issue 9. Reworked the q0015 teaching example to find the perpendicular distance using triangle area and the distance formula. Mirrored the solution in the retired original.
- Issue 20. Moved the triangle showing the missing side length of 4 below the worked solution in both versions.
- Distance on the Coordinate Plane. Limited the right-triangle construction to points with different x- and y-coordinates. Explained the shared-coordinate case in both versions.
- Special Angle Side Lengths. Limited the tangent rule to acute angles in both versions.
- Adjusting for Eye Height. Specified horizontal distance in both versions.

Policy revision `f1e794a366a8d7253e6d338358e818e14be3cd50`. The requested `dart run` hit a sandbox error on the shared Objective-C hook lock. Running the same checker directly with the main checkout's package config gave exit 1 with 26 quiz pool or key-point coverage diagnostics. It reported zero size and nothing-dropped failures. `git diff --check` passed.

CHANGED-QUESTIONS
q-geometry-circles-0009
q-geometry-circles-0010
