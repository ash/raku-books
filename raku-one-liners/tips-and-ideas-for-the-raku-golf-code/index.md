---
title: Tips and ideas for the Raku Golf code
---

{% include menu.html %}

Omitting semicolons

Semicolons are not needed at the end of the statement before the end of the program or before the end of a code block.

```raku
say 42;
```

Omitting topic variable

If a method is called on the topic variable `$_`, then the name of the variable is not really needed for Raku to understand what you are talking about, so, avoid explicitly naming the topic variable:

```raku
$_.say for 1..10
```

Using postfix forms

In many cases, a single operation can be equally expresses as a code block or as a single operation with a posfix form of the loop or condition. Postfix forms are usually shorter. For example:

```raku
for 1..10 {.say}

.say for 1..10
```

Using ranges for making loops

Ranges are great things to manage loops: in a few characters, you specify both the initial and the final state of the loop variable.

```raku
.say for 1..9
```

But think if you can count from 0, in which case, a caret character can be used to get a range starting from 0. The following code prints the numbers 0 to 9:

```raku
.say for ^10
```

Choosing between a range and a sequence

In loops, sequences can work exactly the same way a range would do. The choice may depend on whether the Golf software counts bytes or Unicode characters. In the first case, the two dots of a range are preferable over the three dots of a range. In the second case, use a Unicode character:

```raku-static
.say for 1..10

.say for 1...10

.say for 1…10
```

When you need to count downwards, sequences are your friends, as they can deduce the direction of changing the loop counter:

```raku
.say for 10…1
```

Using `map` instead of a loop

In some cases, especially when you have to make more than one action with the loop variable, try using `map` to iterate over all the values:

```raku
(^10).map: *.say
```

Omitting parentheses and quotes

Raku does not force you to use parentheses in condition checks in the traditional form:

```raku-static
if ($x > 0) {say $x;exit}
```

Sometimes, you will want to omit parentheses in function or method calls, too:

```raku-static
say(42)

say 42
```

Neither you need parentheses when declaring arrays or hashes. With arrays, use the quoting construct on top of that to avoid the quotation marks:

```raku-static
my @a = ('alpha', 'beta')

my @b=<alpha beta>
```

Using chained comparisons

Another interesting feature is using more than one condition in a single expression:

```raku-static
 say $z if $x < 10 < $y
```

Choosing between methods and functions

In many cases, you can choose between calling a function and using a method. Method calls can be additionally chained after each other, so you can save a lot of parentheses or spaces:

```raku-static
(^10).map({.sin}).grep: *>0
```

When there exist both a method and a stand-alone function, method call is often shorter or at least of the same length if you omit parentheses.

```raku-static
abs($x)
abs $x
$x.abs
```

Using Unicode characters

Operators often have their Unicode equivalents, so you can express a wordy construct with a single character. Compare:

```raku-static
if $x=~=$y

if $x≅$y
```

Built-in constants are also available in the Unicode space, for example, `pi` vs `π`, or `Inf` vs `∞`.

There are many numbers, both small and big, that can be replaced with a single Unicode symbol: `1/3` vs `⅓`, or `20` vs `⑳`, or `100` vs .

Using superscripts

Superscripts are great for calculating powers. Compare:

```raku-static
say $x**2

$x².say
```

Using \ to make sigilless variables

Don’t forget about the following way of binding containers and creating a kind of a sigilless variable:

```raku
my \a=42;say a
```

Using default parameters

When you are working with functions or class methods, check if there are default values in their signatures. Also check if there is an alternative variant with positional arguments. Compare, for example, three ways of creating a date object.

```
Date.new(year=>2019,month=>1,day=>1)

Date.new(year=>2019)

Date.new(2019,1,1)
```

Using `&&` instead of `if`

Boolean expressions can save a few characters, as Raku will not evaluate the second condition if the first one gives the result already. For example:

```raku-static
.say if $x>0

$x>0&&.say
```

Choosing between `put` and `say`

Finally, sometimes it is better to use `put` instead of `say`. In some cases, you will be free from parentheses in the output when printing arrays, for example. In some other cases you will get all values instead of a concise output when working with ranges, for example:

```
> say 1..10
1..10

> put 1..10
1 2 3 4 5 6 7 8 9 10
```

{% include nav.html %}
