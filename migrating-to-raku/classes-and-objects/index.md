---
title: Classes and Objects
---

{% include menu.html %}

Object orientation is the part of Perl that most obviously grew by accretion.
For most of its life there was no `class` keyword: you build a class out of a
package, a data structure, and the `bless` function, and you write the accessors
yourself (or reach for Moose, Moo, or `Class::Accessor` to write them for you).
It works, and it is more flexible than it has any right to be, but it is
boilerplate all the way down. Modern Perl has since added a native `class` syntax
of its own — with `class`, `field`, and `method` — but it is recent, still
settling in, and deliberately narrower than what you are about to see. The
`bless`-based style below is still the one you will meet in the overwhelming
majority of existing code, so it is worth recognising.

Raku bakes objects into the language. There is a `class` keyword, attributes
declare their own accessors, and `new` is generated for you. If you have used
Moose or Moo, most of this chapter will feel like coming home — Raku's object
model was a direct influence on Moose, so the resemblance is not a coincidence.
We will point out the correspondences as we go.

## From `bless` to `class`

Here is a small, hand-rolled Perl class — a two-dimensional point with
read-only accessors and a stringifier:

```perl
use v5.10;

package Point;

sub new {
    my ($class, %args) = @_;
    my $self = { x => $args{x} // 0, y => $args{y} // 0 };
    return bless $self, $class;
}

sub x { $_[0]{x} }
sub y { $_[0]{y} }

sub to_string {
    my $self = shift;
    return "($self->{x}, $self->{y})";
}

package main;

my $p = Point->new(x => 3, y => 4);
say $p->x;              # 3
say $p->to_string;      # (3, 4)
```

Everything is explicit: `new` blesses a hash reference into the package, each
accessor is a one-line sub reaching into that hash, and the method invocant
arrives as the first argument.

The same class in Raku:

```raku
class Point {
    has $.x = 0;
    has $.y = 0;

    method to-string {
        return "($.x, $.y)";
    }
}

my $p = Point.new(x => 3, y => 4);
say $p.x;              # 3
say $p.to-string;      # (3, 4)
```

No `bless`, no hand-written `new`, no hand-written accessors. The `has`
declarations create both the storage and the accessor; `Point.new` is generated
and accepts each attribute as a named argument; and `method` gives you the
invocant as `self` without your having to shift it off `@_`. Note also the
dots: `Point.new` and `$p.x` — method calls use `.`, as everywhere in Raku
(Chapter 1 explained why `~` took over concatenation to free up the dot).

The `to-string` method here is an ordinary method, named to mirror the Perl
version. Raku also has a *built-in* stringification hook: define a `Str` method
and the prefix `~` operator and string interpolation will call it automatically.
We use that idiomatic form at the end of the chapter.

Modern Perl's own `class` feature reaches for the same shape, if you are on a
recent enough release (it is still marked experimental):

```perl
use feature 'class';

class Point {
    field $x :param :reader = 0;
    field $y :param :reader = 0;
    method to_string { "($x, $y)" }
}

my $p = Point->new(x => 3, y => 4);
```

The family resemblance is real. What follows in this chapter — roles, submethods,
`multi` methods, `BUILD`/`TWEAK`, definite-vs-optional typing on attributes — is
where Raku's older, more complete object model still goes well beyond it.

## Attributes and the `.` versus `!` twigil

Chapter 3 introduced twigils and promised that `$!name` and `$.name` would make
sense once we reached classes. Here they are.

An attribute is declared with `has`. The twigil you choose controls what the
outside world can do with it:

```raku-static
class Account {
    has $.owner;              # public: read-only accessor generated
    has $.balance is rw = 0;  # public: read-write accessor generated
    has $!pin;                # private: no accessor at all
}
```

- `has $.owner` — the `.` twigil declares a **public** attribute. Raku generates
  a read-only accessor method `owner`. This is the common case.
- `has $.balance is rw` — the same, but `is rw` makes the accessor return a
  writable container, so `$obj.balance = 250` works.
- `has $!pin` — the `!` twigil declares a **private** attribute. No accessor is
  generated; only code inside the class can touch it.

The mental model is the one from Chapter 3: `$!pin` is the *real* storage, always
accessible from inside the class. `$.owner` is sugar — it declares the same
private `$!owner` storage *plus* a public method `owner`. So even for a public
attribute, `$!owner` is the direct variable and `$.owner` is a method call on
`self`. This matters more than it first appears; we return to it under `BUILD`.

Watching each of these in action:

