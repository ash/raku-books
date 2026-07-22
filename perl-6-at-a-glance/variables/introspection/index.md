---
title: Introspection
---

{% include menu.html %}

Due to the mechanism of introspection, it is easily possible to tell the type of the data living in a variable (a variable in Perl 6 is often referred as a container). To do that, call the predefined `WHAT` method on a variable. Even if it is a bare scalar, Perl 6 treats it internally as an object; thus, you may call some methods on it.

For scalars, the result depends on the real type of data residing in a variable. Here is an example (parentheses are part of the output):

```raku
my $scalar = 42;
my $hello-world = "Hello, World";

say $scalar.WHAT;      # (Int)
say $hello-world.WHAT; # (Str)
```

For those variables, whose names start with the sigils `@` and `%`, the `WHAT` method returns the strings `(Array)` and `(Hash)`.

Try with arrays:

```raku-static
my @list = 10, 20, 30;
my @squares = 0, 1, 4, 9, 16, 25;
```

`say @list.WHAT;    # (Array)`

`say @squares.WHAT; # (Array)`

Now with hashes:

```raku-static
my %hash = 'Language' => 'Perl';
my %capitals = 'France' => 'Paris';
```

```raku-static
say %hash.WHAT;     # (Hash)
say %capitals.WHAT; # (Hash)
```

The thing, which is returned after a `WHAT` call, is a so-called type object. In Perl 6, you should use the `===` operator to compare these objects.

For instance:

```raku
my $value = 42;
say "OK" if $value.WHAT === Int;
```

There’s an alternative way to check the type of an object residing in a container — the `isa` method. Call it on an object, passing the type name as an argument, and get the answer:

```raku
my $value = 42;
say "OK" if $value.isa(Int);
```

{% include nav.html %}
