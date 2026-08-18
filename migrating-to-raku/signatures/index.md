---
title: From @_ to Signatures
---

{% include menu.html %}

Here is where the day-to-day feel of writing subroutines changes the most.
Traditionally a Perl subroutine receives its arguments in a single flat array,
`@_`, and it is your job to pull them apart, name them, check their count, and
validate their types by hand. Modern Perl has gained basic subroutine signatures
of its own — `sub add($a, $b) { … }`, with defaults and a slurpy — so this is
now partly shared ground. Raku takes the idea considerably further: its
signature also carries named parameters, type constraints, `is rw`/`is copy`,
return types, and destructuring, and it is what makes multiple dispatch
(Chapter 16) possible. The compiler does the unpacking and the checking for you.

This one change ripples outward. Signatures are also what make multiple dispatch
(Chapter 16) possible, and they turn up again in pointy blocks, `given`/`when`,
and object construction. Learn them well here and much of the rest of the book
falls into place.

## The `@_` world

In Perl, the first line of almost every subroutine is a bit of ceremony to give
the arguments names:

```perl
use v5.10;

sub add {
    my ($a, $b) = @_;
    return $a + $b;
}
say add(2, 3);        # 5
```

If you want the arguments to be mandatory, or to be numbers, or to have
defaults, you write that yourself:

```perl
sub greet {
    my ($name, $greeting) = @_;
    die "name required" unless defined $name;
    $greeting //= 'Hello';
    return "$greeting, $name!";
}
```

Everyone writes this code, and everyone writes it slightly differently.

### Perl prototypes: an older attempt

Long before signatures, Perl offered *prototypes* — a parenthesised run of
sigils after the sub name that constrains how many arguments a sub takes, and in
what context. They are a compile-time check on the *shape* of the call, not real
parameter names:

```perl
use v5.10;

sub add ($$) { $_[0] + $_[1] }   # exactly two scalars

say add(2, 3);        # 5
say add(2, 3, 4);     # compile error: Too many arguments for main::add
```

The `$$` means "two scalar arguments"; `@` slurps the rest as a list, `;` marks
what follows as optional, `\@` demands an array reference, and so on. Prototypes
pin down arity and argument context, but you still unpack `@_` by hand inside,
and nothing here is a *name* or a *type*. They linger on for mimicking built-in
functions, but for everyday code, signatures superseded them.

### Perl's own signatures

Modern Perl (under `use v5.36`, or `use feature 'signatures'`) names the
parameters directly, with defaults and a slurpy — much of what the `@_` ceremony
did by hand:

```perl
use v5.36;

sub greet ($name, $greeting = 'Hello') {
    return "$greeting, $name!";
}

say greet('John');          # Hello, John!
say greet('Jo', 'Hi');      # Hi, Jo!
```

This is a real step up and covers a good share of everyday needs. What it does
*not* offer is named parameters, type constraints, `is rw`/`is copy`, return-type
checks, destructuring, or multiple dispatch — all of which Raku's signatures do,
and which the rest of this chapter explores.

## Positional parameters

The Raku equivalent of `my ($a, $b) = @_;` is to name the parameters in the
signature. There is no `@_` to unpack, because the unpacking has already
happened:

```raku
sub add($a, $b) { $a + $b }
say add(2, 3);        # 5
```

The parameters are declared in the order they arrive — these are *positional*
parameters. By default they are also *required*: call `add` with the wrong number
of arguments and you get an error at the call site, not a silent `undef` three
lines later.

Note also that we dropped `return`. The last expression in a Raku block is its
value, so a one-liner rarely needs it — though `return` is there when you want to
leave early.

## Type constraints

Write a type before a parameter and Raku enforces it, exactly as it does for a
typed variable (Chapter 2):

```raku
sub square(Int $n) { $n * $n }
say square(5);        # 25
```

Pass something that is not an `Int` and the call fails before the body runs. This
is the declarative replacement for the hand-written `die unless looks_like_number`
checks that litter defensive Perl.

## Optional parameters and defaults

A trailing `?` makes a parameter optional; inside the body you test it with
`.defined`:

```raku
sub maybe($x?) { $x.defined ?? "got $x" !! "nothing" }
say maybe();          # nothing
say maybe(42);        # got 42
```

More often you want a *default value*. Give one with `=`, and the parameter
becomes optional automatically — this is the tidy form of Perl's `//=` dance:

```raku
sub greet($name, $greeting = 'Hello') { "$greeting, $name!" }
say greet('John');            # Hello, John!
say greet('John', 'Hi');      # Hi, John!
```

Defaults may even refer to earlier parameters, and are computed at call time.

## Named parameters

Perl fakes named arguments by passing a list of pairs and slurping them into a
hash: `my %args = @_;`. Raku has them for real. A parameter written with a
leading colon is *named* — the caller supplies it by name, in any order:

```raku
sub connect(:$host!, :$port = 80) { "$host:$port" }
say connect(host => 'localhost');             # localhost:80
say connect(:host<example.com>, :port(8080)); # example.com:8080
```

