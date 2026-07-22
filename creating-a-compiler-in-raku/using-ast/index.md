---
title: Using AST
---

{% include menu.html %}

AST, or abstract syntax tree, is a mechanism that allows collecting and keeping data parsed at different stages. If the integer token is called twice when reading a floating-point number `3.14`, or if it was called three times for the number with an exponent, e.g., `3.14E2`, all those integers can be kept in the AST and used later to build the value corresponding to the whole string.

There are two methods available for the `$/` variable inside the methods of the actions class: `make` and `made`. With `make`, you store a value (you assign an attribute to the current node of the parse tree). With `made`, you read the earlier-stored value.

Add the following calls to the token actions:

```raku-static
method integer($/) {
    $/.make(+$/);
}

method sign($/) {
    $/.make(~$/ eq '-' ?? -1 !! 1);
}
```

The values are now saved even if the method is called more than once. To understand how that works, let us look inside the grammar object:

```raku-static
my $test = Number.parse($number, :actions($actions));
dd $test;
```

The `dd` routine is a Rakudo-specific tool that shows the inner structure of the object. For the input number `-84`, the following object is built after parsing:

```raku-static
Number $test = Match.new(list => (), hash => Map.new((:number(Match.new(list => (), hash => Map.new((:integer(Match.new(list => (), hash => Map.new(()), made => 84, orig => -84, pos => 3, from => 1)),:sign(Match.new(list => (), hash => Map.new(()), made => -1, orig => -84, pos => 1, from => 0)))), made => Any, orig => -84, pos => 3, from => 0)))), made => Any, orig => -84, pos => 3, from => 0)
```

Looks messy but you should be able to spot the two places we are most interested in:

```
made => 84, orig => -84, pos => 3, from => 1
made => -1, orig => -84, pos => 1, from => 0
```

The `from` and `pos` keys are set to point to the first character and to the character after the last one that matches the regex. So, the first of these two sub-hashes are the results of parsing the digits (from position 1 to position 3 in the string `'-84'`, thus `84`). The second hash corresponds to the minus character (positions 0 to 1 in the same string).

The `made` attribute is set to 84 and −1 respectively, which confirms that the grammar was able to parse the number and its sign correctly.

These values can now be used to make the result in the parent token.

```raku-static
method number($/) {
    my $n = $<integer>.made;
    $n *= $<sign>.made if $<sign>;
    $/.make($n);
}
```

It accesses the integer value and the sign multiplier via the `made` attributes of the `$<integer>` and the `$<sign>` objects. The last line passes the result to the next level, and you can access it from the `TOP` rule:

```raku-static
method TOP($/) {
    $/.make($<number>.made);
}
```

For the current task of parsing numbers, the `TOP` rule and method could be completely replaced with the content of the `number` token and the action method (notice that `TOP` is now a token, not a rule):

```raku-static
grammar Number {
    token TOP {
        <sign>? [
            | <integer>
            | <floating-point>
        ] <exponent>?
    }

    . . .
}

class NumberActions {
    method TOP($/) {
        my $n = $<integer>.made;
        $n *= $<sign>.made if $<sign>;
        $/.make($n);
    }

    . . .
}
```

If you look at the object returned by the `parse` method, you will see that it contains the following fields:

```
from => 0, orig => -84, made => -84, pos => 3
```

The `made` pair contains our desired negative integer. It is accessible from outside of the grammar and from outside of the actions using the same `made` attribute:

```raku-static
my $test = Number.parse($number, :actions($actions));

if ($test) {
    say "OK $number = " ~ $test.made;
}
```

The task is complete, and we can move on to the integers with an exponential part, e. g., 3E4. With such numbers, the `integer` token is triggered twice, but that is not a problem, as both integer numbers reside in the corresponding `made` attributes of different objects.

Create an action to work with the exponential part:

```raku-static
method exponent($/) {
    my $e = $<integer>;
    $e *= -1 if $<sign> && ~$<sign> eq '-';
    $/.make($e);
}
```

And use the value to multiply the number:

```raku-static
method TOP($/) {
    my $n = $<integer>.made;
    $n *= $<sign>.made if $<sign>;
    $n *= 10 ** $<exponent>.made if $<exponent>;
    $/.make($n);
}
```

Run the test suite, and examine what it produces for the numbers like 3E4 or −1E−2:

```
OK 3E4 = 30000
OK -33E55 =
-330000000000000000000000000000000000000000000000000000000
OK 3E-3 = 0.003
OK -1E-2 = -0.01
```

At this moment, the only token that has no associated action is `floating-point`. (The `exp` token does not need any, as its only task is to match with either `e` or `E`). Let’s look at it once again:

```raku-static
token floating-point {
    \d* ['.' <integer>]
}
```

When we were creating the token, we replaced the `\d+` part with `<integer>`. Actually, an optional sequence `\d*` can also be replaced with it:

```raku-static
token floating-point {
    <integer>? ['.' <integer>]
}
```

There are two `<integer>` calls within the same token now! What do you write in the action in this case? It’s simple: if the name is mentioned more than once, you get an array and thus you can refer to the first occurrence as `$<integer>[0]`, and as `$<integer>[1]` to the second one.

The only problem is that in our case the first integer part is optional. If you parse 3.14, you’ll get two elements as expected, but if you parse .14, then 14 will go to the element with the index 0. One of the possible solutions is just to check the length of the array. Evaluating the value is a relatively simple task.

```raku-static
method floating-point($/) {
    my $int = 0;
    my $frac = 0;

    if $<integer>.elems == 2 {
        ($int, $frac) = $<integer>;
    }
    else {
        $frac = $<integer>[0];
    }

    my $n = $int + $frac / 10 ** $frac.chars;

    $/.make($n);
}
```

The `TOP` token also has to be updated to get the value of the floating-point number if it was parsed:

```raku-static
my $n = $<integer> ?? 
        $<integer>.made !! $<floating-point>.made;
```

The task seems to be solved. All the numbers, including those with a decimal point and an exponential part, are successfully handled:

```
OK 3.14 = 3.14
OK -2.78 = -2.78
OK 5.0 = 5
OK .5 = 0.5
OK -5.3 = -5.3
OK -.3 = -0.3
OK 3E-3 = 0.003
OK -1E-2 = -0.01
OK 3.14E2 = 314
OK .5E-3 = 0.0005
```

{% include nav.html %}
