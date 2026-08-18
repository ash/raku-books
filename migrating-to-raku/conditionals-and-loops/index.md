---
title: Conditionals and Loops
---

{% include menu.html %}

This is friendly territory. `if`, `while`, `for` — the words are the same, and
most programs you have written keep working with only cosmetic edits. The two
changes worth internalising are small but pervasive: the parentheses around a
condition become optional (and idiomatically disappear), and the C-style
three-part `for` loop moves out of `for` and into a keyword of its own called
`loop`. Everything else is a refinement of habits you already have.

## `if`, `elsif`, `else`

In Perl the condition lives in parentheses:

```perl
my $n = 7;
if ($n > 10)   { say 'big' }
elsif ($n > 5) { say 'medium' }
else           { say 'small' }
```

In Raku the parentheses are optional, and leaving them off is the common style.
The block braces are now mandatory, so there is no ambiguity to resolve:

```raku
my $n = 7;
if $n > 10    { say 'big' }
elsif $n > 5  { say 'medium' }
else          { say 'small' }
# medium
```

You may still write the parentheses if you like them, but note the lesson from
Chapter 1: a space between a function name and a parenthesis is meaningful. With
control keywords there is no such trap — `if ($n > 10)` and `if $n > 10` mean the
same thing — but the habit of dropping them keeps your Raku consistent.

## `unless`

`unless` negates its condition, exactly as before:

```perl
unless ($n > 10) { say 'not big' }
```

```raku-static
unless $n > 10 { say 'not big' }   # not big
```

One rule is now enforced rather than merely discouraged: **`unless` may not take
an `else`.** In Perl `unless/else` was legal but widely considered confusing;
Raku turns that style guideline into a compile-time error:

```raku-static
unless 1 > 2 { say 'ok' } else { say 'never' }
```

```
===SORRY!===
"unless" does not take "else", please rewrite using "if"
```

If you find yourself wanting the `else`, you wanted `if` all along.

## `while` and `until`

Both loops carry over unchanged apart from the optional parentheses:

```perl
my $i = 0;
while ($i < 3) { print $i; $i++ }   # 012
```

```raku
my $i = 0;
while $i < 3 { print $i; $i++ }     # 012
```

`until` is the negated form, looping while the condition is *false*:

```raku
my $i = 0;
until $i >= 3 { print $i; $i++ }    # 012
```

Both also work as postfix statement modifiers, which we return to below:

```raku
my $i = 3;
print $i-- while $i > 0;            # 321
```

## The C-style `for` is now `loop`

Here is the one structural change. In Perl the same keyword, `for`, does two
unrelated jobs: the three-part C-style counter and the list iterator. Raku splits
them. The C-style form gets its own keyword, `loop`, and `for` is reserved purely
for iterating over lists.

The Perl counter:

```perl
for (my $i = 0; $i < 3; $i++) { print $i }   # 012
```

becomes, verbatim apart from the keyword:

```raku
loop (my $j = 0; $j < 3; $j++) { print $j }  # 012
```

With no parentheses at all, `loop` is an infinite loop — the clearest possible
spelling of "repeat forever", which you break out of with `last`:

```raku
my $count = 0;
loop {
    last if $count == 3;
    say "tick $count";
    $count++;
}
# tick 0
# tick 1
# tick 2
```

If you write a bare C-style `for` in Raku out of habit, it will not do what you
expect — `for` now always treats its argument as a list to iterate. Keep the two
keywords straight: **`loop` counts, `for` iterates.**

## `for` iterates lists, with pointy blocks

The list-iterating `for` gains a tidy new spelling. In Perl you name the loop
variable before the list:

```perl
my @a = (10, 20, 30);
foreach my $x (@a) { print "$x " }   # 10 20 30
```

In Raku the loop variable moves to the *right* of the list, introduced by a
*pointy block* `->`:

```raku
my @a = 10, 20, 30;
for @a -> $x { print "$x " }         # 10 20 30
```

The `-> $x { ... }` is a block with a signature — the same signature machinery
that powers subroutines (Chapter 15). Ranges iterate the same way, and if you do
not name a variable, the topic `$_` is used, so the leading-dot method call from
Chapter 3 shines:

```raku
for 1..3 { .say }        # .say means $_.say
```

### Read-write loop variables

By default the loop variable is *read-only* — assigning to `$x` above would be an
error. This catches a whole class of accidental mutations. When you genuinely
want to modify the array in place, mark the variable `is rw`:

