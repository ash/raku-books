---
title: From Regexes to Grammars
---

{% include menu.html %}

By the end of Chapter 18 you had named patterns — `token`, `rule`, `regex` — that
call one another with `<name>`. A **grammar** is simply a named collection of
those, gathered into one unit the way a class gathers methods. If you have ever
reached for a parser generator, or worse, tried to parse a nested format with a
tower of Perl regexes and `while` loops, this is the chapter where Raku earns
its keep. Grammars are the language's headline feature, and they are built from
pieces you already understand.

This chapter is a *teaser*, not a reference. The goal is to get you parsing
something real and to show how the parts fit; the full grammar documentation at
`docs.raku.org` goes much deeper.

## From a bag of tokens to a `grammar`

In Perl there is no first-class way to package related regexes. You end up with
a module full of `qr//` variables and hand-written glue. Raku gives you a keyword:

```raku-static
grammar NumberList {
    token TOP    { <number>+ % ',' }
    token number { \d+ }
}
```

A grammar is declared like a class, and its named patterns are like methods. One
of them is special: the rule named `TOP` is the entry point, the pattern the
whole input must match. You start a parse by calling `.parse` on the grammar:

```raku-static
my $m = NumberList.parse("1,22,333");
say $m<number>;         # [｢1｣ ｢22｣ ｢333｣]
say $m<number>[1];      # ｢22｣
say $m<number>[1].Int;  # 22
```

The result is a Match object — the same `$/` object from Chapter 18 — but now it
is a *tree*. Each subrule that matched hangs off it under its own name, and a
quantified subrule like `<number>+` gives you a list you can index. That tree is
the whole point: instead of one flat match, you get structure.

If the input does not match `TOP` from start to finish, `.parse` returns `Nil`.
When you only want to match a *prefix* and not insist on consuming everything,
use `.subparse`:

```raku
grammar G { token TOP { \d+ } }
say G.subparse("42 and more");   # ｢42｣  — matches as far as it can
```

## `token`, `rule`, and `regex` — which to use

All three declare a named pattern; they differ only in the defaults they switch
on, which you met as adverbs in Chapter 18:

- **`regex`** — backtracks like a Perl pattern. Flexible, occasionally slow.
- **`token`** — adds `:ratchet`, so it never backtracks. This is your default for
  parsing: fast and predictable.
- **`rule`** — a `token` that also adds `:sigspace`, so whitespace *between* the
  pieces of the pattern matters and is matched automatically.

The `rule` variant is what makes grammars pleasant for real text, where tokens
are separated by arbitrary spacing. Compare: with `token` you would sprinkle
`\h*` between the parts yourself, but with `rule` the spaces in the pattern do
that for you. Here `rule TOP` lets "1, 22, 333" parse despite the spaces after
each comma:

```raku-nobrowser
grammar NumberList {
    rule  TOP    { <number>+ % ',' }
    token number { \d+ }
}
say NumberList.parse("1, 22, 333")<number>;   # [｢1｣ ｢22｣ ｢333｣]
```

## Calling subrules, and quantifying them

A subrule call `<number>` inside another pattern both *matches* using that rule
and *captures* the result under that name. Quantify it — `<number>+`,
`<thing>*`, `<item>+ % ','` — and the capture becomes a list, exactly as you saw
above with `$m<number>[1]`. This composability is what replaces the nested
loops: a grammar for a nested structure is just rules that call rules that call
rules, all the way down, and the tree mirrors the nesting for free.

## Proto and multi tokens: one name, several shapes

Sometimes a single conceptual thing has several forms — a number might be an
integer or a float, a value might be quoted or bare. Raku lets several tokens
share one name through a `proto` declaration and `multi`-style `:sym<...>`
variants:

```raku
grammar Num {
    token TOP { <number> }
    proto token number {*}
    token number:sym<int>   { \d+ }
    token number:sym<float> { \d+ '.' \d+ }
}
say Num.parse("42")<number>;     # ｢42｣
say Num.parse("3.14")<number>;   # ｢3.14｣
```

The `proto` says "there is a token called `number`, defined in pieces"; each
variant handles one case. Thanks to longest-token matching (Chapter 18), Raku
automatically prefers `float` for `3.14` because it matches more text. This is
the same multiple-dispatch idea you met for subroutines in Chapter 16, applied to
parsing.

## Actions: turning a parse tree into a result

Matching tells you the input is *valid*. Usually you also want to *do* something
with it — build a data structure, compute a value, translate to another format.
For that you attach an **actions class**: a plain class whose method names match
the grammar's rule names. As each rule matches, Raku calls the method of the same
name, handing it that rule's Match object as `$/`.

Inside an action you call `make` to attach a result to the current match, and you
read a child's result back with `.made`. Think of `make` as "this is what this
piece *means*", flowing bottom-up: leaves make simple values, and the rules above
them combine those into bigger ones. Here is a grammar that sums a list of
numbers:

```raku-nobrowser
grammar NumberList {
    rule  TOP    { <number>+ % ',' }
    token number { \d+ }
}

class Sum {
    method number($/) { make $/.Int }                     # a leaf: its value
    method TOP($/)    { make $<number>.map(*.made).sum }  # combine the leaves
}

my $r = NumberList.parse("1, 22, 333, 4", actions => Sum);
say $r<number>;   # [｢1｣ ｢22｣ ｢333｣ ｢4｣]
say $r.made;      # 360
```

You pass the actions class with the `actions` named argument, and the final
result is on `.made` of the top-level match. The grammar describes *shape*; the
actions class describes *meaning*. Keeping them apart means one grammar can drive
several different actions classes — one to evaluate, another to pretty-print, a
third to build an AST.

## A complete worked example: a config parser

Let us tie it all together with something you might actually reach for: parsing a
simple `key = value` configuration file into a hash. This runs exactly as shown.

```raku
grammar Config {
    token TOP    { <line>+ %% \n }
    token line   { <key> \h* '=' \h* <value> }
    token key    { \w+ }
    token value  { \N+ }
}

class ConfigActions {
    method line($/) { make ~$<key> => ~$<value> }   # ~ stringifies the match
    method TOP($/)  { make $<line>.map({ .made }).Hash }
}

my $text = q:to/END/;
name = Andrew
lang = Raku
year = 2026
END

my %config = Config.parse($text, actions => ConfigActions).made;
say %config;         # {lang => Raku, name => Andrew, year => 2026}
say %config<lang>;   # Raku
```

Read it top-down and it is almost self-documenting. `TOP` is one-or-more lines
separated (or terminated, thanks to `%%`) by newlines. Each `line` is a `key`, an
`=`, and a `value`, with optional horizontal whitespace around the equals sign.
The actions class turns each line into a `Pair` and collects them into a `Hash`.
No manual `split`, no line-by-line loop, no fragile chained regexes — the
structure of the format *is* the code.

This is only the doorway. Grammars support inheritance (one grammar can extend
another), error reporting, and full recursive descent capable of parsing entire
programming languages — Rakudo parses Raku itself with a grammar. The official
documentation is the place to go next when you need those depths.

With regexes reworked and grammars in hand, you have the tools to take structured
text apart. Part VII turns to the everyday flip side of that skill: putting text
together and moving it around. Chapter 20 opens it with text processing —
`sprintf`, `split`, `join`, heredocs, and the Unicode niceties that make Raku a
joy for wrangling strings.

{% include nav.html %}
