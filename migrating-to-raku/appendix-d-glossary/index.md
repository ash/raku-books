---
title: Appendix D — Glossary
---

{% include menu.html %}

A short, opinionated dictionary of the Raku words that a Perl programmer meets
for the first time in this book. Definitions are deliberately brief; the chapter
that treats each term in full is named where it helps.

**Adverb** — a named argument written with a colon that tunes an operator,
routine, or quote construct, such as `:g` on a substitution or `:exists` on a
hash subscript. `:g` is short for `:g(True)`; `:!g` means `False`.

**Any** — the base type of nearly every ordinary value. Type constraints
default to `Any`, and most built-in methods live here. Its parent is `Mu`.

**Array vs List** — a **List** is an ordered, immutable sequence of values; an
**Array** (the `@` variable) is a mutable container whose elements each sit in
their own scalar container. Assigning a List to an `@` variable copies its
values into fresh containers (Chapter 4).

**Binding** — associating a name directly with a value or container using `:=`,
rather than copying a value in with `=`. Bound names share one container, so
changing one changes the other (Chapter 3).

**Capture** — the object that bundles the positional and named arguments of a
call, produced by `\(…)`. It is the raw material a signature is matched against
(Chapter 8).

**Container** — the box a variable name refers to, which in turn holds a value.
Scalars are containers you can assign to; List elements are not. Understanding
containers explains assignment, binding, and context (Chapter 8).

**Decontainerisation** — stripping the container off a value so only the value
remains, written with the `<>` postfix or `.self`/`.List`. It is what stops a
nested array from behaving like a single item.

**Definiteness (`:D` / `:U`)** — a type smiley marking whether a value must be a
*defined* instance (`Int:D`) or an *undefined* type object (`Int:U`). `:_`
accepts either. Used heavily in signatures to reject uninitialised values
(Chapter 9).

**Fatarrow** — the `=>` operator, which builds a `Pair` and autoquotes a bare
identifier on its left: `a => 1` is the same as `'a' => 1`.

**gather / take** — a pair that builds a (lazy) sequence: code inside a `gather`
block emits values with `take`, and they are produced on demand (Chapter 27).

**Grapheme** — a user-visible character, possibly composed of several Unicode
codepoints. Raku strings are measured and indexed by grapheme, so `.chars`
counts what a human would call letters (Chapter 7).

**Hyper operator** — a meta-operator (`»op«`) that applies an operator to each
element of a list, potentially in parallel, e.g. `@a »+» 1` (Chapter 11).

**Itemisation** — placing a value into a single scalar container so context
treats it as one item, written `$(…)`. The inverse of decontainerisation.

**Junction** — a single value that superimposes several, combined with `any`,
`all`, `one`, or `none`: `if $x == 1|2|3 {…}`. Comparisons distribute over it
automatically (Chapter 27).

**lazy / Seq** — a **Seq** is a one-shot, on-demand sequence; laziness means
values are computed only when consumed, which is how infinite ranges like `1..*`
are usable (Chapter 4).

**Match** — the object returned by a successful regex match, stored in `$/`. It
stringifies to the matched text and holds the captures `$0`, `$1`, `$<name>`
(Chapter 18).

**Meta-operator** — an operator that takes another operator and builds a new
one: reduction `[+]`, hyper `»+«`, cross `X`, zip `Z`, and the negation and
reversal meta-operators (Chapter 11).

**Multi dispatch** — defining several routines with the same name (`multi`) and
letting Raku pick one at call time by the number and types of the arguments
(Chapter 16).

**Mu** — the root of the type hierarchy, the ancestor of every type including
`Any`. You reach for it rarely, mostly to accept truly anything.

**Phaser** — a block that runs at a defined moment in a program's life:
`BEGIN`, `END`, `ENTER`, `LEAVE`, `FIRST`, `LAST`, `KEEP`, `UNDO`, and others
(Chapter 14).

**Pair** — an immutable key-and-value object built by `=>`. Hashes are made of
Pairs, and named arguments are passed as Pairs (Chapter 5).

**proto** — an optional declaration that defines the shared shape and dispatch
frame for a set of `multi` routines (Chapter 16).

**Rat** — a rational number stored as an exact numerator-over-denominator pair,
which is why `0.1 + 0.2 == 0.3` holds in Raku (Chapter 6).

**Role** — a reusable bundle of methods and attributes that is *composed* into a
class (with `does`) rather than inherited, avoiding many multiple-inheritance
problems; comparable to Moose roles (Chapter 23).

**Sigil** — the leading symbol on a variable name (`$`, `@`, `%`, `&`) that
names its structural kind. In Raku the sigil is invariant: it does not change
when you index into the variable (Chapter 2).

**Sink context** — the "void" context of a statement whose result is not used.
A value evaluated in sink context is discarded, and some lazy things are forced
to run for their side effects.

**Slip** — a list that flattens itself into the surrounding list, produced by
`slip(…)` or the `|` prefix. It is how you splice one list into another
on purpose, given that plain lists no longer auto-flatten.

**Smartmatch** — the `~~` operator, which compares a value against a pattern
(a regex, a type, a range, a junction, a value) and does the sensible thing for
each. It replaces Perl's `=~` for regexes (Chapters 13, 18).

**subset** — a named type that narrows an existing type with a `where` clause,
e.g. `subset Even of Int where * %% 2` (Chapter 9).

**token / rule** — named, reusable pieces of a regex. A `token` is a regex with
backtracking switched off; a `rule` is a `token` that also makes whitespace
significant. They are the building blocks of grammars (Chapter 19).

**Topic** — the current default value, held in `$_`. `for`, `given`, `map`, and
a leading-dot method call all operate on the topic (Chapters 3, 13).

**Twigil** — a second character after the sigil that marks a variable's scope or
origin: `$*dynamic`, `$?compile-time`, `$!private`, `$.public`, `$^placeholder`
(Chapter 3).

**Whatever** — the `*` value, which builds a closure in an expression
(`* + 1`), means "last" in a subscript (`*-1`), and "unbounded" in a range
(`1..*`). Its explicit cousin is the Whatever code object `{ * }` (Chapter 17).

{% include nav.html %}
