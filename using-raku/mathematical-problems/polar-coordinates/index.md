---
title: 37. Polar coordinates
---

{% include menu.html %}

*Convert the Cartesian coordinates to polar and backward.*

Polar coordinates are a convenient way of representing points on a surface with the two values: distance from the centre of coordinates and the angle between the vector and the pole axis.

The conversion formulae between the Cartesian and polar systems, which is valid for positive x and y, are the following:

8 = = cos A, C = = sin A ;

A = arctan C = = G83 + C3, 8 .

These expressions can be implemented as-is in the code:

```raku-static
sub polar-to-cartesian($r, $φ) {
    $r * cos($φ), $r * sin($φ)
}

sub cartesian-to-polar($x, $y) {
    sqrt($x² + $y²), atan($y / $x)
}
```

The functions return lists of either polar or Cartesian coordinates. Because of the simplicity of implementation, it is fine to omit the `return` keyword and the semicolon at the end of the line.

Call the conversion functions with some positive numbers and check that the initial coordinates are restored after the second conversion:

```raku-static
say cartesian-to-polar(1, 2);
say polar-to-cartesian(2.236068, 1.107149);
```

For the negative x and y, the Cartesian-to-polar conversion is a bit more complicated. Depending on the quadrant of the point, the A value is bigger K K or smaller by !. When x is zero, it is either − 3 or 3.

All these variants can be implemented by using multi-subroutines with the `where` clause, as demonstrated below:

```raku-static
sub cartesian-to-polar($x, $y) {
    sqrt($x² + $y²), cartesian-to-φ($x, $y)
}

multi sub cartesian-to-φ($x, $y where {$x > 0}) {
    atan($y / $x)
}

multi sub cartesian-to-φ($x, $y where {$x < 0 && $y ≥ 0}) {
    atan($y / $x) + π
}

multi sub cartesian-to-φ($x, $y where {$x < 0 && $y < 0}) {
    atan($y / $x) – π
}

multi sub cartesian-to-φ($x, $y where {$x == 0 && $y > 0}) {
    π / 2
}

multi sub cartesian-to-φ($x, $y where {$x == 0 && $y < 0}) {
    -π / 2
}

multi sub cartesian-to-φ($x, $y where {$x == 0 && $y == 0}) {
    Nil
}
```

{% include nav.html %}