```raku
class Account {
    has $.owner;
    has $.balance is rw = 0;
    has $!pin;

    method set-pin($p)   { $!pin = $p }
    method check-pin($p) { $!pin eqv $p }
}

my $a = Account.new(owner => 'Alice', balance => 100);
say $a.owner;             # Alice
say $a.balance;           # 100
$a.balance = 250;         # allowed: balance is rw
say $a.balance;           # 250
$a.set-pin(1234);
say $a.check-pin(1234);   # True
```

Try to write a read-only attribute and Raku stops you at run time:

```raku-static
my $p = Point.new(x => 3, y => 4);
$p.x = 99;               # dies: Cannot modify an immutable Int
                         # (X::Assignment::RO)
```

And the private attribute genuinely has no accessor — asking for it from outside
is a method-not-found error:

```raku-static
$a.pin;                  # dies: X::Method::NotFound
```

For the Moose/Moo crowd, the mapping is direct. Moose's
`has 'owner' => (is => 'ro')` is `has $.owner`; `is => 'rw'` is `has $.owner is
rw`; and a private attribute (no reader) is `has $!owner`. What Moose spells out
in an options hash, Raku encodes in a sigil and a twigil.

Arrays and hashes are attributes too, with their natural sigils. Inside the
class you reach for the `!` form to mutate them:

```raku-nobrowser
class Bag {
    has @.items;
    has %.tags;
    method add($x) { @!items.push: $x }
}

my $b = Bag.new(items => [1, 2], tags => {a => 1});
$b.add(3);
say $b.items;            # [1 2 3]
say $b.tags;             # {a => 1}
```

## The generated constructor

You never wrote `new` above, yet `Point.new(x => 3, y => 4)` worked. Every class
inherits a `new` that accepts each public attribute as a **named** argument and
fills in the matching storage. The named-only rule is deliberate — it is the
reason a Perl `Point->new(3, 4)` has no direct equivalent; you pass
`x => 3, y => 4`, and the mapping from name to attribute is unambiguous.

Ask a fresh object to describe itself and you can see what `new` captured:

```raku
class Point { has $.x; has $.y; }
my $p = Point.new(x => 1, y => 2);
say $p;                  # Point.new(x => 1, y => 2)
say $p.WHAT;             # (Point)
```

That default representation — `Point.new(x => 1, y => 2)` — is the class's
`gist`, which we come back to at the end of the chapter.

### Default values and `is required`

An attribute with `= …` gets that default when the constructor is not given a
value (we used `has $.x = 0` earlier). When, instead, a value must always be
supplied, mark it `is required`:

```raku-static
class Temperature {
    has $.celsius is required;
    has $.fahrenheit;
}

Temperature.new;         # dies: X::Attribute::Required
                         # "The attribute '$!celsius' is required..."
```

This replaces the hand-written `die "celsius required"` guard you would put at
the top of a Perl `new`. In Moose terms, `is required` is exactly Moose's
`required => 1`, and `= 0` is Moose's `default => 0`.

### `BUILD` and `TWEAK`

Defaults and required checks cover most construction. When you need to *compute*
something at construction time — derive one attribute from another, validate a
combination, normalise input — Raku gives you two hooks that run inside `new`:
`BUILD` and `TWEAK`. Both are **submethods** (more on that word shortly), which
means they are not inherited as ordinary methods; each class runs its own.

`TWEAK` runs *after* the object's attributes have been initialised, so it is the
one you want for derived values:

```raku
class Temperature {
    has $.celsius is required;
    has $.fahrenheit;

    submethod TWEAK {
        $!fahrenheit = $!celsius * 9/5 + 32;
    }
}

my $t = Temperature.new(celsius => 100);
say $t.fahrenheit;       # 212
```

