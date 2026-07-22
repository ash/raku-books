---
title: 38. Monte Carlo method
---

{% include menu.html %}

*Calculate the area of a circle and the volume of a sphere of radius 1 using the Monte Carlo method.*

The Monte Carlo method is a statistical method of calculating data whose formula is not known. The idea is to generate a big number of random numbers and see how many of them satisfy the condition.

To calculate the area of a circle of the radius 1, pairs of random numbers between −1 and 1 are generated. These pairs represent the points in the square in the center of coordinates with sides of length 2. The area of the square is thus 4. If the distance between the random point and the center of the square is less than 1, then this point is located inside the circle of that radius. Counting the number of points that landed inside the circle and the number of points outside the circle gives the approximate value of the area of the circle, as soon as the area of the square is known. Here is the program.

```raku-nobrowser
my $inside = 0;
my $n = 100_000;
for 1..$n {
    my @point = map {2.rand - 1}, 1..2; # 1..3 for sphere
    $inside++ if sqrt([+] map *², @point) < 1;
}
say 4 * $inside / $n;                   # 8 for sphere
```

The bigger the number of repetitions `$n`, the more accurate is the result. In one of the runs of the program, it printed `3.14392`, which is close to the true result, which is !=3, which is equal to ! in our case. We see that the Monte Carlo result is very close.

For the volume of a sphere, change the program according to the comments. L M !=M, which approximately gives `4.189`. The formula is

{% include nav.html %}
