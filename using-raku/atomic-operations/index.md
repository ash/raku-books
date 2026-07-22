---
title: 93. Atomic operations
---

{% include menu.html %}

*Using the solution for Task 38, the Monte Carlo method, create a program that calculates the result using multiple threads.*

Raky comes with the built-in support for parallel computing. In Task 92, Sleep Sort, we’ve seen how to use the keywords `await`, `gather`, and `take` to spawn a few threads and wait for them to finish.

When different threads want to modify the same variable, such as a counter, it is wise to introduce atomic operations to make sure the threads do not interfere with each other. Here is the modification of the Monte Carlo program calculating the area of a circle with four parallel threads.

```raku-static
my atomicint $inside = 0;

my $n = 5000;
my $p = 4;

await gather for 1..$p {
    take start {
        for 1..$n {
            my @point = map {2.rand - 1}, 1..2;
⚛++ if sqrt([+] map *², @point) <= 1;
            $inside
        }
    }
}

say 4 * $inside / $p / $n;
```

Run the program a few times, changing the value of `$n` (the number of random points per thread) and `$p` (the number of threads). The program should print the value that is close to !, such as `3.141524`.

The new thing here is the atomic increment operation:

```raku-static
⚛++
$inside
```

An atomic operation ensures that the variable is modified with no conflicts between the threads.

The variable itself should be a native integer of a special type—notice how it is declared:

```raku-static
my atomicint $inside;
```

As the atomic operation uses the Unicode character, there is an ASCII alternative:

```raku-static
atomic-fetch-inc($inside)
```

Here’s a list of other atomic operations and their synonyms that can be used with parallel processes:

```raku-static
⚛= $value        atomic-assign($var, $value)
$var
⚛$var         my $a = atomic-fetch($var)
my $a =

⚛++               atomic-fetch-inc($var)
$var
⚛--               atomic-fetch-dec($var)
$var
⚛$var               atomic-inc-fetch($var)
++
⚛$var               atomic-dec-fetch($var)
--

⚛+= $value       atomic-fetch-add($var, $value)
$var
⚛-= $value       atomic-fetch-dec($var, $value)
$var
```

N. B. The code in this task works with the Rakudo compiler starting from version 2017.09. Earlier versions do not support atomic operators.

{% include nav.html %}
