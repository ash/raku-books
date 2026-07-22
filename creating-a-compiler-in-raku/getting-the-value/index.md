---
title: Getting the value
---

{% include menu.html %}

The number has been parsed but what is its value? For a compiler, we need not only to check the validity of the number format but also to convert it from a string to a number, integer or floating-point. In this section, we will append actions to the `Number` grammar so that we can build the number and finally print it.

Let us start with integers and keep the number in a global variable.

```raku-static
my $n = 0;
class NumberActions {
    method integer($/) {
        $n = +$/;
    }
}
```

Everything looks simple here. An integer value is derived directly from converting the match piece of the string to a numeric value using the `+` prefix operator. To see how it works, let us change the main test loop so that it prints the parsed value:

```raku-static
for @cases -> $number {
    my $test = Number.parse($number, :actions(NumberActions));
    
    if ($test) {
        say "OK $number = $n";
    }
    else {
        say "NOT OK $number";
    }
}
```

With non-negative integer numbers, it works well:

```
OK 7 = 7
OK 77 = 77
OK -84 = 84
OK +7 = 7
OK 0 = 0
```

The negative number did not work. It looks like the `+7` string was processed correctly, but actually that’s not true as we completely ignored the sign. This time, the task is a bit more complicated. The first idea is to flip the sign if we meet the minus sign:

```raku-static
method sign($/) {
    $n *= -1 if ~$/ eq '-';
}
```

That does not work though, as the sign is parsed before the digits are parsed, and negating `$n` means applying a sign to zero. We can use a separate variable to keep the information about the sign but that’s not the best thing probably. But let’s do that because this will reveal another problem.

```raku-static
my $n = 0;
my $sign = 1;

class NumberActions {
    method integer($/) {
        $n = $sign * +$/;
    }

    method sign($/) {
        $sign = -1 if ~$/ eq '-';
    }
}
```

This helps to detect the first negative number, but it breaks all the rest. Of course, you can check if the sign was `'+'` but the problem is that the `$n` an `$sign` variables are global, and they must be reset before the next variable is parsed. This is a good time to move them into the actions class.

```raku-static
class NumberActions {
    has $.n = 0;
    has $!sign = 1;

    method integer($/) {
        $!n = $!sign * +$/;
    }

    method sign($/) {
        $!sign = -1 if ~$/ eq '-';
    }
}
```

The `$n` variable is intentionally made a public data member as we have to get the result somehow. You also need to change the test loop.

```raku-static
for @cases -> $number {
    my $actions = NumberActions.new();
    my $test = Number.parse($number, :actions($actions));
    
    if ($test) {
        say "OK $number = " ~ $actions.n;
    }
    else {
        say "NOT OK $number";
    }
}
```

The main change here is that you pass an instance of the `NumberActions` class to the parse method of the grammar. Now, in each iteration, the parser creates its own variables to keep the result.

We moved far enough to have all the integers be parsed correctly:

```
OK 7 = 7
OK 77 = 77
OK -84 = -84
OK +7 = 7
OK 0 = 0
```

For the floating-point numbers, it does not work as smoothly:

```
OK 3.14 = 14
OK -2.78 = -78
OK 5.0 = 0
OK .5 = 5
OK -5.3 = -3
OK -.3 = -3
OK 3E4 = 4
OK -33E55 = -55
OK 3E-3 = -3
OK 3.14E2 = 2
OK .5E-3 = -3
```

As you can see, either the decimal or the exponential part wins. In both cases, that was the last integer part that went through the grammar. Indeed, we transformed the grammar earlier to factor out the repeating parts. The bell rang when we had to introduce the `$sign` variable but now we are suffering even more. All that needs to be handled differently. And here is how AST can help.

{% include nav.html %}
