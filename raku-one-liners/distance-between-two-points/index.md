---
title: Distance between two points
---

{% include menu.html %}

Here’s an illustration to help to formulate the task. Our goal is to find the distance between the points A and B.

To make the answer more transparent and easier to check, I chose the line AB so that it is a hypotenuse of a right triangle with the sides of length 3 and 4. The length of the third side is 5 in this case.

Here’s the solution:

```raku
say abs(5.5+2i - (1.5+5i))
```

The code uses complex numbers, and as soon as you move the problem to a complex plane, you gain from the fact that the distance between the two points on the surface equals to the absolute value of subtraction of these two numbers from one another.

One of the points, in this case, is the point 5.5+2i on the complex plane, and the second point is 1.5+5i. In Raku, you write down complex numbers as you do in mathematics.

Without the built-in support of complex numbers, you would have to use Pythagorean theorem explicitly:

```raku
say sqrt((5.5 - 1.5)² + (2 - 5)²)
```

*Homework. Modify Rakudo’s grammar to allow the following code:*

```raku-static
say √((5.5 - 1.5)² + (2 - 5)²)
```

{% include nav.html %}
