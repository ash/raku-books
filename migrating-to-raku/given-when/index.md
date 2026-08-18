---
title: given/when and Topicalization
---

{% include menu.html %}

Perl never had a switch statement it was happy with. `given`/`when` arrived
experimentally in 5.10 and was later demoted; most code fell back on an
`if`/`elsif` ladder or the well-known `for`-as-switch trick. Raku, by contrast,
builds `given`/`when` into the core of the language and wires it into the topic
variable `$_` and the smartmatch operator `~~`. The result is a switch that does
far more than compare for equality: it dispatches on values, types, ranges, and
regexes with a single, uniform mechanism.

## The Perl starting point

A chain of `elsif`s is the honest baseline. It works, but it repeats the subject
on every line:

```perl
use v5.10;
my $x = 5;
if    ($x == 1) { say 'one' }
elsif ($x == 5) { say 'five' }
else            { say 'other' }
# five
```

The other classic idiom localises `$_` by looping over a single value, turning
the block into a topicaliser so that regex matches and `last` become available:

```perl
for ($x) {
    if (/^\d+$/) { say 'digits'; last }
    say 'not digits';
}
# digits
```

That `for ($x) { ... }` trick — abusing a loop to set the topic — is precisely
the idea Raku promotes to a first-class keyword.

## `given` sets the topic

`given` takes an expression, makes it the topic `$_`, and runs a block. That is
all it does; on its own it is just a topicaliser:

```raku
given 'Hello, World!' {
    .say;                # Hello, World!
    .uc.say;             # HELLO, WORLD!
    say .chars;          # 13
}
```

Every leading-dot method call operates on `$_`, exactly as we saw in Chapter 3.
So `given` is the explicit, named version of "set the topic to this, then act on
it" — the honest form of the Perl `for`-with-one-element hack.

## `when` smartmatches against the topic

Inside a `given` (or any block where `$_` is set), `when` compares the topic
against a value using the smartmatch operator `~~` *implicitly*. When the match
succeeds, the block runs and then — crucially — automatically `last`s out of the
enclosing construct. There is no fall-through, so no `break` is needed:

```raku
sub grade($score) {
    given $score {
        when * >= 90 { 'A' }
        when * >= 80 { 'B' }
        when * >= 70 { 'C' }
        default      { 'F' }
    }
}
say grade(95);           # A
say grade(83);           # B
say grade(50);           # F
```

The `*` here is the *whatever star* (Chapter 17): `* >= 90` builds a little
callback that smartmatches true when the topic is at least 90. `default` is the
catch-all, equivalent to a final `else`.

Note that each `when` block's value becomes the value of the whole `given` — this
`grade` subroutine has no explicit `return` and needs none.

## Matching on more than equality

The power of `when` is that `~~` means different things depending on the
right-hand side. One switch can mix values, types, ranges, and regexes freely:

```raku-nobrowser
sub describe($x) {
    given $x {
        when 0        { 'zero' }
        when Int      { 'some integer' }
        when 1..10    { 'small number' }
        when /^\d+$/  { 'a string of digits' }
        default       { 'something else' }
    }
}
say describe(0);         # zero
say describe(5);         # some integer
say describe(3.14);      # small number
say describe('42abc');   # something else
```

Read the cases as questions asked of the topic: *is it equal to 0? is it an Int?
is it in the range 1..10? does it match this regex?* Because matching stops at the
first success, **order matters**: `describe(5)` reports "some integer" because
`when Int` is tested before `when 1..10`. Put your most specific cases first.

## `proceed` and `succeed`

Automatic `last` is usually what you want, but occasionally you need to override
it. Two keywords give you fine control.

`proceed` falls through to the *next* `when`, deliberately continuing the search
after a match:

```raku
given 42 {
    when Int    { say 'an integer'; proceed }
    when * > 10 { say 'and greater than ten' }
    default     { say 'not reached' }
}
# an integer
# and greater than ten
```

`succeed` does the opposite: it leaves the entire `given` block immediately, and
may carry a value out with it. It is the early-exit you would otherwise write
with `last`, but it can also supply the block's result:

```raku
sub classify($n) {
    given $n {
        when * < 0 { 'negative' }
        default {
            succeed 'non-negative' if $n == 0;
            'positive'
        }
    }
}
say classify(-3);        # negative
say classify(0);         # non-negative
say classify(7);         # positive
```

## `when` inside a `for` loop

Because `for` already sets the topic on each iteration, you can drop `when`
straight into a loop body with no `given` at all — the loop *is* the topicaliser.
This is the clean version of the Perl `for`-as-switch idiom, now built from
parts that were designed to fit together:

```raku
for 1, 'two', 3.0, [4] {
    when Int { say "$_ is Int" }
    when Str { say "$_ is Str" }
    default  { say "$_ is something else" }
}
# 1 is Int
# two is Str
# 3 is something else
# 4 is something else
```

Here the automatic `last` of a matched `when` is understood as `next` — it moves
on to the following iteration rather than leaving the loop.

## `given` as an expression

A `given` block yields the value of whichever branch ran, so it can produce a
result directly. As with `if` in Chapter 12, using a control keyword in
expression position needs the `do` prefix — a bare `given` on the right of `=` is
a compile-time error that tells you exactly what to add:

```raku
my $size = do given 1024 {
    when * < 1000  { 'small' }
    when * < 10000 { 'medium' }
    default        { 'large' }
};
say $size;               # medium
```

This is the shape you will reach for constantly: a table of cases collapsed into a
single value, no temporary variable, no fall-through, no repeated subject. It is
what the `if`/`elsif` ladder always wanted to be.

Topicalisation and smartmatch are the last pieces of ordinary control flow. Next
we look at code that runs *outside* the ordinary flow altogether — at compile
time, at block entry and exit, around each loop iteration — through Raku's
phasers.

{% include nav.html %}
