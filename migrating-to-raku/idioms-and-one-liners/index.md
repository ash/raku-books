---
title: Idioms, Gotchas, and One-liners
---

{% include menu.html %}

We have reached the end of the journey, and it is a good moment to gather the
small stones that most often trip a Perl programmer crossing into Raku — the
gotchas that survive even after you have learned the big ideas — and then to have
some fun with the thing Perl was always best at: the command-line one-liner. Keep
this chapter close for the first few weeks; these are the mistakes everyone
makes, and knowing them in advance saves a lot of puzzled staring.

## The space-before-paren trap

We met this in Chapter 1, and it earns a reminder because it is the single most
common surprise. A space between a function name and its opening parenthesis
changes the meaning. Without the space, the parentheses are the argument list;
with the space, they are a single parenthesised argument — a list.

```raku
say ("a", "b");        # (a b)   — one argument: the list ("a", "b")
say("a", "b");         # ab      — two arguments
```

The rule: `f(...)` is a call with those arguments; `f (...)` passes one thing, the
value of `(...)`. When in doubt, drop the space.

## The single-argument rule

Related, and just as sneaky: `[ ]` around a single array does *not* wrap it in an
extra layer — but around anything that looks like a list, it does. This bites when
you build nested structures.

```raku-nobrowser
my @a = 1, 2, 3;
say [@a];              # [1 2 3]     — a single array flows straight in
say [1, @a];           # [1 [1 2 3]] — now @a is one element among others
```

Recall from Chapter 4 that arrays no longer flatten themselves. If you meant to
merge, use the slip prefix `|`: `[1, |@a]` gives `[1 1 2 3]`.

## `//` versus `||`

Both languages have both operators, and the distinction is the same — but because
Raku code leans on `//` far more often, it is worth stating plainly. `||` tests
*truth*; `//` tests *definedness*. The difference shows the instant a legitimate
value is falsy, such as `0` or the empty string.

```perl
my $x = 0;
say $x || 5;           # 5    — 0 is false, so the default wins
say $x // 5;           # 0    — 0 is defined, so it stays
```

```raku
my $x = 0;
say $x || 5;           # 5
say $x // 5;           # 0
```

Reach for `//` when supplying a default for something that might be undefined but
could legitimately be `0` or `''` — which is most of the time.

## `~~` is not Perl's smartmatch

Perl's smartmatch was famously unpredictable and is now discouraged. Raku's
`~~` is well-defined: it asks "does the left-hand side *match* the right-hand
side?", and the meaning of "match" depends on the right operand. Against a type
it is a type check; against a range, membership; against a regex, a pattern
match; against a junction, distribution.

```raku
say 5 ~~ Int;          # True
say 5 ~~ 3..10;        # True
say "foo" ~~ /o/;      # ｢o｣    — the match object (truthy)
say 3 ~~ (1|2|3);      # True
```

This is the engine behind `given`/`when` (Chapter 13). The key mental shift from
Perl: `~~` is not symmetric and not a mystery — the right-hand side decides the
kind of test.

## `return` from a pointy block

In Raku, `return` always returns from the enclosing *subroutine or method*, never
merely from a block. A pointy block is transparent to it, which can surprise you
inside a `map`:

```raku
sub find-first(@list) {
    @list.map(-> $x { return $x if $x > 2 });   # returns from find-first!
    return -1;
}
say find-first([1, 2, 3, 4]);                   # 3
```

If you only want the block to *produce* a value, do not write `return` at all —
the block's last expression is its value:

```raku
my @doubled = (1, 2, 3).map(-> $x { $x * 2 });
say @doubled;                      # [2 4 6]
```

So: `return` exits the whole routine; to yield from a block, just let the value
fall out.

## `==` versus `eq`

The oldest Perl gotcha survives unchanged, but with a sharper edge. `==` compares
*numerically*, `eq` compares *as strings* — and in Raku, forcing a non-numeric
string through `==` is a loud error rather than a silent zero.

```raku-static
say "10" == "10.0";    # True   — numeric: equal
say "10" eq "10.0";    # False  — string: different
say "abc" == "abd";    # error: Cannot convert string to number
```

Perl would quietly treat `"abc"` as `0` here; Raku refuses to guess. Use `==`
for numbers, `eq` for text, and let the error remind you when you have mixed them
up.