Two things to notice. A named parameter is *optional* by default — the opposite
of positional — so we added `!` to make `:$host!` required. And `:$port = 80`
combines named with a default, the common case for configuration-style
arguments.

When the value is already in a variable of the same name, the `:$port` colon-pair
shorthand passes it without repetition:

```raku
my $port = 22;
sub srv(:$port) { "port $port" }
say srv(:$port);      # port 22
```

### Renaming a named parameter

Sometimes the name the caller uses should differ from the variable name inside
the body. Write `:external($internal)`:

```raku
sub log-it(:message($text)) { "LOG: $text" }
say log-it(message => 'hi');   # LOG: hi
```

The caller says `message =>`, the body works with `$text`.

## Slurpy parameters

To collect "everything else", Perl leans on `@_` directly. Raku has *slurpy*
parameters, marked with `*`. A slurpy array mops up the remaining positional
arguments; a slurpy hash mops up the remaining named ones:

```raku
sub total(*@nums) { [+] @nums }
say total(1, 2, 3, 4);         # 10

sub opts(*%h) { %h.keys.sort.join(',') }
say opts(a => 1, b => 2);      # a,b
```

(The `[+]` is the reduction meta-operator from Chapter 11 — it sums the list.)

There are, in fact, two flavours of slurpy array, and they differ in whether they
*flatten* nested lists. The single-star `*@a` flattens; the double-star `**@a`
preserves structure:

```raku
sub flat(*@a)     { @a.elems }
sub nested(**@a)  { @a.elems }
say flat(1, (2, 3), [4, 5]);     # 5   — flattened
say nested(1, (2, 3), [4, 5]);   # 3   — kept as three items
```

If you have met the two spellings before and misremembered which is which, this
is worth a second look: it is the *single* star that flattens, and the *double*
star that leaves the arguments alone. The double-star form is the one you want
when a nested list is meaningful data rather than a bag of arguments.

## Traits: `is rw` and `is copy`

By default a parameter is read-only — you may look at it but not assign to it.
This is safer than Perl, where `@_` aliases the caller's data and an accidental
`$_[0] = ...` reaches back out.

When you *do* want to modify the caller's variable, ask for it explicitly with
`is rw`:

```raku
sub incr($x is rw) { $x++ }
my $n = 10;
incr($n);
say $n;               # 11
```

When you want a private, modifiable copy that does *not* affect the caller, use
`is copy` — the equivalent of Perl's habit of copying `@_` into `my`
variables just to be able to change them:

```raku
sub tweak($x is copy) { $x++; $x }
my $m = 5;
say tweak($m);        # 6
say $m;               # 5  — untouched
```

## Return types

You can constrain what a routine returns, too. Put `--> Type` at the end of the
signature, or use the `returns` trait:

```raku
sub pi(--> Rat) { 3.14 }
say pi();             # 3.14

sub e() returns Num { 2.718e0 }
say e();              # 2.718
```

A returned value that violates the constraint is an error, caught at the boundary
rather than downstream:

```raku
sub bad(--> Int) { "x" }
say (try bad()) // "type error caught";   # type error caught
```

## Destructuring in the signature

A signature can take an argument apart *as it binds it*. Give a nested signature
in square brackets to unpack an incoming array:

```raku
sub first-rest(@a [$first, *@rest]) { "first=$first rest=@rest[]" }
say first-rest([10, 20, 30]);   # first=10 rest=20 30
```

The parameter `@a` is still the whole array, but `$first` and `@rest` are bound
to its head and tail in the same breath. Named parameters `:$x, :$y` similarly
destructure a hash-shaped argument by key:

```raku
sub point(:$x, :$y) { "($x, $y)" }
say point(x => 1, y => 2);      # (1, 2)
```

## The whole argument list: `|capture`

Occasionally you want the entire bundle of arguments as one object — every
positional and every named — for instance to forward them untouched. That object
is a `Capture`, and you bind it with `|`:

```raku
sub inspect(|c) { c.list.elems ~ " pos, " ~ c.hash.elems ~ " named" }
say inspect(1, 2, 3, a => 4);   # 3 pos, 1 named
```

The same `|` *flattens a Capture back out* at a call site, which is how you
forward arguments verbatim — the clean replacement for `goto &sub` and
`@_`-passing tricks:

```raku
sub inner($a, $b) { $a + $b }
sub outer(|args) { inner(|args) }
say outer(4, 5);      # 9
```

## `@_` still exists

None of this abolishes `@_`. A block or a signatureless `sub` still gets its
arguments there, so the old idiom keeps working:

```raku
sub old-style { @_.join(", ").say }
old-style(1, 2, 3);   # 1, 2, 3
```

But the moment you write a signature, `@_` steps aside and the named parameters
take over. In new code, signatures are simply the way: they document the
interface, check it, and unpack it, all at once.

A signature also unlocks something Perl could only imitate with tangled
`if`-chains: writing *several* versions of the same routine and letting the
argument types decide which one runs. That is multiple dispatch, and it is next.

{% include nav.html %}
