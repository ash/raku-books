---
title: Sophisticated numbers
---

{% include menu.html %}

The translator works with numbers, which we already can parse really well. Let us join the two grammars and let the translator work with all kind of numbers, positive, negative, integers, floating-point and numbers in scientific notation.

Take the body of the `Number` grammar from Chapter 2 and copy it to the grammar of Lingua. The `TOP` rule of `Number` should become the `value` rule in `Lingua`.

```raku-static
token value {
    <sign>? [
        | <integer>
        | <floating-point>
    ] <exponent>?
}
```

Also do not forget to update the actions class:

```raku-static
method value($/) {
    $/.make(+$/);
}
```

Try the following program now:

```raku-static
my alpha;
my beta;
my gamma;

alpha = 3.14;
beta = 42;
gamma = -4.5E-2;

say alpha;
say beta;
say gamma;
```

It should parse the numbers and print them all. This step is fully completed now.

{% include nav.html %}