## Sigil-invariance slips

The headline change from Chapter 2 — the sigil never switches — produces one
recurring slip: fingers trained on Perl still type `$a[1]` to reach an element
of `@a`. In Raku that names a *different, undeclared* variable, and you get a
compile-time error rather than the value you wanted.

```raku
my @a = 10, 20, 30;
say @a[1];             # 20   — correct: the sigil stays @
# say $a[1];           # error: Variable '$a' is not declared
```

The good news is that this is a *compile-time* error, so it is caught instantly,
not at three in the morning in production. Retrain the reflex: the sigil belongs
to the variable, and indexing never changes it.

## The one-liner cookbook

Now the fun part. Both compilers run a program straight from the command line
with `-e`. The line-loop switches are deliberately familiar: `-n` wraps your code
in a loop over each input line, and `-p` does the same but prints `$_` at the end
of each iteration. Combine them with `-e` as `-ne` and `-pe`, exactly as in
Perl.

```
$ raku -e 'say "Hello from a one-liner"'
$ raku -ne '.say if /pattern/'  file
$ raku -pe '$_ = .uc'           file
```

There are two differences worth internalising. First, in Raku's `-n`/`-p` loops
the line is **already chomped** — `$_` never carries the trailing newline, so you
do not sprinkle `chomp` everywhere as you do in Perl. Second, and more
surprising: **Raku has no `-a`/`-F` autosplit switch and no `-i` in-place switch**.
Where Perl gives you `@F` for free, in Raku you split explicitly with
`.words`, `.split`, or `.comb` — which is a small price for one obvious idiom
instead of a hidden global.

```perl
# Perl: -a splits each line into @F automatically
perl -lane 'print $F[0]' file
```

```raku-static
# Raku: split it yourself with .words
raku -ne 'say .words[0]' file
```

`$_` is the default topic in a one-liner just as in a program, so leading-dot
method calls (`.say`, `.uc`, `.words`) act on the current line with no variable
named at all. `BEGIN` and `END` blocks work inside one-liners too, which is how
you initialise and report an accumulator.

Here is a table of everyday tasks, Perl beside Raku:

| Task | Perl | Raku |
|------|--------|------|
| Print matching lines | `perl -ne 'print if /an/'` | `raku -ne '.say if /an/'` |
| Uppercase each line | `perl -pe '$_=uc'` | `raku -pe '$_ = .uc'` |
| Sum the 2nd column | `perl -lane '$s+=$F[1]; END{print $s}'` | `raku -ne 'state $s=0; $s+=.words[1]; END {say $s}'` |
| Count word frequency | `perl -ne 'chomp;$c{$_}++; END{print "$_ $c{$_}\n" for keys %c}'` | `raku -ne 'state %c; %c{$_}++; END {.say for %c.sort}'` |
| Reverse the lines (`tac`) | `perl -e 'print reverse <>'` | `raku -e 'say $*IN.lines.reverse.join("\n")'` |
| In-place edit | `perl -i -pe 's/a/b/' file` | (no switch — edit in the program, e.g. `'file'.IO.spurt(...)`) |

Each of these was run to produce the outputs used throughout this book; for
example, the column-sum over `apple 3 / banana 5 / cherry 2` prints `10`, and the
frequency count over `a b a c b a` prints `a => 3`, `b => 2`, `c => 1`.

## Where you are now

If you have read this far, something has quietly changed. The Raku you met in
Chapter 1 as a stranger with familiar features is now a language you can read at a
glance and write without a manual open. You know why the sigil stopped shifting,
why the dot means "method", why numbers add up and lists stopped flattening; you
can reach for signatures, roles, grammars, promises, and lazy lists as naturally
as you once reached for `@_`, `bless`, and `map`. The workarounds you carried
from Perl — the clever `@{[...]}`, the hand-rolled exception class, the
`fork`-and-reap dance — have become one-word built-ins.

There is much more to explore, and the community is welcoming, but you no longer
need a translator: you think in Raku now. The appendices that follow are a
reference to return to — a cheat sheet, the operator and special-variable tables,
a glossary, and pointers onward. Keep writing Raku, and enjoy it. Welcome to the
other side.

{% include nav.html %}
