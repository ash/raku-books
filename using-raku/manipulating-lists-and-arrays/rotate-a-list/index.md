---
title: 50. Rotate a list
---

{% include menu.html %}

*Move all elements of an array N positions to the left or to the right.*

`Array` is a data type in Raku that offers the `rotate` method, which does exactly what is needed. It takes an argument that tells the length and direction of the rotation.

```raku
my @a = (1, 3, 5, 7, 9, 11, 13, 15);

say @a.rotate(3);
say @a.rotate(-3);
```

Positive values rotate to the left; negative values rotate to the right. Elements that go beyond the array borders, are appended to the end (or to the beginning if rotating to the right).

The original array stays untouched. The program prints the following:

```
[7 9 11 13 15 1 3 5]
[11 13 15 1 3 5 7 9]
```

To modify the array, assign the result of rotation to the variable itself:

```raku-static
@a.=rotate(3);
```

Alternatively, a pair of `shift` and `push` methods can lead to the same result:

```raku-static
@a.push(@a.shift) for 1..3;
```

Rotating to the opposite side can be done using complementary methods:

```raku-static
@a.unshift(@a.pop) for 1..3;
```

In the last three examples, `@a` is updated after the operations.

{% include nav.html %}