Notice `$!celsius`, not `$.celsius`. Inside `TWEAK` the object is still being
built, and Raku will not let you call an accessor method on a partially
constructed object — try `$.celsius` here and you get a compile-time error
("Virtual method call `$.celsius` may not be used on partially constructed
object"). This is the practical payoff of the `$!`/`$.` distinction: in
constructor code, always use the direct `$!` form.

`BUILD` runs *earlier*, before default initialisation, and receives the
constructor's named arguments. Use it when you want to take control of how
arguments map onto attributes:

```raku
class Person {
    has $.name;
    has $.age;

    submethod BUILD(:$name, :$age = 0) {
        $!name = $name.tc;      # normalise: title-case the name
        $!age  = $age;
    }
}

my $p = Person.new(name => 'alice', age => 30);
say $p.name;                         # Alice
say Person.new(name => 'bob').age;   # 0
```

Reach for `TWEAK` by default; it is the simpler tool. Drop to `BUILD` only when
you need to intercept the raw arguments. If you have written a Moose `BUILD` or a
`BUILDARGS`, the roles are similar — `TWEAK` is the everyday post-construction
hook, `BUILD` the lower-level argument-handling one.

## Methods, `self`, and the two ways to reach an attribute

A `method` is like a `sub`, but with an implicit invocant available as `self`.
Inside a method you have two ways to name an attribute, and they are the same two
forms from the twigil discussion:

- `$!attr` — direct access to this object's storage. Fast, and the only form
  allowed during construction.
- `$.attr` — a method call, short for `self.attr`. It goes through the accessor,
  which means a subclass can override it (Chapter 23) and it respects `is rw`.

For reading a value either works; `$.attr` is the idiomatic choice in ordinary
methods because it dispatches politely through the accessor. You call other
methods on `self` with the dot:

```raku
class Greeter {
    has $.name;
    method greet { "Hello, {$.name}, from {self.^name}" }
}
say Greeter.new(name => 'Bob').greet;
# Hello, Bob, from Greeter
```

`self.^name` uses the metaobject call `.^` — the same introspection dot from
Chapter 2 — to ask the object its class name.

### Private methods: `!method`

Just as `$!` marks private storage, a leading `!` marks a private method. It is
defined with `method !name` and called with `self!name`, and it is invisible from
outside the class:

```raku-static
class Greeter {
    has $.name;
    method !decorate($s) { "*** $s ***" }
    method greet { self!decorate("Hello, $.name") }
}

my $g = Greeter.new(name => 'Bob');
say $g.greet;            # *** Hello, Bob ***
$g.decorate("x");        # dies: X::Method::NotFound
```

In Perl a "private" method is a convention — a sub whose name starts with an
underscore that you politely agree not to call. In Raku it is enforced: there is
no public `decorate` at all.

### `submethod`

A **submethod** is a method that is *not* inherited: it belongs to the class that
declares it and does not show up in subclasses. `BUILD` and `TWEAK` are
submethods for exactly this reason — each class must run its own construction
logic rather than silently inheriting a parent's. You will occasionally declare
your own submethods for the same "this class only" reason, but most of the time
you meet them as `BUILD`/`TWEAK`.

### `multi method`

Methods can be multis, dispatching on the number and types of their arguments
just like the `multi sub`s of Chapter 16:

```raku-nobrowser
class Formatter {
    multi method show(Int $n) { "number $n" }
    multi method show(Str $s) { "string $s" }
}

my $f = Formatter.new;
say $f.show(42);         # number 42
say $f.show("hi");       # string hi
```

This is how you replace the Perl pattern of a single method that inspects
`ref`/`Scalar::Util::looks_like_number` and branches by hand: let the dispatcher
choose the right body by type.

## Stringification: `Str` and `gist`

In Perl you make an object stringify by overloading `""` (via the `overload`
pragma). Raku splits the job in two, and both are just methods you define.

- `Str` is the value's string form — what the prefix `~` operator, string
  interpolation, and `print`/`put` use.
- `gist` is the value's *human-readable* form — what `say` and the REPL use. It
  is allowed to be lossy and friendly.

```raku
class Temperature {
    has $.celsius;
    method Str  { "$!celsius°C" }
    method gist { "Temperature({$!celsius}°C)" }
}

my $t = Temperature.new(celsius => 100);
say ~$t;                 # 100°C                — prefix ~ calls Str
say $t;                  # Temperature(100°C)   — say uses gist
say "It is $t";          # It is 100°C          — interpolation uses Str
```

That prefix `~` is worth pausing on: it is Raku's explicit "stringify this"
operator, the unary sibling of the `~` you already use to concatenate. `~$obj`
means exactly `$obj.Str`, so defining a `Str` method is what makes an object
behave like a string everywhere — under `~`, inside `"..."`, and in `print`.
This is the idiomatic replacement for the ad-hoc `to-string` method we wrote at
the start of the chapter: give the class a real `Str` method and the whole
language stringifies it for you.

If you define neither, you get the default we saw earlier —
`Temperature.new(celsius => 100)` — which is Raku's out-of-the-box `gist` for any
object, and a genuinely useful default for debugging. Define `Str` when the
object has a natural textual value; add `gist` when you want `say` output to read
differently from that value.

With a single class understood — its attributes, its constructor hooks, its
methods — the next question is how classes relate to one another. Chapter 23
takes up inheritance and, more importantly, roles: the composable unit of
behaviour that, for most designs, you should reach for before a base class.

{% include nav.html %}
