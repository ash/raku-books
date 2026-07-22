---
title: What’s behind 0.1 + 0.2
---

{% include menu.html %}

Let us examine a one-liner that computes a zero.

```raku
say 0.1 + 0.2 - 0.3
```

If you are familiar with programming, you know well that as soon as you start using floating-point arithmetic, you lose precision, and you can face the small errors very quickly.

You might also saw the website 0.30000000000000004.com that has a long list of different programming languages and how they print a simple expression `0.1 + 0.2`. In most cases, you don’t get an exact value of 0.3. And often when you get it, it is actually the result of rounding during the print operation.

In Raku, 0.1 + 0.2 is exactly 0.3, and the above-mentioned one-liner prints an exact zero.

Let us dive into the compiler internals a bit to see how that works. The Grammar of Raku (implemented in the Rakudo compiler) has the following fragment that detects numbers:

```raku-static
token numish {
    [
    | 'NaN' >>
    | <integer>
    | <dec_number>
    | <rad_number>
    | <rat_number>
    | <complex_number>
    | 'Inf' >>
    | $<uinf>='∞'
    | <unum=:No+:Nl>
    ]
}
```

Most likely, you are familiar enough with Raku, and you know that the above behaviour is explained by the fact that it uses rational numbers to store floating-point numbers such as 0.1. That’s right, but looking at the grammar, you can see that the journey is a bit longer.

What is called `rat_number` in the grammar is a number written in angle brackets:

```raku-static
token rat_number { '<' <bare_rat_number> '>' }
token bare_rat_number {
    <?before <.[-−+0..9<>:boxd]>+? '/'>
    <nu=.signed-integer> '/' <de=integer>
}
```

So, if you change the program to:

```raku
say <1/10> + <2/10> - <3/10>
```

then you will immediately operate rational numbers. Here is a corresponding action that converts the numbers in this format:

```raku-static
method rat_number($/) { make $<bare_rat_number>.ast }

method bare_rat_number($/) {
    my $nu := $<nu>.ast.compile_time_value;
    my $de := $<de>.ast;
    my $ast := $*W.add_constant(
        'Rat', 'type_new', $nu, $de, :nocache(1));
    $ast.node($/);
    make $ast;
}
```

At some point, the abstract syntax tree gets a node containing a constant of the `Rat` type with the `$nu` and `$de` parts for numerator and denominator.

In our example, the numbers written in the form of `0.1` first pass the `dec_number` token:

```raku-static
token dec_number {
    :dba('decimal number')
    [
    | $<coeff> = [ '.' <frac=.decint> ] <escale>?
    | $<coeff> = [ <int=.decint> '.' <frac=.decint> ]
                 <escale>?
    | $<coeff> = [ <int=.decint> ] <escale>
    ]
}
```

The integer and the fractional parts of the number get into the `<int>` and `<frac>` keys of the final Match object. The action method for this grammar token is rather complex. Let me show it to you.

```raku-static
method dec_number($/) {
    if $<escale> { # wants a Num
        make $*W.add_numeric_constant: $/, 'Num', ~$/;
    } else { # wants a Rat
        my $Int := $*W.find_symbol(['Int']);
        my $parti;
        my $partf;

        # we build up the number in parts
        if nqp::chars($<int>) {
            $parti := $<int>.ast;
        } else {
            $parti := nqp::box_i(0, $Int);
        }
        if nqp::chars($<frac>) {
            $partf := nqp::radix_I(
                      10, $<frac>.Str, 0, 4, $Int);

            $parti := nqp::mul_I($parti, $partf[1], $Int);
            $parti := nqp::add_I($parti, $partf[0], $Int);

            $partf := $partf[1];
        } else {
            $partf := nqp::box_i(1, $Int);
        }

        my $ast := $*W.add_constant(
            'Rat', 'type_new', $parti, $partf,
            :nocache(1));
        $ast.node($/);
        make $ast;
    }
}
```

For each of the numbers `0.1`, `0.2`, and `0.3`, the above code takes their integer and fractional parts, prepares the two integers, `$parti` and `$partf`, and passes them to the same constructor of a new constant as we saw in the `rat_number` action, and after that you get a `Rat` number.

Now we skip some details and take a look at another important part of rational numbers that you have to know about.

In our example, the integer and the fractional parts get the following values:

```raku-static
$parti=1, $partf=10
$parti=2, $partf=10
$parti=3, $partf=10
```

You can easily see it yourself if you hack on your local copy of Rakudo files.

Alternatively, use the `--target=parse` option in the command line:

```
$ raku --target=parse -e'say 0.1 + 0.2 - 0.3'
```

A part of the output will contain the data we want to see:

```
- 0: 0.1
- value: 0.1
    - number: 0.1
    - numish: 0.1
        - dec_number: 0.1
        - frac: 1
        - int: 0
        - coeff: 0.1
- 1: 0.2
- value: 0.2
    - number: 0.2
    - numish: 0.2
        - dec_number: 0.2
        - coeff: 0.2
        - frac: 2
        - int: 0
```

Having the numbers presented as fractions, it is quite easy to make exact calculations, and that’s why we see a pure zero in the output.

Returning to our fractions. If you print both numerator and denominator (using the `nude` method, for example), you will see that the fraction is normalised if possible:

```
> <1/10>.nude.say
(1 10)
> <2/10>.nude.say
(1 5)
> 0.2.nude.say
(1 5)
> 0.3.nude.say
(3 10)
```

As you see, we have 1/5 instead of 2/10. That represents the same number with the same accuracy. When you use the number, you should not worry about finding the common divider for both fractions, for example:

```
> (0.1 + 0.2).nude.say
(3 10)
```

{% include nav.html %}
