---
title: Scalars and Sigils
---

{% include menu.html %}

A scalar is the variable you reach for first, in both languages, and this is
where Raku feels most familiar. `my $x = 10;` means exactly what you expect. But
underneath that comfortable surface there are a few new ideas — a second
character that can follow the sigil, a distinction between assignment and
binding, and a cleaner replacement for `local` — that repay a careful look early
on. Get them straight now and later chapters on objects, regexes, and
subroutines will feel like old friends.

## Declaring scalars

The core declarators carry over almost unchanged. `my` gives you a lexical
variable, `our` a package variable:

```perl
my  $x = 10;
our $y = 20;
```

```raku-static
my  $x = 10;
our $y = 20;
```

Perl 5.10 introduced `state` for a variable that persists across calls to the
same subroutine but stays private to it. Raku has `state` too, with the same
meaning, and no feature guard to switch on:

```raku
sub counter {
    state $n = 0;
    return ++$n;
}
say counter() for 1..3;      # 1 2 3
```

The one you will *miss by name* is `local`. Raku does not have `local`; its job —
temporarily giving a variable a new value for the duration of a dynamic scope —
is done by dynamic variables, which we come to below. It is a cleaner mechanism,
not just a rename.

## Assignment versus binding

In Perl there is only one way to put a value into a variable: assignment with
`=`. Raku keeps `=`, but adds *binding* with `:=`. The difference matters once
you think of a variable as a box (a *container*) holding a value.

Assignment puts a value *into* the box. Binding makes one name an alias for
another's box, so they are henceforth the same variable:

```raku
my $a = 5;
my $b := $a;     # $b is now another name for $a's container
$b = 99;
say $a;          # 99
```

You will not need `:=` every day, but it explains a lot of Raku's behaviour once
you meet containers properly (Chapter 8), and it is how signatures bind arguments
to parameters (Chapter 15). For now, just know that `=` and `:=` are different,
and `=` is the one you want unless told otherwise.

## Sigils name the variable

Chapter 2 introduced the headline rule: the sigil belongs to the variable and
does not change when you index into it. It is worth restating in its scalar form,
because it explains what `$` now *means*.

A `$` variable holds a single item. That item can be anything at all — a number,
a string, or even an array or hash as a single value:

```raku
my $number = 42;
my $text   = 'Hello';
my $arr    = [1, 2, 3];      # a scalar holding an array
say $arr[0];                 # 1
say $arr.elems;              # 3
```

That last case — a scalar holding an array — is roughly Perl's array reference,
`my $arr = [1, 2, 3]`, and it is dereferenced far more gently here: `$arr[0]`,
no arrow needed. The full story of how `$`, `@`, and `%` relate to one another
belongs to Chapter 8; the point for now is that `$` is the "one thing" sigil, and
what that one thing *is* need not be simple.

## Twigils: the second character

Here is a genuinely new idea. In Raku, a sigil may be followed by a second
symbol, called a *twigil*, that says something about *where the variable lives*
or *how it is scoped*. The variable's name is still what comes after; the twigil
is metadata.

You have, in fact, already seen several twigils in passing. This table collects
the ones you will meet, with a pointer to where each is covered in full:

| Form  | Twigil | Meaning                                   | Covered in |
|-------|--------|-------------------------------------------|------------|
| `$*x` | `*`    | dynamic variable (a cleaner `local`)      | this chapter |
| `$?x` | `?`    | compile-time constant (`$?FILE`, `$?LINE`)| this chapter |
| `$!x` | `!`    | private object attribute                  | Chapter 22 |
| `$.x` | `.`    | public attribute (method-backed)          | Chapter 22 |
| `$^x` | `^`    | self-declared block parameter (placeholder)| Chapter 17 |

Two of these belong here; the rest are forward references so that when you meet
`$!name` in a class you recognise the shape rather than the specifics.

### Dynamic variables: `$*` (the `local` replacement)

A dynamic variable is visible not just in the lexical scope where it is declared,
but in any code *called* from that scope, however deep. That is exactly what
Perl programmers used `local` to achieve. Compare the two.

In Perl, you `local`ise a package variable, and callees see the temporary
value:

```perl
our $x = 1;
sub show { print "$x\n" }
sub tmp  { local $x = 2; show() }
tmp();     # 2
show();    # 1
```

In Raku, you declare the variable with the `*` twigil, and any called code that
refers to `$*x` sees the caller's value:

```raku
my $*greeting = 'Hi';
sub greet { say $*greeting }
greet();               # Hi
```

Raku's own runtime uses this everywhere: `$*IN`, `$*OUT`, `$*ERR` are the
standard handles, `$*PID` is the process id, `@*ARGS` holds the command-line
arguments (the counterpart of `@ARGV`). Because they are dynamic, you can
temporarily rebind them — redirecting output, say — without global side effects.
The special variables get a full treatment in Appendix C.

### Compile-time variables: `$?`

Variables with the `?` twigil are filled in by the compiler and are constant at
run time. The two you will use most report where you are in the source — the Perl
5 equivalents of `__FILE__` and `__LINE__`:

```raku
say $?FILE;     # /path/to/your/program.raku
say $?LINE;     # the current line number
```

Others include `$?LANG` (the language being compiled) and, inside a class,
`$?CLASS`. You rarely *set* these; you read them for diagnostics and tooling.

## Constants and sigilless names

For a value that never changes, Perl offers `use constant`. Raku builds it into
the language with the `constant` declarator:

```raku
constant PI = 3.14159;
say PI;
```

Raku goes one step further and lets you declare a *sigilless* name by binding to
a backslashed identifier. It behaves like a single-assignment alias — handy when
a sigil would only add noise:

```raku
my \answer = 42;
say answer;     # 42
```

Use this sparingly. Sigils are one of Perl's great readability features — you can
tell an array from a scalar at a glance — and dropping them is a deliberate
choice for the rare case where the value is really just a name for a constant.

## The topic variable `$_`

Finally, the old friend `$_`. It is still the default variable — the *topic* —
and still what `for`, `map`, `grep`, and bare method calls fall back to. What is
new is that a leading-dot method call operates on it implicitly, so the Perl
idiom of acting on `$_` becomes even terser:

```perl
for (1, 2, 3) { print "$_\n" }
```

```raku
for 1, 2, 3 { .say }        # .say means $_.say
```

`$_` graduates from "the variable everything secretly uses" in Perl to a
first-class, explicitly *topicalised* value in Raku — the foundation of `given`/
`when`, which we reach in Chapter 13.

With scalars and sigils understood, we can move on to the containers they so
often hold: arrays and lists.

{% include nav.html %}
