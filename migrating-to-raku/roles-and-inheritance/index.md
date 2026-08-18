---
title: Roles and Inheritance
---

{% include menu.html %}

Chapter 22 built a single class. Real programs have many, and they share code.
Perl has one main mechanism for that — inheritance, via `@ISA` (usually spelled
`use parent`) — and a scattering of add-ons for the cases where inheritance is
the wrong shape: `Role::Tiny`, Moose roles, mixin modules. Raku ships all of
this in the core language, and it nudges you towards the tool the Perl community
spent two decades learning to prefer: **roles** over deep inheritance.

We will start with inheritance, because it maps most directly, then spend the
larger half of the chapter on roles, which is where the interesting migration
advice lives.

## Inheritance with `is`

A Perl subclass declares its parent and overrides methods:

```perl
use v5.10;

package Animal;
sub new { my ($c, %a) = @_; bless {%a}, $c }
sub name  { $_[0]{name} }
sub sound { '...' }
sub speak {
    my $self = shift;
    return $self->name . " says " . $self->sound;
}

package Dog;
use parent -norequire, 'Animal';
sub sound { 'Woof' }

package main;
my $d = Dog->new(name => 'Rex');
say $d->speak;             # Rex says Woof
```

`Dog` inherits `new`, `name`, and `speak`, and overrides `sound`. When `speak`
calls `$self->sound`, method resolution finds `Dog`'s version. The same design
in Raku, using `is` to name the parent:

```raku
class Animal {
    has $.name;
    method sound { '...' }
    method speak { "$.name says {self.sound}" }
}

class Dog is Animal {
    method sound { 'Woof' }
}

my $d = Dog.new(name => 'Rex');
say $d.speak;              # Rex says Woof
say $d ~~ Animal;          # True   — an "isa" test
```

`is Animal` is Raku's `use parent 'Animal'`. `Dog` inherits the attribute
`$.name`, the generated `new`, and `speak`; it overrides `sound`. The smartmatch
`$d ~~ Animal` is the idiomatic "is this an Animal?" test, replacing Perl's
`$d->isa('Animal')` — though modern Perl has closed most of that gap too. Its
`class` feature spells the parent with an `:isa` attribute, and it has an infix
`isa` operator that reads much like the smartmatch:

```perl
use v5.38;
use feature 'class';
no warnings 'experimental::class';

class Animal {
    field $name :param :reader;
    method sound { '...' }
    method speak { "$name says " . $self->sound }
}

class Dog :isa(Animal) {
    method sound { 'Woof' }
}

my $d = Dog->new(name => 'Rex');
say $d->speak;             # Rex says Woof
say 'yes' if $d isa Animal;   # yes
```

The `isa` operator is older than the `class` feature and works on `bless`ed
objects too, so `$d isa Animal` is available in ordinary Perl OO from 5.32
onwards. What comes next in this chapter — roles — is where the two languages
part company, because Perl has no core equivalent at all.

For the Moose/Moo crowd: `is Animal` is Moose's `extends 'Animal'`. There is no
separate keyword to import — `is` is built in.

## Calling the parent: `callsame`, `nextsame`, `callwith`

In Perl you reach the overridden method with `SUPER::`:

```perl
sub greet {
    my $self = shift;
    return $self->SUPER::greet() . ", from Child";
}
```

Raku replaces the `SUPER::` name with a small family of redispatch routines. They
share a naming logic: `call*` runs the next candidate and returns to you;
`next*` hands off and does not come back. `*same` reuses your arguments; `*with`
lets you supply new ones.

```raku-local
class Base {
    method greet { "Hello" }
}

class Child is Base {
    method greet {
        my $parent = callsame;         # run Base.greet, same args, return here
        "$parent, from Child";
    }
}
say Child.new.greet;                   # Hello, from Child

class Loud is Base {
    method greet { nextsame }          # defer entirely to Base.greet
}
say Loud.new.greet;                    # Hello
```

- `callsame` — call the next candidate with the same arguments, get the result.
  This is the everyday `SUPER::method(@_)`.
- `nextsame` — like `callsame` but *tail-calls*: control never returns to your
  method. Handy when your override only wants to run before deciding to bow out.
