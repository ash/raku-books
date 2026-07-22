---
title: 20. Factorial!
---

{% include menu.html %}

*Print the factorial of a given number.*

By definition, the factorial of a positive integer number N is a product of all the integers numbering from 1 to N, including N. This can be easily expressed with the use of a reduction operator:

```raku
my $n = 5;
my $f = [*] 1 .. $n;
say $f;
```

The record `[*] 1 .. $n` is equivalent to the following expression:

```raku-static
1 * 2 * 3 * 4 * ... * ($n – 1) * $n
```

A compact form `[*]` means that the operation character `*` is placed between the numbers in the given list.

The result in the case of `$n` equals 5 is:

Another approach to calculating factorials is using recursion according to the formula:

&! = & ∙(& −1)!

On each iteration step, the function calls itself with decremented argument and should stop as soon as the value becomes less than two. In Raku, the knowledge of the fact that 1! is 1 can be encoded as a special case using multi-functions.

Multi-functions are subroutines prefixed with the `multi` keyword. They all share the name but may be distinguished by the type, number or values of their arguments.

For the factorial, define two multi-functions, one to calculate the factorial of the smallest numbers 0 and 1 (ignore the negative numbers for now):

```raku-static
multi sub factorial(Int $x where {$x < 2}) {
    return 1;
}
```

The second variant is for all the other numbers.

```raku-static
multi sub factorial(Int $x) {
    return $x * factorial($x - 1);
}
```

The `where` clause in the function signature splits the calls to the `factorial` functions. It is enough to have the `where` clause only in one of the two function variants, but you can explicitly add it for clarity: `where $x >= 2`.

Calling the factorial with the number 5 calls the second variant a few times first, switching to the first variant when `$x` reaches `1`. As that variant does not iteratively call itself, the whole recursion loop stops.

```raku-static
say factorial(5);
```

Take a look at the signature of the function:

```raku-static
(Int $x where {$x < 2})
```

Here, the variable `$x` is typed as `Int` (which is an integer in Raku) and restricted by the condition `{$x < 2}` in the `where` clause. Therefore, this signature does its work to decide if the corresponding subroutine accepts the number or not.

Raku offers another exciting thing, which gives quite impressive results in its application to the factorial task. It is possible to define your own postfix operators, so you can write `5!` in the code and get the factorial of five.

Here is an example of defining the postfix `!` operator:

```raku-static
sub postfix:<!>($n) {
    return [*] 1 .. $n;
}
```

Using it is straightforward:

```raku-static
say 5!;
```

This factorial operator is also applicable to variables, including the default variable:

```raku-static
my $x = 7;
say $x!; # Prints 5040

say .! for 3..7; # 6, 24, 120, 720, 5040
```

Recursive definition works with the user-defined operator, too. It is possible to use it even from the body of the operator definition itself:

```raku
sub postfix:<!>($n) {
    $n <= 1 ?? 1 !! $n * ($n - 1)!
}

say 5!; # Prints 120
```

The stop condition of the recursion is implemented here via the Boolean check `$n <= 1`. In one-line functions like those shown above, it is not necessary to type the `return` keyword, as the last calculated value is used as the result.

{% include nav.html %}
