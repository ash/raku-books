---
title: Anonymous code blocks
---

{% include menu.html %}

Perl 6 introduces the concept of so-called pointy blocks (or pointy arrow blocks). These are anonymous closure blocks, which return a reference to the function and can take arguments.

The syntax of defining pointy blocks is an arrow `->` followed by the argument list and a block of code.

```raku
my $cube = -> $x {$x ** 3};
say $cube(3); # 27
```

Here, the block `{$x ** 3}`, which takes one argument `$x`, is created first. Then, it is called using a variable `$cube` as a reference to the function: `$cube(3)`.

Pointy blocks are quite handy in loops.

```raku
for 1..10 -> $c {
    say $c;
}
```

```

```

The `for` loop takes two arguments: the range `1..10` and the block of code with the argument `$c`. The whole construction looks like syntactic sugar for loops.

There can be more than one argument. In that case, list them all after an arrow.

`my $pow = -> $x, $p {$x ** $p};`

`say $pow(2, 15); # 32768`

```

```

The same works with loops and with other Perl elements where you need passing anonymous code blocks.

```raku
for 0..9 -> $i, $j {
    say $i + $j;
}
```

In a loop iteration, two values from the list are consumed each time. So, the loop iterates five times and prints the sum of the pairs of numbers: `1`, `5`, `9`, `13` and `17`.

{% include nav.html %}