- `callwith(...)` — call the next candidate with **different** arguments. This is
  `SUPER::method(...)` with a fresh argument list.

There is also `nextwith`, the hand-off form of `callwith`. The four names cover
every combination of "come back or not" and "same args or not", which is more
than `SUPER::` gave you, and it works uniformly across inheritance, roles, and
multiple dispatch.

## Multiple inheritance and the C3 MRO

Raku lets a class have more than one parent — stack the `is` traits:

```raku-static
class A2 { method who { "A2" } }
class B2 is A2 { }
class C2 is A2 { method who { "C2" } }
class D2 is B2 is C2 { }
```

This is the classic diamond: `D2` inherits from both `B2` and `C2`, which both
inherit from `A2`. Which `who` does `D2` get? Perl's default resolution was
depth-first, which handled diamonds badly (it could reach `A2` before `C2`).
Raku uses the **C3 linearisation** — the same algorithm Perl opts into with
`use mro 'c3'` — and you can inspect the resulting order:

```raku-static
say D2.^mro;              # ((D2) (B2) (C2) (A2) (Any) (Mu))
say D2.new.who;           # C2
```

The metaobject call `.^mro` returns the method resolution order as a list of
types. Reading it left to right: `D2`, then `B2`, then `C2`, then their shared
`A2`, then Raku's universal ancestors `Any` and `Mu`. Because `C2` comes before
`A2`, `D2.new.who` finds `C2`'s override — the diamond resolves sensibly.

Multiple inheritance works, but it is rarely the right tool. The moment two base
classes want to contribute behaviour to the same child, you are usually reaching
for a role.

## Roles: composition over inheritance

A **role** is a bundle of methods (and attributes) meant to be *mixed into* a
class rather than inherited from. You declare it with `role` and compose it with
`does`:

```raku
role Comparable {
    method compare($other) { ... }               # required (a stub)
    method greater($other) { self.compare($other) > 0 }
}

class Weight does Comparable {
    has $.kg;
    method compare($other) { $.kg <=> $other.kg }
}

my $a = Weight.new(kg => 70);
my $b = Weight.new(kg => 60);
say $a.greater($b);       # True
say $a ~~ Comparable;     # True
```

`Comparable` supplies `greater` for free but insists that any consumer provide
`compare`. `Weight does Comparable` pulls in `greater` and satisfies the
requirement. The role is not a parent — `Weight`'s only ancestor is still the
default — yet `$a ~~ Comparable` is `True`, because doing a role makes you a kind
of it.

The `{ ... }` in the role body is Raku's **stub**: the "yada-yada" operator,
declaring a method that *must* be implemented by whoever composes the role. Fail
to provide it and composition fails loudly at compile time:

```raku-static
role Drawable { method draw { ... } }
class Bad does Drawable { }        # no draw
# Compile-time error:
# Method 'draw' must be implemented by Bad
# because it is required by roles: Drawable.
```

That compile-time guarantee is the whole point of a required method: the role
states an interface, and the compiler enforces it before your program ever runs.

### Why a role and not a base class?

The classic problem with inheritance is that behaviour you want to share often
does not correspond to an *is-a* relationship. A `Serialisable` mixin, a
`Comparable` interface, a `Logger` — none of these describe what an object *is*;
they describe what it can *do*. Force them into a base class and you get
tangled hierarchies and the diamond problems above.

Roles side-step this. They compose flatly: doing three roles is not a chain of
three parents but a single class that has all three sets of methods poured into
it. The rule of thumb:

- Use **inheritance** (`is`) for a genuine *is-a* specialisation where the child
  really is a more specific kind of the parent, and you want to share state and
  extend behaviour.
- Use a **role** (`does`) for a capability shared across otherwise unrelated
  classes — an interface with some behaviour attached. This should be your
  default; reach for a base class only when you specifically need one.

If you have written Moose or Moo, this is familiar ground. The mapping is almost
one-to-one:

| Moose / Moo            | Raku            |
|------------------------|-----------------|
| `has`                  | `has`           |
| `extends 'Base'`       | `is Base`       |
| `with 'Role'`          | `does Role`     |
| `role { ... }` package | `role { ... }`  |
| `requires 'method'`    | `method m { ... }` (stub) |