```raku
my @a = 10, 20, 30;
for @a -> $x is rw { $x *= 2 }
say @a;                  # [20 40 60]
```

There is also a shorthand for exactly this case, the double-pointy `<->`:

```raku-static
for @a <-> $x { $x++ }   # each element aliased read-write
```

### Taking several items at a time

A pointy block may declare more than one variable, and `for` will then consume
the list that many elements at a stride. Modern Perl gained the same ability:

```perl
use v5.36;

my @pairs = (1, 2, 3, 4);
for my ($a, $b) (@pairs) { say "$a-$b" }
# 1-2
# 3-4
```

Raku expresses it with the pointy-block syntax used everywhere else in the book,
and either way it retires the old dance of iterating over indices in steps of
two:

```raku
my @pairs = 1, 2, 3, 4;
for @pairs -> $a, $b { say "$a-$b" }
# 1-2
# 3-4
```

The same technique reads a flat list of key/value data, or steps a grid two rows
at a time — anywhere you would previously have written `for (my $i = 0; ...; $i
+= 2)`.

## `last`, `next`, `redo`, and labels

The loop-control words are unchanged in name and meaning: `last` leaves the loop,
`next` skips to the next iteration, `redo` restarts the current iteration without
re-evaluating the condition.

```raku
my $tries = 0;
for 'a', 'b' -> $c {
    $tries++;
    redo if $c eq 'a' && $tries < 3;
    say "$c ($tries)";
}
# a (3)
# b (4)
```

To break out of an *outer* loop from within an inner one, label the loop and name
it. The label goes before the loop, and the control word takes it as an argument:

```raku-static
LINES: for @matrix -> @row {
    for @row -> $cell {
        last LINES if $cell eq 'e';
        say $cell;
    }
}
```

A word of warning learned the hard way: **do not name a label `OUTER`.** Raku
reserves `OUTER::` as a pseudo-package for the enclosing lexical scope, so `last
OUTER` is parsed as a type name and fails with a baffling "Cannot resolve caller"
error. Any other name — `LINES`, `SCAN`, `ROWS` — is fine.

## Postfix statement modifiers

Every conditional and loop keyword also works as a postfix modifier on a single
statement, just as in Perl. This is where idiomatic Raku is at its most
compact:

```raku-static
.say for 1..3;           # 1 2 3, each on its own line
say 'yes' if 5 > 3;      # yes
print $i-- while $i > 0;
```

Read them right to left: "say each of 1..3", "say yes if the condition holds".
The modifier form takes no braces and no block — it is one statement governed by
one condition — which is exactly what makes it read like English.

## `do`: blocks that return a value

A bare block in Raku is a first-class thing that produces the value of its last
statement. Prefix it with `do` to use that value in a larger expression — the
direct descendant of Perl's `do { ... }`:

```raku
my $r = do { my $t = 2 + 3; $t * 2 };
say $r;                  # 10
```

`do` also lets you use a control structure as an expression. On its own, `if` is
a statement; `do if` yields the value of the branch that ran:

```raku
my $x = 5;
my $label = do if $x > 3 { 'big' } else { 'small' };
say $label;              # big
```

And `do for` gathers the values of every iteration into a list — a compact
alternative to `map` when the body is a block:

```raku
my @squares = do for 1..3 { $_ * $_ };
say @squares;            # [1 4 9]
```

## `repeat`: the do-while loop

Perl's `do { ... } while` runs the body once before testing the condition. That
idiom is subtly broken — `do BLOCK` is not really a loop, so `last` and `next`
do not work inside it. Raku fixes this with a dedicated keyword, `repeat`, which
comes in both `while` and `until` flavours:

```perl
my $k = 0;
do { print $k; $k++ } while ($k < 3);   # 012 (Perl)
```

```raku
my $k = 5;
repeat { say "k=$k"; $k++ } while $k < 5;
# k=5      — the body always runs at least once
```

The body executes, *then* the condition is checked, so the loop above runs once
even though `$k < 5` is already false. The `until` form negates the test:

```raku
my $m = 0;
repeat { say "m=$m"; $m++ } until $m >= 2;
# m=0
# m=1
```

Unlike the Perl `do`-block idiom, `repeat` is a real loop, so `last`, `next`,
and loop phasers all behave inside it.

With the imperative control structures in hand, we can turn to the one piece of
control flow that is genuinely new to a Perl programmer: `given`/`when`, Raku's
answer to the switch statement, and the topicalisation that powers it.

{% include nav.html %}
