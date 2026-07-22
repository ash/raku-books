---
title: 40. Guess the number
---

{% include menu.html %}

*Write a program that generates a random integer number 0 through 10 and asks the user to guess it, saying if the entered value is too small or too big.*

First, a random number needs to be generated. In Raku, the `rand` routine can be called on an integer object, and it returns a random floating-point value between 0 and that integer. As the task requires a random integer number, call the `round` method on the result:

```
10.rand.round
```

Now, ask for the initial guess and enter the loop, which compares the guess with `$n`.

```raku-static
my $n = 10.rand.round;

my $guess = prompt('Guess my number between 0 and 10: ');

while $guess != $n {
    if $guess < $n {
        say 'Too small.';
    }
    elsif $guess > $n {
        say 'Too big.';
    }
    $guess = prompt('Try again: ');
}

say 'Yes, this is it!';
```

The `if`-`elsif` chain may be replaced with a ternary operator:

```raku-static
say $guess < $n ?? 'Too small.' !! 'Too big.';
```

{% include nav.html %}