Moose roles *are* essentially Raku roles — the design travelled from Raku into
Moose and back into your muscle memory. The main change is syntactic: `with`
becomes `does`, and a required method is a stubbed method rather than a
`requires` declaration.

### Runtime mixins: `does` and `but`

Composition need not happen at compile time. You can mix a role into a single
*object*, at run time, leaving every other object of its class untouched. The
operator is `but` (for a fresh copy) or `does` (mutating in place):

```raku
role Nameable { method label { "<{self.^name}>" } }

my $x = 42;
my $y = $x but Nameable;
say $y.label;             # <Int+{Nameable}>
say $y + 1;               # 43   — still behaves as an Int
```

`$y` is an `Int` that has additionally gained the `Nameable` role; its type name
becomes `Int+{Nameable}`, but it still adds, sorts, and compares like any other
integer. Perl has nothing this clean — the nearest equivalent is re-`bless`ing
into a throwaway subclass, by hand. This is the mechanism behind `$obj but True`
tricks and, as Chapter 26 will show, behind attaching extra data to exceptions
and failures.

### Resolving conflicts

When two roles bring a method of the same name, composition does not silently
pick one — it is a compile-time error, and you must resolve it:

```raku-static
role A { method hello { "A" } }
role B { method hello { "B" } }

class C does A does B { }          # error:
# Method 'hello' must be resolved by class C
# because it exists in multiple roles (B, A)
```

The class settles the conflict by providing its own `hello`, and it can reach the
role versions explicitly with the `Role::method` syntax:

```raku-static
class C does A does B {
    method hello {
        "C resolves: " ~ self.A::hello ~ "/" ~ self.B::hello;
    }
}
say C.new.hello;          # C resolves: A/B
```

This is the flat-composition model showing its teeth: rather than letting one
role quietly shadow another (as inheritance order would), Raku forces you to
decide. Compare this with Perl's multiple inheritance, where the winner is
whatever the MRO happens to reach first — easy to get wrong, hard to notice.

## A worked example

Putting inheritance and roles together. `Describable` is a role — a capability,
requiring `area` and supplying `describe`. `Shape` is a small base class holding
shared state. Concrete shapes inherit the state and compose the capability, and
`Square` specialises `Rectangle` through ordinary inheritance:

```raku
role Describable {
    method area { ... }                     # required
    method describe {
        "a {self.^name.lc} of area {self.area.round(0.01)}"
    }
}

class Shape {
    has $.colour = 'black';
}

class Circle is Shape does Describable {
    has $.radius;
    method area { pi * $.radius ** 2 }
}

class Rectangle is Shape does Describable {
    has $.width;
    has $.height;
    method area { $.width * $.height }
}

class Square is Rectangle {
    method new(:$side, *%rest) {
        self.bless(width => $side, height => $side, |%rest);
    }
}

my @shapes = Circle.new(radius => 2),
             Rectangle.new(width => 3, height => 4),
             Square.new(side => 5, colour => 'red');

.describe.say for @shapes;
say 'total: ', @shapes.map(*.area).sum.round(0.01);
say @shapes[2].colour;      # red — inherited from Shape
```

Running it:

```
a circle of area 12.57
a rectangle of area 12
a square of area 25
total: 49.57
red
```

Two things are worth pausing on. First, `Square`'s constructor: it writes its own
`new` and calls `self.bless` with the two dimensions, because — a genuine gotcha
— **private attribute storage is not inherited**. `Rectangle`'s `has $.width`
creates the storage `$!width` *in `Rectangle`*, and `Square` cannot assign to
`$!width` directly (that is a compile-time "attribute not declared" error). The
child reaches its inherited attributes through the constructor or the accessors,
not through the parent's private `$!` variables. Second, `describe` lives once, in
the role, yet works for every shape — composition delivering shared behaviour
without a shared ancestor beyond `Shape`.

Between them, `class`, `is`, `role`, and `does` cover the object model you used
Moose to reach for in Perl — now with none of the module scaffolding. With
objects, roles, and inheritance in hand, Part IX turns to the larger scale: how
to package this code into modules, expose it with `is export`, and share it —
which Chapter 24 takes up next.

{% include nav.html %}
