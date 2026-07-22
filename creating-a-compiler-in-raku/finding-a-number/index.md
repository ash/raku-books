---
title: Finding a number
---

{% include menu.html %}

Calculators work with numbers, so the first thing we’ll do will be a parser that parses numbers. In the previous chapter, we only worked with non-negative integers, but there are much more number formats that a good calculator has to understand. It includes, for example, negative numbers and floating-point numbers, which can be also written in scientific notation. We also have to allow the cases when people omit zeros before the decimal point and type .5 instead of 0.5.

Let’s iteratively create the parser for different kinds of numbers. As we are going to make a lot of changes in the grammar, a test suite comes for the rescue.

```raku-static
my @cases = 7, 77, -84;
for @cases -> $number {
    say "Test $number";
    say Number.parse($number);
}
```

The `@cases` array contains a list of numbers that will be tested against the `Number` grammar. Here is its first version:

```raku-static
grammar Number {
    rule TOP {
        <number>
    }

    token number {
        \d+
    }
}
```

The whole grammar expects a single number, which is a sequence of digits. It works with our current test cases, and the program’s output is quite predictable:

```
Test 7
｢7｣
 number => ｢7｣
Test 77
｢77｣
 number => ｢77｣
Test -84
Nil
```

The first two numbers pass the exam, but the third one does not. For a negative number, the `parse` method returns `Nil`.

So, we need to extend the `number` token and add an optional minus sign in front of the number. An important thing that it still has to be a token, as you normally do not expect a space between the sign and the number.

```raku-static
token number {
    '-'? \d+
}
```

This small change makes another half of integer numbers, negative integers, valid. The above test will now pass.

```
Test -84
｢-84｣
 number => ｢-84｣
```

But what if you spell a positive number as `+7`?

```raku-static
my @cases = 7, 77, -84, '+7', 0;
```

(A grammar parser always consumes strings, but we can let Raku convert positive numbers to avoid extra quoting in the list of test cases.)

This number is not a valid number according to the grammar. As it expects the whole string to be a number, we cannot expect that the plus sign will be simply ignored. The parser needs to know about the possible sign at the beginning, thus, we need to add it to the token body:

```raku-static
token number {
    <[+-]>? \d+
}
```

Let us also reduce the noise in the output, and do not print the parse tree:

```raku-static
for @cases -> $number {
    my $test = Number.parse($number);
    say ($test ?? 'OK ' !! 'NOT OK ') ~ $number;
}
```

The output now is partially compatible with the TAP (Test Anything Protocol) which is widely used in testing Perl modules.

```
OK 7
OK 77
OK -84
OK +7
OK 0
```

Add a non-valid number and you’ll immediately see that it fails, for example:

```
NOT OK 3.14
```

The first attempt to implement a parser for the flowing-point numbers can be as simple as this:

```raku-static
token number {
    <[+-]>? \d+ ['.' \d+]?
}
```

We just added an optional decimal part. But what if you meet a number with a point but with no integer part? It will not pass the test, but it is easy to solve by changing `\d+` to `\d*` in the left part of the regex:

```raku-static
token number {
    <[+-]>? \d* ['.' \d+]?
}
```

Unfortunately, this change breaks the token, as it can be applied to a single sign or even to an empty string. All these test cases are now OK:

```raku-static
my @cases =
    7, 77, -84, '+7', 0,
    3.14, -2.78, 5.0, '.5',
    '', '-', '+';
```

It is a bit tricky to try to express all the options in a single regex. It is much easier to explicitly list all the alternatives. As we know that the sign can appear in front of any number, let us group the alternatives in square brackets:

```raku-static
token number {
    <[+-]>? [
        | \d+ 
        | \d* ['.' \d+]
    ]
}
```

This approach makes the whole token more readable and more extendable. We can add another alternative to match the numbers in scientific notation.

```raku-static
token number {
    <[+-]>? [
        | \d+
        | \d* ['.' \d+]
        | \d+ <[eE]> <[+-]>? \d+
    ]
}
```

More test cases pass the grammar now:

```
'3E4', '-33E55', '3E-3', '-1E-2'
```

What we are missing are the numbers in scientific notation with non-integer mantissa, e.g., `3.14E2` or `.5E-3`. Another alternative can solve this issue:

```raku-static
token number {
    <[+-]>? [
        | \d+
        | \d* ['.' \d+]
        | \d+ <[eE]> <[+-]>? \d+
        | \d* ['.' \d+] <[eE]> <[+-]>? \d+
    ]
}
```

In this form, there are parts that repeat, such as `\d+` or `\d* ['.' \d+]`. In such compact rules that may be fine, but it is also possible to decompose it further, and to introduce sub-tokens that are responsible for such repeated parts. The transformed `number` token and its family look like this:

```raku-static
token number {
    <sign>? [
        | <integer>
        | <floating-point>
        | <integer> <exponent>
        | <floating-point> <exponent>
    ]
}

token sign {
    <[+-]>
}

token exp {
    <[eE]>
}

token integer {
    \d+
}

token floating-point {
    \d* ['.' <integer>]
}

token exponent {
    <exp> <sign>? <integer>
}
```

While there is much more code comparing to the previous version, each token is simpler to understand. Compare, for example, the previous and the current regexes for a number in scientific notation having a floating point number in its mantissa. Earlier, it was:

```
\d* ['.' \d+] <[eE]> <[+-]>? \d+
```

After the transformation, it became:

```
<floating-point> <exponent>
```

Looking at the alternatives of the main token,

```
| <integer>
| <floating-point>
| <integer> <exponent>
| <floating-point> <exponent>
```

you immediately see what they describe. Even more, we can reduce it further:

```raku-static
token number {
    <sign>? [
        | <integer>
        | <floating-point>
    ] <exponent>?
}
```

In other words, a number is either an integer or a floating-point value, which is preceded by an optional sign and can be followed by an optional exponent part. In this form, the description is so clean and compact. All the details (the regex “noise”) is hidden in the supplementary tokens.

{% include nav.html %}
