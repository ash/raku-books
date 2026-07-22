---
title: 53. Adding up two arrays
---

{% include menu.html %}

*Take two arrays and create a new one whose elements are the sums of the corresponding items of the initial arrays.*

At first, we assume that the arrays are of the same length. In this case, the easiest way to solve the task is to use a meta-operator:

```raku
my @a = 10..20;
my @b = 30..40;

my @sum = @a <<+>> @b;
say @sum; # [40 42 44 46 48 50 52 54 56 58 60]
```

Meta-operators may take a few different forms. In the case of the `+` operator, it is possible to construct the following meta-operators and their alternatives using the Unicode characters:

```
<<+>>     «+»
>>+<<     »+«
>>+>>     »+»
<<+<<     «+«
```

For the above arrays of the same length, all the operators work the same. The difference between them becomes important when the operands are arrays with different numbers of elements. The sharp angles of the arrows must be directed toward the shorter operand.

You can memorise that rule by comparing the operator with the ‘more’ and ‘less’ operators `>` and `<`. The longer array stands at the ‘bigger’ end. Depending on the operator, the shorter array is either repeated as many times as needed to make pairs of each element of the longer array or is only connected with the first few elements of it. Otherwise, an exception occurs.

Consider the following four combinations with arrays of different lengths:

```raku-static
my @long = 1, 2, 3, 4;
my @short = 10, 20;

@long <<+<< @short;
@long >>+>> @short;
@long <<+>> @short;
@long >>+<< @short;
```

The first three additions compile and run:

```raku-static
say @long <<+<< @short; # [11 22]
say @long >>+>> @short; # [11 22 13 24]
say @long <<+>> @short; # [11 22 13 24]
```

As you see, the `<<+<<` operator only addresses the first two elements of the four-element array.

The `>>+>>` operator repeats the short array twice, and the four values `[10,` `20, 10, 20]` add up to the four values of the `@long` array.

The most tolerant operator is `<<+>>`. It lets the operands have different lengths and makes the shorter one longer if necessary.

The `>>+<<` operator requires both operands to have the same length. So, in our example, a runtime error is generated. This operator is called nondwimmy in the error message because it does not try to adjust to your needs.

```
Lists on either side of non-dwimmy hyperop of infix:<+> are
not of the same length
left: 4 elements, right: 2 elements
```

You have to decide whether or not you are going to use the Unicode forms of the operators.

{% include nav.html %}
