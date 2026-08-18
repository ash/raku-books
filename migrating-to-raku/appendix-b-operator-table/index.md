---
title: Appendix B — Operator Translation Table
---

{% include menu.html %}

Most Perl operators survive into Raku untouched: `+ - * / **`, the string
comparisons `eq ne lt gt le ge`, the numeric ones `== != < > <= >=`, and the
logical `and or not && || !`. This appendix concentrates on the ones that
*changed*, and then lists the genuinely new operators that Perl has no word
for. Everything here was run under Rakudo v2026.07.

## Operators that changed

| Perl | Raku | Notes |
|--------|------|-------|
| `.` (concatenation) | `~` | the dot is now the method-call operator |
| `.=` | `~=` | append-assign |
| `x` (repetition) | `x` (string) / `xx` (list) | `"ab" x 3`; `@a xx 3` repeats the list |
| `? :` (ternary) | `?? !!` | `$ok ?? "yes" !! "no"` |
| `..` (range) | `..` | plus `^..`, `..^`, `^..^` for exclusive ends |
| `...` (flip-flop) | `ff` / `fff` | `...` is now the sequence operator (below) |
| `<=>` | `<=>` | now returns `Order::Less/Same/More`, not `-1/0/1` |
| `cmp` | `cmp` | smart comparison; `leg` forces string semantics |
| `//` (defined-or) | `//` | unchanged; `//=` also works |
| `=~` | `~~` | smartmatch drives regex matching |
| `!~` | `!~~` | negated smartmatch |
| `&` (bitwise and) | `+&` | numeric-and; `~&` for the string/buffer version |
| `\|` (bitwise or) | `+\|` | numeric-or; `~\|` for strings |
| `^` (bitwise xor) | `+^` | numeric-xor; `~^` for strings; also unary `+^` = `~` in Perl |
| `<<` (left shift) | `+<` | `1 +< 4` is `16` |
| `>>` (right shift) | `+>` | `32 +> 2` is `8` |
| `%` (modulo) | `%` | unchanged; see also `%%` below |
| `->` (deref / method) | `.` | `$obj.method`, `$ref[0]` |

The bitwise renaming is the one to internalise. Perl overloads `& | ^` for
both numbers and strings and works out which you meant from context; Raku splits
them so intent is explicit. The `+`-prefixed forms (`+&`, `+|`, `+^`, `+<`,
`+>`) operate on numbers, and the `~`-prefixed forms (`~&`, `~|`, `~^`) operate
on strings and buffers:

```raku
say 6 +& 3;                # 2     (numeric AND)
say 6 +| 1;                # 7     (numeric OR)
say 1 +< 4;                # 16    (left shift)
say ("AB" ~& "  ").raku;   # "\0\0"  (character-wise string AND)
```

And `<=>` / `cmp` now hand back an `Order` enum rather than a signed integer,
which reads better and still sorts correctly:

```raku
say 1 <=> 2;       # Less
say "b" cmp "a";   # More
say 3 <=> 3;       # Same
```

## New operators with no Perl equivalent

Raku adds a family of operators that Perl programmers had to write loops or
reach for modules to express. These are covered in full in Chapter 11.

### Equality and identity

| Operator | Meaning | Example → result |
|----------|---------|------------------|
| `eqv` | equivalence: same type **and** value, structurally | `(1,2) eqv (1,2)` → `True` |
| `===` | value identity (same immutable value / same object) | `[1] === [1]` → `False` |
| `=:=` | container identity: do two names share one container? | `$x =:= $x` → `True` |
| `=~=` | approximate numeric equality (within tolerance) | `1.0 =~= 1.0000001` → `False` |

`===` and `=:=` are the subtle pair: `===` asks "are these the *same value*?"
(two freshly built arrays are not), while `=:=` asks "are these the *same
box*?" — the tool for checking whether a binding actually aliased.

### Meta-operators and list operators

| Operator | Meaning | Example → result |
|----------|---------|------------------|
| `[ ]` reduction | fold an infix operator across a list | `[+] 1..5` → `15`; `[*] 1..5` → `120` |
| `»op«` / `>>op<<` | hyper: apply an operator element-wise | `(1,2,3) »+» 10` → `(11 12 13)` |
| `X` | cross product of lists | `<a b> X <1 2>` → `((a 1)(a 2)(b 1)(b 2))` |
| `Z` | zip lists together | `<a b> Z <1 2>` → `((a 1)(b 2))` |
| `...` | sequence: generate a series by pattern | `1, 2, 4 ... 32` → `(1 2 4 8 16 32)` |
| `==>` | feed: pipe a list into the next expression | `1..10 ==> grep(* %% 2) ==> sum()` → `30` |
| `<==` | leftward feed: same, other direction | `sum() <== grep(*%%2) <== 1..10` |
| `%%` | divisibility test | `10 %% 5` → `True`; `10 %% 3` → `False` |

The meta-operators combine with almost any infix: `[~]` concatenates a list of
strings, `[<]` tests whether a list is strictly increasing, `»*»` scales every
element. This composability is why a great many Perl loops collapse to a
single Raku expression.

### The Whatever star

`*` on its own is the **Whatever** value. In an expression it builds a closure,
so `* + 1` is shorthand for `-> $x { $x + 1 }`; in a subscript `*-1` means "the
last element"; in a range `0..*` means "to infinity".

```raku
say (1..5).map(* ** 2);   # (1 4 9 16 25)
my @a = 10, 20, 30;
say @a[*-1];              # 30
```

For the full treatment of these operators — including precedence, the
reduction of non-associative operators, and lazy sequences — see Chapters 10
and 11.

{% include nav.html %}
